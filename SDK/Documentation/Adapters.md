# Adapters
There are two types of adapters in VPNKit: Connection Adapters and API Adapters.
An API Adapter is used to connect to an API. The only adapter you will need to worry about is the V3APIAdapter. This connects to the current version of the VPN backend and will handle retrieval of API resources. 
A Connection Adapter is used to connect to specific VPN protocols. The main adapter usable on iOS, macOS and tvOS is the `NEVPNManagerAdapter`. This adapter interfaces with the Apple provided NEVPNManager interface, to provide system supported VPN connections.

# Connection Adapter
  A ConnectionAdapter must be allowed to receive options from the owning application.
  `(id)initWithOptions:(NSDictionary *)options;`
    parameter: options - A bunch of options

## Properties
 1. `connectedDate`: NSDate - Set when the VPN is connected else nil.
 2. `statusHandler`: VPNStatusHandler - Allows the Adapter to report connection status and changes to `VPNAPIManager`.
