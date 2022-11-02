# ConsumerVPN for VPNKit 6

Please see the ConsumerVPN Client Readme document to get started.

## What's New:
- Added `kVPNManagerConfigurationNameKey` key at connectionOptions, which value will be VPN configuration name.
- Added `VPNDemandConfiguration` at `VPNConfiguration` to handle VPN On Demand settings.
- Added unregister notifications on view disappear.
- Added VPNAPIManager `cleanup()` call while application terminates.
- Rename `kStayConnectedOnQuit` to `kVPNStayConnectedOnQuit` which ensure that connections are not killed off when the app dies during an active connection.
- Rename `installHelperAndConnectOnInstall()` method to `synchronizeConfiguration()`, which responsible to updates VPN configuration.
- Replace `login()` API with `loginWithRetry()` after purchase success.
