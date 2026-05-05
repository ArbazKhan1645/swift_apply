# SwiftApply 🚀 - The Ultimate Automated Job Application & Outreach Tool

[![Flutter](https://img.shields.io/badge/Flutter-v3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**SwiftApply** is a high-performance, open-source Flutter application designed to revolutionize how job seekers apply for positions. By combining intelligent clipboard detection with automated communication protocols, SwiftApply reduces the time spent on repetitive applications from minutes to seconds.

---

## 🌟 Key Features

### ⚡ Magic Fill (Clipboard Intelligence)
Stop manually copying and pasting! SwiftApply automatically detects job-related information (emails, phone numbers, company names, and roles) from your clipboard. Simply copy a job post or message, and watch the app populate the fields for you.

### 📧 Dual-Mode Outreach (SMTP & WhatsApp API)
Choose how you want to reach out to recruiters:
- **Direct SMTP Email:** Configure your professional email and send applications with attachments directly from the app.
- **WhatsApp Business API:** Integrated support for WhatsApp Cloud API for instant, automated outreach.
- **Native Fallback:** If credentials aren't set, the app intelligently falls back to native `mailto:` and `wa.me` launchers.

### 📁 CV Library & Management
Manage multiple versions of your CV. Select the most relevant resume for each job lead with a single tap. All files are managed locally for maximum privacy.

### 📊 Job Lead Tracker (Offline-First)
Built with an integrated SQLite database, SwiftApply allows you to save, filter, and track the status of every job lead. Never lose track of where you applied.

### 💎 Premium Glassmorphism UI
Experience a state-of-the-art interface featuring:
- **Elegant Dark Mode** with curated accent colors.
- **Glassmorphism effects** for a modern, sleek aesthetic.
- **Haptic Feedback** for a tactile, premium user experience.
- **Fluid Animations** for smooth navigation.

---

## 🛠 Tech Stack

- **Framework:** [Flutter](https://flutter.dev) (Android & iOS)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Routing:** [GoRouter](https://pub.dev/packages/go_router)
- **Local Database:** [sqflite](https://pub.dev/packages/sqflite)
- **Dependency Injection:** [Injectable](https://pub.dev/packages/injectable) & [GetIt](https://pub.dev/packages/get_it)
- **Communication:** [Mailer](https://pub.dev/packages/mailer) & [HTTP](https://pub.dev/packages/http)
- **Deep Linking:** Custom intent filters for LinkedIn and Indeed.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.22 or higher)
- Android Studio / VS Code
- A valid SMTP or WhatsApp API setup (Optional for fallback mode)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/ArbazKhan1645/swift_apply.git
   ```
2. Navigate to the project directory:
   ```bash
   cd swift_apply
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run code generation:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. Run the app:
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👤 Author

**Arbaz Mashwani**
- **GitHub:** [@ArbazKhan1645](https://github.com/ArbazKhan1645)
- **Email:** [mashwnaikhan192@gmail.com](mailto:mashwnaikhan192@gmail.com)
- **LinkedIn:** [Arbaz Mashwani](https://www.linkedin.com/in/arbaz-mashwani)

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 🌠 Support the Project

If you find this project helpful, please give it a ⭐ on GitHub! It helps more people discover the tool and supports my open-source journey.

#Flutter #OpenSource #JobAutomation #WhatsAppAPI #SoftwareDevelopment #MobileApp #Dart #SwiftApply
