# Lesson Mastery Fix - 100% Correct Requirement

## Problem
Lessons were not being marked as mastered even after perfect completion. Badges were not being awarded. The system was deriving mastery from accumulated activity results instead of evaluating the current attempt in isolation.

## Root Cause
The completion logic in `LessonScreen` was checking `progress.status == LessonProgressStatus.mastered`, which was derived from `LessonProgressService.evaluate()`. This service accumulates all `ActivityResult` records and evaluates them collectively, which:
- Could show a lesson as mastered based on previous attempts even if the current attempt failed
- Did not enforce the "100% correct in current attempt" requirement

## Solution

### 1. LessonScreen Completion Logic (FIXED)
**File**: `lib/screens/lesson_screen.dart`

Changed the mastery determination to check the **current attempt** rather than accumulated results:

```dart
// BEFORE:
if (progress.status == LessonProgressStatus.mastered) {
  // Save completion and award badge
}

// AFTER:
final isCurrentAttemptPerfect = lessonController.correctAnswers == lessonController.totalQuestions;
if (isCurrentAttemptPerfect) {
  await LessonCompletionService.saveCompletion(widget.lesson.id);
  await BadgeService.checkAndAwardBadge(widget.lesson);
}
```

**Key Points**:
- `lessonController.correctAnswers` - Number of correct answers in CURRENT attempt only
- `lessonController.totalQuestions` - Total questions in the lesson
- Only saves `LessonCompletion` (mastery marker) if current attempt is 100% correct
- Only awards badge if current attempt is 100% correct
- Previous attempts are completely ignored

### 2. MasteryEvaluator Enum Comments (UPDATED)
**File**: `lib/logic/mastery_evaluator.dart`

Updated the `LessonMasteryStatus` enum documentation to reflect the new rule:

```dart
/// La lección ha sido dominada (100% correct in a single attempt).
mastered,

/// La lección ha sido iniciada pero no fue dominada (attempted but not perfect).
inProgress,
```

### 3. Profile Screen Status Display (FIXED)
**File**: `lib/screens/profile_screen.dart`

Changed to display the actual mastery status (from `MasteryEvaluator`) instead of progress evaluation:

```dart
// BEFORE:
status: progress.status  // From accumulated results

// AFTER:
final masteryStatus = await evaluator.evaluateLesson(lesson.id);
final displayStatus = switch (masteryStatus) {
  LessonMasteryStatus.notStarted => LessonProgressStatus.notStarted,
  LessonMasteryStatus.inProgress => LessonProgressStatus.inProgress,
  LessonMasteryStatus.mastered => LessonProgressStatus.mastered,
};
status: displayStatus
```

**Key Points**:
- Profile screen now shows real mastery status, not derived progress
- Uses `MasteryEvaluator.evaluateLesson()` which checks `LessonCompletion` records
- Mastery only shows if `LessonCompletion` was created (perfect attempt)

## How It Works Now

### Perfect Completion (100% Correct)
```
User answers all questions correctly
  ↓
isLessonCompleted = true (all answers correct)
  ↓
isCurrentAttemptPerfect = (correctAnswers == totalQuestions) = true
  ↓
LessonCompletionService.saveCompletion() ✓
BadgeService.checkAndAwardBadge() ✓
Navigation/Callback (lesson marked DOMINADA)
```

### Partial/Failed Completion (< 100% Correct)
```
User answers questions, but makes an error
  ↓
isLessonCompleted = true (all questions answered, but one incorrect)
  ↓
isCurrentAttemptPerfect = (correctAnswers == totalQuestions) = false
  ↓
LessonCompletionService.saveCompletion() ✗
BadgeService.checkAndAwardBadge() ✗
Lesson remains EN PROGRESO
```

### Retry After Previous Failure
```
Lesson has EN PROGRESO status (from failed attempt)
  ↓
User retries lesson
  ↓
LessonAttempt is reset (via UniqueKey in LessonsScreen)
  ↓
User answers all questions correctly this time
  ↓
LessonCompletionService.saveCompletion() ✓
BadgeService.checkAndAwardBadge() ✓
Lesson becomes DOMINADA
```

## State Definitions

**DOMINADA (Mastered)**
- `LessonCompletion` record exists for the lesson
- Guaranteed: Student got 100% correct in at least one attempt
- Badges are unlocked

**EN PROGRESO (In Progress)**
- `LessonCompletion` does NOT exist
- At least one `ActivityResult` exists for the lesson
- Student has attempted but not achieved perfect score
- Badges are locked

**NO INICIADA (Not Started)**
- No `LessonCompletion`
- No `ActivityResult`
- Student has not attempted the lesson

## What Didn't Change

- `LessonAttempt` - Already correctly tracks current attempt state with `isComplete` property
- `LessonCompletionService` - Persistence layer unchanged
- `MasteryEvaluator` - Already checks `LessonCompletion` correctly
- Progress bar logic - Still uses `LessonProgressService.evaluate()` for UI display
- Question positioning/resume logic - Still works correctly
- Badge awarding conditions - Only changed to require perfect current attempt

## Validation

✓ Perfect attempt immediately marks lesson as DOMINADA
✓ Failed/partial attempt keeps lesson EN PROGRESO
✓ Retrying and passing upgrades to DOMINADA
✓ Badges unlock only on first perfect completion
✓ Lesson state consistent across lessons list, profile, and badge screens
✓ No regression in lesson flow or progress UI
✓ Previous attempts do NOT affect mastery evaluation
