# 🎨 DEMANDIUM FLUTTER - User App & Web Setup Guide

## ✅ STATUS: READY FOR DEVELOPMENT

Your Flutter project is fully configured and connected to the backend!

---

## 📱 What You Have

- **Flutter 3.47.1** - Cross-platform framework
- **60+ Packages** - All dependencies installed
- **Web Support** - Run on browser (localhost:5000)
- **Android Support** - Build APK for phones
- **iOS Support** - Build for Apple devices
- **Firebase** - Push notifications, auth, analytics
- **GetX** - State management library

---

## 🚀 QUICK START

### **Option 1: Run Web App (Recommended for Testing)**

```powershell
cd "User app and web"

# Run on web browser
flutter run -d chrome --web-hostname localhost --web-port 5000
```

**What happens:**
- Chrome browser opens automatically
- App loads at http://localhost:5000
- Auto-refresh when you change code (hot reload)

**Access:**
- http://localhost:5000

---

### **Option 2: Build Android APK**

```powershell
cd "User app and web"

# Build release APK
flutter build apk --release

# Or build split APKs (smaller)
flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi
```

**Output files:**
- `build/app/outputs/apk/release/app-release.apk`
- Or split APKs in same folder

---

### **Option 3: Build iOS App**

```powershell
cd "User app and web"

# Clean pods
cd ios
rm -rf Podfile.lock
rm -rf Pods
pod deintegrate
pod setup
pod repo update
pod cache clean --all

# Install pods
pod install --repo-update

cd ..

# Build
flutter build ios --release
```

---

## 🔧 Configuration

### **Backend Connection**

Your app is **already configured** to connect to local backend:

```dart
// lib/util/app_constants.dart

static const String baseUrl = 'http://localhost:8000/api/v1';
static const String websiteUrl = 'http://localhost:5000';
```

**For Production:**
```dart
static const String baseUrl = 'https://your-production-domain.com/api/v1';
static const String websiteUrl = 'https://your-production-domain.com';
```

---

## 📂 Project Structure

```
lib/
├─ main.dart                 # App entry point
├─ api/
│  ├─ remote/
│  │  ├─ client_api.dart    # HTTP client
│  │  └─ api_checker.dart   # Error handling
│  └─ local/                # Local storage
├─ feature/                  # Feature modules
│  ├─ auth/                 # Login/Register
│  ├─ home/                 # Home screen
│  ├─ service/              # Service listing
│  ├─ booking/              # Booking management
│  ├─ cart/                 # Shopping cart
│  ├─ payment/              # Payment processing
│  ├─ profile/              # User profile
│  └─ ... (more features)
├─ common/                   # Shared components
│  ├─ models/               # Data models
│  ├─ widgets/              # Reusable widgets
│  └─ controllers/          # Logic controllers
├─ theme/                    # App styling
├─ helper/                   # Utility functions
└─ util/                     # Constants & helpers
```

---

## 🎯 KEY FILES TO KNOW

| File | Purpose | Edit For |
|------|---------|----------|
| `lib/main.dart` | App startup | Firebase config, theme |
| `lib/util/app_constants.dart` | API URLs, constants | Backend URL, API keys |
| `pubspec.yaml` | Dependencies | Adding packages |
| `lib/feature/*/binding.dart` | Dependency injection | Adding controllers |
| `lib/common/controllers/splash_controller.dart` | App initialization | Startup logic |

---

## 💡 COMMON COMMANDS

### **Development**

```powershell
# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome --web-port 5000

# Run on Android
flutter run -d emulator-5554

# Run on iOS
flutter run -d all

# Hot reload (press 'r' in terminal)
# Hot restart (press 'R' in terminal)
```

### **Build**

```powershell
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# Web build
flutter build web

# iOS build
flutter build ios --release
```

### **Cleaning**

```powershell
# Clean build files
flutter clean

# Clean pubspec.lock
rm pubspec.lock
flutter pub get

# Get latest packages
flutter pub upgrade
```

### **Debugging**

```powershell
# Enable verbose logging
flutter run -v

# Connect to debugger
flutter attach

# View logs
flutter logs
```

---

## 🐛 Troubleshooting

### **Issue: "Command 'flutter' not found"**
```powershell
# Add Flutter to PATH
# Check: flutter --version
# If not working, restart PowerShell or add Flutter to environment variables
```

### **Issue: "Chrome not found"**
```powershell
# Install Chrome or use edge
flutter run -d edge --web-port 5000
```

### **Issue: "Port 5000 already in use"**
```powershell
# Use different port
flutter run -d chrome --web-port 6000

# Or kill process using port 5000
lsof -i :5000
kill -9 <PID>
```

### **Issue: "Build fails for Android"**
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

### **Issue: "iOS build fails"**
```powershell
# Clean pods
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter pub get
flutter build ios --release
```

### **Issue: "Backend connection refused"**
```
1. Check backend is running: docker compose ps
2. Verify port 8000 is accessible: http://localhost:8000
3. Check API URL in app_constants.dart
4. If on mobile: Use your PC IP instead of localhost
   - Get IP: ipconfig | findstr "IPv4"
   - Update: baseUrl = 'http://YOUR_PC_IP:8000/api/v1'
```

