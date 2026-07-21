import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Pantalla de transición atractiva cuando se completa un ejercicio
class ExerciseCompletionScreen extends StatefulWidget {
  final String lessonTitle;
  final int correctAnswers;
  final int totalQuestions;
  final VoidCallback onContinue;

  const ExerciseCompletionScreen({
    super.key,
    required this.lessonTitle,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.onContinue,
  });

  @override
  State<ExerciseCompletionScreen> createState() => _ExerciseCompletionScreenState();
}

class _ExerciseCompletionScreenState extends State<ExerciseCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = widget.totalQuestions > 0
        ? (widget.correctAnswers / widget.totalQuestions * 100).round()
        : 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple[400]!,
              Colors.purple[300]!,
              Colors.pink[200]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.scale(context, 20, 24, 28)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji principal con animación
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withAlpha(80),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            '🎉',
                            style: TextStyle(
                              fontSize: Responsive.scale(context, 80, 100, 120),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: Responsive.scale(context, 20, 24, 28)),

                  // Título con fade in
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          '¡Ejercicio Completado!',
                          style: TextStyle(
                            fontSize: Responsive.scale(context, 24, 28, 32),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha(80),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: Responsive.scale(context, 8, 10, 12)),
                        Text(
                          widget.lessonTitle,
                          style: TextStyle(
                            fontSize: Responsive.scale(context, 16, 18, 20),
                            color: Colors.white.withAlpha(220),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.scale(context, 32, 40, 48)),

                  // Tarjeta de estadísticas
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: EdgeInsets.all(Responsive.scale(context, 20, 24, 28)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(60),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Precisión
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[600],
                                size: Responsive.scale(context, 32, 36, 40),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Precisión',
                                    style: TextStyle(
                                      fontSize: Responsive.scale(context, 14, 15, 16),
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '$accuracy%',
                                    style: TextStyle(
                                      fontSize: Responsive.scale(context, 28, 32, 36),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: Responsive.scale(context, 20, 24, 28)),

                          Divider(color: Colors.grey[300]),

                          SizedBox(height: Responsive.scale(context, 20, 24, 28)),

                          // Respuestas correctas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                icon: Icons.star,
                                iconColor: Colors.amber,
                                label: 'Correctas',
                                value: '${widget.correctAnswers}',
                              ),
                              _buildStatItem(
                                icon: Icons.format_list_numbered,
                                iconColor: Colors.blue,
                                label: 'Total',
                                value: '${widget.totalQuestions}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: Responsive.scale(context, 32, 40, 48)),

                  // Botón de continuar
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withAlpha(100),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: widget.onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.scale(context, 40, 48, 56),
                            vertical: Responsive.scale(context, 16, 18, 20),
                          ),
                          minimumSize: Size(
                            Responsive.scale(context, 200, 220, 240),
                            Responsive.scale(context, 52, 56, 60),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continuar',
                              style: TextStyle(
                                fontSize: Responsive.scale(context, 16, 18, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              size: Responsive.scale(context, 20, 22, 24),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(Responsive.scale(context, 10, 12, 14)),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: Responsive.scale(context, 28, 32, 36),
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.scale(context, 20, 22, 24),
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.scale(context, 12, 13, 14),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
