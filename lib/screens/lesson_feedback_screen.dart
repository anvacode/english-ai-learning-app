import 'package:flutter/material.dart';
import '../models/lesson_feedback_data.dart';
import '../utils/safe_math.dart';

/// Screen that displays pedagogical feedback after a lesson is completed.
/// Shows the student's performance metrics and encouragement based on accuracy.
class LessonFeedbackScreen extends StatefulWidget {
  final String lessonId;
  final bool isMastered; // Whether the lesson was mastered (>= 80% accuracy)
  final VoidCallback? onRetry; // Optional retry callback for incomplete mastery

  const LessonFeedbackScreen({
    super.key,
    required this.lessonId,
    this.isMastered = true, // Default to true for backward compatibility
    this.onRetry,
  });

  @override
  State<LessonFeedbackScreen> createState() => _LessonFeedbackScreenState();
}

class _LessonFeedbackScreenState extends State<LessonFeedbackScreen> {
  late Future<LessonFeedbackData> _feedbackFuture;
  bool _canNavigate = false; // Prevent navigation for first 5 seconds

  @override
  void initState() {
    super.initState();
    _feedbackFuture = LessonFeedbackData.fromLesson(widget.lessonId);
    
    // Enforce minimum display duration of 5 seconds
    // After 5 seconds, allow navigation
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _canNavigate = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lección'),
        elevation: 0,
      ),
      body: FutureBuilder<LessonFeedbackData>(
        future: _feedbackFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final feedback = snapshot.data!;
          return _buildFeedbackContent(context, feedback);
        },
      ),
    );
  }

  /// Build the main feedback content
  Widget _buildFeedbackContent(
    BuildContext context,
    LessonFeedbackData feedback,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'Retroalimentación de la lección',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Mastery status card
            _buildMasteryCard(feedback),
            const SizedBox(height: 32),

            // Performance summary
            _buildPerformanceSummary(feedback),
            const SizedBox(height: 32),

            // Pedagogical message
            _buildPedagogicalMessage(feedback),
            const SizedBox(height: 48),

            // Return button (disabled for first 5 seconds)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: _canNavigate
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      onPressed: () {
                        // If retry callback provided (incomplete mastery), call it
                        if (widget.onRetry != null) {
                          widget.onRetry!();
                        } else {
                          // Otherwise, return to lessons list
                          Navigator.pop(context, true);
                        }
                      },
                      child: Text(
                        widget.isMastered ? 'Volver a lecciones' : 'Intentar de nuevo',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      onPressed: null, // Disabled
                      child: const Text(
                        'Por favor, lee la retroalimentación...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the mastery status card
  Widget _buildMasteryCard(LessonFeedbackData feedback) {
    final color = _getMasteryColor(feedback.masteryStatus);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Icon and label
          Text(
            feedback.getMasteryIcon(),
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 12),
          Text(
            feedback.getMasteryLabel(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the performance summary section
  Widget _buildPerformanceSummary(LessonFeedbackData feedback) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Correct answers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Respuestas correctas:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '${feedback.correctAttempts} de ${feedback.totalAttempts}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Accuracy percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Precisión:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '${feedback.accuracyPercentage}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),

          // Progress bar
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentToNormalized(feedback.accuracyPercentage),
              backgroundColor: Colors.grey[300],
              color: Colors.deepPurple,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the pedagogical message section
  Widget _buildPedagogicalMessage(LessonFeedbackData feedback) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          left: BorderSide(
            color: Colors.blue,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        feedback.getPedagogicalMessage(),
        style: const TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Get color based on mastery level
  Color _getMasteryColor(MasteryLevel status) {
    switch (status) {
      case MasteryLevel.mastered:
        return Colors.green;
      case MasteryLevel.inProgress:
        return Colors.orange;
      case MasteryLevel.needsReinforcement:
        return Colors.red;
    }
  }
}
