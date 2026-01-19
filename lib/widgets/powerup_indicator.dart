import 'package:flutter/material.dart';
import '../services/powerup_service.dart';

/// Widget que muestra un indicador de power-ups activos.
/// 
/// Muestra un badge con el ícono del power-up y el tiempo restante.
class PowerUpIndicator extends StatefulWidget {
  final double iconSize;
  final bool showLabel;

  const PowerUpIndicator({
    super.key,
    this.iconSize = 24,
    this.showLabel = true,
  });

  @override
  State<PowerUpIndicator> createState() => _PowerUpIndicatorState();
}

class _PowerUpIndicatorState extends State<PowerUpIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  List<Map<String, dynamic>> _activePowerUps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _loadActivePowerUps();
  }

  Future<void> _loadActivePowerUps() async {
    final powerUps = await PowerUpService.getActivePowerUpsInfo();
    if (mounted) {
      setState(() {
        _activePowerUps = powerUps;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _activePowerUps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _activePowerUps.map((powerUp) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildPowerUpBadge(powerUp),
        );
      }).toList(),
    );
  }

  Widget _buildPowerUpBadge(Map<String, dynamic> powerUp) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange[400]!,
                  Colors.amber[600]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  powerUp['icon'] ?? '⚡',
                  style: TextStyle(fontSize: widget.iconSize),
                ),
                if (widget.showLabel && powerUp['remainingTime'] != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    powerUp['remainingTime'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget compacto que solo muestra el ícono del power-up activo.
class PowerUpIcon extends StatefulWidget {
  final double size;

  const PowerUpIcon({
    super.key,
    this.size = 20,
  });

  @override
  State<PowerUpIcon> createState() => _PowerUpIconState();
}

class _PowerUpIconState extends State<PowerUpIcon> {
  bool _hasActivePowerUp = false;

  @override
  void initState() {
    super.initState();
    _checkPowerUp();
  }

  Future<void> _checkPowerUp() async {
    final isActive = await PowerUpService.isDoubleStarsActive();
    if (mounted) {
      setState(() {
        _hasActivePowerUp = isActive;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasActivePowerUp) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.5),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        '⚡',
        style: TextStyle(fontSize: widget.size),
      ),
    );
  }
}
