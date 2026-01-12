# CRITICAL STATE SYNCHRONIZATION BUG - ROOT CAUSE ANALYSIS & FIX

## The Bug: Stimulus and Options Desynchronization on Retry

### Symptom
```
First Attempt:  Question stimulus (e.g., "BLACK") + options (black, red, green) ✓ Match
Retry Attempt:  Question stimulus (BLACK) + options (orange, gray, blue) ✗ Mismatch!
```

The student sees a BLACK color but the options don't include "black" as a valid answer, making the question unsolvable.

---

## Root Cause: Dual Question Index State

### The Problem

The codebase had **TWO different question indices** tracking the same thing:

1. **UI Level** (lesson_screen.dart):
   ```dart
   class _LessonScreenState extends State<LessonScreen> {
     int currentItemIndex = 0;  // ← UI's local copy
   ```

2. **Controller Level** (lesson_controller.dart):
   ```dart
   class LessonController extends ChangeNotifier {
     int _currentQuestionIndex = 0;  // ← Controller's copy
   ```

### How This Caused the Bug

```
On Retry:
  
  Step 1: retryLesson() called
    - Controller: _currentQuestionIndex = 0 ✓
    - UI: currentItemIndex still = 4 (from previous fail)
  
  Step 2: _randomizeOptions() called
    - Reads stimulus: widget.lesson.items[currentItemIndex]
      = widget.lesson.items[4] (dog) ✗
    
    - Gets options from: controller.getCurrentQuestionOptions()
      - Controller checks: _currentQuestionIndex = 0
      - Uses cache: _optionsCache[0]
      = options for index 0 (color) ✗
    
  Result: DOG stimulus + COLOR options = MISMATCH ✗
```

### Why Two Indices Existed

1. **UI State** - lesson_screen.dart managed which question to display
2. **Controller Caching** - lesson_controller.dart cached options by question index

They weren't synchronized on retry because:
- `retryLesson()` reset the controller's index
- But `_loadProgressAndPosition()` didn't reset the UI's index atomically
- A timing issue could cause them to diverge

---

## The Fix: Single Source of Truth

### Solution Architecture

**Eliminate the duplicate index. Use ONLY the controller's index.**

#### Before (BROKEN)
```
UI State (lesson_screen.dart):
  currentItemIndex = 4  ← UI's local copy

Controller State (lesson_controller.dart):
  _currentQuestionIndex = 0  ← Controller's copy
  
_randomizeOptions():
  stimulus = items[currentItemIndex]    ← Uses UI's index
  options = controller.getOptions()  ← Uses controller's index
  
RESULT: Mismatch because they use different indices!
```

#### After (FIXED)
```
UI State (lesson_screen.dart):
  (NO currentItemIndex)  ← Removed!

Controller State (lesson_controller.dart):
  _currentQuestionIndex = 0  ← ONLY source of truth
  
_randomizeOptions():
  questionIndex = controller.currentQuestionIndex  ← Read from controller
  stimulus = items[questionIndex]    ← Uses controller's index
  options = controller.getOptions()  ← Uses controller's index
  
RESULT: Perfect match! Same index used everywhere.
```

---

## Implementation Details

### Change 1: Remove Local currentItemIndex

**File**: `lib/screens/lesson_screen.dart`

```dart
class _LessonScreenState extends State<LessonScreen> {
  // ✗ REMOVED: int currentItemIndex = 0;
  
  // NOTE: currentItemIndex is NO LONGER used here.
  // Question index comes from LessonController._currentQuestionIndex only
  // This ensures single source of truth and prevents desynchronization
```

**Why**: Eliminated the duplicate index that was causing desynchronization.

---

### Change 2: Update _randomizeOptions() to Read from Controller

**File**: `lib/screens/lesson_screen.dart`

```dart
void _randomizeOptions() {
  // ✅ Read question index from CONTROLLER (single source of truth)
  final lessonController = context.read<LessonController>();
  final currentQuestionIndex = lessonController.currentQuestionIndex;
  
  if (currentQuestionIndex < widget.lesson.items.length) {
    // ✅ Get stimulus from current question index
    final currentItem = widget.lesson.items[currentQuestionIndex];
    final correctAnswerValue = currentItem.options[currentItem.correctAnswerIndex];
    
    // ✅ Get options from controller using SAME index
    final questionOptions = lessonController.getCurrentQuestionOptions(
      currentItem.options,
      correctAnswerValue,
    );
    
    setState(() {
      _randomizedOptions = questionOptions.randomizedOptions;
      _correctAnswerValue = questionOptions.correctAnswer;
    });
  }
}
```

