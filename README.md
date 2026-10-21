# Order Management System - Admin Application

## Overview
The Admin Application is a cross-platform mobile client built with Flutter, designed for system administrators and vendors to manage the end-to-end operations of the platform. It provides a comprehensive dashboard for order fulfillment, inventory management, and regional branch coordination.

## Key Features
* **Order Pipeline Management:** Strict enforcement of the order workflow, ensuring orders follow the correct lifecycle sequence (Admin Confirmation to Vendor Acceptance).
* **Regional Routing:** System capabilities for routing orders based on regional branch coverage and zones.
* **Vendor Status Control:** Automated availability toggling based on configured business hours, alongside manual override capabilities for dynamic operational control.
* **Inventory Management:** Full CRUD operations for product catalogs, including comprehensive image handling, utilizing the `image_picker` and caching mechanisms.
* **Real-time Analytics:** Integrated dashboard charts utilizing `fl_chart` for visual operational insights.
* **Secure Authentication:** Role-based access control ensuring data isolation and secure access to administrative API endpoints. Push notifications handled via Firebase Cloud Messaging.

## Technology Stack
* **Framework:** Flutter / Dart
* **State Management:** Riverpod
* **Storage & Caching:** GetStorage, SharedPreferences, Flutter Secure Storage
* **Network & API Integration:** `http` package with secure authentication headers
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
   cd order_admin
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## Development Guidelines
* Maintain strict type safety across all Data Transfer Objects (DTOs) and API payloads.
* Ensure all state changes reflect correctly in the UI, utilizing Riverpod's reactive principles, particularly for order status transitions and vendor availability toggles.
