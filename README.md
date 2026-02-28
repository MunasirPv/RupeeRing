# RupeeRing 🔔
The 100% Free, Open-Source UPI Payment Soundbox

RupeeRing turns any Android device into a smart payment announcer. Designed for merchants, freelancers, and small business owners, it listens for incoming payment notifications from major UPI apps and announces the amount out loud—just like a physical soundbox, but without the subscription fees, hardware costs, or intrusive ads.

## ✨ Features
* **100% Free & Open Source:** No hidden charges, no premium tiers.
* **Zero Ads:** A clean, distraction-free interface built for fast-paced retail environments.
* **Universal UPI Support:** Works seamlessly with PhonePe, Google Pay, Paytm, BHIM, BharatPe, Navi, and other standard UPI apps.
* **Privacy First:** RupeeRing operates locally on your device. It only reads payment notifications to trigger the Text-to-Speech (TTS) engine and does not collect or transmit your financial data.
* **Customizable Alerts:** Adjust the volume, voice, and language (English, Hindi, Malayalam) of the announcements.
* **Local Transaction History:** Includes a filterable dashboard to browse the last 30-days of payments out-of-the-box.

## 🛠️ Tech Stack
* **Framework:** Flutter / Dart
* **Core Functionality:** Android NotificationListenerService & Shared Preferences Storage
* **Data Layer:** SQLite Database (sqflite)
* **Audio:** Native Text-to-Speech (TTS) implementation via flutter_tts

## 🚀 Getting Started
To build and run this project locally, ensure you have the Flutter SDK installed on your system.

### 1. Clone the repository
```bash
git clone https://github.com/MunasirPv/RupeeRing.git
```

### 2. Navigate to the project directory
```bash
cd RupeeRing
```

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Run the app
```bash
flutter run
```
