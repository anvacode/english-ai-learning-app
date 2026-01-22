import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop_item.dart';
import '../services/shop_service.dart';
import '../services/theme_service.dart';
import '../logic/star_service.dart';
import '../widgets/star_display.dart';
import '../widgets/error_dialog.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_container.dart';
import '../theme/text_styles.dart';

/// Pantalla de la tienda de estrellas.
/// 
/// Muestra todos los ítems disponibles para comprar
/// y permite a los usuarios gastar sus estrellas.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _totalStars = 0;
  Set<String> _purchasedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final total = await StarService.getTotalStars();
    final purchased = await ShopService.getPurchasedItemIds();
    setState(() {
      _totalStars = total;
      _purchasedIds = purchased;
      _isLoading = false;
    });
  }

  Future<void> _purchaseItem(ShopItem item) async {
    try {
      // Mostrar diálogo de confirmación
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar compra'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Comprar "${item.name}"?'),
              const SizedBox(height: 8),
              Text(
                'Precio: ${item.price} ⭐',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tienes: $_totalStars ⭐',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Comprar'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Obtener ThemeService del contexto
      // ignore: use_build_context_synchronously
      final themeService = context.read<ThemeService>();

      // Realizar compra
      await ShopService.purchaseItem(item, themeService: themeService);

      // Recargar datos
      await _loadData();

      // Mostrar mensaje de éxito específico según el tipo de ítem
      if (mounted) {
        String message;
        if (item.type == ShopItemType.avatar) {
          message = '¡Avatar activado! Puedes verlo en tu perfil';
        } else if (item.type == ShopItemType.theme) {
          message = '¡Tema activado! Los colores han cambiado';
        } else {
          message = '¡${item.name} comprado exitosamente!';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('StateError: ', '');
        
        // Verificar si es un error de estrellas insuficientes
        if (errorMessage.contains('Insufficient stars')) {
          ErrorHelper.showInsufficientStarsError(
            context,
            required: item.price,
            available: _totalStars,
          );
        } else {
          // Otro tipo de error
          ErrorHelper.showCustomError(
            context,
            title: 'Error en la Compra',
            message: errorMessage,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ShopService.getAvailableItems();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tienda de Estrellas',
          style: context.headline2,
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: context.horizontalPadding),
            child: Center(
              child: StarDisplay(
                iconSize: context.isMobile ? 24 : 28,
                fontSize: context.isMobile ? 18 : 20,
                showBackground: true,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveContainer(
              child: Column(
                children: [
                  // Banner de estrellas disponibles
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.horizontalPadding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber[100]!,
                          Colors.orange[100]!,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tus Estrellas',
                          style: TextStyle(
                            fontSize: context.isMobile ? 16 : (context.isTablet ? 18 : 20),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_totalStars ⭐',
                          style: TextStyle(
                            fontSize: context.isMobile ? 32 : (context.isTablet ? 36 : 40),
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lista de ítems
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(context.horizontalPadding),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isPurchased = _purchasedIds.contains(item.id);
                        final canAfford = _totalStars >= item.price;

                        return _ShopItemCard(
                          item: item,
                          isPurchased: isPurchased,
                          canAfford: canAfford,
                          onPurchase: () => _purchaseItem(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Widget que representa una tarjeta de ítem de la tienda.
class _ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final bool isPurchased;
  final bool canAfford;
  final VoidCallback onPurchase;

  const _ShopItemCard({
    required this.item,
    required this.isPurchased,
    required this.canAfford,
    required this.onPurchase,
  });

  Color _getTypeColor() {
    switch (item.type) {
      case ShopItemType.avatar:
        return Colors.blue;
      case ShopItemType.theme:
        return Colors.purple;
      case ShopItemType.effect:
        return Colors.pink;
      case ShopItemType.powerup:
        return Colors.orange;
      case ShopItemType.content:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getTypeLabel() {
    switch (item.type) {
      case ShopItemType.avatar:
        return 'Avatar';
      case ShopItemType.theme:
        return 'Tema';
      case ShopItemType.effect:
        return 'Efecto';
      case ShopItemType.powerup:
        return 'Power-up';
      case ShopItemType.content:
        return 'Contenido';
      default:
        return 'Otro';
    }
  }
  
  IconData _getTypeIcon() {
    switch (item.type) {
      case ShopItemType.avatar:
        return Icons.person;
      case ShopItemType.theme:
        return Icons.palette;
      case ShopItemType.effect:
        return Icons.auto_awesome;
      case ShopItemType.powerup:
        return Icons.bolt;
      case ShopItemType.content:
        return Icons.extension;
      default:
        return Icons.shopping_bag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPurchased
            ? BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ícono del ítem - optimizado para móvil
              Container(
                width: 52,
                height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    typeColor.withAlpha(51),
                    typeColor.withAlpha(13),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: typeColor.withAlpha(76),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  item.icon,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Información del ítem
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPurchased) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Comprado',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Badge de tipo con diseño mejorado para móvil
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withAlpha(38),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: typeColor.withAlpha(76),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTypeIcon(),
                                size: 13,
                                color: typeColor,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  _getTypeLabel(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: typeColor,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${item.price} ⭐',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botón de compra
            if (!isPurchased) ...[
              const SizedBox(width: 6),
              SizedBox(
                width: 72,
                child: ElevatedButton(
                  onPressed: canAfford ? onPurchase : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Comprar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }
}
