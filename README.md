Task Management:

Users can create, edit, delete, and view tasks with the following fields: title, description, due date, and priority (low, medium, high). Tasks must be stored in Firebase or another backend. Additionally, users can mark tasks as complete or incomplete.

Task Filtering:

Implement filtering for tasks by priority and status (completed/incomplete). Display tasks in a list format, sorted by due date from earliest to latest.

## Task Management App

A Flutter task management app for gig workers utilizing Clean Architecture and BLoC state management.

## Features
- **User Authentication**: Register and log in using Firebase Authentication (email/password) with error handling.
- **Task Management**: Create, edit, delete, and view tasks with fields: title, description, due date, and priority (low, medium, high).
- **Task Completion**: Mark tasks as complete/incomplete.
- **Task Filtering**: Filter tasks by priority and status (completed/incomplete).
- **Sorting**: Display tasks in a list sorted by due date (earliest to latest).
- **UI**: Built with Material Design, responsive for iOS & Android.

## Setup Instructions

### Prerequisites
Ensure the following are installed:
- [Flutter](https://flutter.dev/docs/get-started/install) (latest stable version)
- [Dart](https://dart.dev/get-dart)
- [Firebase CLI](https://firebase.google.com/docs/cli) (for setup)
- Code editor (e.g., [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio))

### Step 1: Clone the Repository
```sh
git clone https://github.com/AmarChaudhar/taskmanagement
cd taskmanagement
```

### Step 2: Install Dependencies
```sh
flutter pub get
```

### Step 3: Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Add an **Android App** and **iOS App**.
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in:
   - `android/app/` for `google-services.json`
   - `ios/Runner/` for `GoogleService-Info.plist`
4. Enable **Firebase Authentication**:
   - Go to **Authentication** > **Sign-in method** and enable **Email/Password Authentication**.
5. Enable **Cloud Firestore**:
   - Go to **Firestore Database**, click **Create Database**, and select **Start in test mode** (adjust security rules later).

### Step 4: Run the App
```sh
flutter run
```

### Folder Structure
```
lib/
│── main.dart
│── model/
│   ├── task model 
│── authentication/
│   ├── auth bloc 
│── repository/
│   ├── auth repository
│── screens/
│   ├── blocs/
│   ├── screens/
│   ├── widgets/
```

### Environment Variables
Create a `.env` file in the root directory to add any Firebase-related API keys if needed.

### Troubleshooting
- If Firebase is not working, run:
  ```sh
  flutterfire configure
  ```
- Ensure **Firestore** and **Authentication** are enabled in the Firebase Console.

### License
This project is licensed under the MIT License.

Dependencies:
  firebase_core: ^3.2.0
  firebase_auth: ^5.1.2
  cloud_firestore: ^5.1.0
  firebase_database: ^11.0.3
  firebase_storage: ^12.1.1
  cloud_functions: ^5.0.3
  firebase_analytics: ^11.2.0
  flutter_bloc: ^8.1.3 # Latest stable version
  equatable: ^2.0.5 # Compatible version
  intl: ^0.20.2
