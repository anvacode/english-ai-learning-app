# 🐛 Bug Fix: Lección en Bucle al Salir Durante Matching

## 📋 Descripción del Problema

**Reportado por usuario:** Al terminar las preguntas múltiples y empezar el ejercicio de matching, si el usuario sale de la aplicación y vuelve a entrar a la lección, aparece la última pregunta en un bucle infinito.

### Comportamiento Incorrecto:

1. Usuario completa todas las preguntas múltiples ✅
2. Empieza el ejercicio de matching 🎯
3. Usuario sale de la app (presiona back o cierra) 🚪
4. Usuario vuelve a entrar a la misma lección 🔙
5. **BUG:** Muestra la última pregunta y se queda en bucle ♾️

### Causa Raíz:

El problema estaba en dos lugares:

#### 1. `LessonScreen` (líneas 114-117)
```dart
// If all items are completed, start from the last item
if (completedIds.length == widget.lesson.items.length) {
  firstIncomplete = widget.lesson.items.length - 1; // ❌ PROBLEMA
}
```

Cuando TODAS las preguntas estaban completadas, posicionaba al usuario en la **última pregunta** en lugar de detectar que debería ir al matching.

#### 2. `LessonFlowScreen` (línea 33)
```dart
@override
void initState() {
  super.initState();
  _currentExerciseIndex = 0; // ❌ Siempre empezaba desde 0
}
```

El flujo NO recordaba en qué ejercicio estaba. Siempre reiniciaba desde el ejercicio 0 (preguntas múltiples), incluso si el usuario ya las había completado.

---

## ✅ Solución Implementada

### Cambio 1: `LessonFlowScreen` - Restaurar Progreso del Flujo

**Archivo:** `lib/screens/lesson_flow_screen.dart`

**Antes:**
```dart
@override
void initState() {
  super.initState();
  _currentExerciseIndex = 0; // Siempre desde 0
}
```

**Después:**
```dart
class _LessonFlowScreenState extends State<LessonFlowScreen> {
  late int _currentExerciseIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlowProgress(); // ✅ Cargar progreso
  }
  
  /// Carga el progreso del flujo desde SharedPreferences
  Future<void> _loadFlowProgress() async {
    // Determinar qué ejercicio debe mostrarse basándose en los resultados guardados
    int exerciseToShow = 0;
    
    // Verificar si las preguntas múltiples están completadas
    final results = await ActivityResultService.getActivityResults();
    final lessonResults = results.where((r) => r.lessonId == widget.lesson.id).toList();
    
    // Contar cuántas preguntas únicas correctas hay
    final completedQuestionIds = <String>{};
    for (final result in lessonResults) {
      if (result.isCorrect && result.itemId != 'matching_exercise') {
        completedQuestionIds.add(result.itemId);
      }
    }
    
    // Si todas las preguntas están completadas, ir al matching (ejercicio 1)
    if (completedQuestionIds.length >= widget.lesson.items.length) {
      // Verificar si matching también está completo
      final matchingComplete = lessonResults.any(
        (r) => r.itemId == 'matching_exercise' && r.isCorrect
      );
      
      if (matchingComplete) {
        // Todo está completo - mostrar feedback y salir
        exerciseToShow = widget.exercises.length; // Forzar completado
      } else {
        // Preguntas completas, matching pendiente
        exerciseToShow = 1; // Ir al matching
      }
    } else {
      // Preguntas incompletas, empezar desde el principio
      exerciseToShow = 0;
    }
    
    setState(() {
      _currentExerciseIndex = exerciseToShow;
      _isLoading = false;
    });
    
    // Si todo está completo, mostrar feedback inmediatamente
    if (_currentExerciseIndex >= widget.exercises.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onLessonComplete();
        }
      });
    }
  }
}
```

### Cambio 2: `LessonFlowScreen.build()` - Manejo de Estados

**Agregado al método `build()`:**

```dart
@override
Widget build(BuildContext context) {
  // Mostrar loading mientras se determina el ejercicio correcto
  if (_isLoading) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
  
  // Si el índice excede los ejercicios, significa que todo está completo
  if (_currentExerciseIndex >= widget.exercises.length) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finalizando lección...'),
          ],
        ),
      ),
    );
  }
  
  // ... resto del código normal
}
```

---

## 🔄 Flujo Corregido

### Escenario 1: Usuario completa preguntas y sale antes del matching

1. Usuario completa 8/8 preguntas ✅
2. Empieza matching (0/8 parejas) 🎯
3. Usuario sale 🚪
4. Usuario vuelve a entrar 🔙
5. **✅ CORRECTO:** `_loadFlowProgress()` detecta:
   - Preguntas completadas: 8/8
   - Matching completado: NO
   - **Acción:** Ir directamente al matching (ejercicio 1)

### Escenario 2: Usuario completa matching y sale

