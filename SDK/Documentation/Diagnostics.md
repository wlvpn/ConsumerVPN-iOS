# Diagnostics
## _How to extract Diagnostics in the application_

APIs listed below have been used to fetch VPNKit logs for diagnostics.

### Fetch Logs from SDK
```swift
func loadDiagnosticData() -> String? {
     guard let logPath = apiManager.logFile(),
           let content = try? String(contentsOfFile: logPath) else {
           return nil
    }
    
    return content
}
```

### Remove Logs from SDK
```swift
  apiManager.clearLogs()
```

### Set log level before share / export Diagnostics.
```swift
  apiManager.setLogLevel(level)
```

## Log Level

- Off - Remove clear logs.
- Normal - Logs upto error level.
- Advance - Logs upto debug level.

## Tech

VPNKit logging uses below project(s) to work properly:

- [CocoaLumberjack] - Fast & simple, yet powerful & flexible logging framework for macOS, iOS, tvOS and watchOS.

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [CocoaLumberjack]: <https://github.com/CocoaLumberjack/CocoaLumberjack>
