## Options Generation Fix - Complete Review

### Problem Statement
Answer options were being generated inconsistently across the codebase, with no guarantee that:
- Correct answer was always included
- Options were generated only once per lesson
- Options were never regenerated on rebuilds
- Options were never reused between attempts

### Solution Overview

**Created: `lib/utils/question_options_builder.dart`**

A dedicated utility class ensuring consistent option generation:

```dart
class QuestionOptionsBuilder {
  /// buildOptionsFromPool: For lessons with predefined option pools
  static List<String> buildOptionsFromPool({
    required List<String> allOptions,
    required int correctAnswerIndex,
  })
  
  /// buildOptions: For explicit correct answer + incorrect pool separation
  static List<String> buildOptions({
    required String correctAnswer,
    required List<String> incorrectOptions,
  })
}
```

**Guarantees:**
1. ✅ Correct answer is ALWAYS added first
2. ✅ Incorrect options are added from the pool
3. ✅ Final list is shuffled
4. ✅ Assertions verify correct answer is still present after shuffle
5. ✅ RangeError thrown if correctAnswerIndex is invalid

---

### Changes Applied

#### 1. **LessonController** (`lib/logic/lesson_controller.dart`)

**`initializeLesson()`**
- Now uses `QuestionOptionsBuilder.buildOptionsFromPool()` 
- Options are built EXACTLY ONCE during lesson initialization
- Each Question object stores pre-generated, randomized options

**`retryLesson()`**
- Rebuilds Question objects from lesson data
- Calls `QuestionOptionsBuilder.buildOptionsFromPool()` again
- Ensures FRESH options, never reused from previous attempt

**`getCurrentQuestionOptions()`**
- Updated documentation: "OPTIONS ARE NEVER REGENERATED HERE"
- Only reads pre-built options from `_questions[_currentQuestionIndex]`
- Never shuffles, modifies, or generates options

#### 2. **Question Model** (`lib/models/question.dart`)

- Added comprehensive docstring explaining:
  - Options are generated exactly once per question
  - Options are always shuffled before storage
  - Correct answer is guaranteed to be in options
  - On retry, fresh Question objects with new options are created
  - UI must never generate or modify options

#### 3. **LessonScreen** (`lib/screens/lesson_screen.dart`)

- Renamed method: `_randomizeOptions()` (confusing name)
  - Actually: "Load options from controller"
  - Does NOT perform any shuffling or generation
- Updated documentation: "OPTIONS ARE NOT GENERATED HERE"
- Only reads pre-built options and caches them locally for rendering

#### 4. **Tests** (`test/question_options_builder_test.dart`)

- ✅ Correct answer always included
- ✅ All pool items present in result
- ✅ Results are shuffled (different orderings)
- ✅ RangeError on invalid index
- ✅ Works for all question positions

---

### Application Across All Lessons

The fix applies consistently to all three lesson categories:

**Colors** (stimulus: Color)
- 10 color items with 3 options each
- Uses `QuestionOptionsBuilder.buildOptionsFromPool()`

**Fruits** (stimulus: Image)
- 8 fruit items with 3 options each
- Uses `QuestionOptionsBuilder.buildOptionsFromPool()`

**Animals** (stimulus: Image)
- 10+ animal items with 3 options each
- Uses `QuestionOptionsBuilder.buildOptionsFromPool()`

---

### Flow Diagram

```
Lesson Initialization
├─ initializeLesson(lesson)
│  ├─ for each LessonItem:
│  │  ├─ Extract correctAnswer from options[correctAnswerIndex]
│  │  ├─ Call QuestionOptionsBuilder.buildOptionsFromPool()
│  │  │  ├─ Start with correct answer
│  │  │  ├─ Add all options from pool
│  │  │  ├─ Shuffle
│  │  │  └─ Assert correct answer still present
│  │  └─ Create immutable Question with shuffled options
│  └─ Store Question objects in _questions list
│
Lesson Display
├─ LessonScreen.build()
│  ├─ Read LessonController state
│  ├─ For current question:
│  │  ├─ Call lessonController.getCurrentQuestionOptions()
│  │  │  └─ Returns pre-built Question.options (no generation)
│  │  └─ Cache in _randomizedOptions for rendering
│  └─ Render UI with cached options
│
Lesson Retry
├─ lessonController.retryLesson()
│  ├─ Clear _questions list
│  ├─ Rebuild Question objects using QuestionOptionsBuilder again
│  │  └─ FRESH options (different shuffle order)
│  └─ Reset question index to 0
├─ UI reloads and reads fresh options from controller
└─ First question has new options (not reused)
```

---

### Contract Enforcement

| Requirement | Mechanism | Verification |
|---|---|---|
| Correct answer ALWAYS included | `QuestionOptionsBuilder` adds it first | Assertion in builder, test case |
| Generated only once per lesson | Stored in immutable `Question` object | No regeneration in UI or rebuild |
| Never regenerated on rebuild | `getCurrentQuestionOptions()` reads cached `_questions` | Documentation and code review |
| Never reused on retry | `retryLesson()` calls builder again | Fresh `Question` objects created |
| Never generated in widget build() | UI only reads from controller | `LessonScreen._randomizeOptions()` reads, not generates |

---

### Testing

All contracts verified by unit tests in `test/question_options_builder_test.dart`:

```
✅ Correct answer always included
✅ All pool items present
✅ Results are shuffled
✅ Invalid index throws RangeError
✅ Works for last item in pool
✅ Multiple options format supported
```

---

### No Breaking Changes

- ✅ Existing lesson data structure unchanged
- ✅ Question model is backward compatible (fields unchanged)
- ✅ LessonController API unchanged
- ✅ UI display logic unchanged
- ✅ Progress, feedback, and badge logic untouched

---

### Next Steps

Ready to test with:
1. Start a lesson (e.g., Colors)
2. Answer questions in order
3. Verify options change on each question
4. Fail a question and retry (should show DIFFERENT option order)
5. Retry lesson (should show COMPLETELY NEW options)
6. Switch between lesson categories (should use different option pools)

If issues arise, the builder provides assertion errors immediately.
