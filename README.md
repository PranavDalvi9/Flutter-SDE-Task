
# 🚀 Flutter SDE Task App

A Flutter application built as part of the **Flutter SDE Task**. The app includes authentication, a questionnaire, and a break timer screen with persistent state and Firebase integration.

---

## 📋 Table of Contents

- [Features](#-features)
- [App Flow](#-app-flow)
- [Tech Stack](#-tech-stack)
- [Screenshots](#-screenshots)
- [Requirements & Deliverables](#-requirements--deliverables)
- [Bonus](#-bonus)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [App Link](#-app-link)
- [License](#-license)

---

## ✨ Features

✅ **Login Screen**
- Firebase email/password authentication
- Form validation with optional referral code

✅ **Questionnaire Screen**
- Placeholder screen for user questions post-login
- State is saved using local storage

✅ **Break Screen**
- Reads break `start_time` and `duration` from Firebase Firestore
- Timer counts down with circular progress
- Option to end break early and save `actual_end_time`

✅ **Persistent Flow**
- Remembers the last screen and resumes from there on relaunch

✅ **Logout Support**
- Clear all local data and sign the user out

---

## 🔄 App Flow

1. App starts ➜ Checks login status and stored screen
2. If not logged in ➜ Navigates to **Login**
3. If logged in ➜ Navigates to last screen (e.g. **Questionnaire** or **Break**)
4. After login ➜ Saves and loads the next screen
5. Break timer runs and displays end time or finished message

---

## 🧰 Tech Stack

| Category          | Library/Tool             |
|------------------|--------------------------|
| UI Framework     | Flutter                  |
| Authentication   | Firebase Auth            |
| Database         | Firebase Firestore       |
| Local Storage    | SharedPreferences        |
| State Persistence| Custom LocalStorage class|
| Timer UI         | circular_percent_indicator |
| Date Formatting  | intl                     |

---

## 📸 Screenshots

> UI is designed according to [Figma Reference](https://www.figma.com/design/eGc0p6KWFxfsRMevyvtjE5/Interview?node-id=0-1&p=f&m=dev)

- Login Screen
- Questionnaire Screen
- Break Screen with countdown timer
- Break Ended View

---

## ✅ Requirements & Deliverables

| Requirement                                     | Status  |
|------------------------------------------------|---------|
| Pixel perfect, responsive UI                   | ✅ Done  |
| State management                               | ✅ Done  |
| Integration with backend (Firebase)            | ✅ Done  |
| State persistence on app relaunch              | ✅ Done  |
| Error handling (e.g. login failures)           | ✅ Done  |
| Clean code, modular structure                  | ✅ Done  |

---

## 🎯 Bonus

| Bonus Feature                  | Status        |
|-------------------------------|---------------|
| Android and iOS compatibility | ✅ Completed   |
| Flutter unit/widget tests     | ❌ Not implemented yet |

---

## 🏁 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-username/flutter-sde-task-app.git
cd flutter-sde-task-app
