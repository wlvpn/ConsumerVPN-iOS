# Traffic counter for OpenVPN

- Data traffic can be accessed through notification `VPNNetworkMonitorUpdateNotification` at `statusNetworkMonitorUpdate` method
- Notifies the receiver about incoming and outgoing network data used. Includes a bandwidth object with this   information.
- `object` property holds type `VPNBandwidthModel`
-  User have to override `statusNetworkMonitorUpdate` method and accesss the data.
-  `Note`: 
    macOS app never suspends and they can access data traffic continuously. But in iOS if app is suspended no data traffic will be received

```
  #import <Foundation/Foundation.h>
 
   @interface VPNBandwidthModel : NSObject
   
      @property (strong) NSNumber *totalUpload;
      @property (strong) NSNumber *totalDownload;
      @property (strong) NSNumber *lastUpload;
      @property (strong) NSNumber *lastDownload;
   
  @end
```


```
extension ViewController :  VPNConnectionStatusReporting {
    func statusNetworkMonitorUpdate(notification: Notification) {
        var dataLastUploadSize: UInt = 0
        var dataLastDownloadSize: UInt = 0
        
        // We only need the last upload/download at this time
        guard let bandwidthModel = notification.object as? VPNBandwidthModel,
              let lastUpload = bandwidthModel.lastUpload?.uintValue,
              let lastDownload = bandwidthModel.lastDownload?.uintValue else { return }
        
        // get the lastUpload/download, totalUpload/download in string form
        let lastUploadString = convertBytesSizeToString(dataLastUploadSize)
        let lastDownloadString = convertBytesSizeToString(dataLastDownloadSize)
    }
}
```

Please refer: [Notifications](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Notifications.md)
