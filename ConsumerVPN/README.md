# ConsumerVPN for iOS

![Swift](https://img.shields.io/badge/swift-5.0-orange)
![Platform iOS](https://img.shields.io/badge/platform-iOS-lightgrey)
![Supports iOS](https://img.shields.io/badge/iOS-fat--binary-blue)
![Supports ARM](https://img.shields.io/badge/ARM-arm64-informational)
![XCFramework Included](https://img.shields.io/badge/XCFramework-included-success)
[![VPNKit 7.1.1](https://img.shields.io/badge/VPNKit-7.1.1-brightgreen)](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/README.md)

ConsumerVPN is a ready-to-brand application built with Swift and the WLVPN VPN SDK. It provides a foundation for your own VPN app and serves as a complete guide for integrating the WLVPN VPN SDK.(VPNKit).

## Table of Contents

1. [Prerequisites](#prerequisites)
    - i.[System Requirements](#system-requirements)
    - ii.[Getting Started](#getting-started)
    - iii. [Tools Required](#tools-required) 
2. [Setup Instructions](#2-setup-instructions)
    - i. [Download the Project](#i-download-the-project)
    - ii [Initialize Theme Submodule](#ii-initialize-theme-submodule)
3. [Adding the WLVPN SDK (VPNKit)](#3-adding-the-wlvpn-sdk-vpnkit)
4. [Info.plist](#4-infoplist)
5. [Setting Up Framework Search Paths](#5-setting-up-framework-search-paths)
6. [Setting Up Permissions](#6-setting-up-permissions-entitlements-and-capabilities)
7. [WireGuard Integration](#7-wireguard-integration)
8. [VPNKit Initializer](#8-vpnkit-initializer)
9. [Key Files](#9-key-files)
10. [Customizing Your App's Look](#10-customizing-your-apps-look-theme-integration)
11. [Support](#11-support)

## 1. Prerequisites

### System Requirements

- iOS device with iOS 13.0 or newer
- Currently, there is **no** support for simulators.

### Getting Started

To build this app, you’ll need below account-specific details and the VPNKit SDK folder, both provided by your WLVPN account manager. For assistance, contact **support@wlvpn.com**.

- Account Name  
- Auth Suffix  
- API Key    

### Tools Required

- [Xcode](https://developer.apple.com/xcode/) version 13 or newer   

## 2. Setup Instructions

### i. Download the Project

First, you need to get the project files onto your computer.

1.  Open the **Terminal** app on your Mac. You can find it by searching in Spotlight (Cmd + Space, then type "Terminal").
2.  Copy and paste the following lines into the Terminal, pressing **Enter** after each line:

    ```bash
    git clone https://github.com/wlvpn/ConsumerVPN-iOS.git
    cd consumervpn-ios
    ```
    *What this does:*
    * `git clone ...` downloads the entire ConsumerVPN project from the internet to your computer.
    * `cd consumervpn-ios` moves you into the newly downloaded project folder in Terminal.

### ii. Initialize Theme Submodule

This project uses a "Theme" submodule to control the look and feel of your app (colors, fonts, etc.). You need to get these theme files ready.

1.  In the same Terminal window, copy and paste these lines and press **Enter** after each:

    ```bash
    git submodule init
    git submodule update
    ```
    *What this does:* These commands download the necessary theme files into your project.

## 3. Adding the WLVPN SDK (VPNKit)

You will receive a folder named `VPNKit` from your WLVPN account manager. This folder contains files (called `.xcframework` files) that are essential for the VPN functionality.

**For iOS apps, you only need the `.xcframework` files found inside the `VPNKit/XCFramework` subfolder.**

### How to Add Them to Your Project:

1.  **Open your Xcode project:** Navigate to the `consumervpn-ios` folder you downloaded, and double-click the file `ConsumerVPN.xcodeproj`.
2.  **Drag and Drop:**
    * Locate the `VPNKit/XCFramework` folder you received from your WLVPN account manager.
    * **Drag** all the `.xcframework` files directly into the folder named **`SDK`** ,visible in the Xcode Project Navigator (the left-hand panel in Xcode).
    * When a prompt appears, make sure to check **"Copy items if needed"** and select your app target. This ensures the files are copied into your project.
3.  **Configure in Xcode:**
    * In Xcode, select your main app project in the Project Navigator (the very top item in the left panel).
    * Go to the **"General"** tab.
    * Scroll down to the section called **"Frameworks, Libraries, and Embedded Content."**
    * You should see the `.xcframework` files you just added listed here. If not, click the **"+" button** and add them manually.
    * For each of the listed frameworks, adjust the "Embed" setting as shown in the table below. This tells Xcode how to include these files in your app.

    Add the following frameworks and app extensions in the target’s **Frameworks, Libraries, and Embedded Content** section in Xcode:

    | Framework or Extension                 | Embed Setting          |
    |----------------------------------------|------------------------|
    | ConsumerVPNWGExtension.appex           | Embed Without Signing  |
    | NetworkExtension.framework             | Do Not Embed           |
    | VPKWireGuardAdapter.xcframework        | Embed & Sign           |
    | VPKWireGuardExtension.xcframework      | Embed & Sign           |
    | VPNKit.xcframework                     | Embed & Sign           |
    | VPNV3APIAdapter.xcframework            | Embed & Sign           |

## 4. Info.plist

The `Info.plist` file is like an ID card for your app. It holds important settings and information. This project uses a shared `Info.plist` file located in the `Theme` directory to maintain configuration consistency across brands or environments.

- `CFBundleIdentifier` – Typically set to `$(PRODUCT_BUNDLE_IDENTIFIER)` for dynamic substitution per target.
- `CFBundleShortVersionString` and `CFBundleVersion` – Read from `$(MARKETING_VERSION)` and `$(CURRENT_PROJECT_VERSION)` respectively to represent app version and build.
- `NSAppTransportSecurity` – Currently allows arbitrary loads and specific exceptions (e.g., `wlvpn.com`) for development or API support.
- `UIBackgroundModes` – Includes `fetch` and `processing` to support VPN background operations.
- `UIRequiredDeviceCapabilities` – Currently includes `armv7` to ensure compatible devices.
- `com.wireguard.ios.app_group_id` – Group ID used for sharing resources between main app and extensions (e.g., `group.com.wlvpn.ios.consumervpn`)

## 5. Setting Up Framework Search Paths

You need to tell Xcode where to find the important `.xcframework` files you just added.

1.  In Xcode, select your app target.
2.  Go to the **"Build Settings"** tab.
3.  Search for **"Framework Search Paths."**
4.  Double-click next to "Framework Search Paths" and click the **"+"** button.
5.  Add the following path to both the **Debug** and **Release** configurations:

    ```
    $(SRCROOT)/SDK
    ```

    Example:

    ```
    ~/consumervpn-ios/SDK
    ```
    *What this means:* This tells Xcode to look for necessary files in the `SDK` folder directly inside your project folder. For example, if your project is in `~/consumervpn-ios`, Xcode will look in `~/consumervpn-ios/SDK`.

## 6. Setting Up Permissions (Entitlements and Capabilities)

Your app needs permissions (called **Entitlements** and **Capabilities**) to use certain iOS features, like connecting to a VPN. You need to configure these in Xcode and make sure they match your Apple Developer account settings.

1.  In Xcode, select your **Target**.
2.  Go to the **"Signing & Capabilities"** tab.
3.  Add and configure the following capabilities by clicking the **"+"** button next to "Capabilities" if they are not already there:

| Capability                   | Purpose                                                   |
|------------------------------|-----------------------------------------------------------|
| Access Wi-Fi Information     | Enables access to network interfaces and conditions       |
| App Groups                   | Enables data sharing between the main app and extensions  |
| Network Extensions           | Enables custom VPN protocol support via Packet Tunnel     |
| Background Modes             | Enables background reconnections                          |

**Important Notes:**

* All **App Groups** and **Capabilities** you set here **must also be configured in your Apple Developer account** under "Identifiers."
* The permissions in your app's `Entitlements` file must perfectly match what's set up in your provisioning profile (which you manage in your Apple Developer account).

### Entitlements Configuration

Your app uses a file named `.entitlements` to declare these system permissions. Make sure the `ConsumerVPN.entitlements` file in your project (`ConsumerVPN/ConsumerVPN.entitlements`) includes these settings:

```xml
<key>com.apple.developer.networking.networkextension</key>
<array>
    <string>packet-tunnel-provider</string>
</array>
<key>com.apple.developer.networking.vpn.api</key>
<array>
    <string>allow-vpn</string>
</array>
<key>com.apple.developer.networking.wifi-info</key>
<true/>
<key>com.apple.security.application-groups</key>
<array>
    <string><app_group_id></string>
</array>
```

 *What this does:* These lines tell iOS exactly what your app is allowed to do, such as using network extensions for VPN and sharing data with its own extensions. Replace <app_group_id> with the actual ID you set up (e.g., group.com.wlvpn.ios.consumervpn).

To verify this: Check under "Signing and Capabilities > Entitlements" in Xcode for both your main app and any associated extension targets.

## 7. WireGuard Integration

The WireGuard, a modern VPN protocol, support is implemented using `NEPacketTunnelProvider`, which allows the app to manage its own VPN connection .
The project includes:
- A dedicated WireGuard adapter: `VPKWireGuardAdapter.xcframework`
- A WireGuard extension: `VPKWireGuardExtension.xcframework`
- The necessary entitlements and capabilities to support packet-level routing
The WireGuard extension is included as `ConsumerVPNWGExtension.appex` and needs to be properly set up within your app.

Refer: [WireGuard Integration](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Wireguard.md)

## 8. VPNKit Initializer

To get the VPN features working in your app, you'll need a class that handles the initial setup of `VPNKit`. `ConsumerVPN` have a class `SDKInitializer`.
This `SDKInitializer` class (or whatever you choose to name your own initialization class) is the dedicated and organized place where you initialize VPNKit and set up all the essential information it needs to operate.
It sets up everything required to make secure VPN connections.

Path: `ConsumerVPN/SDKInitializer`  
Refer: [Initializers](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Initializers.md)

## 9. Key Files

Import these in your bridging headers:

```swift
@import VPNKit;
@import VPNV3APIAdapter;
@import VPKWireGuardAdapter;
@import VPKWireGuardExtension;
```

## 10. Customizing Your App's Look (Theme Integration)

The **Theme** module is a [Git submodule](https://www.freecodecamp.org/news/how-to-use-git-submodules/) included in the **ConsumerVPN iOS** app. It allows multiple apps, including ConsumerVPN iOS, to share a single source of truth for theming, fonts, and brand styles without duplicating code. By using the Theme submodule, the ConsumerVPN iOS project can lock to a specific version (commit), ensuring consistent branding while allowing updates to be integrated when needed.   
After running `git submodule update`, perform the following steps:   
• Import shared theme resources (colors, fonts).   
• Link assets (images, styles) into the app target

Example:

```swift
self.view.backgroundColor = [ThemeColors primaryBackground];
self.label.font = [ThemeFonts headline];
```

Refer: [Theme Guide](https://github.com/wlvpn/consumervpn-ios-theme/blob/main/Theme%20Guide.md)

## 11. Support

For technical support please contact:  
📧 **support@wlvpn.com** 
