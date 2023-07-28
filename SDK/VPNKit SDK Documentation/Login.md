# Required for login
## The VPNAPIManager 
   The VPNAPIManager is the central object responsible for the SDK. It does the job of coordination between the API adapter, the connection adapters and the client application.
   A objc class that holds the configuration of a VPN connection.
   Build a VPNAPIManager object for various api and connection adapter settings.
 - `brandName`: The brand name of this client
 - `configName`: The VPN configuration name of this client
 - `apiKey`: The api key provided on WLVPN signup
 - `suffix`: The username suffix provided on WLVPN Signup

## The VPNConfiguration
  This class manages the state of the VPN configuration and API state for the app. You can set/get the current user, account, country, city, server, etc.... you can also set VPN connection options such as on-demand.

## API methods

 1.`(void)loginWithRetryForUsername:(NSString *_Nonnull)username password:(NSString *_Nonnull)password;`
     We use this function after signup, due to revenue cat web hook issue.
     This function will login with retries to the current adapter with the provided username and password.
     When the function starts, it will immediately send a VPNAccountStatusReporting notification.
     If any error occurs, this function will post a statusLoginFailed notification with the object set to an NSError.
     If login succeeds, this function will post a statusloginSucceeded notification with the object set to the new Account.
     Parameters:
     - `username`: The username of of the user to login
     - `password` The password of the user to login
 
 2. `(void)loginWithUsername:(NSString * _Nonnull)username password:(NSString * _Nonnull)password;`
     This function will login to the current adapter with the provided username and password.
     When the function starts, it will immediately send a statusLoginWillBegin notification.
     If any error occurs, this function will post a statusLoginFailed notification with the object set to an NSError.
     If login succeeds, this function will post a statusloginSucceeded notification with the object set to the new Account.
     Parameters:
     - `username`: The username of of the user to login
     - `password` The password of the user to login

3. `(void)logout;`
     Logs the current user out and removes all their information from Core Data

```sh
   class AppDelegate: UIResponder, UIApplicationDelegate {
   var apiManager: VPNAPIManager!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Initialize the APIManager using helper Objc object.
        apiManager = SDKInitializer.initializeAPIManager(
            withBrandName: // brandname here,
            configName: //configNamehere,
            apiKey: // apikey here,
            andSuffix:// suffix here
        )
        if apiManager.vpnConfiguration.user == nil {
            //Login here with account and revenueCat details
            // Provide the revenueCatAPIKey, revenueCatConsoleDebugging, revenueCatProductIdentifiers = [""]
        }
     }
  }
```

# Logout
   To logout call the method `logout()`
   Logs the current user out and removes all their information from Core Data.
   When the function starts, it will immediately send a VPNAccountStatusReporting notification.
   If any error occurs, this function will post a statusLogoutFailed with the object set to an NSError.
   If logout succeeds, this function will post a statusLogoutSucceeded.
  
```
apiManager.logout()
```

