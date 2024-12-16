# StockItEasy - Inventory Management Application

**StockItEasy** is a Flutter-based inventory management application that leverages Firebase and Google APIs to provide an intuitive platform for managing stock, user accounts, and administrative tasks. The application is designed to streamline workflows and ensure efficient stock tracking, store management, and user account handling. Below, you'll find a comprehensive overview of the application, including its functionality, features, and the technologies used in both the frontend and backend.

---

## Features Overview

### Key Functionalities:
1. **Stock Management:**
   - Add, edit, and delete inventory items.
   - Track item quantities in real-time.
   - View activity history for inventory changes.

2. **User Authentication:**
   - Secure login and registration with Google OAuth using Firebase Authentication.
   - Firebase Firestore integration for user details.

3. **Store Management:**
   - Assign and display a unique store number for each user (read-only after initial setup).
   - Update and view personal account settings.

4. **Administrative Tools:**
   - Edit store number (only during initial account setup).
   - Manage employee schedules and privacy policies.
   - Integrated activity history logs for inventory and user actions.

5. **Customizable Settings:**
   - Change password via email.
   - Update personal information.
   - View and accept terms and conditions.

---

## Application Structure

### Authentication and Authorization
- **Google Login**: 
  - Implements **Firebase Authentication** with Google OAuth for secure and seamless login.
  - User account data is securely stored in **Firestore**.
- **Login Security**: Password resets and account verification features included.

### Inventory Management Features
- **Real-time Inventory Updates**: 
  - All inventory data is stored and synchronized using **Firebase Firestore**.
  - Admins can add, remove, or modify inventory items.
- **Activity History**: 
  - Tracks all changes made to inventory or schedules for audit purposes.
  - Displays changes per user for accountability.
  
### Account Settings
- **Personal Information**:
  - Users can update their display names and view store numbers.
  - Store numbers are immutable after the first setup to maintain data integrity.
- **Change Password**:
  - Secure password reset via Firebase Authentication’s email system.
- **Admin Tools**:
  - Manage employee schedules and assign store tasks.
  - View and update privacy policy compliance.
  
---

## Backend (Firebase)

The application utilizes **Firebase** as its backend service, with the following features integrated:

### Firebase Authentication
- Enables secure login and registration with **Google OAuth**.
- Handles email-based password reset functionality.

### Firebase Firestore
- Serves as the primary database for:
  - User profiles (name, email, store number).
  - Inventory items and their attributes (quantity, description, timestamps).
  - Logs for tracking user activity and inventory changes.
- Uses real-time listeners for dynamic UI updates when database entries change.

### Firebase Hosting (Optional)
- Capable of hosting backend APIs or admin-related services.

---

## Frontend (Flutter)

The frontend is built entirely in **Flutter**, ensuring a highly customizable and cross-platform UI for Android and iOS. Below are the primary pages and their functionalities:

### Home Page
- Displays a dashboard with quick links to key functionalities.
- Interactive buttons with hover effects enhance the user experience.

### Account Settings
- Allows users to:
  - Edit their personal information, such as names.
  - View their email and store number (store number is read-only after setup).
  - Change their account password via email.

#### Features:
- **Store Number Assignment**: A dialog ensures that the store number is assigned only once during initial setup.
- **Validation**: Prevents empty or duplicate names.

### Inventory Page
- Full CRUD (Create, Read, Update, Delete) functionality for managing stock items.
- Search and filter capabilities for inventory lookup.
- **Activity History**:
  - Displays a log of all inventory transactions.
  - Includes timestamps and user information for traceability.

### Privacy Policy and Terms
- Displays policies and collects user acceptance.
- Allows users to adjust privacy settings.

### Admin Tools
- **Schedule Management**:
  - Admins can register, view, and edit schedules for employees.
- **Notification System**:
  - Alerts admins about important tasks and reminders.

---

## Technologies Used

### Backend
1. **Firebase**:
   - Firestore (Real-time Database)
   - Firebase Authentication
   - Firebase Hosting (optional)
2. **Google API**:
   - OAuth for login.

### Frontend
1. **Flutter**:
   - Fully responsive design.
   - Interactive and dynamic UI with animations.
2. **Dart**:
   - Ensures smooth integration with Firebase.

### APIs and External Tools
1. **Google OAuth**:
   - Secure user authentication.
   - Streamlined login process with Google accounts.
2. **Firebase Firestore**:
   - Real-time database for all user and inventory data.
   - Stores logs for activity tracking.

---

## Installation Guide

### Prerequisites
- Install **Flutter SDK**: [Download Flutter](https://flutter.dev/docs/get-started/install)
- Create a **Firebase Project**: [Set up Firebase](https://firebase.google.com/docs)
- Enable the following services in Firebase:
  - Authentication (Google Sign-In).
  - Firestore Database.

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/stockiteasy.git
   cd stockiteasy
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective directories.
4. Run the app:
   ```bash
   flutter run
   ```

---


## Contribution Guidelines

We welcome contributions from the community! To contribute:
1. Fork the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add feature"
   ```
4. Push and submit a pull request.

---

## License

This project is licensed under the **MIT License**. See the `LICENSE` file for more information.

---

With **StockItEasy**, managing your store and inventory has never been easier!
