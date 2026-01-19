import 'package:flutter/material.dart';

/// Widget que muestra una imagen de lección con manejo de errores.
/// 
/// Incluye:
/// - Indicador de carga mientras se carga la imagen
/// - Animación fade-in cuando se carga
/// - Imagen de respaldo si falla la carga
/// - Tamaño configurable
class LessonImage extends StatefulWidget {
  final String? imagePath;
  final Color? fallbackColor;
  final double? width;
  final double? height;
  final BoxFit fit;

  const LessonImage({
    super.key,
    this.imagePath,
    this.fallbackColor,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<LessonImage> createState() => _LessonImageState();
}

class _LessonImageState extends State<LessonImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay path de imagen, mostrar placeholder de color
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      return _buildFallback();
    }

    return Image.asset(
      widget.imagePath!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          // Image loaded, start fade-in animation
          _fadeController.forward();
          return FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          );
        }
        // Still loading, show loading indicator
        return _buildLoadingIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        // Image failed to load, show fallback
        return _buildFallback();
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.fallbackColor ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.fallbackColor != null 
              ? _getBorderColor(widget.fallbackColor!)
              : Colors.grey[400]!,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.fallbackColor ?? Colors.grey).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Si hay un color fallback, mostrar solo el color (para lecciones de colores)
      // Si no, mostrar el ícono de imagen no encontrada
      child: widget.fallbackColor != null
          ? Center(
              child: Text(
                _getColorEmoji(widget.fallbackColor!),
                style: const TextStyle(fontSize: 60),
              ),
            )
          : Icon(
              Icons.image_not_supported,
              size: (widget.width != null && widget.height != null)
                  ? (widget.width! < widget.height! ? widget.width! * 0.4 : widget.height! * 0.4)
                  : 40,
              color: Colors.grey[600],
            ),
    );
  }

  /// Obtiene un color de borde que contraste con el color de fondo
  Color _getBorderColor(Color bgColor) {
    // Si el color es muy claro, usar borde oscuro
    final brightness = bgColor.computeLuminance();
    if (brightness > 0.5) {
      return bgColor.withOpacity(0.6);
    }
    // Si es oscuro, usar borde más claro
    return Colors.white.withOpacity(0.3);
  }

  /// Obtiene un emoji relacionado con el color para hacerlo más visual
  String _getColorEmoji(Color color) {
    // Comparar con colores comunes
    if (color == Colors.red || color.value == Colors.red.value) return '🔴';
    if (color == Colors.blue || color.value == Colors.blue.value) return '🔵';
    if (color == Colors.green || color.value == Colors.green.value) return '🟢';
    if (color == Colors.yellow || color.value == Colors.yellow.value) return '🟡';
    if (color == Colors.orange || color.value == Colors.orange.value) return '🟠';
    if (color == Colors.purple || color.value == Colors.purple.value) return '🟣';
    if (color == Colors.brown || color.value == Colors.brown.value) return '🟤';
    if (color == Colors.black || color.value == Colors.black.value) return '⚫';
    if (color == Colors.white || color.value == Colors.white.value) return '⚪';
    if (color == Colors.pink || color.value == Colors.pink.value) return '🩷';
    
    // Color por defecto
    return '🎨';
  }
}
