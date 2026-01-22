# 🎮 REESTRUCTURACIÓN COMPLETA DE LA APP
## Diseño de Nueva Arquitectura - Enero 2026

---

## 📋 **PROBLEMAS ACTUALES IDENTIFICADOS**

### 1. ❌ **Experiencia Repetitiva**
- Solo 3 tipos de ejercicios: Multiple Choice, Matching, Spelling
- Todos dentro del mismo flujo lineal de lección
- Falta variedad en la metodología de aprendizaje

### 2. ❌ **Spelling Integrado Forzosamente**
- El Spelling es parte obligatoria del flujo de lección
- No se puede practicar de forma independiente
- Rompe el ritmo de aprendizaje

### 3. ❌ **Niveles Superiores Poco Desarrollados**
- Intermedio y Avanzado tienen mismo formato que Principiante
- No hay actividades desafiantes específicas para estos niveles
- Contenido limitado y poco variado

---

## 🎯 **NUEVA ARQUITECTURA PROPUESTA**

### **FLUJO PRINCIPAL: LECCIONES** 📚
```
Lección → Multiple Choice → Matching → ✅ Completado
              ↓                ↓
          (Sin Spelling integrado)
```

**Características:**
- ✅ Flujo simple y directo
- ✅ Sin interrupciones con spelling
- ✅ Enfocado en aprendizaje del vocabulario
- ✅ Progreso claro y medible

---

### **FLUJO SECUNDARIO: PRÁCTICA** 🎮
```
┌─────────────────────────────────────────┐
│     SECCIÓN DE PRÁCTICA/JUEGOS          │
│  (Nueva pestaña en navegación)          │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│  Por cada lección completada:           │
│  - Spelling Challenge 🔤                │
│  - Listening Quiz 🎧                    │
│  - Speed Match ⚡                        │
│  - Word Scramble 🔀                     │
│  - Fill the Blanks 📝                   │
│  - Picture Memory 🖼️                    │
└─────────────────────────────────────────┘
```

**Características:**
- ✅ Acceso independiente desde menú principal
- ✅ Se desbloquean al completar lecciones
- ✅ Gamificación con rankings y récords
- ✅ Recompensas extra en estrellas
- ✅ Práctica opcional y divertida

---

## 🎮 **NUEVOS TIPOS DE ACTIVIDADES**

### **1. SPELLING CHALLENGE** 🔤 (Ya existe - solo mover)
**Descripción:** Formar palabras arrastrando letras
**Habilidad:** Escritura y ortografía
**Niveles:** Todos
**Estrellas:** 1 por palabra correcta

---

### **2. LISTENING QUIZ** 🎧 (NUEVO)
**Descripción:** Escuchar palabra y seleccionar imagen correcta
**Habilidad:** Comprensión auditiva
**Niveles:** Todos
**Implementación:**
```dart
class ListeningExercise {
  final String wordToSpeak;
  final String correctImagePath;
  final List<String> optionImages; // 4 opciones
  final int correctIndex;
}
```

**Flujo:**
1. Muestra 4 imágenes
2. Reproduce audio de una palabra (usando flutter_tts)
3. Usuario selecciona la imagen correcta
4. Feedback inmediato

**Estrellas:** 1 por respuesta correcta

---

### **3. SPEED MATCH** ⚡ (NUEVO)
**Descripción:** Emparejar palabras con imágenes contra reloj
**Habilidad:** Memoria y velocidad
**Niveles:** Todos
**Implementación:**
```dart
class SpeedMatchGame {
  final List<MatchPair> pairs; // 8 pares
  final Duration timeLimit; // 60 segundos
  final int targetPairs; // 8 pares
}
```

**Flujo:**
1. Muestra grid 4x4 con palabras e imágenes mezcladas
2. Timer cuenta regresiva desde 60s
3. Usuario toca palabra → toca imagen
4. Si es correcto: desaparecen y +10 puntos
5. Si es incorrecto: -5 puntos
6. Al terminar o acabar tiempo: mostrar puntuación

**Estrellas:** 
- 3★ si termina en < 30s
- 2★ si termina en < 45s
- 1★ si termina en < 60s

---

### **4. WORD SCRAMBLE** 🔀 (NUEVO)
**Descripción:** Ordenar palabras para formar oración correcta
**Habilidad:** Gramática y estructura de frases
**Niveles:** Intermedio y Avanzado
**Implementación:**
```dart
class WordScrambleExercise {
  final String sentence; // "The cat is on the table"
  final List<String> scrambledWords; // ["table", "the", "cat", "on", "is", "The"]
  final String imagePath; // Imagen ilustrativa
}
```

