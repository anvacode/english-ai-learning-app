# 🎓 English AI Learning App

Una aplicación educativa interactiva para que niños aprendan inglés de forma divertida mediante lecciones, juegos y ejercicios.

[![Flutter Version](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Firestore-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📱 Plataformas Soportadas

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11+)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)

## ✨ Características Principales

### 🎯 Sistema de Lecciones
- **3 Niveles de Dificultad**: Principiante, Intermedio, Avanzado
- **Múltiples Categorías**: Colores, animales, frutas, familia, números, partes del cuerpo, ropa, comidas, acciones
- **Tipos de Ejercicios**:
  - Preguntas de opción múltiple
  - Ejercicios de emparejamiento (matching)
  - Juego de deletreo (spelling)
  - Práctica auditiva con TTS (Text-to-Speech)

### 🏆 Sistema de Gamificación
- **Estrellas**: Gana estrellas por completar lecciones
- **Insignias**: Desbloquea logros por tu progreso
- **Rachas**: Mantén tu racha de días consecutivos
- **Tienda**: Compra avatares y objetos con tus estrellas

### 🔐 Autenticación y Sincronización
- **Email/Contraseña**: Registro e inicio de sesión tradicional
- **Google Sign-In**: Inicio rápido con cuenta de Google
- **Sincronización en la Nube**: Tu progreso se guarda en Firebase
- **Modo Offline**: Funciona sin conexión y sincroniza cuando hay internet

### 🎨 Interfaz Adaptativa
- **Diseño Responsive**: Se adapta a móviles, tablets y desktop
- **Modo Oscuro/Claro**: Soporte para temas
- **Animaciones**: Transiciones suaves y efectos visuales
- **Accesible**: Diseño amigable para niños

## 🚀 Cómo Empezar

### Requisitos Previos

- [Flutter](https://flutter.dev/docs/get-started/install) (versión 3.10 o superior)
- [Dart](https://dart.dev/get-dart) (versión 3.0 o superior)
- [Android Studio](https://developer.android.com/studio) o [VS Code](https://code.visualstudio.com/)
- Cuenta en [Firebase](https://firebase.google.com/) (para autenticación y sincronización)

### Instalación

1. **Clona el repositorio**:
   ```bash
   git clone https://github.com/anvacode/english-ai-learning-app.git
   cd english-ai-learning-app
   ```

2. **Instala las dependencias**:
   ```bash
   flutter pub get
   ```

3. **Configura Firebase**:
   - Crea un proyecto en [Firebase Console](https://console.firebase.google.com/)
   - Agrega apps Android, iOS y Web
   - Descarga los archivos de configuración (`google-services.json`, `GoogleService-Info.plist`)
   - Colócalos en las carpetas correspondientes
   - Habilita Authentication (Email/Password y Google)
   - Configura Firestore Database

4. **Ejecuta la app**:
   ```bash
   # Para Android
   flutter run

   # Para Web
   flutter run -d chrome

   # Para iOS (solo en Mac)
   flutter run -d ios
   ```

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── firebase_options.dart        # Configuración Firebase
├── data/
│   └── lessons_data.dart        # Datos de lecciones
├── logic/
│   ├── auth_provider.dart       # Gestión de autenticación
│   ├── lesson_controller.dart   # Control de lecciones
│   └── student_service.dart     # Gestión de estudiantes
├── models/
│   ├── lesson.dart              # Modelo de lección
│   ├── student.dart             # Modelo de estudiante
│   └── user_profile.dart        # Peril de usuario
├── screens/
│   ├── auth/                    # Pantallas de autenticación
│   ├── practice/                # Juegos de práctica
│   └── home_screen.dart         # Pantalla principal
├── services/
│   ├── firebase_service.dart    # Servicio Firebase
│   ├── audio_service.dart       # Reproducción de audio
│   └── sync_service.dart        # Sincronización
└── widgets/                     # Widgets reutilizables
```

## 🎮 Uso

### Para Estudiantes

1. **Inicia la app** y completa el onboarding inicial
2. **Selecciona un nivel** (Principiante, Intermedio, Avanzado)
3. **Elige una lección** de las categorías disponibles
4. **Completa los ejercicios**:
   - Escucha la palabra en inglés
   - Selecciona la respuesta correcta
   - Empareja palabras con imágenes
   - Practica la pronunciación
5. **Gana estrellas** y desbloquea nuevas lecciones
6. **Visita la tienda** para personalizar tu avatar

### Para Desarrolladores

Ver la documentación en la carpeta [`docs/`](docs/):

- [`GUIA_AUTENTICACION.md`](docs/GUIA_AUTENTICACION.md) - Cómo funciona la autenticación
- [`GOOGLE_SIGNIN_SETUP.md`](docs/GOOGLE_SIGNIN_SETUP.md) - Configuración de Google Sign-In
- [`TESTING_GUIDE.md`](docs/TESTING_GUIDE.md) - Guía de testing
- [`TECHNICAL_REVIEW.md`](docs/TECHNICAL_REVIEW.md) - Revisión técnica del proyecto

## 🛠️ Tecnologías Utilizadas

- **Flutter** - Framework UI
- **Firebase** - Backend (Auth, Firestore, Storage)
- **Provider** - State management
- **SharedPreferences** - Almacenamiento local
- **flutter_tts** - Text-to-Speech
- **google_sign_in** - Autenticación con Google
- **sqflite** - Base de datos local SQLite

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar con coverage
flutter test --coverage

# Ejecutar análisis estático
flutter analyze
```

## 🤝 Contribuir

1. Haz fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commitea tus cambios (`git commit -m 'Agrega nueva funcionalidad'`)
4. Haz push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Autores

- **anvacode** - *Desarrollo inicial* - [GitHub](https://github.com/anvacode)

## 🙏 Agradecimientos

- Iconos por [Flutter Material Icons](https://fonts.google.com/icons)
- Imágenes educativas de dominio público
- Comunidad de Flutter por el soporte

---

<p align="center">
  <b>¡Haz que aprender inglés sea divertido! 🌟</b>
</p>
