# Masrofy

A Flutter + Firebase personal finance app for tracking income, expenses, budgets, and financial activity.

## Overview

Masrofy is a personal finance app built with Flutter and Firebase. It currently supports email/password authentication, user profiles, transaction tracking, monthly budgets, notifications, and a bottom navigation shell for the main app areas.

User data is stored under each authenticated user in Cloud Firestore. Transactions are streamed in real time, dashboard totals are calculated from real transaction data, and monthly budget spending is calculated from expense transactions for the selected month.

The app is still under active development. Reports and Profile currently exist as styled placeholder screens.

## Tech Stack

- Flutter
- Dart
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Android support
- iOS support
- Web support
- Windows/macOS scaffold support
- Linux scaffold support, without Firebase options configured in `firebase_options.dart`

## Features

- [x] Firebase Authentication
- [x] Login/Register
- [x] Forgot Password
- [x] Auth state routing
- [x] Dashboard
- [x] Transactions
- [x] Add Transaction
- [x] View Transaction Details
- [x] Edit/Delete Transactions
- [x] Monthly Budget
- [x] Bottom Navigation
- [x] Notifications system
- [x] Reports placeholder
- [x] Profile placeholder
- [x] Launcher icon configuration

## App Screens

- **Splash**: Checks Firebase Auth state and routes signed-in users into the main app.
- **Login**: Signs in existing users with email and password.
- **Register**: Creates a Firebase Auth account and stores a user profile document.
- **Forgot Password**: Sends a Firebase password reset email.
- **Main Navigation**: IndexedStack-based bottom navigation with Home, Transactions, Add, Budget, Reports, and Profile tabs.
- **Dashboard**: Shows the signed-in user header, finance summary cards, notification bell, and current monthly budget section.
- **Transactions**: Streams and displays all user transactions with local type filters and search.
- **Add Transaction**: Adds income or expense transactions to Firestore.
- **Transaction Details**: Shows transaction fields and provides edit/delete actions.
- **Edit Transaction**: Updates an existing transaction document.
- **Budget**: Shows monthly budget, live expense progress, remaining amount, and set/edit/delete controls.
- **Reports**: Placeholder screen for future reports and analytics.
- **Profile**: Placeholder screen for future profile settings.
- **Notifications**: Lists user notifications, unread state, mark-all-read, delete, and clear-all actions.

## Project Structure

```text
lib/
  core/
    assets/
    navigation/
    routes/
    theme/
    utils/
    widgets/
  features/
    auth/
      data/
      presentation/
      widgets/
    budget/
      data/
      presentation/
    dashboard/
      data/
      presentation/
      widgets/
    notifications/
      data/
      presentation/
    profile/
      presentation/
    reports/
      presentation/
    splash/
      presentation/
  firebase_options.dart
  main.dart
```

### Folder Roles

- `lib/main.dart`: Initializes Firebase and starts the Material app with named routes.
- `lib/firebase_options.dart`: FlutterFire-generated Firebase options for supported platforms.
- `lib/core/assets/`: Central asset path constants.
- `lib/core/navigation/`: Main bottom navigation wrapper.
- `lib/core/routes/`: App route constants and route registrations.
- `lib/core/theme/`: App colors, text styles, and theme configuration.
- `lib/core/utils/`: Shared utility code.
- `lib/core/widgets/`: Reusable UI widgets.
- `lib/features/auth/`: Firebase Auth, user profile creation, login, register, and password reset.
- `lib/features/dashboard/`: Dashboard, transaction model/service, add/edit/details/list screens, and finance cards.
- `lib/features/budget/`: Monthly budget model, Firestore service, and budget UI.
- `lib/features/notifications/`: Notification model, Firestore service, and notifications UI.
- `lib/features/reports/`: Reports placeholder screen.
- `lib/features/profile/`: Profile placeholder screen.
- `lib/features/splash/`: Splash screen and auth-state routing.

## Firestore Structure

The app uses user-scoped Firestore data.

```text
users/{uid}
users/{uid}/transactions/{transactionId}
users/{uid}/notifications/{notificationId}
users/{uid}/budgets/{budgetId}
```

### `users/{uid}`

Important fields:

- `uid`
- `fullName`
- `email`
- `createdAt`
- `updatedAt`

### `users/{uid}/transactions/{transactionId}`

Important fields:

- `id`
- `title`
- `amount`
- `type`: `income` or `expense`
- `category`
- `note`
- `paymentMethod`
- `createdAt`
- `updatedAt`

### `users/{uid}/notifications/{notificationId}`

Important fields:

- `id`
- `title`
- `message`
- `type`
- `isRead`
- `createdAt`

Notification types currently created include transaction add/update/delete and budget set/update/delete events.

### `users/{uid}/budgets/{budgetId}`

Budget document ids use the month key format when created by the app:

```text
users/{uid}/budgets/{YYYY-MM}
```

Important fields:

- `id`
- `monthKey`
- `amount`
- `spent`
- `remaining`
- `createdAt`
- `updatedAt`

Budget UI calculates live monthly spending from expense transactions in the selected month. Stored `spent` and `remaining` are written when setting/updating a budget, but the displayed progress is based on the transaction stream.

## Firebase Setup

1. Create a Firebase project.
2. Enable Email/Password Authentication.
3. Create a Cloud Firestore database.
4. Add Android Firebase config:

   ```text
   android/app/google-services.json
   ```

5. Add or refresh `lib/firebase_options.dart` with FlutterFire CLI if needed:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

6. Keep Firebase client configuration files local to your project setup and do not expose private server keys or service account credentials.

Note: `lib/firebase_options.dart` exists, but `lib/main.dart` currently calls `Firebase.initializeApp()` without `DefaultFirebaseOptions.currentPlatform`.

## Firestore Rules

Example user-scoped rules:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /notifications/{notificationId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /budgets/{budgetId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

Review and harden rules before production use.

## Firestore Indexes

Firestore may require composite indexes for some queries.

The monthly budget spent calculation queries transactions with:

- `type == expense`
- `createdAt >= start of month`
- `createdAt < start of next month`

If Firestore reports a missing index, use the Firebase Console error link to create the required index.

## Installation

```bash
git clone <repo-url>
cd masrofy
flutter pub get
```

## Running

```bash
flutter run
flutter run -d chrome
```

## Build

```bash
flutter build apk --release
flutter build appbundle --release
```

## Testing

```bash
flutter analyze
flutter test
```

## Git Workflow

```bash
git checkout -b feature/your-feature
git add .
git commit -m "Your commit message"
git push -u origin feature/your-feature
```

## Known Notes / Limitations

- Reports and Profile are currently placeholders.
- Firebase config must be set up locally for the target platforms.
- `firebase_options.dart` exists, but app initialization currently uses bare `Firebase.initializeApp()`.
- Firestore indexes may be required for transaction filtering used by budget calculations.
- The UI is still under development.
- Android package id currently uses `com.example.masrofy`.
- The asset folder is named `assetes/` in the repository and `pubspec.yaml`.
- Tests are currently limited.

## Roadmap

- Reports and charts
- Profile settings
- Categories management
- Budget alerts
- Arabic/English localization
- Dark mode
- Better tests
- Responsive tablet/web UI

## License

No explicit license file is currently included.
