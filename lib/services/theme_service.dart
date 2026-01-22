import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shop_service.dart';
import '../models/shop_item.dart';
import '../theme/app_colors.dart';

/// Servicio para gestionar los temas de la aplicación.
/// 
/// Maneja los temas comprados, el tema activo y proporciona
/// ColorSchemes para cada tema disponible.
class ThemeService extends ChangeNotifier {
  static const String _activeThemeKey = 'active_theme_id';
  
  String? _activeThemeId;
  bool _isInitialized = false;
  
  /// Tema activo actual (null = tema por defecto)
  String? get activeThemeId => _activeThemeId;
  
  /// Indica si el servicio está inicializado
  bool get isInitialized => _isInitialized;
  
  /// Inicializa el servicio cargando el tema activo
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    _activeThemeId = prefs.getString(_activeThemeKey);
    _isInitialized = true;
    notifyListeners();
  }
  
  /// Obtiene los temas comprados por el usuario
  Future<List<ShopItem>> getPurchasedThemes() async {
    final purchasedItems = await ShopService.getPurchasedItems();
    return purchasedItems.where((item) => item.type == ShopItemType.theme).toList();
  }
  
  /// Verifica si un tema está comprado
  Future<bool> isThemePurchased(String themeId) async {
    final purchasedThemes = await getPurchasedThemes();
    return purchasedThemes.any((item) => item.metadata?['themeId'] == themeId);
  }
  
  /// Establece el tema activo
  Future<void> setActiveTheme(String? themeId) async {
    // Si se proporciona un themeId, verificar que esté comprado
    if (themeId != null) {
      final isPurchased = await isThemePurchased(themeId);
      if (!isPurchased) {
        throw StateError('El tema "$themeId" no ha sido comprado');
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    if (themeId == null) {
      await prefs.remove(_activeThemeKey);
    } else {
      await prefs.setString(_activeThemeKey, themeId);
    }
    
    _activeThemeId = themeId;
    notifyListeners();
  }
  
  /// Obtiene el ColorScheme para un tema específico
  static ColorScheme getColorScheme(String? themeId) {
    switch (themeId) {
      case 'rainbow':
        return _rainbowColorScheme;
      case 'space':
        return _spaceColorScheme;
      case 'nature':
        return _natureColorScheme;
      default:
        return _defaultColorScheme;
    }
  }
  
  /// Obtiene el ThemeData completo para un tema específico
  static ThemeData getThemeData(String? themeId) {
    final colorScheme = getColorScheme(themeId);
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 2,
      ),
    );
  }
  
  /// ColorScheme por defecto - Moderna paleta azul profesional
  static final ColorScheme _defaultColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.error,
    tertiary: AppColors.accent,
    onTertiary: AppColors.textPrimary,
    tertiaryContainer: AppColors.warningLight,
    onTertiaryContainer: AppColors.textSecondary,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorLight,
    onErrorContainer: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.primaryDark,
    onInverseSurface: Colors.white,
    inversePrimary: AppColors.primaryLight,
  );
  
  /// ColorScheme Arcoíris - colores brillantes y alegres
  static final ColorScheme _rainbowColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFFFF6B6B), // Rojo coral
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFFFE5E5),
    onPrimaryContainer: const Color(0xFF8B0000),
    secondary: const Color(0xFF4ECDC4), // Turquesa
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFE0F7F5),
    onSecondaryContainer: const Color(0xFF006B63),
    tertiary: const Color(0xFFFFE66D), // Amarillo
    onTertiary: Colors.black,
    tertiaryContainer: const Color(0xFFFFF9E0),
    onTertiaryContainer: const Color(0xFF5C5000),
    error: const Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: Colors.white,
    onSurface: const Color(0xFF1A1A1A),
    surfaceContainerHighest: const Color(0xFFF5F5F5),
    onSurfaceVariant: const Color(0xFF49454F),
    outline: const Color(0xFF79747E),
    outlineVariant: const Color(0xFFCAC4D0),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: const Color(0xFF313033),
    onInverseSurface: const Color(0xFFF4EFF4),
    inversePrimary: const Color(0xFFFFB4AB),
  );
  
  /// ColorScheme Espacial - azul oscuro/púrpura con acentos
  static final ColorScheme _spaceColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF7B68EE), // Púrpura medio
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFF3D2E7C),
    onPrimaryContainer: const Color(0xFFE8DDFF),
    secondary: const Color(0xFF00CED1), // Cyan oscuro
    onSecondary: Colors.black,
    secondaryContainer: const Color(0xFF004D4F),
    onSecondaryContainer: const Color(0xFFB0F0F2),
    tertiary: const Color(0xFFFFD700), // Dorado
    onTertiary: Colors.black,
    tertiaryContainer: const Color(0xFF5C4D00),
    onTertiaryContainer: const Color(0xFFFFE97D),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    surface: const Color(0xFF0D0D1A), // Azul muy oscuro
    onSurface: const Color(0xFFE6E1E5),
    surfaceContainerHighest: const Color(0xFF1A1A2E),
    onSurfaceVariant: const Color(0xFFCAC4D0),
    outline: const Color(0xFF938F99),
    outlineVariant: const Color(0xFF49454F),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: const Color(0xFFE6E1E5),
    onInverseSurface: const Color(0xFF313033),
    inversePrimary: const Color(0xFF5B4FC4),
  );
  
  /// ColorScheme Naturaleza - verdes y marrones naturales
  static final ColorScheme _natureColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFF2E7D32), // Verde bosque
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFA5D6A7),
    onPrimaryContainer: const Color(0xFF1B5E20),
    secondary: const Color(0xFF8D6E63), // Marrón
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFD7CCC8),
    onSecondaryContainer: const Color(0xFF4E342E),
    tertiary: const Color(0xFFFFB74D), // Naranja ámbar
    onTertiary: Colors.black,
    tertiaryContainer: const Color(0xFFFFE0B2),
    onTertiaryContainer: const Color(0xFF5D4037),
    error: const Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: const Color(0xFFFFFBF5), // Crema suave
    onSurface: const Color(0xFF1A1A1A),
    surfaceContainerHighest: const Color(0xFFF5F0E8),
    onSurfaceVariant: const Color(0xFF49454F),
    outline: const Color(0xFF79747E),
    outlineVariant: const Color(0xFFCAC4D0),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: const Color(0xFF313033),
    onInverseSurface: const Color(0xFFF4EFF4),
    inversePrimary: const Color(0xFF81C784),
  );
  
  /// Obtiene información del tema para mostrar en UI
  static Map<String, dynamic> getThemeInfo(String themeId) {
    switch (themeId) {
      case 'rainbow':
        return {
          'name': 'Arcoíris',
          'description': 'Colores brillantes y alegres',
          'icon': '🌈',
          'previewColors': [
            const Color(0xFFFF6B6B),
            const Color(0xFF4ECDC4),
            const Color(0xFFFFE66D),
          ],
        };
      case 'space':
        return {
          'name': 'Espacial',
          'description': 'Viaja por el espacio mientras aprendes',
          'icon': '🚀',
          'previewColors': [
            const Color(0xFF7B68EE),
            const Color(0xFF00CED1),
            const Color(0xFFFFD700),
          ],
        };
      case 'nature':
        return {
          'name': 'Naturaleza',
          'description': 'Colores verdes y naturales',
          'icon': '🌳',
          'previewColors': [
            const Color(0xFF2E7D32),
            const Color(0xFF8D6E63),
            const Color(0xFFFFB74D),
          ],
        };
      default:
        return {
          'name': 'Moderno',
          'description': 'Diseño profesional con azules y acentos cálidos',
          'icon': '🎨',
          'previewColors': [
            AppColors.primary,
            AppColors.secondary,
            AppColors.accent,
          ],
        };
    }
  }
}
