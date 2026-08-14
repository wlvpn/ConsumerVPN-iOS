# Handling WireGuard/OpenVPN Handshake Updates

## Overview

This document provides guidance of how to manage the health of a WireGuard/OpenVPN VPN connection. Its primary focus is on using the handshake update mechanism to detect underlying problems that may not be visible at the system level.

## `vpnHandshakeUpdateDetected(_ error: Error?)`

The `vpnHandshakeUpdateDetected(error: Error?)` method is a callback within the `WGPacketTunnelProvider` class. It is automatically invoked when the WireGuard/OpenVPN tunnel fails or recover to complete a handshake, even though the VPN status may still appear as "connected." This function helps identify and address underlying connectivity problems in real time.

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
* **Network Path Changes:**
    * The device roamed between networks (Wi-Fi ↔ cellular, SSID change).
    * The device woke from sleep with a stale session.
    * Repeated handshake timeouts suggest the port may be blocked.
* **Captive Portal:**
    * The current network requires HTTP sign-in (e.g. hotel/airport Wi-Fi) and is intercepting traffic before it can reach the VPN server.
* **Tunnel Cancelled (OpenVPN only):**
    * The tunnel was stopped externally by the OS, another process, or another extension — for example, another VPN was activated, the user toggled the VPN configuration in Settings, or the system terminated the extension after an unrecoverable error. By the time this is surfaced, the SDK has already invoked `cancelTunnelWithError(...)` on the provider — the tunnel itself is going down.

### Example Implementation