**Flujo:**
1. Muestra imagen y palabras desordenadas
2. Usuario arrastra palabras para formar oración
3. Botón "Verificar" comprueba orden
4. Si correcto: avanza, si no: mensaje de error

**Estrellas:** 1 por oración correcta

---

### **5. FILL THE BLANKS** 📝 (NUEVO)
**Descripción:** Completar espacios en frases con palabra correcta
**Habilidad:** Vocabulario en contexto
**Niveles:** Intermedio y Avanzado
**Implementación:**
```dart
class FillTheBlanksExercise {
  final String sentence; // "I ___ to school every day"
  final int blankIndex; // posición de la palabra faltante
  final List<String> options; // ["go", "went", "going"]
  final int correctIndex;
}
```

**Flujo:**
1. Muestra frase con hueco
2. 3-4 opciones de palabras
3. Usuario selecciona la correcta
4. Feedback inmediato

**Estrellas:** 1 por respuesta correcta

---

### **6. PICTURE MEMORY** 🖼️ (NUEVO)
**Descripción:** Juego de memoria con imágenes y palabras
**Habilidad:** Memoria visual y vocabulario
**Niveles:** Todos
**Implementación:**
```dart
class PictureMemoryGame {
  final List<MemoryCard> cards; // 12 cartas (6 pares)
  final Duration viewTime; // 3 segundos iniciales
}

class MemoryCard {
  final String id;
  final String imagePath; // o palabra en texto
  final String pairId; // para identificar el par
  bool isFlipped;
  bool isMatched;
}
```

**Flujo:**
1. Muestra grid 3x4 con cartas boca abajo
2. Usuario toca 2 cartas
3. Si coinciden: permanecen visibles
4. Si no: se voltean de nuevo
5. Objetivo: encontrar todos los pares

**Estrellas:** 
- 3★ si completa en < 10 movimientos
- 2★ si completa en < 15 movimientos
- 1★ si completa en < 20 movimientos

---

### **7. TRUE OR FALSE** ✓✗ (NUEVO)
**Descripción:** Evaluar si la afirmación sobre la imagen es verdadera
**Habilidad:** Comprensión lectora
**Niveles:** Intermedio y Avanzado
**Implementación:**
```dart
class TrueFalseExercise {
  final String imagePath;
  final String statement; // "The cat is sleeping"
  final bool isTrue;
}
```

**Flujo:**
1. Muestra imagen
2. Muestra afirmación
3. Usuario selecciona True/False
4. Feedback inmediato

**Estrellas:** 1 por respuesta correcta

---

## 🏗️ **NUEVA ESTRUCTURA DE ARCHIVOS**

```
lib/
├── models/
│   ├── lesson_exercise.dart (existente - mantener)
│   ├── practice_activity.dart (NUEVO)
│   ├── listening_exercise.dart (NUEVO)
│   ├── speed_match_game.dart (NUEVO)
│   ├── word_scramble_exercise.dart (NUEVO)
│   ├── fill_blanks_exercise.dart (NUEVO)
│   ├── picture_memory_game.dart (NUEVO)
│   └── true_false_exercise.dart (NUEVO)
│
├── screens/
│   ├── lesson_flow_screen.dart (MODIFICAR - quitar spelling)
│   ├── practice/
│   │   ├── practice_hub_screen.dart (NUEVO - menú de juegos)
│   │   ├── spelling_practice_screen.dart (MOVER spelling_exercise_screen.dart)
│   │   ├── listening_quiz_screen.dart (NUEVO)
│   │   ├── speed_match_screen.dart (NUEVO)
│   │   ├── word_scramble_screen.dart (NUEVO)
│   │   ├── fill_blanks_screen.dart (NUEVO)
│   │   ├── picture_memory_screen.dart (NUEVO)
│   │   └── true_false_screen.dart (NUEVO)
│   │
│   └── home_screen.dart (MODIFICAR - agregar botón Práctica)
│
├── logic/
│   ├── practice_service.dart (NUEVO - gestión de actividades)
│   └── practice_progress_service.dart (NUEVO - tracking)
│
├── widgets/
│   ├── practice_card.dart (NUEVO - card para cada juego)
│   ├── practice_stats_widget.dart (NUEVO - estadísticas)
│   └── activity_badge.dart (NUEVO - insignia de actividad)
│
└── data/
    ├── lessons_data.dart (MODIFICAR - quitar spelling)
    └── practice_data.dart (NUEVO - datos de actividades)
```

