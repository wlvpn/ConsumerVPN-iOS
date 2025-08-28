# Handling WireGuard Handshake Updates

## Overview

This document provides guidance of how to manage the health of a WireGuard VPN connection. Its primary focus is on using the handshake update mechanism to detect underlying problems that may not be visible at the system level.

## `vpnHandshakeUpdateDetected(_ error: Error?)`

The `vpnHandshakeUpdateDetected(error: Error?)` method is a callback within the `WGPacketTunnelProvider` class. It is automatically invoked when the WireGuard tunnel fails or recover to complete a handshake, even though the VPN status may still appear as "connected." This function helps identify and address underlying connectivity problems in real time.

### Declaration

```swift
override func vpnHandshakeUpdateDetected(_ error: Error?)
```

### Description

This method provides a structured way to manage handshake update events. A handshake is the cryptographic process where the client and server authenticate each other to establish or re-establish a secure connection. A failure in this step indicates a potential issue with the VPN connection, despite its "connected" status in the system.

### Common Causes of Handshake Failure

This method can be triggered by several issues, including:

* **Account-Related Issues:**
    * The VPN account has exceeded its data limit.
    * The account has been suspended or deactivated.
* **Server-Related Issues:**
    * The VPN server is offline or unreachable.
    * The client's session was cleared by the server due to inactivity.
    * Network disruptions are occurring between the client and the server.
* **Network Issues:**
    * The device has lost its internet connection.

### Example Implementation

```swift
public override func vpnHandshakeUpdateDetected(_ error: Error?) {
    
    NSLog("[VPNKIT-NE] Internet Status: \(self.isInternetAvaialble) Last Handshake Date: \(self.lastHandshakeDate)")
    
    guard let nsError = error as NSError?,
        let handshakeError = HandshakeError.fromNSError(nsError) else {
         // All good, tunnel is having active connection
        NSLog("[VPNKIT-NE] All good!!!")
        return
    }
    
    NSLog("[VPNKIT-NE] HandshakeError: \(error)")
    
    switch handshakeError {
        case .failure:
            // The handshake failed even with an active internet connection.
            // This suggests a persistent issue with the server or account.
            //
            // Recommended Action: Disconnect the tunnel to prevent data leaks
            // and notify the user.
            // self.cancelTunnelWithError(...)
            break
    case .internetUnreachable:
            // The handshake failed because there is no internet connection.
            // This is likely a temporary issue.
            //
            // Recommended Action: Wait for the system's network service to
            // restore connectivity. The tunnel will attempt to reconnect automatically.
            break
    default:
            break
    }
}
```

---

### Related APIs

For robust error handling, consider using the following related methods:

#### `lastHandshakeDate` property
The date timestamp of the last successful WireGuard handshake.

#### `isInternetAvaialble` property
The current internet connectivity status (as a boolean).

#### `HandshakError` Enum

To handle handshake-related failures in a structured way, use the `HandshakeError.fromNSError(_:)` helper. This method maps the generic error passed to `vpnHandshakeUpdateDetected(_:)` into a well-defined `HandshakeError` enum. This makes it easier to write clean, maintainable logic for conditions like connectivity loss or account issues.

```swift
enum HandshakeError: Error {
    case failure                // 3000
    case internetUnreachable    // 3001
}
```

#### `cancelTunnelWithError(_:)`

This method terminates the VPN tunnel. You can optionally pass an `Error` object to provide specific details about the failure, which can be useful for logging and diagnostics.

**Recommendation:**

* If a significant amount of time has passed since the last handshake **and** the device has internet access, you can consider the tunnel **stalled**. Depending on your application's requirements, you might:
    * Disconnect the VPN tunnel immediately.
    * Attempt a limited number of reconnections.
    * Notify the user about the unstable connection.
* If there is **no internet access**, avoid manual reconnection attempts. Allow the operating system to manage network restoration, which will enable the tunnel to retry the handshake automatically.
* **Important:** Relying solely on the time since the last handshake to detect an unhealthy connection can lead to false positives. It is recommended to allow a considerable time window (e.g., 20 minutes) without a successful handshake before concluding that the connection is permanently stalled.
