# StarCounter - Guía de Inicio Rápido ⚡

## 🎯 ¿Qué es StarCounter?

Un widget mejorado para mostrar el contador de estrellas del usuario con:
- ✅ Actualización automática cada 2 segundos
- ✅ Animaciones atractivas para niños
- ✅ Diseño con colores amber vibrantes
- ✅ Manejo de estados (loading/error/success)
- ✅ Funciona offline

## 🚀 Implementación en 30 segundos

### Paso 1: Importar

```dart
import '../widgets/star_counter.dart';
```

### Paso 2: Usar

```dart
// En cualquier parte de tu widget
StarCounter()
```

**¡Eso es todo!** El resto usa valores por defecto optimizados.

## 📱 Ejemplos Rápidos por Pantalla

### En AppBar (Home, Lessons, Shop)

```dart
AppBar(
  title: Text('Mi Pantalla'),
  actions: [
    Padding(
      padding: EdgeInsets.only(right: 16),
      child: StarCounter(
        iconSize: 20,
        fontSize: 16,
        showBackground: true,
      ),
    ),
  ],
)
```

### En Perfil (grande y destacado)

```dart
StarCounter(
  iconSize: 32,
  fontSize: 28,
  showBackground: true,
  animateChanges: true,
)
```

### En Tienda (con botón refresh)

```dart
StarCounterWithRefresh(
  iconSize: 24,
  fontSize: 18,
)
```

### En Diálogos (sin auto-refresh)

```dart
StarCounter(
  iconSize: 28,
  fontSize: 24,
  showBackground: true,
  refreshInterval: 0, // Sin actualización automática
)
```

## 🎨 Personalización Rápida

### Tamaños

```dart
StarCounter(iconSize: 16, fontSize: 14)  // Pequeño
StarCounter(iconSize: 24, fontSize: 18)  // Mediano (default)
StarCounter(iconSize: 32, fontSize: 28)  // Grande
```

### Colores

```dart
StarCounter(
  iconColor: Colors.purple[600],
  textColor: Colors.purple[900],
)
```

### Sin Fondo

```dart
StarCounter(showBackground: false)
```

### Sin Animaciones

```dart
StarCounter(animateChanges: false)
```

### Actualización Personalizada

```dart
StarCounter(refreshInterval: 1)  // Cada 1 segundo
StarCounter(refreshInterval: 5)  // Cada 5 segundos
StarCounter(refreshInterval: 0)  // Manual (sin auto-refresh)
```

## 🔔 Callbacks (Opcional)

```dart
StarCounter(
  onStarsUpdated: (newCount) {
    print('Estrellas: $newCount');
    // Mostrar notificación, actualizar UI, etc.
  },
)
```

## 🔄 Refresco Manual (Avanzado)

```dart
final GlobalKey _starKey = GlobalKey();

StarCounter(
  key: _starKey,
  refreshInterval: 0,
)

// Más tarde...
ElevatedButton(
  onPressed: () {
    (_starKey.currentState as dynamic).refresh?.call();
  },
  child: Text('Actualizar'),
)
```

**Tip:** Usar `StarCounterWithRefresh` es más fácil.

## 📊 Recomendaciones por Pantalla

| Pantalla | Widget | refreshInterval |
|----------|--------|----------------|
| HomeScreen | StarCounter | 2s |
| LessonsScreen | StarCounter | 2s |
| ProfileScreen | StarCounter | 3s |
| ShopScreen | StarCounterWithRefresh | 1s |
| Dialogs | StarCounter | 0 (manual) |

## 🐛 Solución Rápida de Problemas

| Problema | Solución |
|----------|----------|
| No se actualiza | `refreshInterval: 2` (no 0) |
| Animación no funciona | `animateChanges: true` |
| Muy lento | Verificar StarService |
| Error visible | Es normal si no hay datos |

## 📚 Más Información

- **API completa:** `STAR_COUNTER_README.md`
- **Ejemplos detallados:** `star_counter_examples.dart`
- **Guía de integración:** `STAR_COUNTER_INTEGRATION_GUIDE.md`
- **Resumen técnico:** `STAR_COUNTER_SUMMARY.md`

## ✅ Checklist de Uso

- [ ] Importé el widget
- [ ] Lo agregué a mi pantalla
- [ ] Configuré tamaño apropiado
- [ ] Probé que se actualiza
- [ ] Verifiqué las animaciones

## 💡 Tips Finales

1. **Default es bueno:** `StarCounter()` funciona perfecto sin configurar nada
2. **AppBar = compacto:** Usa tamaños más pequeños (20/16)
3. **Perfil = grande:** Usa tamaños más grandes (32/28)
4. **Tienda = refresh:** Usa `StarCounterWithRefresh`
5. **Diálogos = sin auto:** Usa `refreshInterval: 0`

---

**¡Listo para usar!** 🚀

El widget está en: `lib/widgets/star_counter.dart`
