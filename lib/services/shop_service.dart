import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/shop_item.dart';
import '../logic/star_service.dart';
import '../logic/user_profile_service.dart';
import 'theme_service.dart';

/// Servicio para manejar la tienda de estrellas.
/// 
/// Gestiona los ítems disponibles, las compras realizadas
/// y la aplicación de ítems comprados.
class ShopService {
  static const String _purchasedItemsKey = 'purchased_shop_items';

  /// Obtiene todos los ítems disponibles en la tienda.
  static List<ShopItem> getAvailableItems() {
    return [
      // Avatares
      const ShopItem(
        id: 'avatar_star',
        name: 'Avatar Estrella',
        description: 'Conviértete en una estrella brillante',
        price: 50,
        type: ShopItemType.avatar,
        icon: '⭐',
        metadata: {'avatarId': 8},
      ),
      const ShopItem(
        id: 'avatar_champion',
        name: 'Avatar Campeón',
        description: 'Muestra que eres un campeón',
        price: 80,
        type: ShopItemType.avatar,
        icon: '🏆',
        metadata: {'avatarId': 9},
      ),
      const ShopItem(
        id: 'avatar_superhero',
        name: 'Avatar Superhéroe',
        description: '¡Poderes de aprendizaje!',
        price: 100,
        type: ShopItemType.avatar,
        icon: '🦸',
        metadata: {'avatarId': 10},
      ),
      
      // Temas
      const ShopItem(
        id: 'theme_rainbow',
        name: 'Tema Arcoíris',
        description: 'Colores brillantes y alegres',
        price: 40,
        type: ShopItemType.theme,
        icon: '🌈',
        metadata: {'themeId': 'rainbow'},
      ),
      const ShopItem(
        id: 'theme_space',
        name: 'Tema Espacial',
        description: 'Viaja por el espacio mientras aprendes',
        price: 50,
        type: ShopItemType.theme,
        icon: '🚀',
        metadata: {'themeId': 'space'},
      ),
      const ShopItem(
        id: 'theme_nature',
        name: 'Tema Naturaleza',
        description: 'Colores verdes y naturales',
        price: 45,
        type: ShopItemType.theme,
        icon: '🌳',
        metadata: {'themeId': 'nature'},
      ),
      
      // Efectos
      const ShopItem(
        id: 'effect_confetti',
        name: 'Efecto Confeti',
        description: 'Confeti dorado al completar lecciones',
        price: 60,
        type: ShopItemType.effect,
        icon: '✨',
        metadata: {'effectId': 'confetti'},
      ),
      const ShopItem(
        id: 'effect_sparkles',
        name: 'Efecto Estrellitas',
        description: 'Estrellitas mágicas en cada respuesta',
        price: 55,
        type: ShopItemType.effect,
        icon: '💫',
        metadata: {'effectId': 'sparkles'},
      ),
      
      // Power-ups
      const ShopItem(
        id: 'powerup_double_stars',
        name: 'Doble Estrellas',
        description: 'Gana el doble de estrellas por 3 días',
        price: 150,
        type: ShopItemType.powerup,
        icon: '⚡',
        metadata: {'duration': 3, 'multiplier': 2.0},
      ),
    ];
  }

