
# Implementing WireGuard Handshake Failure

### `vpnHandshakeFailureDetected()`

`vpnHandshakeFailureDetected()` is a critical callback in the `WGPacketTunnelProvider` class. It is triggered when the WireGuard VPN tunnel fails to complete a handshake, even though the VPN is still marked as "connected." This method is essential for detecting and responding to underlying connection issues in real time.

### Declaration

```swift
override func vpnHandshakeFailureDetected()
```

### Description

This method provides a structured mechanism to handle handshake failure scenarios. A handshake is the process by which the client and server verify and establish a secure connection. A failure in this process could mean the VPN tunnel is non-functional, even though the system considers it connected.

### Common Scenarios That Trigger This Method

* **Account-related issues:**

  * VPN account has reached data cap.
  * Account is suspended or deactivated.
* **Network issues:**

  * Device has no internet access.
* **Server-related issues:**

  * VPN server is down or unreachable.
  * Intermediate network disruptions between client and server.

### Example Usage

```swift
override func vpnHandshakeFailureDetected() {
    self.getLastHandshake { [weak self] lastHandshakeDate, networkStatus in
        guard let self = self else { return }

        if networkStatus {
            // Handshake failed despite having internet. Take corrective action.
            // Recommended: Disconnect the tunnel, trigger reconnect, or notify user
            // self.cancelTunnelWithError(...)
        } else {
            // No internet – likely a temporary connectivity issue.
            // Recommended: Wait for reconnection or allow retry mechanism
        }
    }
}
```

### Related APIs

#### `getLastHandshake(completion:)`

Retrieves:

* The timestamp of the last successful WireGuard handshake.
* The current internet connectivity status.

**Recommendation:**

* If a significant delay has passed since the last successful handshake **and** internet is available, the client may consider the tunnel **stalled**.

  * Based on product or security requirements, the client can choose to:

    * Disconnect the VPN tunnel.
    * Attempt a limited reconnect.
    * Notify the user or take other corrective actions.
* If internet is **not available**, do not reconnect. Allow the system to restore connectivity and let the tunnel retry automatically.

#### `cancelTunnelWithError(_:)`

Cancels the VPN tunnel, optionally providing a specific error reason to inform system logs or user-facing diagnostics.
