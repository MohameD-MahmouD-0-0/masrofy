# Masrofy

Personal finance tracking app built with Flutter and Firebase.

## Project Overview

Masrofy is a Flutter finance app that currently provides Firebase-backed authentication and a basic transaction dashboard. Users can register, log in, reset their password, log out, and add income or expense transactions stored in Cloud Firestore.

Current implementation includes:

- Firebase Authentication for email/password sign-in.
- User registration, login, forgot password, and logout flows.
- Firestore user profile storage under `users/{uid}`.
- Dashboard screen with user greeting.
- Income, expense, and balance summary calculated from Firestore transactions.
- Add transaction form for income and expense entries.
- Recent transactions list from real-time Firestore snapshots.
- Android launcher icon configuration through `flutter_launcher_icons`.
- App name/package setup still uses the Flutter example package id in places, so review it before release.

This project is not production-ready yet. It is an active Flutter/Firebase app foundation that still needs platform hardening, security rules review, broader testing, and more finance features.

## Tech Stack

- Flutter
- Dart
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Android support
- iOS support

## Current Features

- [x] Splash/Auth routing
- [x] Login
- [x] Register
- [x] Forgot password
- [x] Dashboard summary
- [x] Add income/expense transaction
- [x] Firestore real-time transactions
- [x] Logout
- [ ] Budgets
- [ ] Charts/reports
- [ ] Category management
- [ ] Profile management screen
- [ ] Dark mode
- [ ] Localization

## Project Structure

```text
lib/
  main.dart
  firebase_options.dart
  core/
    assets/
    routes/
    theme/
    utils/
    widgets/
  features/
    auth/
      data/
      presentation/
      widgets/
    dashboard/
      data/
      presentation/
      widgets/
    splash/
      presentation/

android/
ios/
assetes/
test/
```

### Key folders

`lib/main.dart`  
Application entry point. Initializes Firebase and starts `MyApp`.

`lib/firebase_options.dart`  
Generated FlutterFire configuration file. It contains platform Firebase options for web, Android, iOS, macOS, and Windows. The current `main.dart` still uses bare `Firebase.initializeApp()`, so wire this file into initialization when targeting web or fully multi-platform Firebase.

`lib/core/`  
Shared application code:

- `assets/`: central asset path constants.
- `routes/`: route names and route map.
- `theme/`: colors, text styles, and app theme.
- `utils/`: general utilities.
- `widgets/`: reusable UI widgets such as text fields and primary buttons.

`lib/features/auth/`  
Authentication feature:

- `data/`: Firebase Auth service, user profile service, and auth error mapping.
- `presentation/`: login, register, and forgot password screens.
- `widgets/`: shared auth layout widgets.

`lib/features/dashboard/`  
Finance dashboard feature:

- `data/`: transaction model and Firestore transaction service.
- `presentation/`: dashboard and add transaction screens.
- `widgets/`: summary and transaction cards.

`lib/features/splash/`  
Splash screen and auth-state routing.

`android/` and `ios/`  
Generated Flutter platform folders. Android includes `google-services.json` and launcher icon resources.

`assetes/`  
Image assets declared in `pubspec.yaml`. Note: the folder is currently named `assetes`, not `assets`.

`test/`  
Basic Flutter test coverage. Current tests verify transaction summary calculations.

## Firebase Setup

Masrofy requires Firebase to run the authentication and Firestore features.

1. Create a Firebase project.
2. Enable Email/Password sign-in in Firebase Authentication.
3. Create a Cloud Firestore database.
4. Add Android configuration:

   ```text
   android/app/google-services.json
   ```

5. Generate or refresh FlutterFire configuration:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

6. When using `lib/firebase_options.dart`, initialize Firebase like this:

   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

Do not commit private server keys or service account credentials. Firebase client API keys are not server secrets, but they should still be restricted appropriately in Firebase/Google Cloud settings.

### Firestore Data Shape

User profile:

```text
users/{uid}
```

Transaction collection:

```text
users/{uid}/transactions/{transactionId}
```

Transaction fields currently used:

- `id`
- `title`
- `amount`
- `type` (`income` or `expense`)
- `category`
- `note`
- `createdAt`
- `updatedAt`

## Installation & Running

Install dependencies:

```bash
flutter pub get
```

Run on the default connected device:

```bash
flutter run
```

Run on Chrome:

```bash
flutter run -d chrome
```

Clean generated build output:

```bash
flutter clean
```

## Build Commands

Build an Android APK:

```bash
flutter build apk --release
```

Build an Android App Bundle:

```bash
flutter build appbundle --release
```

## Known Issues / Notes

- `lib/firebase_options.dart` exists, but `lib/main.dart` currently calls `Firebase.initializeApp()` without `DefaultFirebaseOptions.currentPlatform`. Web Firebase initialization may fail until this is wired in.
- The asset folder is named `assetes/`; consider renaming it to `assets/` and updating `pubspec.yaml` and asset constants.
- Android still uses `com.example.masrofy` in platform configuration. Change this before publishing.
- Firestore security rules are not included in this repository. Add rules that restrict each user to their own profile and transactions.
- Tests are basic and currently cover transaction summary calculations only.
- UI has been improved for the current dashboard and forms, but more design refinement is still expected as features grow.
- Some platform files are generated and may change after running FlutterFire or launcher icon tools.

## Roadmap

- Budgets
- Category management
- Charts and reports
- Arabic/English localization
- Dark mode
- More complete widget, service, and integration tests
- Profile screen
- Transaction editing and deleting
- Firestore security rules and indexes documentation
- Production package id and app signing setup

## Contribution Workflow

Create a feature branch:

```bash
git checkout -b feature/your-feature
```

Stage changes:

```bash
git add .
```

Commit:

```bash
git commit -m "Your message"
```

Push:

```bash
git push -u origin feature/your-feature
```

## License

This project is for educational purposes unless a license is added.
