import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop_item.dart';
import '../services/shop_service.dart';
import '../services/theme_service.dart';
import '../services/effects_service.dart';
import '../services/powerup_service.dart';
import '../logic/user_profile_service.dart';
import '../widgets/avatar_widget.dart';

/// Pantalla para ver y gestionar los ítems comprados.
/// 
/// Permite al usuario ver todos sus ítems comprados y activar/desactivar
/// temas, efectos y ver el estado de power-ups.
class PurchasedItemsScreen extends StatefulWidget {
  const PurchasedItemsScreen({super.key});

  @override
  State<PurchasedItemsScreen> createState() => _PurchasedItemsScreenState();
}

class _PurchasedItemsScreenState extends State<PurchasedItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ShopItem> _purchasedItems = [];
  bool _isLoading = true;
  
  // Estado de ítems activos
  String? _activeThemeId;
  Set<String> _activeEffects = {};
  int _currentAvatarId = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await ShopService.getPurchasedItems();
    final activeEffects = await EffectsService.getActiveEffects();
    final profile = await UserProfileService.loadProfile();
    
    setState(() {
      _purchasedItems = items;
      _activeEffects = activeEffects;
      _currentAvatarId = profile.avatarId;
      _isLoading = false;
    });
    
    // Cargar tema activo del provider
    if (mounted) {
      final themeService = context.read<ThemeService>();
      setState(() {
        _activeThemeId = themeService.activeThemeId;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ShopItem> _getItemsByType(ShopItemType type) {
    return _purchasedItems.where((item) => item.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ítems'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.face), text: 'Avatares'),
            Tab(icon: Icon(Icons.palette), text: 'Temas'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'Efectos'),
            Tab(icon: Icon(Icons.flash_on), text: 'Power-ups'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAvatarsTab(),
                _buildThemesTab(),
                _buildEffectsTab(),
                _buildPowerUpsTab(),
              ],
            ),
    );
  }

  Widget _buildAvatarsTab() {
    final avatars = _getItemsByType(ShopItemType.avatar);
    
    if (avatars.isEmpty) {
      return _buildEmptyState(
        icon: Icons.face,
        message: 'No tienes avatares comprados',
        hint: 'Visita la tienda para comprar avatares especiales',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatar = avatars[index];
        final avatarId = avatar.metadata?['avatarId'] as int? ?? 8;
        final isActive = _currentAvatarId == avatarId;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isActive
                ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: AvatarWidget(avatarId: avatarId, size: 50),
            title: Text(
              avatar.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(avatar.description),
            trailing: isActive
                ? Chip(
                    label: const Text('Activo'),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  )
                : ElevatedButton(
                    onPressed: () => _activateAvatar(avatarId),
                    child: const Text('Usar'),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildThemesTab() {
    final themes = _getItemsByType(ShopItemType.theme);
    
    if (themes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.palette,
        message: 'No tienes temas comprados',
        hint: 'Visita la tienda para comprar temas coloridos',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: themes.length + 1, // +1 para el tema por defecto
      itemBuilder: (context, index) {
        if (index == 0) {
          // Tema por defecto
          return _buildThemeCard(
            themeId: null,
            name: 'Tema por defecto',
            description: 'El tema clásico de la aplicación',
            icon: '💜',
            isActive: _activeThemeId == null,
          );
        }
        
        final theme = themes[index - 1];
        final themeId = theme.metadata?['themeId'] as String?;
        final isActive = _activeThemeId == themeId;

        return _buildThemeCard(
          themeId: themeId,
          name: theme.name,
          description: theme.description,
          icon: theme.icon,
          isActive: isActive,
        );
      },
    );
  }

  Widget _buildThemeCard({
    required String? themeId,
    required String name,
    required String description,
    required String icon,
    required bool isActive,
  }) {
    final themeInfo = ThemeService.getThemeInfo(themeId ?? 'default');
    final previewColors = themeInfo['previewColors'] as List<Color>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Chip(
                    label: const Text('Activo'),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  )
                else
                  ElevatedButton(
                    onPressed: () => _activateTheme(themeId),
                    child: const Text('Usar'),
                  ),
              ],
            ),
            if (previewColors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: previewColors.map((color) {
                  return Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEffectsTab() {
    final effects = _getItemsByType(ShopItemType.effect);
    
    if (effects.isEmpty) {
      return _buildEmptyState(
        icon: Icons.auto_awesome,
        message: 'No tienes efectos comprados',
        hint: 'Visita la tienda para comprar efectos visuales',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: effects.length,
      itemBuilder: (context, index) {
        final effect = effects[index];
        final effectId = effect.metadata?['effectId'] as String?;
        final isActive = effectId != null && _activeEffects.contains(effectId);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.all(12),
            secondary: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isActive ? Colors.amber[100] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(effect.icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
            title: Text(
              effect.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(effect.description),
            value: isActive,
            onChanged: (value) => _toggleEffect(effectId!, value),
          ),
        );
      },
    );
  }

  Widget _buildPowerUpsTab() {
    final powerUps = _getItemsByType(ShopItemType.powerup);
    
    if (powerUps.isEmpty) {
      return _buildEmptyState(
        icon: Icons.flash_on,
        message: 'No tienes power-ups comprados',
        hint: 'Visita la tienda para comprar power-ups',
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: PowerUpService.getActivePowerUpsInfo(),
      builder: (context, snapshot) {
        final activePowerUps = snapshot.data ?? [];
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: powerUps.length,
          itemBuilder: (context, index) {
            final powerUp = powerUps[index];
            final activeInfo = activePowerUps.firstWhere(
              (p) => p['id'] == powerUp.id,
              orElse: () => {},
            );
            final isActive = activeInfo.isNotEmpty;
            final remainingTime = activeInfo['remainingTime'] as String?;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: isActive
                    ? const BorderSide(color: Colors.orange, width: 2)
                    : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? LinearGradient(
                                colors: [Colors.orange[400]!, Colors.amber[600]!],
                              )
                            : null,
                        color: isActive ? null : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          powerUp.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            powerUp.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            powerUp.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          if (isActive && remainingTime != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '⏱️ $remainingTime restante',
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isActive)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.orange,
                        size: 28,
                      )
                    else
                      const Icon(
                        Icons.timer_off,
                        color: Colors.grey,
                        size: 28,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String hint,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activateAvatar(int avatarId) async {
    try {
      await UserProfileService.updateAvatar(avatarId);
      setState(() {
        _currentAvatarId = avatarId;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar actualizado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _activateTheme(String? themeId) async {
    try {
      final themeService = context.read<ThemeService>();
      await themeService.setActiveTheme(themeId);
      setState(() {
        _activeThemeId = themeId;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tema actualizado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleEffect(String effectId, bool active) async {
    try {
      await EffectsService.setEffectActive(effectId, active);
      setState(() {
        if (active) {
          _activeEffects.add(effectId);
        } else {
          _activeEffects.remove(effectId);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(active ? 'Efecto activado' : 'Efecto desactivado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
