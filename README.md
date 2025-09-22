# Matrimony Flutter App

## Overview
The Matrimony Flutter App is a mobile application designed to facilitate connections between users in a matrimony setting. It includes features for user registration, login, viewing user profiles, liking users, and managing user activities.

## Features
- **User Registration**: Users can create an account by providing their details.
- **User Login**: Existing users can log in to their accounts.
- **User Dashboard**: A dashboard that displays a list of users with their photos and names.
- **User Details**: View detailed information about a selected user.
- **Liking List**: A feature to view users that the current user has liked.
- **Activity Management**: Users can view their activities within the app.

## Project Structure
```
matrimony_flutter_app
├── lib
│   ├── main.dart
│   ├── models
│   │   ├── user.dart
│   │   ├── role.dart
│   │   ├── activity.dart
│   │   └── liking.dart
│   ├── screens
│   │   ├── login_screen.dart
│   │   ├── registration_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── user_detail_screen.dart
│   │   ├── liking_list_screen.dart
│   │   └── activity_screen.dart
│   ├── widgets
│   │   ├── user_photo_card.dart
│   │   └── user_list_item.dart
│   ├── services
│   │   ├── auth_service.dart
│   │   ├── user_service.dart
│   │   ├── liking_service.dart
│   │   └── activity_service.dart
│   └── utils
│       └── constants.dart
├── pubspec.yaml
└── README.md
```

## Setup Instructions
1. Clone the repository to your local machine.
2. Navigate to the project directory.
3. Run `flutter pub get` to install the necessary dependencies.
4. Use `flutter run` to start the application on your device or emulator.

## Technologies Used
- Flutter
- Dart

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.