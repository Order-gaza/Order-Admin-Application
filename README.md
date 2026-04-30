# Customer Application - Order Platform

## Overview
The Customer Application is a cross-platform mobile client built with Flutter, providing users with a seamless and intuitive shopping experience. It interfaces directly with the central PHP backend to deliver real-time product catalogs, cart management, and order tracking functionalities.

## Key Features
* **Product Catalog:** Browse and search through items from various regional vendors with dynamic image loading via `cached_network_image` and clean UI state handling via `shimmer`.
* **Cart & Checkout System:** Robust cart management that strictly validates against real-time vendor availability and regional coverage before allowing checkout.
* **Order Tracking:** Real-time visibility into order status, tracking the progression from placement through admin confirmation and final delivery.
* **Interactive UI:** Features such as rating bars, smooth page indicators, and responsive layouts designed for modern mobile displays.
* **User Authentication:** Secure user registration, login, and profile management utilizing tokenized sessions with `flutter_secure_storage`.
* **Push Notifications:** Immediate alerts for order status changes powered by Firebase Cloud Messaging and local notifications.

## Technology Stack
* **Framework:** Flutter / Dart
* **State Management:** GetX
* **Storage:** GetStorage, SharedPreferences, Flutter Secure Storage
* **Network Integration:** `http` package for robust API communication
* **Target Platforms:** Android, iOS

## Getting Started

### Prerequisites
* Flutter SDK (Targeting `^3.6.0`)
* Dart SDK
* Android Studio or Xcode for platform-specific compilation
* Valid Firebase Configuration for push notifications

### Installation
1. Clone the repository:
   ```bash
   git clone [repository_url]
   ```
2. Navigate to the project directory:
   ```bash
   cd order_app
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## Architecture & Security Posture
* Production builds adhere to secure coding practices, including code obfuscation and root/jailbreak detection mechanisms.
* API interactions are secured via authenticated tokens to ensure data integrity and user privacy. Ensure API endpoints align correctly with the backend's RBAC system.
