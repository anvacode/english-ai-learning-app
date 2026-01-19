# 🧪 Guía de Pruebas - Optimización Web y Onboarding

## 📋 **PRUEBAS A REALIZAR**

### **1. Verificar Sistema Responsive en Web** 🌐

#### **Ejecutar en Chrome:**
```bash
cd english_ai_app
flutter run -d chrome
```

#### **Probar diferentes tamaños de pantalla:**

**A. Modo Móvil (< 768px):**
1. Abrir DevTools (F12)
2. Toggle Device Toolbar (Ctrl+Shift+M)
3. Seleccionar "iPhone 12 Pro" o establecer 375px de ancho
4. Verificar:
   - ✅ Grid de HomeScreen muestra 2 columnas
   - ✅ Padding es de 16px
   - ✅ Fuentes son del tamaño móvil (más pequeñas)
   - ✅ StarDisplay es de tamaño móvil

**B. Modo Tablet (768px - 1024px):**
1. Establecer ancho a 800px
2. Verificar:
   - ✅ Grid de HomeScreen muestra 3 columnas
   - ✅ Padding es de 24px
   - ✅ Fuentes son ligeramente más grandes
   - ✅ Avatar en perfil es más grande (120px)

**C. Modo Desktop (>= 1024px):**
1. Establecer ancho a 1920px
2. Verificar:
   - ✅ Grid de HomeScreen muestra 4 columnas
   - ✅ Contenido está centrado y limitado a 1200px
   - ✅ Padding es de 32px
   - ✅ Fuentes son las más grandes
   - ✅ Avatar en perfil es el más grande (140px)
   - ✅ No hay espacio desperdiciado en los lados

---

### **2. Verificar Onboarding Moderno** ✨

#### **A. Resetear estado del onboarding:**

**Opción 1 - Eliminar archivo de SharedPreferences:**
```bash
# Encontrar y eliminar el archivo de SharedPreferences
# Ubicación varía según plataforma
```

**Opción 2 - Reinstalar la app:**
```bash
flutter clean
flutter run
```

