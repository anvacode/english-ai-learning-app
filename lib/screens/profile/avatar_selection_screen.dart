import 'package:flutter/material.dart';
import '../../widgets/avatar_widget.dart';
import '../../services/shop_service.dart';
import '../../models/shop_item.dart';

/// Pantalla para seleccionar un avatar.
/// 
/// Muestra un grid de 8 avatares predefinidos y los avatares
/// comprados de la tienda, permitiendo al usuario seleccionar uno.
class AvatarSelectionScreen extends StatefulWidget {
  final int currentAvatarId;

  const AvatarSelectionScreen({
    super.key,
    required this.currentAvatarId,
  });

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  late int _selectedAvatarId;
  List<ShopItem> _purchasedAvatars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedAvatarId = widget.currentAvatarId;
    _loadPurchasedAvatars();
  }

  Future<void> _loadPurchasedAvatars() async {
    final purchasedItems = await ShopService.getPurchasedItems();
    final avatars = purchasedItems
        .where((item) => item.type == ShopItemType.avatar)
        .toList();
    
    setState(() {
      _purchasedAvatars = avatars;
      _isLoading = false;
    });
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selectedAvatarId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Avatar'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Elige tu avatar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sección de avatares predefinidos
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Avatares básicos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Expanded(
                    flex: 2,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return _buildAvatarTile(index, isShopAvatar: false);
                      },
                    ),
                  ),
                  
                  // Sección de avatares de tienda (si hay comprados)
                  if (_purchasedAvatars.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Avatares especiales',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Expanded(
                      flex: 1,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _purchasedAvatars.length,
                        itemBuilder: (context, index) {
                          final avatar = _purchasedAvatars[index];
                          final avatarId = avatar.metadata?['avatarId'] as int? ?? 8;
                          return _buildAvatarTile(avatarId, isShopAvatar: true, shopItem: avatar);
                        },
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatarTile(int avatarId, {required bool isShopAvatar, ShopItem? shopItem}) {
    final isSelected = _selectedAvatarId == avatarId;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatarId = avatarId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : isShopAvatar
                  ? Colors.amber[50]
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : isShopAvatar
                    ? Colors.amber[300]!
                    : Colors.grey[300]!,
            width: isSelected ? 4 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: AvatarWidget(
                avatarId: avatarId,
                size: 50,
                backgroundColor: Colors.transparent,
              ),
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            if (isShopAvatar && !isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