  /// Obtiene los IDs de los ítems comprados por el usuario.
  static Future<Set<String>> getPurchasedItemIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_purchasedItemsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.cast<String>().toSet();
    } catch (e) {
      // Error decoding purchased items: $e
      return {};
    }
  }

  /// Verifica si un ítem ha sido comprado.
  static Future<bool> isItemPurchased(String itemId) async {
    final purchasedIds = await getPurchasedItemIds();
    return purchasedIds.contains(itemId);
  }

  /// Compra un ítem usando estrellas.
  /// 
  /// [item] es el ítem a comprar.
  /// [themeService] es opcional, permite activar temas inmediatamente.
  /// 
  /// Lanza una excepción si el usuario no tiene suficientes estrellas
  /// o si el ítem ya fue comprado.
  static Future<void> purchaseItem(
    ShopItem item, {
    ThemeService? themeService,
  }) async {
    // Verificar si ya está comprado
    if (await isItemPurchased(item.id)) {
      throw StateError('Este ítem ya ha sido comprado');
    }

    // Verificar estrellas suficientes
    final totalStars = await StarService.getTotalStars();
    if (totalStars < item.price) {
      throw StateError(
        'No tienes suficientes estrellas. Necesitas ${item.price}, tienes $totalStars',
      );
    }

    // 1. Guardar compra PRIMERO (si la app crashea aquí, el usuario no pierde estrellas)
    final purchasedIds = await getPurchasedItemIds();
    purchasedIds.add(item.id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _purchasedItemsKey,
      jsonEncode(purchasedIds.toList()),
    );

    // 2. Gastar estrellas con rollback si falla
    try {
      await StarService.spendStars(item.price, item.name);
    } catch (e) {
      // Rollback: revertir la compra
      purchasedIds.remove(item.id);
      await prefs.setString(
        _purchasedItemsKey,
        jsonEncode(purchasedIds.toList()),
      );
      rethrow;
    }

    // 3. Activar automáticamente según el tipo de ítem
    await _activateItemOnPurchase(item, themeService: themeService);
  }
  
  /// Activa un ítem automáticamente después de comprarlo.
  /// 
  /// [themeService] es opcional, permite activar temas inmediatamente.
  static Future<void> _activateItemOnPurchase(
    ShopItem item, {
    ThemeService? themeService,
  }) async {
    switch (item.type) {
      case ShopItemType.avatar:
        // Activar avatar automáticamente
        final avatarId = item.metadata?['avatarId'] as int?;
        if (avatarId != null) {
          await UserProfileService.updateAvatar(avatarId);
        }
        break;
        
      case ShopItemType.theme:
        // Activar tema automáticamente
        final themeId = item.metadata?['themeId'] as String?;
        if (themeId != null) {
          if (themeService != null) {
            // Aplicar tema inmediatamente usando Provider
            await themeService.setActiveTheme(themeId);
          } else {
            // Fallback: guardar en SharedPreferences para próximo inicio
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('active_theme_id', themeId);
          }
        }
        break;
        
      case ShopItemType.effect:
        // Activar efecto automáticamente
        final effectId = item.metadata?['effectId'] as String?;
        if (effectId != null) {
          final prefs = await SharedPreferences.getInstance();
          final activeEffects = prefs.getStringList('active_effects')?.toSet() ?? {};
          activeEffects.add(effectId);
          await prefs.setStringList('active_effects', activeEffects.toList());
        }
        break;
        
      case ShopItemType.powerup:
        // Activar power-up con su duración
        final duration = item.metadata?['duration'] as int? ?? 3;
        final expirationDate = DateTime.now().add(Duration(days: duration));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'powerup_expiration_${item.id}',
          expirationDate.toIso8601String(),
        );
        final activePowerUps = prefs.getStringList('active_powerups')?.toSet() ?? {};
        activePowerUps.add(item.id);
        await prefs.setStringList('active_powerups', activePowerUps.toList());
        break;
        
      default:
        break;
    }
  }

  /// Obtiene todos los ítems comprados.
  static Future<List<ShopItem>> getPurchasedItems() async {
    final purchasedIds = await getPurchasedItemIds();
    final allItems = getAvailableItems();
    return allItems.where((item) => purchasedIds.contains(item.id)).toList();
  }

  /// Obtiene el avatar comprado activo (si existe).
  static Future<int?> getActiveAvatarId() async {
    final purchasedItems = await getPurchasedItems();
    final avatarItems = purchasedItems.where(
      (item) => item.type == ShopItemType.avatar && item.metadata != null,
    );

    // Retornar el primer avatar comprado (puedes mejorar esto para permitir selección)
    if (avatarItems.isNotEmpty) {
      return avatarItems.first.metadata!['avatarId'] as int?;
    }
    return null;
  }

  /// Limpia todas las compras (solo para testing).
  static Future<void> clearAllPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_purchasedItemsKey);
  }
}
