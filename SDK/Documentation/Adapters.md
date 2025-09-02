# Adapters
There are two types of adapters in VPNKit: Connection Adapters and API Adapters.
An API Adapter is used to connect to an API. The only adapter you will need to worry about is the V3APIAdapter. This connects to the current version of the VPN backend and will handle retrieval of API resources. 
A Connection Adapter is used to connect to specific VPN protocols. The main adapter usable on iOS, macOS and tvOS is the `NEVPNManagerAdapter`. This adapter interfaces with the Apple provided NEVPNManager interface, to provide system supported VPN connections.

# Connection Adapter
  A ConnectionAdapter must be allowed to receive options from the owning application.
  `(id)initWithOptions:(NSDictionary *)options;`
    parameter: options - A dictionary containing configuration parameters to customize the adapter’s behavior. Keys and values are expected to be defined by the owning application.
        Supported keys: 
            kIKEv2Encryption: AES128 or AES256 (default: AES256). On tvOS, AES256GCM is always enforced regardless of the input.
            kIKEv2IntegrityAlgorithm: SHA256, SHA384, or SHA512 (default: SHA256).
            kIKEv2DiffieHellmanGroup: Must be Group 14 or higher (default: Group 14).
        Security Notes:
            DH groups below 14 (e.g., Group 2) are no longer supported on iOS 26+.
            SHA1-based algorithms (SHA1-96, SHA1-160) are not supported.
            DES and 3DES are not used by the SDK under any conditions.
            All default settings are compliant with Apple’s IKEv2 security requirements as of iOS 26 and macOS 15.
        
Refer to: [Initializers](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Initializers.md)

## Properties
 1. `connectedDate`: NSDate - Set when the VPN is connected else nil.
 2. `statusHandler`: VPNStatusHandler - Allows the Adapter to report connection status and changes to `VPNAPIManager`.