---

## 🎨 **DISEÑO UI: PRACTICE HUB**

### **Pantalla Principal de Práctica**
```
┌────────────────────────────────────────────┐
│  🎮 Práctica y Juegos              ⭐ 1,250 │
├────────────────────────────────────────────┤
│                                             │
│  Filtra por lección:                        │
│  [Todas] [Frutas] [Animales] [Colores]...  │
│                                             │
│  ┌──────────────┐  ┌──────────────┐        │
│  │   🔤 Spelling │  │  🎧 Listening │        │
│  │   Challenge   │  │     Quiz      │        │
│  │               │  │               │        │
│  │   12/15 🎯    │  │   8/15 🎯     │        │
│  │   ⭐⭐⭐ 45    │  │   ⭐⭐⭐ 24    │        │
│  └──────────────┘  └──────────────┘        │
│                                             │
│  ┌──────────────┐  ┌──────────────┐        │
│  │  ⚡ Speed     │  │  🔀 Word      │        │
│  │    Match      │  │   Scramble    │        │
│  │               │  │               │        │
│  │   🔒 Locked   │  │   5/10 🎯     │        │
│  │   Completa    │  │   ⭐⭐ 15      │        │
│  │   "Animales"  │  │               │        │
│  └──────────────┘  └──────────────┘        │
│                                             │
│  ┌──────────────┐  ┌──────────────┐        │
│  │  📝 Fill the  │  │  🖼️ Picture   │        │
│  │    Blanks     │  │    Memory     │        │
│  │               │  │               │        │
│  │   0/8 🎯      │  │   3/8 🎯      │        │
│  │   ⭐ 0        │  │   ⭐⭐ 9       │        │
│  └──────────────┘  └──────────────┘        │
│                                             │
│  [Ver Estadísticas] [Rankings]             │
│                                             │
└────────────────────────────────────────────┘
```

### **Card Individual de Juego**
```
┌─────────────────────────────┐
│  🔤                          │
│  Spelling Challenge          │
│  ─────────────────────       │
│  Forma palabras              │
│  arrastrando letras          │
│                              │
│  📊 Progreso: 12/15          │
│  ⭐ Estrellas: 45            │
│  🏆 Mejor: 15/15             │
│                              │
│  [🎮 Jugar Ahora]            │
└─────────────────────────────┘
```

---

## 💾 **SISTEMA DE PERSISTENCIA**

### **PracticeProgress (SharedPreferences)**
```dart
class PracticeProgress {
  final String lessonId;
  final String activityType;
  final int completed; // ejercicios completados
  final int total; // ejercicios totales
  final int starsEarned;
  final int bestScore; // mejor puntuación
  final DateTime lastPlayed;
  
  // Keys para SharedPreferences:
  // practice_${lessonId}_${activityType}_completed
  // practice_${lessonId}_${activityType}_stars
  // practice_${lessonId}_${activityType}_best_score
}
```

---

## 🎯 **SISTEMA DE DESBLOQUEO**

### **Reglas de Desbloqueo:**
1. **Spelling Challenge**: Se desbloquea al completar la lección
2. **Listening Quiz**: Se desbloquea al completar la lección
3. **Speed Match**: Se desbloquea al completar la lección + obtener 2★
4. **Word Scramble**: Solo niveles Intermedio/Avanzado
5. **Fill the Blanks**: Solo niveles Intermedio/Avanzado
6. **Picture Memory**: Se desbloquea al completar 3+ lecciones
7. **True or False**: Solo niveles Intermedio/Avanzado

---

## ⭐ **SISTEMA DE RECOMPENSAS**

### **Estrellas por Actividad:**
| Actividad | Estrellas por Ejercicio | Bonus Completo |
|-----------|------------------------|----------------|
| Spelling | 1★ por palabra | +5★ (8/8) |
| Listening | 1★ por respuesta | +5★ (8/8) |
| Speed Match | 1-3★ por tiempo | +10★ (perfect) |
| Word Scramble | 1★ por oración | +5★ (8/8) |
| Fill Blanks | 1★ por respuesta | +5★ (8/8) |
| Picture Memory | 1-3★ por movimientos | +10★ (perfect) |
| True/False | 1★ por respuesta | +5★ (8/8) |