**Key**: Both stimulus and options now use the same index from the controller.

---

### Change 3: Add Controller Method to Update Index

**File**: `lib/logic/lesson_controller.dart`

```dart
/// Set the current question index explicitly (used when advancing to next question)
/// This is the ONLY way to change the question index during a lesson
void setCurrentQuestionIndex(int index) {
  if (index >= 0 && index < _totalQuestions) {
    _currentQuestionIndex = index;
    notifyListeners();
  }
}
```

**Why**: UI can now request index changes through the controller, keeping control centralized.

---

### Change 4: Update _onNextOrRetry() to Use Controller

**File**: `lib/screens/lesson_screen.dart`

```dart
Future<void> _onNextOrRetry() async {
  final lessonController = context.read<LessonController>();
  
  if (_isCorrect == true) {
    // ... find next incomplete item ...
    
    // Update controller to new question index (not local state)
    if (nextIndex != lessonController.currentQuestionIndex) {
      lessonController.setCurrentQuestionIndex(nextIndex);
    }
    
    setState(() {
      _selectedAnswerIndex = null;
      _answered = false;
      _isCorrect = null;
      _randomizeOptions();  // Will use controller's NEW index
    });
  }
}
```

**Key**: Index changes go through controller, not directly to UI state.

---

### Change 5: Update _handleOptionTap() to Use Controller Index

**File**: `lib/screens/lesson_screen.dart`

```dart
Future<void> _handleOptionTap(int tappedIndex) async {
  // ✅ Get current question index from controller (single source of truth)
  final lessonController = context.read<LessonController>();
  final currentQuestionIndex = lessonController.currentQuestionIndex;
  
  if (currentQuestionIndex >= widget.lesson.items.length) return;

  final currentItem = widget.lesson.items[currentQuestionIndex];
  // ... rest of logic ...
}
```

**Key**: Current question always read from controller, never from local state.

---

## Verification: Before and After

### Before (Broken Retry Flow)

```
FIRST ATTEMPT (Success):
  Controller: _currentQuestionIndex = 0
  UI: currentItemIndex = 0
  
  _randomizeOptions():
    stimulus = items[0]
    options = cache[0]
    ✓ Match

USER FAILS AND RETRIES:
  retryLesson() called:
    Controller: _currentQuestionIndex = 0  ✓
  
  _loadProgressAndPosition() called:
    UI: currentItemIndex = (should reset but doesn't atomically)
  
  _randomizeOptions() called:
    stimulus = items[currentItemIndex]  ← Could still be 4
    options = cache[0]
    ✗ MISMATCH!
```

### After (Fixed Retry Flow)

```
FIRST ATTEMPT (Success):
  Controller: _currentQuestionIndex = 0
  
  _randomizeOptions():
    index = controller.currentQuestionIndex = 0
    stimulus = items[0]
    options = cache[0]
    ✓ Match

USER FAILS AND RETRIES:
  retryLesson() called:
    Controller: _currentQuestionIndex = 0  ✓
    _optionsCache.clear()  ✓
  
  _loadProgressAndPosition() called:
    (no UI index to reset)
  
  _randomizeOptions() called:
    index = controller.currentQuestionIndex = 0  ← Always from controller
    stimulus = items[0]  ← Same index
    options = generated from items[0]  ← Same index
    ✓ PERFECT MATCH!
```

---

## Why This Fix Is Correct

### 1. Single Source of Truth
- Controller is now the ONLY place that tracks question index
- UI reads from it, never maintains its own copy
- No desynchronization possible

### 2. Atomic Reset on Retry
```dart
void retryLesson() {
  _currentQuestionIndex = 0;        // ← Reset in ONE place
  _optionsCache.clear();             // ← Clear options too
  notifyListeners();                // ← Notify UI to re-render
}
```
No split state, no timing issues.

