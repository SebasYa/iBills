# iBills - Invoice Management

<div align="center">
  <img src="https://github.com/SebasYa/iBills/blob/main/iBills/Assets.xcassets/AppIcon.appiconset/IVA.png" alt="App Icon" width="300">
</div>

<div align="center">

![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white&style=flat)
![SwiftUI](https://img.shields.io/badge/SwiftUI-000000?style=for-the-badge&logo=swift&logoColor=white&style=flat)
![Xcode](https://img.shields.io/badge/Xcode-1575F9?style=for-the-badge&logo=xcode&logoColor=white&style=flat)
![Charts](https://img.shields.io/badge/Charts-00BFFF?style=for-the-badge&style=flat)
![SwiftData](https://img.shields.io/badge/Swift%20Data-FF5C5C?style=for-the-badge&logo=swift&logoColor=white&style=flat)

</div>

## Overview

iBills is a modern iOS invoice management app built with **SwiftUI** and **SwiftData**, focused on tracking invoices and automatically breaking down **VAT (IVA in Argentina)**.

The app helps users register invoices, organize them by year and month, analyze **VAT Credit vs VAT Debit**, and visualize yearly tax movement through interactive charts. It is designed as a **local-first** experience, with on-device persistence and biometric/device authentication for a more realistic finance-oriented workflow.

<img src="https://github.com/SebasYa/iBills/blob/main/iBillGif.gif" alt="App Demo" width="260"/> <img src="https://github.com/SebasYa/iBills/blob/main/iBillsGif2.gif" alt="App Demo" width="270"/>

## Why This Project

This project was built to showcase:

- A complete **end-to-end iOS app** experience
- Clean architecture with **Model / View / ViewModel / Service**
- Real-world usage of **SwiftData** for local persistence
- Financial data handling with automatic **VAT and net amount calculation**
- Interactive data visualization with **Apple Charts**
- Secure access using **LocalAuthentication**
- Strong UX details such as empty states, search, grouping, confirmations, and bulk deletion flows

## Features

- **Invoice Management**: Add and delete invoices with a streamlined mobile workflow.
- **Automatic VAT Breakdown**: Calculate net amount and VAT from the total invoice amount.
- **VAT Tracking**: Separate and visualize **VAT Credit** and **VAT Debit**.
- **Yearly VAT Balancing**: Check whether the selected year results in VAT payable or a favorable technical balance.
- **Interactive Charts**: Explore VAT movement over time with yearly interactive charts.
- **Grouped History**: Browse invoices organized by **year** and **month**.
- **Search Support**: Filter invoices by **business name** or **invoice number**.
- **Bulk Deletion**: Remove a single invoice, a full month, or an entire year with confirmation dialogs.
- **Biometric / Device Authentication**: Protect access using Face ID, Touch ID, or device passcode.
- **SwiftData Integration**: Store all invoice data locally on-device.
- **Polished SwiftUI Interface**: Custom tab bar, card-based layout, and focused navigation across screens.

## Main Screens

### Home
The main screen for day-to-day usage. Users can add invoices, browse grouped history, search records, and manage deletion flows.

### Balance
Displays yearly VAT totals, including:

- VAT Credit
- VAT Debit
- Net VAT Balance
- Invoice count
- Purchases vs sales count
- Average VAT
- Net taxable base by category

### Graphs
Provides interactive yearly visualization for:

- VAT Credit
- VAT Debit
- VAT Balance

Users can inspect daily points and view a summary of the selected period, including latest accumulated value, peak value, and number of movement days.

### Authentication
The app opens behind local authentication, making the experience feel more aligned with a finance/productivity app handling sensitive information.

## Architecture

The project follows a clean separation of responsibilities using a SwiftUI + MVVM-style structure with dedicated service layers for business logic, persistence, analytics, and authentication.

### Project Structure

```text
iBills/
├── Model/
├── Service/
├── View/
│   ├── Home/
│   ├── Balance/
│   └── Graph/
└── ViewModel/
```


## Supported VAT Rates

The app currently supports:

- `27%`
- `21%`
- `10.5%`

## Tech Stack

- **Swift 5**
- **SwiftUI**
- **SwiftData**
- **Charts**
- **LocalAuthentication**
- **Xcode 16+**
- **iOS 18.0+**

## Requirements

- **Xcode**: 16 or later
- **iOS**: 18.0 or later
- A simulator or physical device compatible with iOS 18
- Biometrics or device passcode configured if you want to fully test authentication behavior

## Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/SebasYa/iBills.git


