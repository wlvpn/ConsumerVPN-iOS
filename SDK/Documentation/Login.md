# Required for login

## The VPNAPIManager 
   The `VPNAPIManager` is the central object responsible for the SDK. It does the job of coordination between the API adapter, the Connection Adapters and the client application.
   A objc class that holds the configuration of a VPN connection.
   Build a `VPNAPIManager` object for various API and Connection Adapter settings.
 - `brandName`: The brand name of this client
 - `configName`: The VPN configuration name of this client
 - `apiKey`: The api key provided on WLVPN signup
 - `suffix`: The username suffix provided on WLVPN Signup

## The VPNConfiguration
  This class manages the state of the VPN configuration and API state for the app. You can set/get the current user, account, country, city, server, etc.... You can also set VPN connection options such as on-demand etc...
 > Refer: [VPNConfiguration](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/VPNConfiguration.md)
  

## API methods


  1. **`(void)loginWithRetryForUsername:(NSString *_Nonnull)username password:(NSString *_Nonnull)password;`**     
    We use this function after signup, due to revenue cat web hook issue.
    This function will login with the provided username and password.
    When the function starts, it will immediately send a **VPNLoginWillBeginNotification** notification.
    If any error occurs, this function will post a  **VPNLoginFailedNotification** notification with the object set to an NSError.
    If login succeeds, this function will post a **VPNLoginSucceededNotification** notification with the object set to the new Account.
    Parameters:
     - `username`: The username of of the user to login
     - `password` The password of the user to login
     
 
  2. **`(void)loginWithUsername:(NSString * _Nonnull)username password:(NSString * _Nonnull)password;`**     
    This function will login with the provided username and password.
    When the function starts, it will immediately send a **VPNLoginWillBeginNotification** notification.
    If any error occurs, this function will post a **VPNLoginFailedNotification** notification with the object set to an NSError.
    If login succeeds, this function will post a **VPNLoginSucceededNotification** notification with the object set to the new Account.
    Parameters:
     - `username`: The username of of the user to login
     - `password` The password of the user to login
     

  3. **`(void)loginWithAccessToken:(NSString * _Nonnull)accessToken refeshToken:(NSString * _Nonnull)refreshToken;`**      
    This function will login with the provided access token and refresh token.
    When the function starts, it will immediately send a **VPNLoginWillBeginNotification** notification.
    If any error occurs, this function will post a **VPNLoginFailedNotification** notification with the object set to an NSError.
    If login succeeds, this function will post a **VPNLoginSucceededNotification** notification with the object set to the new Account.
    Parameters:
     - `accessToken` The access token provided by WLVPN representative.
     - `refreshToken` The refresh token provided by WLVPN representative.
    

4. **`(void)logout;`**  
    Logs out the current user and clears all stored information.
    
    

# Logout
   To logout the user, call the `logout()` method
   Logs out the current user and clears all stored information.
   When the function starts, it will immediately send a **VPNLogoutWillBeginNotification** notification.
   If any error occurs, this function will post a **VPNLogoutFailedNotification** notification with an NSError object.
   //check name of all notifications  name
   If logout succeeds, this function will post a **VPNLogoutSucceededNotification** notification.
  
```swift
apiManager.logout()
```

# Session Expired
If session expires, the **VPNLogoutSucceededNotification** notification will be posted with error code `VPNTokenExpiredError` or `VPNReauthenticationFailed`.

//**Token based authentication** - The SDK will send `VPNLogoutSucceededNotification` which has `VPNTokenExpiredError` error as an notification object when the authentication tokens are expired/invalidated. The implementer needs to re-authenticate the user.
//**Password based authentication** - Upon token invalidation/expiration, the SDK will attempt to re-authenticate the user using the saved email and password. If the authentication fails, will send `VPNLogoutSucceededNotification` notification which has `VPNReauthenticationFailed` error as an  notification object. The implementer needs to re-authenticate the user.

# Example implementation:

```swift
 LoginViewController: ViewController {
    
    //Call Login
    func login(username : String, password: String) {
        apiManager.login(withUsername: username, password: password)
    }
}

 LoginViewController: VPNAccountStatusReporting {
    //Listen to the Notification
    func statusLoginWillBegin(_ notification: Notification) {
        //Any update here
    }
    
    func statusLoginSucceeded(_ notification: Notification) {
        onLogin()
    }
    
     func statusAutomaticLoginSuceeded(_ notification: Notification) {
        onLogin()
    }
    
    func statusLoginFailed(_ notification: Notification) {
        //Handle error
    }
    
    func statusLogoutWillBegin(_ notification: Notification) {
        //Any update here
    }
    
    func statusLogoutSucceeded(_ notification: Notification) {
        //Any update here or handle the session expired error

        // When logout by SDK, check error for more detail
        if let error = notification.object as? NSError {
            // handle session expired or reauthentication failed error if any.
        }
        
    }
    
    func statusLogoutFailed(_ notification: Notification) {
        // Handle error
    }
    
    func statusAccountExpired(_ notification: Notification) {
        //Handle error
    }
    
    
    //Call refreshLocation on successful login
    func onLogin() {
        Task { @MainActor in
            let _ = try? await apiManager.refreshLocation()
            let _ = await apiManager.updateServerList()
            var error: Error?
            if apiManager.canSynchronizeConfiguration(&error) == true {
                apiManager.synchronizeConfiguration()
                // On success update
            }
        }
    }

```    



# Implementation notes:
    
 SDK performs an automatic login if the user was previously logged in and did not logged out. Please check **VPNAutomaticLoginSucceededNotification** notification
    
  **VPNAccountStatusReporting** notifications regarding Login can be found:
  > Refer: [Notifications](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Notifications.md)
   
  Errors based on error codes can be found:
  > Refer: [Errors](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Errors.md)