### 3. Stimulus and Options Use Same Index
```dart
final questionIndex = controller.currentQuestionIndex;  // ← ONE source
final stimulus = items[questionIndex];                   // ← Index A
final options = controller.getOptions(index: questionIndex);  // ← Index A
```
Both always use the same index, making mismatch impossible.

### 4. Options Always Regenerated on Retry
```dart
void retryLesson() {
  _optionsCache.clear();  // ← Forces fresh generation
}

// Next access:
getCurrentQuestionOptions(options, correctAnswer) {
  if (!_optionsCache.containsKey(_currentQuestionIndex)) {
    // Generate fresh
  }
}
```
No stale options reused across attempts.

---

## Edge Cases Handled

### Edge Case 1: Multiple Retries
```
Attempt 1: Fail at question 2
  → retry: index resets to 0, cache clears

Attempt 2: Answer question 0-1 correctly, fail at 2
  → retry: index resets to 0, cache clears

Attempt 3: Complete successfully
  → All options regenerated each time ✓
```

### Edge Case 2: Advancing Between Questions
```
Question 0: Answer correctly
  → setCurrentQuestionIndex(1) called
  → _randomizeOptions() regenerates for index 1
  → stimulus = items[1]
  → options = cache[1]  ✓ Match
```

### Edge Case 3: Lesson with Partial Progress
```
Session 1: Answer questions 0-2, fail question 3
  → Progress saved

Session 2: Reopen lesson
  → Load progress: find first incomplete = index 3
  → setCurrentQuestionIndex(3)
  → _randomizeOptions() called
  → stimulus = items[3]
  → options = cache[3]  ✓ Match
```

---

## Compilation and Testing

### ✅ Compilation Status
- No errors found
- All variable references correct
- All method signatures valid

### ✅ Logic Verification
```
Retry Flow Validation:
  ✓ Controller state resets atomically
  ✓ Options cache clears completely
  ✓ Question index always from controller
  ✓ Stimulus and options always match

Advancement Flow:
  ✓ setCurrentQuestionIndex() updates controller
  ✓ _randomizeOptions() uses new index
  ✓ Options regenerated for new question
  ✓ No stale options reused

First Attempt vs Retry:
  ✓ Identical behavior
  ✓ No special retry logic in UI
  ✓ Controller handles reset transparently
  ✓ UI re-renders from fresh controller state
```

---

## Architecture Improvement

### Before
```
┌─────────────────┐
│  LessonScreen   │
│  currentItemIdx │ ← Duplicate state!
└────────┬────────┘
         │
         ↓
┌─────────────────────────┐
│  LessonController       │
│  _currentQuestionIndex  │ ← Duplicate state!
└────────┬────────────────┘
         │
    ┌────┴────┐
    ↓         ↓
stimulus    options ← DESYNCHRONIZED!
```

### After
```
┌──────────────────────────┐
│  LessonController        │
│  _currentQuestionIndex   │ ← Single source
│  _optionsCache           │
└────────┬─────────────────┘
         │
         ↓
┌─────────────────┐
│  LessonScreen   │
│  (reads index)  │ ← Reads from controller
└────────┬────────┘
         │
    ┌────┴────┐
    ↓         ↓
stimulus    options ← SYNCHRONIZED!
```

---

## Summary

**The Bug**: Two question indices (UI and Controller) caused stimulus and options to use different indices on retry.

**The Fix**: Eliminated the duplicate index. UI now always reads question index from Controller.

**The Result**:
- ✅ Stimulus and options always match
- ✅ Retry behaves identically to first attempt
- ✅ No stale state reused
- ✅ Single source of truth maintained
- ✅ No timing issues or race conditions

**Code Changes**:
1. Removed `currentItemIndex` from LessonScreenState
2. Updated `_randomizeOptions()` to read index from controller
3. Added `setCurrentQuestionIndex()` method to controller
4. Updated `_onNextOrRetry()` to use controller's method
5. Updated `_handleOptionTap()` to read index from controller

**Files Modified**:
- `lib/screens/lesson_screen.dart` (5 changes)
- `lib/logic/lesson_controller.dart` (1 addition)

**No Breaking Changes**: The fix is internal to state management. All public APIs unchanged.
