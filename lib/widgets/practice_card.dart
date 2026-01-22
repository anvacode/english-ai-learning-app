import 'package:flutter/material.dart';
import '../models/practice_activity.dart';

/// Widget de tarjeta para mostrar una actividad de práctica
class PracticeCard extends StatelessWidget {
  final PracticeActivity activity;
  final PracticeProgress? progress;
  final VoidCallback onTap;
  
  const PracticeCard({
    super.key,
    required this.activity,
    this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = activity.isUnlocked;
    final hasProgress = progress != null && progress!.completedExercises > 0;
    
    return Card(
      elevation: isUnlocked ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isUnlocked ? Colors.white : Colors.grey[300],
      child: InkWell(
        onTap: isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Icono y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icono de la actividad
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? Color(activity.color).withAlpha(26)
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      activity.iconEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  
                  // Badge de desbloqueo/completitud
                  if (!isUnlocked)
                    const Icon(Icons.lock, color: Colors.grey, size: 24)
                  else if (hasProgress && progress!.isCompleted)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Título
              Text(
                activity.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.black87 : Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 6),
              
              // Descripción
              Text(
                activity.description,
                style: TextStyle(
                  fontSize: 11,
                  color: isUnlocked ? Colors.grey[600] : Colors.grey[500],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Progreso y estadísticas
              if (isUnlocked) ...[
                // Barra de progreso
                if (hasProgress) ...[
                  LinearProgressIndicator(
                    value: progress!.completionPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(activity.color),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Estadísticas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Progreso
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasProgress
                              ? '${progress!.completedExercises}/${progress!.totalExercises}'
                              : '0/${activity.totalExercises}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    // Estrellas ganadas
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasProgress ? '${progress!.starsEarned}' : '0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                // Mensaje de desbloqueo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          activity.requiredLessons.isNotEmpty
                              ? 'Completa lección'
                              : 'Bloqueado',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }
}
