## `Errors`

# Error codes:

## `VPNKitFrameworkUsageError: 1 - 99`
- VPNKitConfigurationError = -1: A required configuration setting was not made.
- VPNKitParameterError = 10: A parameter passed to the function was not valid. (Either nil or no length)
- VPNKitVPNSetupError = 30: VPN Setup Failed. Some component of the setup process didn't work. NEVPNManager, Helper Tool, etc...
- VPNKitConnectionError = 40: Generic Unknown connection error
- VPNKitConnectionFailedError = 50: Generic Unknown connection error
	

## `VPNImportError: General Errors: 900 - 999`
- VPNUnknownError = 900 : Unknown Error
- VPNAPIKeyInvalidError = 901: The provided API key is not valid
- VPNAPIMissingRequiredParameterError = 902: Request is missing a required parameter
- VPNAPITooManyFailedAttemptsError = 903: The user has attempted login too many times
- VPNDataImportError = 904
- VPNCoreDataMappingError = 905: VPNCoreDataMapper couldn't map the provided data
- VPNServersEmptyError = 906: The server list is empty
- VPNConnectionLostError = 940: Connection Error
- VPNReachabilityError = 950: Connection Error


## `VPNKitLoginError: Login Errors 1000 - 1099`
- VPNLoginKeychainError = 1010: Couldn't load the password from the keychain
- VPNLoginCredentialsError = 1020: Invalid credentials on login
- VPNAccessTokenExpiredError = 1021: Access token is expired
- VPNRefreshTokenExpired = 1022: Refresh token is expired
- VPNLoginTooManyAttemptsError = 1023: Invalid credentials on login
- VPNLoginInvalidUserError = 1040: Invalid or Expired user account
- VPNKitLoginErrorDomainBlocked = 1060: Used if the connection appears to be blocked; usually related to China, UAE or Turkey.
- VPNConnectionFailedNoInternet = 1070: The user has no internet 
- VPNLoginOAuthProvisionError = 1080: The request could not provision OAuth


# `VPNKitServerErrorServer: Loading Errors 1100 - 1199`
- VPNKitServerLoadError = 1121: Unable to load servers


# `VPNKitLocationServiceError : Location Service Errors 1200 - 1300`
- VPNKitLocationServiceErrorAccessDenied = 1200: Unable to load service


# `VPNKitConfigurationRuntimeError: Run-time Configuration Errors 1300 - 1400`
- VPNConfigurationRuntimeErrorBase = 1300: Generic configuration run-time error
- VPNUnverifiedEmailError = 1301: Unverified email error
- VPNExpiredAccountError = 1302: Expired account error
- VPNInvalidLoginError = 1303: Invalid login credentials error
- VPNConfigurationMissingCountryError = 1304: Missing country error
- VPNConfigurationMissingCityError = 1305: Missing city error
- VPNConfigurationMissingServerError = 1306: Missing server error
- VPNConfigurationInvalidProtocolError = 1307: Invalid protocol error
- VPNInvalidFieldsError = 1308: Invalid required fields
- VPNInternalServiceError = 1309: Internal error (Wireguard service)
- VPNServerUnhealthyError = 1310: Server unhealthy
- VPNInvalidServerError = 1311: Invalid server
- VPNConfigurationRuntimeErrorMax = 1400: Generic configuration run-time error


# `VPNKitAdapterError - Adapter Errors 5000`
-  VPNKitInvalidAdapter = 5000: Invalid adapter
-  VPNKitInvalidApiClient = 5001: Invalid api client
