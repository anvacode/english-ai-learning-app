import 'package:flutter/material.dart';
import '../models/shop_item.dart';
import '../services/shop_service.dart';
import '../logic/star_service.dart';
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

      // Realizar compra
      await ShopService.purchaseItem(item);

      // Recargar datos
      await _loadData();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('¡${item.name} comprado exitosamente!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(e.toString().replaceAll('Exception: ', '')),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ShopService.getAvailableItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda de Estrellas'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: StarDisplay(
                iconSize: 24,
                fontSize: 18,
                showBackground: true,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Banner de estrellas disponibles
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                      const Text(
                        'Tus Estrellas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_totalStars ⭐',
                        style: TextStyle(
                          fontSize: 32,
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
                    padding: const EdgeInsets.all(16),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícono del ítem
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item.icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),

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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isPurchased)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Comprado',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getTypeLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${item.price} ⭐',
                        style: TextStyle(
                          fontSize: 18,
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
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: canAfford ? onPurchase : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Comprar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
