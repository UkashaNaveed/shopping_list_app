# Shopping List App

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Realtime_Database-%23FFCA28.svg?logo=firebase&logoColor=black)](https://firebase.google.com/)

A reactive, lightweight shopping list manager built with Flutter and backed by Firebase Realtime Database via direct REST APIs.

---


https://github.com/user-attachments/assets/c58f88f6-79d9-4162-b491-6714f6c70a79


## Overview

Shopping List is a mobile application built to demonstrate clean asynchronous state handling, form validation, and cloud persistence in Flutter without heavy client SDKs. It interfaces directly with Firebase Realtime Database using standard HTTP operations (`GET`, `POST`, `DELETE`), pairing immediate user feedback via optimistic UI updates with automatic server rollback on failure.

## Features

- **Direct Cloud Persistence**: Synchronizes grocery items with Firebase Realtime Database via lightweight HTTP REST endpoints (`http` package).
- **Optimistic UI Updates**: Swipe-to-dismiss (`Dismissible`) removes items instantly from the UI, with automatic state restoration if the network request fails.
- **Form Validation & Categories**: Robust input checks for item names and quantities, paired with color-coded category tags (Produce, Dairy, Meat, Carbs, and more).
- **Resilient Error & Loading States**: Dedicated handling for empty database payloads (`"null"`), active network loading spinners, and friendly error notifications.
- **Material 3 Dark Theme**: Modern dark aesthetic configured with custom seed color palettes and Material 3 components.

## Architecture & Data Flow

```
┌──────────────────┐        HTTP REST        ┌─────────────────────────┐
│  Flutter Client  │ ─────────────────────>  │  Firebase Realtime DB   │
│                  │ <─────────────────────  │  (REST API / JSON)      │
│  - GroceryList   │   GET / POST / DELETE   │                         │
│  - NewItem Form  │                         │                         │
└──────────────────┘                         └─────────────────────────┘
```

The database structures items in JSON format at `/shopping-list.json`:

```json
{
  "-Nx123abc456": {
    "name": "Bananas",
    "quantity": 6,
    "category": "Fruit"
  }
}
```

## Prerequisites

Before running the project, make sure you have:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (v3.0.0 or higher recommended)
- [Dart SDK](https://dart.dev/get-dart)
- An active [Firebase Project](https://console.firebase.google.com/) with a Realtime Database instance

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/shopping_list_app.git
cd shopping_list_app
```

### 2. Install Dependencies

Fetch all packages specified in `pubspec.yaml`:

```bash
flutter pub get
```

### 3. Configure Firebase Realtime Database

> [!IMPORTANT]
> This application relies on direct HTTP endpoints to Firebase Realtime Database. Configure your own database host before launching.

1. Create a Firebase Realtime Database in the [Firebase Console](https://console.firebase.google.com/).
2. Update the Firebase URL hostname in `lib/widgets/grocery_list.dart` and `lib/widgets/new_item.dart`:

```dart
final url = Uri.https(
  'YOUR_DATABASE_NAME-default-rtdb.firebaseio.com',
  'shopping-list.json',
);
```

> [!TIP]
> For initial local testing, ensure your database rules allow read and write access:
>
> ```json
> {
>   "rules": {
>     ".read": true,
>     ".write": true
>   }
> }
> ```

### 4. Run the Application

Launch on an emulator or physical device:

```bash
flutter run
```

## Project Structure

```
lib/
├── data/
│   ├── categories.dart       # Category enum mapping and display colors
│   └── dummy_items.dart      # Mock item data for offline testing
├── models/
│   ├── category.dart         # Category model
│   └── grocery_item.dart     # Grocery item data model
├── widgets/
│   ├── grocery_list.dart     # Main view with async fetch & swipe-to-delete
│   └── new_item.dart         # Item entry form with validation
└── main.dart                 # App entrypoint and Material 3 dark theme setup
```
