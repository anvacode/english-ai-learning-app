# 📱 Configuración de Google Sign-In para Android

## ✅ **Código Actualizado**

El código de Google Sign-In ya está actualizado para funcionar en Android. Ahora detecta la plataforma y usa el método correcto:
- **Web**: Usa `signInWithPopup` (como antes)
- **Android/iOS**: Usa el paquete `google_sign_in` de Flutter

---

## 🔧 **Paso 1: Obtener el SHA-1 Fingerprint**

Para que Google Sign-In funcione en Android, necesitas agregar el SHA-1 fingerprint a Firebase Console.

### **Opción A: Usando Gradle (Recomendado)**

1. Abre una terminal en la carpeta del proyecto:
   ```bash
   cd english_ai_app/android
   ```

2. Ejecuta:
   ```bash
   .\gradlew signingReport
   ```

3. Busca en la salida la sección `Variant: debug` y copia el valor de **SHA1**

### **Opción B: Usando keytool directamente**

1. Abre PowerShell o CMD

2. Ejecuta este comando:
   ```bash
   keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

3. Busca la línea que dice **SHA1:** y copia el valor (sin espacios)

### **Opción C: Si tienes Android Studio**

1. Abre Android Studio
2. Ve a **Gradle** (panel derecho)
3. Expande: `android` → `Tasks` → `android` → `signingReport`
4. Doble click en `signingReport`
5. En la consola, busca `SHA1:` bajo `Variant: debug`

---

## 🔥 **Paso 2: Agregar SHA-1 a Firebase Console**

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto: **english-learning-app-4559e**
3. Ve a **⚙️ Configuración del proyecto** (icono de engranaje)
4. Baja hasta la sección **Tus aplicaciones**
5. Busca la app **Android** (o créala si no existe)
6. Haz click en **Agregar huella digital**
7. Pega el SHA-1 que copiaste
8. Haz click en **Guardar**

**Nota:** Si no tienes una app Android registrada:
1. Haz click en **Agregar app** → **Android**
2. **Package name**: `com.example.english_ai_app`
3. **App nickname** (opcional): `English AI App Android`
4. Haz click en **Registrar app**
5. Luego agrega el SHA-1 como se describe arriba

---

## ✅ **Paso 3: Verificar que Google Sign-In esté habilitado**

1. En Firebase Console, ve a **Authentication**
2. Click en la pestaña **Sign-in method**
3. Verifica que **Google** esté **Enabled** ✅
4. Si no está habilitado:
   - Click en **Google**
   - Activa el interruptor
   - Guarda los cambios

---

## 🧪 **Paso 4: Probar en tu dispositivo**

1. Conecta tu dispositivo Android o inicia un emulador
2. Ejecuta la app:
   ```bash
   flutter run
   ```
3. Ve a la pantalla de login
4. Toca el botón **"Continuar con Google"**
5. Deberías ver el selector de cuentas de Google
6. Selecciona tu cuenta
7. ¡Deberías iniciar sesión exitosamente! ✅

---

## 🐛 **Solución de Problemas**

### **Error: "10:" o "DEVELOPER_ERROR"**

**Causa:** El SHA-1 no está configurado o no coincide.

**Solución:**
1. Verifica que agregaste el SHA-1 correcto en Firebase Console
2. Asegúrate de usar el SHA-1 del keystore de **debug** (no release)
3. Espera unos minutos después de agregar el SHA-1 (puede tardar en propagarse)
4. Reinicia la app completamente

### **Error: "12500:" o "Sign in failed"**

**Causa:** Google Sign-In no está habilitado en Firebase Console.

**Solución:**
1. Ve a Firebase Console → Authentication → Sign-in method
2. Verifica que Google esté **Enabled**
3. Si no está, habilítalo y guarda

### **Error: "No se puede conectar a Google Play Services"**

**Causa:** El dispositivo no tiene Google Play Services instalado o actualizado.

**Solución:**
1. Asegúrate de usar un dispositivo/emulador con Google Play Services
2. Actualiza Google Play Services desde Play Store
3. Si usas un emulador, usa uno con Google APIs (no AOSP)

### **El botón no hace nada o no aparece**

**Causa:** Error en el código o dependencias no actualizadas.

**Solución:**
1. Ejecuta:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
2. Verifica que estás usando la versión más reciente del código

---

## 📋 **Checklist de Configuración**

- [ ] SHA-1 fingerprint obtenido
- [ ] SHA-1 agregado en Firebase Console
- [ ] App Android registrada en Firebase (si no existía)
- [ ] Google Sign-In habilitado en Firebase Console
- [ ] Código actualizado (ya está hecho ✅)
- [ ] App probada en dispositivo Android

---

## 🔍 **Verificar que Funciona**

Después de iniciar sesión con Google:

1. Ve a Firebase Console → Authentication → Users
2. Deberías ver tu usuario con:
   - **Providers:** Google
   - **Email:** tu email de Google
   - **Sign-in method:** google.com

---

## 💡 **Notas Importantes**

1. **SHA-1 de Debug vs Release:**
   - Para desarrollo: usa el SHA-1 del keystore de **debug**
   - Para producción: necesitarás el SHA-1 del keystore de **release**

2. **Múltiples SHA-1:**
   - Puedes agregar múltiples SHA-1 en Firebase Console
   - Útil si desarrollas en varias máquinas

3. **Tiempo de propagación:**
   - Después de agregar el SHA-1, puede tardar 5-10 minutos en aplicarse
   - Si no funciona inmediatamente, espera unos minutos

---

## 🎉 **¡Listo!**

Una vez completados estos pasos, Google Sign-In debería funcionar perfectamente en Android.

Si tienes problemas, revisa los logs de Flutter:
```bash
flutter run -v
```

Esto mostrará errores detallados que pueden ayudar a diagnosticar el problema.
