import 'package:flutter/material.dart';
import '../services/audio_service.dart';

/// Widget reutilizable para reproducir pronunciación de palabras.
/// 
/// Muestra un ícono de altavoz que, al presionarse, pronuncia el texto
/// especificado usando text-to-speech.
class SpeakerButton extends StatefulWidget {
  /// El texto a pronunciar cuando se presiona el botón.
  final String text;
  
  /// Tamaño del ícono. Por defecto: 24.0
  final double iconSize;
  
  /// Color del ícono. Por defecto: Colors.deepPurple
  final Color? iconColor;
  
  /// Tamaño del botón. Por defecto: 40.0
  final double buttonSize;

  const SpeakerButton({
    super.key,
    required this.text,
    this.iconSize = 24.0,
    this.iconColor,
    this.buttonSize = 40.0,
  });

  @override
  State<SpeakerButton> createState() => _SpeakerButtonState();
}

class _SpeakerButtonState extends State<SpeakerButton>
    with SingleTickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  bool _isSpeaking = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Inicializar el servicio de audio si no está inicializado
    _audioService.initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isSpeaking) {
      await _audioService.stop();
      setState(() {
        _isSpeaking = false;
      });
    } else {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      setState(() {
        _isSpeaking = true;
      });
      
      await _audioService.speak(widget.text);
      
      // Esperar un momento para que termine la pronunciación
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? Theme.of(context).colorScheme.primary;
    
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.buttonSize,
          height: widget.buttonSize,
          decoration: BoxDecoration(
            color: _isSpeaking 
                ? iconColor.withAlpha(51)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
            size: widget.iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
