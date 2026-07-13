import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/star_service.dart';
import '../models/shop_item.dart';
import '../services/shop_service.dart';
import '../services/theme_service.dart';
import '../theme/text_styles.dart';
import '../utils/responsive.dart';
import '../widgets/error_dialog.dart';
import '../widgets/responsive_container.dart';
import '../widgets/star_display.dart';

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
                iconSize: Responsive.scale(context, 24, 28, 32),
                fontSize: Responsive.scale(context, 18, 20, 22),
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
                            fontSize: Responsive.scale(context, 16, 18, 20),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_totalStars ⭐',
                          style: TextStyle(
                            fontSize: Responsive.scale(context, 32, 36, 40),
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
    final iconSize = Responsive.scale(context, 22, 26, 30);
    final iconContainerSize = Responsive.scale(context, 48, 52, 56);

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.scale(context, 10, 12, 14)),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.borderRadius(context)),
        side: isPurchased
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.scale(context, 10, 12, 14),
          vertical: Responsive.scale(context, 8, 10, 12),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      typeColor.withAlpha(51),
                      typeColor.withAlpha(13),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(Responsive.scale(context, 10, 12, 14)),
                  border: Border.all(
                    color: typeColor.withAlpha(76),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    item.icon,
                    style: TextStyle(fontSize: iconSize),
                  ),
                ),
              ),
              SizedBox(width: Responsive.scale(context, 8, 10, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: context.cardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPurchased) ...[
                          SizedBox(width: Responsive.scale(context, 3, 4, 5)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.scale(context, 5, 6, 7),
                              vertical: Responsive.scale(context, 2, 3, 4),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(Responsive.scale(context, 8, 10, 12)),
                            ),
                            child: Text(
                              'Comprado',
                              style: context.label.copyWith(color: Colors.green),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: Responsive.scale(context, 2, 3, 4)),
                    Text(
                      item.description,
                      style: context.bodyText2.copyWith(height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.scale(context, 4, 6, 8)),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.scale(context, 6, 8, 10),
                              vertical: Responsive.scale(context, 3, 4, 5),
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withAlpha(38),
                              borderRadius: BorderRadius.circular(Responsive.scale(context, 6, 8, 10)),
                              border: Border.all(
                                color: typeColor.withAlpha(76),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getTypeIcon(),
                                  size: Responsive.scale(context, 11, 13, 15),
                                  color: typeColor,
                                ),
                                SizedBox(width: Responsive.scale(context, 2, 3, 4)),
                                Flexible(
                                  child: Text(
                                    _getTypeLabel(),
                                    style: TextStyle(
                                      fontSize: Responsive.scale(context, 9, 10, 11),
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
                        SizedBox(width: Responsive.scale(context, 5, 6, 8)),
                        Text(
                          '${item.price} ⭐',
                          style: context.price,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isPurchased) ...[
                SizedBox(width: Responsive.scale(context, 5, 6, 8)),
                SizedBox(
                  width: Responsive.scale(context, 64, 72, 80),
                  child: ElevatedButton(
                    onPressed: canAfford ? onPurchase : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.scale(context, 5, 6, 8),
                        vertical: Responsive.scale(context, 8, 10, 12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.scale(context, 8, 10, 12)),
                      ),
                    ),
                    child: Text(
                      'Comprar',
                      style: context.buttonSmall,
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
