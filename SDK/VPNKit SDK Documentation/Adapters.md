# Adapters
There are two types of adapters in VPNKit: Connection adapters and API adapters.
An API adapter is used to connect to an API. The only adapter you will need to worry about is the V3APIAdapter. This connects to the current version of the VPN backend and will handle retrieval of API resources. A connection adapter is used to connect to specific VPN protocols. The main adapter usable on macOS and iOS is the NEVPNManagerAdapter. This adapter interfaces with the Apple provided NEVPNManager interface to provide system supported VPN connections.

# NEVPNManagerAdapter:
  A ConnectionAdapter must be allowed to receive options from the owning application.
`- (id)initWithOptions:(NSDictionary *)options;`
    parameter: options - A bunch of options
# Connection Adapter
  A ConnectionAdapter must be allowed to receive options from the owning application.
  `(id)initWithOptions:(NSDictionary *)options;`
    parameter: options - A bunch of options

## Properties
 1. `connectedDate`: NSDate - Stores when the VPN is connected. NSDate if connected, nil if disconnected.
 2. `statusHandler`: VPNStatusHandler - Allows the Adapter to report connection status and changes to VPNAPIManager.