### **Beneficios:**
- ✅ Más formas de ganar estrellas
- ✅ Incentivo para jugar todas las actividades
- ✅ Rejugabilidad para mejorar puntuaciones

---

## 📊 **CONTENIDO POR NIVEL**

### **PRINCIPIANTE** (10 lecciones)
**Actividades disponibles:**
- ✅ Spelling Challenge
- ✅ Listening Quiz
- ✅ Speed Match
- ✅ Picture Memory

**Total actividades:** 40 (10 lecciones × 4 actividades)

---

### **INTERMEDIO** (10 lecciones)
**Actividades disponibles:**
- ✅ Spelling Challenge
- ✅ Listening Quiz
- ✅ Speed Match
- ✅ Word Scramble ⭐ (NUEVO)
- ✅ Fill the Blanks ⭐ (NUEVO)
- ✅ Picture Memory
- ✅ True or False ⭐ (NUEVO)

**Total actividades:** 70 (10 lecciones × 7 actividades)

---

### **AVANZADO** (8 lecciones)
**Actividades disponibles:**
- ✅ Spelling Challenge
- ✅ Listening Quiz
- ✅ Speed Match
- ✅ Word Scramble
- ✅ Fill the Blanks
- ✅ Picture Memory
- ✅ True or False

**Total actividades:** 56 (8 lecciones × 7 actividades)

---

## 🚀 **PLAN DE IMPLEMENTACIÓN**

### **FASE 1: Arquitectura Base** (Prioridad Alta)
- [ ] Crear modelos base (`practice_activity.dart`)
- [ ] Crear `PracticeService` para gestión
- [ ] Crear `PracticeHubScreen` (hub principal)
- [ ] Modificar `HomeScreen` para agregar botón "Práctica"
- [ ] Implementar sistema de desbloqueo

### **FASE 2: Migrar Spelling** (Prioridad Alta)
- [ ] Mover `SpellingExerciseScreen` a carpeta `practice/`
- [ ] Renombrar a `SpellingPracticeScreen`
- [ ] Quitar Spelling de `lesson_flow_screen.dart`
- [ ] Quitar Spelling de `lessons_data.dart`
- [ ] Agregar Spelling al Practice Hub

### **FASE 3: Nuevas Actividades Básicas** (Prioridad Media)
- [ ] Implementar Listening Quiz
- [ ] Implementar Speed Match
- [ ] Implementar Picture Memory
- [ ] Crear datos para estas actividades

### **FASE 4: Actividades Avanzadas** (Prioridad Media)
- [ ] Implementar Word Scramble
- [ ] Implementar Fill the Blanks
- [ ] Implementar True or False
- [ ] Crear contenido específico para Intermedio/Avanzado

### **FASE 5: Pulido y Optimización** (Prioridad Baja)
- [ ] Agregar animaciones y transiciones
- [ ] Implementar sistema de rankings
- [ ] Agregar estadísticas detalladas
- [ ] Testing exhaustivo

---

## ✅ **BENEFICIOS DE LA REESTRUCTURACIÓN**

### **Para el Usuario:**
- 🎮 **7 tipos de actividades** vs 3 actuales
- 🎯 **Práctica opcional** sin romper flujo de lecciones
- ⭐ **Más formas de ganar estrellas**
- 🏆 **Gamificación con rankings**
- 📚 **Contenido específico** por nivel

### **Para la App:**
- 🏗️ **Arquitectura más limpia** y modular
- 📈 **Escalable**: fácil agregar nuevas actividades
- 💾 **Mejor organización** de datos
- 🔧 **Más fácil de mantener**

---

## 📅 **TIEMPO ESTIMADO**

- **Fase 1**: 1-2 horas
- **Fase 2**: 30 minutos
- **Fase 3**: 2-3 horas
- **Fase 4**: 2-3 horas
- **Fase 5**: 1-2 horas

**Total: 6-10 horas de desarrollo**

---

## 🎉 **RESULTADO FINAL**

Una aplicación de aprendizaje de idiomas **moderna, variada y profesional** con:

✅ **28+ tipos de lecciones** (10 Principiante + 10 Intermedio + 8 Avanzado)
✅ **166 actividades de práctica** (40 + 70 + 56)
✅ **7 tipos de juegos** interactivos
✅ **Sistema de progreso** robusto
✅ **Experiencia no repetitiva** y engagement alto

---

**Documento creado:** 22 de Enero, 2026
**Versión:** 1.0
**Estado:** Diseño aprobado - Listo para implementar