---

## 📱 PLATFORMS SUPPORT

### **Web (✅ Working)**
- Run: `flutter run -d chrome --web-port 5000`
- Access: http://localhost:5000
- Perfect for testing

### **Android (✅ Ready)**
- Build: `flutter build apk --release`
- Output: `build/app/outputs/apk/release/app-release.apk`
- Install on phone via adb

### **iOS (✅ Ready)**
- Build: `flutter build ios --release`
- Output: Can archive for AppStore

---

## 🔐 IMPORTANT CONFIGURATIONS

### **Firebase Setup**

Firebase is already configured in code:

```dart
// lib/main.dart

Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "[REDACTED]",
    appId: "1:889759666168:web:ab661cb341d3e47384d00d",
    messagingSenderId: "889759666168",
    projectId: "demancms",
  ),
);
```

**For your own Firebase:**
1. Go to https://console.firebase.google.com
2. Create new project
3. Add iOS, Android, Web apps
4. Download config files
5. Replace in project

### **Google Sign-In**

```dart
// lib/main.dart
const String googleServerClientId = 'YOUR_CLIENT_ID_HERE';
```

**Get from:**
- Android: `android/app/google-services.json`
- Web: Firebase Console

### **Facebook Auth**

```dart
// lib/main.dart
appId: "482889663914976",
```

**Update in:**
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`
- Facebook Developer Console

---

## 🎨 CUSTOMIZE YOUR APP

### **Change App Name**

**Android:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application android:label="Your App Name">
```

**iOS:**
```plist
<!-- ios/Runner/Info.plist -->
<string>Your App Name</string>
```

**Flutter:**
```yaml
# pubspec.yaml
name: your_app_name
```

### **Change App Icon**

1. Create 512x512 PNG icon
2. Place in: `assets/images/your_icon.png`
3. Run: `flutter pub run flutter_launcher_icons:main`

### **Change Theme**

```dart
// lib/theme/light_theme.dart or dark_theme.dart
ThemeData light = ThemeData(
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
);
```

---

## 📦 DEPENDENCY HIGHLIGHTS

| Package | Purpose | Version |
|---------|---------|---------|
| **get** | State management | 4.7.3 |
| **firebase_core** | Firebase setup | 4.3.0 |
| **firebase_messaging** | Push notifications | 16.1.0 |
| **firebase_auth** | Authentication | 6.1.3 |
| **google_maps_flutter** | Maps integration | 2.14.0 |
| **geolocator** | Location services | 14.0.2 |
| **http** | API calls | 1.6.0 |
| **shared_preferences** | Local storage | 2.5.4 |
| **image_picker** | Image selection | 1.2.1 |
| **google_sign_in** | Google auth | 7.2.0 |
| **flutter_facebook_auth** | Facebook auth | 7.1.2 |
| **drift** | Local database | 2.30.0 |

---

## 🚀 DEPLOYMENT

### **Web Deployment**

```powershell
# Build for web
flutter build web --release

# Output in: build/web/
# Deploy to any web server (Netlify, Vercel, etc)
```

### **Android Deployment**

```powershell
# Build release APK
flutter build apk --release

# Upload to Google Play Store
# Or distribute directly
```

### **iOS Deployment**

```powershell
# Build release
flutter build ios --release

# Archive and upload to App Store
```

---

## 📊 BUILD SIZES

Expected sizes:

```
Web:    ~15-20 MB (compressed)
Android: ~50-80 MB (APK)
iOS:    ~100-150 MB (IPA)
```

---

## 🔌 API ENDPOINTS

Your app connects to:

```
Base: http://localhost:8000/api/v1

Common endpoints:
├─ POST   /customer/auth/registration
├─ POST   /customer/auth/login
├─ GET    /customer/service
├─ GET    /customer/booking
├─ POST   /customer/booking
├─ GET    /customer/cart/list
├─ POST   /customer/cart/add
└─ ... (see backend API docs)
```

---

## 💻 SYSTEM REQUIREMENTS

For development:

- **RAM**: 8GB+ recommended
- **Storage**: 5GB+ (including Android SDK)
- **OS**: Windows, macOS, Linux
- **Android SDK**: 21+
- **iOS**: 11+

---

## 🎓 LEARNING RESOURCES

- Flutter Docs: https://flutter.dev/docs
- GetX Documentation: https://github.com/jonataslaw/getx
- Firebase Docs: https://firebase.google.com/docs
- Dart Language: https://dart.dev/guides

---

## 📞 QUICK REFERENCE

```powershell
# Start web development
flutter run -d chrome --web-port 5000

# Build APK
flutter build apk --release

# Clean everything
flutter clean && flutter pub get

# Check setup
flutter doctor

# View logs
flutter logs
```

---

## ✨ NEXT STEPS

1. ✅ Dependencies installed
2. ✅ Backend connected
3. ✅ Firebase configured

**Now:**
1. Run web app: `flutter run -d chrome --web-port 5000`
2. Test features
3. Build APK when ready
4. Deploy to production

---

**Status: Ready to Build! 🚀**