**Opción 3 - Agregar código temporal en main.dart:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('onboarding_completed'); // Temporal para testing
  runApp(const MyApp());
}
```

#### **B. Verificar funcionalidad del onboarding:**

1. **Slide 1 (Aprender):**
   - ✅ Fondo degradado azul/púrpura
   - ✅ Icono de escuela grande con círculos
   - ✅ Título: "¡Aprende Inglés Jugando!"
   - ✅ Animación fade-in + scale
   - ✅ Botón "Saltar" visible en esquina superior derecha
   - ✅ Botón "Siguiente" en la parte inferior
   - ✅ Dot indicator activo en posición 1

2. **Slide 2 (Estrellas):**
   - ✅ Fondo degradado amarillo/dorado
   - ✅ Icono de estrella
   - ✅ Título: "¡Gana Estrellas!"
   - ✅ Transición suave desde slide 1
   - ✅ Dot indicator activo en posición 2

3. **Slide 3 (Insignias):**
   - ✅ Fondo degradado turquesa
   - ✅ Icono de trofeo
   - ✅ Título: "¡Colecciona Insignias!"
   - ✅ Dot indicator activo en posición 3

4. **Slide 4 (Avatar):**
   - ✅ Fondo degradado rosa
   - ✅ Icono de cara
   - ✅ Título: "¡Personaliza tu Avatar!"
   - ✅ Botón "Saltar" NO visible (última página)
   - ✅ Botón cambia a "¡Empezar!" con icono de check
   - ✅ Dot indicator activo en posición 4

5. **Navegación:**
   - ✅ Swipe horizontal funciona (deslizar con mouse o touch)
   - ✅ Botón "Siguiente" avanza al siguiente slide
   - ✅ Botón "Saltar" lleva directamente a HomeScreen
   - ✅ Botón "¡Empezar!" lleva a HomeScreen
   - ✅ Transición elegante a HomeScreen (slide + fade)

6. **Estado persistente:**
   - ✅ Después de completar onboarding, no se muestra nuevamente
   - ✅ Al volver a abrir la app, va directo a HomeScreen
   - ✅ Login diario funciona correctamente después del onboarding

---

### **3. Verificar Pantallas Principales** 📱

#### **HomeScreen:**
1. Abrir la app
2. Verificar responsive:
   - **Móvil:** 2 columnas, botones grandes
   - **Tablet:** 3 columnas, botones más grandes
   - **Desktop:** 4 columnas, contenido centrado
3. Verificar:
   - ✅ StarDisplay se adapta en tamaño
   - ✅ Iconos emoji se adaptan en tamaño
   - ✅ Fuentes se adaptan
   - ✅ Todo es clickeable

#### **LessonsScreen:**
1. Navegar a "Lecciones"
2. Verificar:
   - ✅ Contenido limitado a 1200px en desktop
   - ✅ Padding se adapta
   - ✅ ExpansionTiles son legibles
   - ✅ Cards de lecciones no se cortan
   - ✅ Fuentes son apropiadas

#### **ProfileScreen:**
1. Navegar a "Perfil"
2. Verificar:
   - ✅ Avatar cambia de tamaño (100/120/140px)
   - ✅ Nickname tiene fuente apropiada
   - ✅ Cards no se desbordan
   - ✅ Estadísticas son legibles
   - ✅ Badges se muestran correctamente

#### **ShopScreen:**
1. Navegar a "Inicio" → "Tienda"
2. Verificar:
   - ✅ Banner de estrellas es responsive
   - ✅ Items de la tienda no se cortan
   - ✅ Descripción con ellipsis si es muy larga
   - ✅ Botones de compra funcionan
   - ✅ No hay overflow (error de "overflowed by X pixels")

---

### **4. Verificar Compatibilidad Cross-Platform** 🔄

#### **Android:**
```bash
flutter run -d <android-device-id>
```
- ✅ Todo funciona como antes
- ✅ No hay regresiones
- ✅ Onboarding se ve bien

#### **iOS (si tienes Mac):**
```bash
flutter run -d <ios-device-id>
```
- ✅ Todo funciona como antes
- ✅ No hay regresiones

#### **Windows:**
```bash
flutter run -d windows
```
- ✅ App se ejecuta
- ✅ Responsive funciona
- ✅ Onboarding se ve bien

---

### **5. Verificar Performance** ⚡

#### **Métricas a revisar:**
1. **Frame rate:**
   - Abrir DevTools > Performance
   - Verificar que se mantenga ~60 FPS
   - Especialmente durante animaciones del onboarding

2. **Build times:**
   - No debería haber aumento significativo

3. **Memory usage:**
   - Verificar que no haya memory leaks
   - Especialmente al navegar entre pantallas

---

### **6. Casos de Prueba Específicos** 🎯

#### **A. Primera vez (usuario nuevo):**
1. Instalar app por primera vez
2. Verificar:
   - ✅ Se muestra SplashScreen
   - ✅ Se muestra ModernOnboardingScreen
   - ✅ Después del onboarding, va a HomeScreen
   - ✅ No se muestra login diario

#### **B. Usuario existente (con onboarding completado):**
1. Abrir app existente
2. Verificar:
   - ✅ Se muestra SplashScreen
   - ✅ Se muestra diálogo de login diario (si corresponde)
   - ✅ Va directo a HomeScreen
   - ✅ NO se muestra onboarding nuevamente

#### **C. Responsive transitions:**
1. En web, cambiar tamaño de ventana dinámicamente
2. Verificar:
   - ✅ Layout se adapta suavemente
   - ✅ No hay saltos bruscos
   - ✅ Todo permanece funcional

---

### **7. Verificar Linter** 🔍

```bash
cd english_ai_app
flutter analyze
```

Resultado esperado:
```
No issues found!
```

---

## 🐛 **PROBLEMAS COMUNES Y SOLUCIONES**

### **Problema 1: Onboarding no aparece**
**Solución:**
- Eliminar `onboarding_completed` de SharedPreferences
- O reinstalar la app

### **Problema 2: Grid no cambia de columnas**
**Solución:**
- Verificar que `ResponsiveContainer` esté envolviendo el contenido
- Verificar imports en los archivos modificados

### **Problema 3: Texto se desborda**
**Solución:**
- Ya implementado `TextOverflow.ellipsis` en todos los lugares necesarios
- Si aparece en otro lugar, agregar `maxLines` y `overflow`

### **Problema 4: Animaciones lentas**
**Solución:**
- Verificar que no haya operaciones pesadas en `build()`
- Profile mode: `flutter run --profile`

---

## ✅ **CHECKLIST DE PRUEBAS COMPLETADAS**

Marcar cuando se complete cada prueba:

### **Responsive:**
- [ ] Móvil (< 768px) - HomeScreen
- [ ] Móvil (< 768px) - LessonsScreen
- [ ] Móvil (< 768px) - ProfileScreen
- [ ] Móvil (< 768px) - ShopScreen
- [ ] Tablet (768-1024px) - Todas las pantallas
- [ ] Desktop (>= 1024px) - Todas las pantallas

### **Onboarding:**
- [ ] Slide 1 - Aprender
- [ ] Slide 2 - Estrellas
- [ ] Slide 3 - Insignias
- [ ] Slide 4 - Avatar
- [ ] Botón "Siguiente"
- [ ] Botón "Saltar"
- [ ] Botón "¡Empezar!"
- [ ] Transición a HomeScreen
- [ ] Estado persistente (no se muestra nuevamente)

### **Funcionalidad:**
- [ ] StarDisplay funciona
- [ ] Login diario funciona
- [ ] Lecciones se pueden abrir
- [ ] Perfil editable
- [ ] Tienda funciona
- [ ] Compras funcionan
- [ ] Badges se desbloquean

### **Performance:**
- [ ] 60 FPS en animaciones
- [ ] No hay memory leaks
- [ ] Build time aceptable

### **Linter:**
- [ ] `flutter analyze` sin errores

---

## 📸 **CAPTURAS DE PANTALLA RECOMENDADAS**

Para documentación, tomar capturas de:
1. Onboarding - Cada slide
2. HomeScreen - Móvil/Tablet/Desktop
3. LessonsScreen - Desktop con ancho limitado
4. ProfileScreen - Desktop
5. ShopScreen - Sin overflows

---

## 🎉 **RESULTADO ESPERADO**

Después de completar todas las pruebas, deberías tener:

✅ App funcionando perfectamente en todos los tamaños de pantalla
✅ Onboarding moderno y atractivo
✅ Sin errores de linter
✅ Sin regresiones en funcionalidad existente
✅ Performance óptima
✅ Código limpio y mantenible

---

**¡Listo para producción!** 🚀
