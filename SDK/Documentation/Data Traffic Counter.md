# Data Traffic counter

- Data traffic can be accessed through `VPNNetworkMonitorUpdateNotification` notification at `statusNetworkMonitorUpdate` handler method.
- Notifies the receiver about incoming and outgoing network data used. Includes a bandwidth notification object with this information.
- `object` property holds type `VPNBandwidthModel`
-  User has to implement `statusNetworkMonitorUpdate` method and accesss the data.
-  `Note`: 
    macOS app never suspends and they can access data traffic continuously. But in iOS if app is suspended no data traffic will be provided.

### Properties

```markdown
- totalUpload               : NSNumber - This property holds the total amount of data uploaded over the network. It is likely a cumulative count representing all the data uploaded since a certain point in time or since the application started tracking this data.
- totalDownload             : NSNumber - This property holds the total amount of data downloaded over the network. Similar to `totalUpload`, it represents a cumulative count of all the data downloaded.
- lastUpload                : NSNumber - This property holds the amount of data uploaded in the most recent measurement period. This could be a snapshot of the latest upload activity, possibly in bytes or another unit of data.
- lastDownload              : NSNumber - This property holds the amount of data downloaded in the most recent measurement period. Like `lastUpload`, it represents the latest download activity.
- lastUploadPerSecond       : NSNumber - This property represents the rate of data uploaded per second during the most recent measurement period. It provides an indication of the upload speed or bandwidth usage.
- lastDownloadPerSecond     : NSNumber - This property represents the rate of data downloaded per second during the most recent measurement period. It provides an indication of the download speed or bandwidth usage.
```

### Summary

- **`totalUpload` and `totalDownload`**: Cumulative amounts of uploaded and downloaded data.
- **`lastUpload` and `lastDownload`**: Amounts of data uploaded and downloaded during the most recent measurement period.
- **`lastUploadPerSecond` and `lastDownloadPerSecond`**: Upload and download rates measured in data per second during the most recent measurement period.

These properties together provide a comprehensive overview of network usage, allowing for both cumulative and real-time analysis of data transfer rates and volumes.

Please check below example implementation:

```swift
extension ViewController : VPNConnectionStatusReporting {
    func statusNetworkMonitorUpdate(notification: Notification) {
        // We only need the last upload/download at this time
        guard let bandwidthModel = notification.object as? VPNBandwidthModel,
              let lastUpload = bandwidthModel.lastUpload?.uintValue,
              let lastDownload = bandwidthModel.lastDownload?.uintValue,
              let lastUploadPerSecond = bandwidthModel.lastUploadPerSecond?.uintValue,
              let lastDownloadPerSecond = bandwidthModel.lastDownloadPerSecond?.uintValue else { return }
        
        // get the lastUpload/download, totalUpload/download in string form
        let lastUploadString = convertBytesSizeToString(lastUpload)
        let lastDownloadString = convertBytesSizeToString(lastDownload)
        debugprint("\(lastDownloadString)")
    }
}
```

> Refer: [Notifications](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Notifications.md)