```swift
public override func vpnHandshakeUpdateDetected(_ error: Error?) {
    
    NSLog("[VPNKIT-NE] Internet Status: \(self.isInternetAvailable) Last Handshake Date: \(self.lastHandshakeDate)")
    
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
    case .roaming:
            // Handshake failed shortly after a network path change.
            //
            // Recommended Action: Wait briefly — the tunnel typically recovers
            // once the new path stabilizes. Avoid disconnecting.
            //
            // Note: by default the SDK debounces `.roaming` to one
            // notification per roam episode (`notifyRoamingOnce = true`). Set
            // `self.notifyRoamingOnce = false` if your UI / telemetry needs
            // an event on every retry inside the post-roam window.
            break
    case .staleSession:
            // Handshake failed after wake from sleep / long idle.
            //
            // Recommended Action: Trigger a reconnect to refresh the session.
            break
    case .handshakeTimeout:
            // Repeated handshake failures with no path change and no prior success.
            //
            // Recommended Action: Notify the user that the port may be
            // blocked and suggest switching protocol or network.
            break
    case .tunnelCancelled(let reason):
            // OpenVPN TCP only. The tunnel was already cancelled externally — the
            // SDK has invoked `cancelTunnelWithError(...)` on the provider just
            // before this notification fires. `reason` is the raw log line
            // (e.g. "Tunnel stopped externally: Optional(OpenVPNError.linkError)")
            // and is intended for logging / diagnostics, not parsing.
            NSLog("[VPNKIT-NE] tunnelCancelled reason: \(reason)")
            //
            // Recommended Action: This notification is informational and
            // intended for logging or user notification purposes only. When
            // Connect-On-Demand is enabled, the VPN will reconnect automatically
            // once internet connectivity is restored. When Connect-On-Demand is
            // disabled, this cancellation is expected and the VPN will remain
            // disconnected. No `disconnect()` call is required.
    case .captivePortalLikely:
            // Repeated handshake failures after a network path change while the
            // OS still reports the network as reachable — the new network most
            // likely requires HTTP sign-in (captive portal). Reconnect attempts
            // have been paused inside the extension to avoid burning cycles
            // against an unreachable server.
            //
            // Recommended Action: If `isKillSwitchEnabled` is true
            // (`includeAllNetworks = true`), the user cannot reach the captive
            // portal *through* the tunnel — the iOS captive sign-in sheet is
            // also blocked. Call `disconnect()` so the SDK clears the kill
            // switch (`includeAllNetworks = false`) and tears the tunnel down.
            // iOS will then present its captive sign-in sheet; once the user
            // signs in, the app can reconnect the VPN with the kill switch
            // re-enabled.
            //
            // If the kill switch is OFF, no app intervention is strictly
            // required: iOS shows the captive sheet automatically and the SDK
            // auto-resumes reconnects on the next satisfiable `NWPathMonitor`
            // update. Because that update can fire on benign blips (signal
            // strength fluctuation, ARP refresh), the SDK may try one or two
            // reconnects against the still-captive portal before re-pausing.
            //
            // If you want tighter control over recovery, the app can probe
            // `http://captive.apple.com/hotspot-detect.html` from the *app*
            // target after receiving `.captivePortalLikely` — a 200 response
            // whose body contains "Success" indicates an open network. The
            // app can then trigger an explicit reconnect (e.g.
            // `apiManager.connect()`); otherwise it can keep the
            // "Sign in to network" UI displayed.
            // The probe must be plain HTTP (port 80) — captive portals can't
            // intercept HTTPS — which requires an `NSAppTransportSecurity`
            // exception for `captive.apple.com` in the *app* target's
            // `Info.plist`.
            if self.isKillSwitchEnabled {
                #if os(macOS)
                self.disconnect { error in
                    // Optional: surface error / log
                }
                #elseif os(iOS) || os (tvOS)
                // App target needs to call `apiManager.disconnect()`
                #endif
            }
    default:
            break
    }
}
```

---

### Related APIs

For robust error handling, consider using the following related methods:

#### `lastHandshakeDate` property
The date timestamp of the last successful WireGuard/OpenVPN handshake.

#### `isInternetAvailable` property
The current internet connectivity status (as a boolean). Derived directly
from the adapter's live `NWPath.Status` at read time — no cached flag, so
the value always reflects the actual path state and cannot become stale
during a race with the next path update. Returns `true` strictly when the
live path status is `.satisfied`; treats `.unsatisfied`,
`.requiresConnection`, and the pre-monitor-start window as `false`-ish
(with a default-optimistic `true` only until the very first path update
arrives).

#### `notifyRoamingOnce` property
Controls how aggressively `.roaming` events are surfaced to
`vpnHandshakeUpdateDetected(_:)`. Default `true` — the SDK emits **one**
`.roaming` notification per roam episode (boundary = successful handshake,
fresh network path change, or tunnel start/stop). Set to `false` to
receive a `.roaming` notification on every handshake retry inside the
post-roam window. Useful for diagnostics, telemetry, or aggressive
recovery UI; default behaviour treats `.roaming` as the informational
transient it is by contract.

#### `isOnDemandEnabled` property
The current Connect-On-Demand status (as a boolean).

#### `isKillSwitchEnabled` property
The current kill switch status (as a boolean), reflecting the
`includeAllNetworks` flag from the active tunnel protocol configuration.
When `true`, all device traffic is forced through the tunnel and cannot
bypass it — including iOS's own captive-portal sign-in probes.

#### `disconnect(completion:)` method (macOS only)
Tears down the VPN tunnel and resets the configuration so that
`includeAllNetworks` and `isOnDemandEnabled` are both cleared on the
underlying `NETunnelProviderManager`. This method lives on the network
extension subclass (`OVPacketTunnelProvider` / `WGPacketTunnelProvider`)
and is intended to be called as `self.disconnect { ... }` from inside
`vpnHandshakeUpdateDetected(_:)` on **macOS only** — where the system-
extension model reliably allows the extension to load and save its own
manager preferences.

On **iOS and tvOS**, the extension should not mutate manager preferences
during a tear-down. Instead, signal the app target (e.g. via a flag in
the shared App-Group `UserDefaults`, the SDK's last-error file, or by
observing `NEVPNStatusDidChange`), and have the app call its own
disconnect API (such as `apiManager.disconnect()` from the VPNKit
`VPNAPIManager`). That API clears `isOnDemandEnabled` / `includeAllNetworks`
from the app process where it is fully supported.

Use this for captive portal recovery on both platforms:
- `captivePortalLikely` when `isKillSwitchEnabled` is `true` — otherwise iOS's captive sign-in sheet stays blocked.

#### `HandshakError` Enum

To handle handshake-related failures in a structured way, use the `HandshakeError.fromNSError(_:)` helper. This method maps the generic error passed to `vpnHandshakeUpdateDetected(_:)` into a well-defined `HandshakeError` enum. This makes it easier to write clean, maintainable logic for conditions like connectivity loss or account issues.

```swift
enum HandshakeError: Error {
    case failure                // 3000
    case internetUnreachable    // 3001
    case roaming                // 3002
    case staleSession           // 3003
    case handshakeTimeout       // 3004
    case tunnelCancelled        // 3005
    case captivePortalLikely    // 3006
}
```

#### `cancelTunnelWithError(_:)`

This method terminates the VPN tunnel. You can optionally pass an `Error` object to provide specific details about the failure, which can be useful for logging and diagnostics.

**Recommendation:**

* If a significant amount of time has passed since the last handshake **and** the device has internet access, you can consider the tunnel **stalled**. Depending on your application's requirements, you might:
    * Disconnect the VPN tunnel immediately.
    * Attempt a limited number of reconnections.
    * Notify the user about the unstable connection.
* If there is **no internet access**, avoid manual reconnection attempts. Allow the operating system to manage network restoration, which will enable the tunnel to retry the handshake automatically. The `isInternetAvailable` property is read directly from the adapter's live `NWPath.Status`, so it is safe to use as the authoritative "do we have internet right now?" signal at any point — including from inside `vpnHandshakeUpdateDetected(_:)`.
* For **`.roaming`** classifications, the SDK debounces by default to one notification per roam episode. Flip `notifyRoamingOnce = false` on the provider if your app needs an event on every handshake retry inside the post-roam window (telemetry, support-session diagnostics, aggressive recovery UI).
* If the tunnel was **cancelled** (`HandshakeError.tunnelCancelled`, currently emitted by OpenVPN TCP only), the underlying tunnel is already going down — the SDK invoked `cancelTunnelWithError(...)` just before delivering this notification. This notification is informational and intended for logging or user notification purposes only. When Connect-On-Demand is enabled, the VPN will reconnect automatically once internet connectivity is restored. When Connect-On-Demand is disabled, this cancellation is expected and the VPN will remain disconnected. No `disconnect()` call is required. The `reason` string carried with the case is the raw log line and is intended only for logging.
* If **captive portal is likely** (`HandshakeError.captivePortalLikely`), check the `isKillSwitchEnabled` property. If it is `true`, the manager configuration's `includeAllNetworks` flag must be cleared so iOS can present its captive sign-in sheet. **On macOS**, call `self.disconnect { ... }` from `vpnHandshakeUpdateDetected(_:)`. **On iOS / tvOS**, signal the app target and have it call its own disconnect API (e.g. `apiManager.disconnect()`). If the kill switch is off, no action is strictly required — the SDK auto-resumes reconnects on the next satisfiable path update once the user signs in to the network. For tighter recovery control (kill switch off), the app can probe `http://captive.apple.com/hotspot-detect.html` from the **app target** after receiving the notification — a 200 response with body containing "Success" indicates the portal has been cleared, at which point the app can trigger an explicit reconnect; otherwise the app can keep its "Sign in to network" UI displayed. The probe is HTTP (port 80) so the app target needs an `NSAppTransportSecurity` exception for `captive.apple.com`. The SDK debounces the `captivePortalLikely` notification (one per captive episode) and pauses internal reconnect attempts to avoid burning cycles while the portal is in front of the VPN server.
* **Important:** Relying solely on the time since the last handshake to detect an unhealthy connection can lead to false positives. It is recommended to allow a considerable time window (e.g., 20 minutes) without a successful handshake before concluding that the connection is permanently stalled.