1. Usuario completa 8/8 preguntas ✅
2. Usuario completa 8/8 parejas ✅
3. Usuario sale ANTES de ver el feedback 🚪
4. Usuario vuelve a entrar 🔙
5. **✅ CORRECTO:** `_loadFlowProgress()` detecta:
   - Preguntas completadas: 8/8
   - Matching completado: ✅
   - **Acción:** `exerciseToShow = widget.exercises.length` (forzar completado)
   - **Resultado:** Muestra feedback de lección completada y regresa

### Escenario 3: Usuario está a mitad de las preguntas

1. Usuario completa 3/8 preguntas
2. Usuario sale 🚪
3. Usuario vuelve a entrar 🔙
4. **✅ CORRECTO:** `_loadFlowProgress()` detecta:
   - Preguntas completadas: 3/8
   - **Acción:** Empezar desde preguntas (ejercicio 0)
   - **Resultado:** Resume desde pregunta 4

---

## 📊 Lógica de Detección

```dart
// Pseudo-código de la lógica
if (todasLasPreguntasCompletadas) {
  if (matchingCompleto) {
    // TODO LISTO → Mostrar feedback y salir
    exerciseToShow = FINAL;
  } else {
    // MATCHING PENDIENTE → Ir al matching
    exerciseToShow = 1;
  }
} else {
  // PREGUNTAS PENDIENTES → Empezar desde preguntas
  exerciseToShow = 0;
}
```

---

## 🧪 Testing

### Test Case 1: Salir durante matching
```
DADO que el usuario completó todas las preguntas
Y está en el ejercicio de matching
CUANDO el usuario sale y vuelve a entrar
ENTONCES debe continuar en el matching, NO en las preguntas
```

**Pasos para probar:**
1. Iniciar lección Animals o Family
2. Completar todas las preguntas correctamente
3. Cuando aparezca el matching, NO completarlo
4. Presionar back o cerrar app
5. Volver a entrar a la misma lección
6. ✅ **Verificar:** Debe mostrar el matching, NO la última pregunta

### Test Case 2: Salir después de completar todo
```
DADO que el usuario completó todas las preguntas
Y completó todo el matching
CUANDO el usuario sale antes de ver el feedback
Y vuelve a entrar
ENTONCES debe mostrar el feedback de lección completada
```

**Pasos para probar:**
1. Iniciar lección Animals o Family
2. Completar todas las preguntas correctamente
3. Completar todo el matching
4. Salir JUSTO después (antes del feedback si es posible)
5. Volver a entrar a la misma lección
6. ✅ **Verificar:** Debe mostrar feedback y marcar como completada

### Test Case 3: Salir a mitad de preguntas
```
DADO que el usuario completó solo algunas preguntas
CUANDO el usuario sale y vuelve a entrar
ENTONCES debe continuar desde donde lo dejó
```

**Pasos para probar:**
1. Iniciar cualquier lección con matching
2. Completar 3-4 preguntas (no todas)
3. Salir
4. Volver a entrar
5. ✅ **Verificar:** Debe continuar con la siguiente pregunta

---

## 📁 Archivos Modificados

- **`lib/screens/lesson_flow_screen.dart`** (+53 líneas)
  - Agregado método `_loadFlowProgress()`
  - Agregado campo `_isLoading`
  - Agregada lógica de detección de progreso
  - Agregado manejo de estados en `build()`

---

## ✅ Estado

- **Errores de linting:** 0
- **Código compila:** ✅
- **Listo para testing:** ✅
- **Breaking changes:** NO

---

## 🎯 Impacto

**Antes:**
- ❌ Lecciones con matching quedaban en bucle
- ❌ Experiencia frustrante para el usuario
- ❌ Podía causar que el niño abandonara la app

**Después:**
- ✅ Flujo de lección se restaura correctamente
- ✅ Usuario puede salir y volver sin problemas
- ✅ Experiencia fluida y natural
- ✅ Lección recuerda el progreso exacto

---

## 💡 Notas Técnicas

### ¿Por qué no usar SharedPreferences directamente?

Se usa `ActivityResultService` porque:
1. Ya guarda todos los resultados correctos
2. Es la fuente de verdad del progreso
3. No requiere lógica adicional de persistencia
4. Consistente con el resto de la app

### ¿Por qué `exerciseToShow = widget.exercises.length`?

Cuando todo está completo, setting el índice más allá del máximo:
1. Activa el estado "finalizando lección"
2. Muestra feedback inmediatamente
3. Previene intentos de renderizar ejercicios inexistentes

---

## 🚀 Deploy

**Fecha:** 19 de enero de 2026  
**Versión:** 1.0.1  
**Prioridad:** Alta (bug crítico de UX)

---

**Desarrollado por:** Claude (AI Assistant)  
**Reportado por:** Usuario  
**Estado:** ✅ RESUELTO
