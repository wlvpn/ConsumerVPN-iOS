```markdown
## `Errors`

# Error codes:

## `VPNKitFrameworkUsageError: 1 - 99`
- VPNKitConfigurationError             = -1: A required configuration setting was not made.
- VPNKitParameterError                 = 10: A parameter passed to the function was not valid. (Either nil or no length)
- VPNKitVPNSetupError                  = 30: VPN Setup Failed. Some component of the setup process didn't work. NEVPNManager, Helper Tool, etc...
- VPNKitIKev2AuthenticationSetupError  = 31: IkEv2 VPN Setup Failed during server authentication
- VPNKitConnectionError                = 40: Generic Unknown connection error
- VPNKitConnectionFailedError          = 50: Generic Unknown connection error

## `VPNImportError: General Errors: 100 - 999`
- VPNTokenExpiredError                 = 403: Error on token login, Token refresh is needed
- VPNUnknownError                      = 900: Unknown Error
- VPNAPIKeyInvalidError                = 901: The provided API key is not valid
- VPNAPIMissingRequiredParameterError  = 902: Request is missing a required parameter
- VPNAPITooManyFailedAttemptsError     = 903: The user has attempted login too many times
- VPNDataImportError                   = 904: Data Import Error
- VPNCoreDataMappingError              = 905: VPNCoreDataMapper couldn't map the provided data
- VPNServersEmptyError                 = 906: The server list is empty
- VPNLoginInProgressError              = 907: Login is in progress Error
- VPNConnectionLostError               = 940: Connection Error
- VPNReachabilityError                 = 950: Connection Error

## `VPNKitLoginError: Login Errors 1000 - 1099`
- VPNLoginKeychainError                = 1010: Couldn't load the password from the keychain
- VPNLoginCredentialsError             = 1020: Invalid credentials on login
- VPNAccessTokenExpiredError           = 1021: Access token is expired
- VPNRefreshTokenExpired               = 1022: Refresh token is expired
- VPNLoginTooManyAttemptsError         = 1023: Invalid credentials on login
- VPNReauthenticationFailed            = 1024: User reauthentication failed
- VPNLoginInvalidUserError             = 1040: Invalid or Expired user account
- VPNKitLoginErrorDomainBlocked        = 1060: Used if the connection appears to be blocked; usually related to China, UAE or Turkey.
- VPNConnectionFailedNoInternet        = 1070: The user has no internet
- VPNLoginOAuthProvisionError          = 1080: The request could not provision OAuth

## `VPNKitServerErrorServer: Loading Errors 1100 - 1199`
- VPNKitServerLoadError                = 1121: Unable to load servers
- VPNKitServerUpdateInProgress         = 1122: Server udpate in progress

## `VPNKitLocationServiceError : Location Service Errors 1200 - 1300`
- VPNKitLocationServiceErrorAccessDenied = 1200: Unable to load service

## `VPNKitConfigurationRuntimeError: Run-time Configuration Errors 1300 - 1400`
- VPNConfigurationRuntimeErrorBase     = 1300: Generic configuration run-time error
- VPNUnverifiedEmailError              = 1301: Unverified email error
- VPNExpiredAccountError               = 1302: Expired account error
- VPNInvalidLoginError                 = 1303: Invalid login credentials error
- VPNConfigurationMissingCountryError  = 1304: Missing country error
- VPNConfigurationMissingCityError     = 1305: Missing city error
- VPNConfigurationMissingServerError   = 1306: Missing server error
- VPNConfigurationInvalidProtocolError = 1307: Invalid protocol error
- VPNInvalidFieldsError                = 1308: Invalid required fields
- VPNInternalServiceError              = 1309: Internal error (Wireguard service)
- VPNServerUnhealthyError              = 1310: Server unhealthy
- VPNInvalidServerError                = 1311: Invalid server
- VPNInactiveError                     = 1312: User Inactive error
- VPNMissingBearerTokenError           = 1313: Bearer token missing error
- VPNNoServerFoundError                = 1314: No servers found for location
- VPNNoEntryExitServerFoundError       = 1315: No servers found for entry and exit location
- VPNMultihopNotSupportError           = 1316: Multihop not supported error
- VPNPermissionDeniedError             = 1317: No Permission Error
- VPNUpdateNotAllowedError             = 1318: VPN update not allowed error
- VPNMultihopAPIVersionNotSupported    = 1319: Multihop API Version is not supported error 
- VPNMultihopNotAvailable              = 1320: Multihop API not available error
- VPNConfigurationRuntimeErrorMax      = 1400: Generic configuration run-time error

## `VPNKitAdapterError - Adapter Errors 5000`
- VPNKitInvalidAdapter                 = 5000: Invalid adapter
- VPNKitInvalidApiClient               = 5001: Invalid api client

## `VPNKitUserAccountValidationErrors: User Account Validation Errors 1500`
- VPNKitAccountErrorBase               = 1500: Invalid account
- VPNKitAccountCapReachedError         = 1500: Account Cap is Reached
- VPNKitAccountPausedError             = 1501: Account is Paused
- VPNKitAccountSuspendedError          = 1502: Account is Suspended
- VPNKitAccountClosedError             = 1503: Account is Closed
- VPNKitAccountPendingError            = 1504: Account is pending
- VPNKitAccountInvalidError            = 1510: Account is Invalid run-time error
```
