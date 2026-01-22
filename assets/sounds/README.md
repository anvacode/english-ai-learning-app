# Archivos de Audio Requeridos

Esta carpeta debe contener los siguientes archivos de audio para los efectos de sonido de la aplicación:

## Archivos Necesarios:

### 1. `correct.mp3`
- **Propósito**: Sonido de respuesta correcta
- **Descripción**: Tono alegre y positivo (por ejemplo: campanita, "ding", melodía ascendente)
- **Duración recomendada**: 0.5-1.5 segundos
- **Características**: Debe ser amigable para niños, no muy fuerte

### 2. `wrong.mp3`
- **Propósito**: Sonido de respuesta incorrecta
- **Descripción**: Tono suave, no negativo (por ejemplo: "buzz" suave, tono descendente corto)
- **Duración recomendada**: 0.5-1 segundo
- **Características**: Debe ser alentador, no desalentador. Evitar sonidos muy negativos o fuertes

### 3. `click.mp3`
- **Propósito**: Sonido de clic de botón
- **Descripción**: Clic sutil (por ejemplo: "tap", "pop" suave)
- **Duración recomendada**: 0.1-0.3 segundos
- **Características**: Sonido muy corto y limpio

## Fuentes de Audio Gratuitas:

Puedes obtener efectos de sonido gratuitos de:
- **Freesound.org** - Requiere atribución
- **Zapsplat.com** - Gratuito para uso educativo
- **Mixkit.co** - Biblioteca de efectos gratuitos
- **Pixabay** - Efectos de sonido libres de derechos

## Formato de Archivo:

- **Formato**: MP3 (recomendado) o WAV
- **Calidad**: 128kbps o superior
- **Tamaño**: Mantener archivos pequeños (<100KB cada uno)

## Instalación:

1. Descargar los archivos de audio con los nombres exactos listados arriba
2. Colocarlos en esta carpeta (`assets/sounds/`)
3. Los archivos ya están configurados en `pubspec.yaml`
4. Ejecutar `flutter pub get` si es necesario
5. Reconstruir la aplicación

## Nota:

Si los archivos de audio no están presentes, la aplicación seguirá funcionando normalmente sin efectos de sonido. Los errores se capturan silenciosamente para no interrumpir la experiencia del usuario.
