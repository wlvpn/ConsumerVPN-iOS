# Metadata - getCollection: Method

Description
The getCollection: method is a part of the metadata property within the apiManager instance. It is designed to retrieve a collection of data asynchronously. This method utilizes a block-based approach to handle the results of the data retrieval operation.

Parameters
result: A dictionary containing key-value pairs of string data, representing the collection retrieved. This parameter is nullable.

error: An NSError object indicating any error that occurred during the data retrieval process. This parameter is nullable.

```objc
    [apiManager.metadata getCollection:^(NSDictionary<NSString *,NSString *> * _Nullable result, NSError * _Nullable error) {
        
    }];
```

# Metadata - updateCollection: Method

Description
The updateCollection:completion: method is a part of the current class and facilitates the update of a collection of data. It operates asynchronously, using a block-based approach to handle the results of the update operation.

Parameters
values: A dictionary containing the data to be used for updating the collection.

completion: A block that is executed upon completion of the update operation, providing the updated collection as a dictionary and any encountered errors. This block takes two parameters: result, a dictionary with string keys and values representing the updated collection, and error, an NSError object indicating any error that occurred during the update process.

```objc
    [apiManager.metadata updateCollection:(nonnull NSDictionary *) completion:^(NSDictionary<NSString *,NSString *> * _Nullable result, NSError * _Nullable error) {
        
    }];
```

# Metadata - clearCollection: Method

Description
The clearCollection: method is a part of the current class and is designed to clear or delete an entire collection of data. This method operates asynchronously and employs a block-based approach to handle the results of the clear operation.

Parameters
completion: A block that is executed upon completion of the clear operation, providing any encountered errors. This block takes one parameter: error, an NSError object indicating any error that occurred during the clear process.

```objc
    [apiManager.metadata clearCollection:^(NSError * _Nullable error) {
        
    }];
```


# Using Metadata.
* You must be logged in as a user before using metadata 
* A maximum of five sets of metadata can be stored per user

Methods:

Get all associated metadata for currently logged in user
```objc
[apiManager.metadata getCollection:^(NSDictionary<NSString *,NSString *> * _Nullable result, NSError * _Nullable error) {
    if (error != nil) {
        // Handle the error
    } else {
        // Process the result dictionary
    }
}];
```


Update all associated metadata for currently logged in user
```objc

[apiManager.metadata updateCollection:updateValues completion:^(NSDictionary<NSString *, NSString *> * _Nullable result, NSError * _Nullable error) {
    if (error != nil) {
        // Handle the error
    } else {
        // Process the updated collection in the result dictionary
    }
}];
```


Clear all associated metadata for currently logged in user
```objc

[apiManager.metadata clearCollection:^(NSError * _Nullable error) {
    if (error != nil) {
        // Handle the error
    } else {
        // Clear operation completed successfully
    }
}];
```


# MetaError Enumeration

Description
The MetaError enumeration defines a set of errors related to meta-service operations. It conforms to the NSError protocol, making it suitable for representing errors in error-handling scenarios.

MetaErrors
error(statusCode: Int, description: String): Represents an error with a specific HTTP status code and a descriptive message.

unexpectedResponse: Indicates an unexpected or malformed response from the meta-service.

requestFailed: Represents a general failure in making a request to the meta-service.

invalidURL: Indicates an issue with the formation or validity of the URL used for the meta-service operation.

metaserviceNotAvailable: Represents an error when the meta-service is not available.

#HTTP status Codes

400    
A problem with the structure of the request or it didn't comply with the limitations of the endpoint. For example, adding more than five keys.

401    
Bearer token invalid

403    
Bearer token expired

500    
Internal server error


Example error handling

```swift
        if ([exception.domain isEqualToString:MetaServiceErrorDomain]) {
            switch (exception.code) {
                case MetaErrorCodeErrorWithStatusCode: {
                    NSInteger statusCode = [[exception.userInfo objectForKey:@"statusCode"] integerValue];
                    NSString *description = [exception.userInfo objectForKey:@"description"];
                    // Handle MetaErrorCodeErrorWithStatusCode. See HTTP Status Codes
                    break;
                }
                case MetaErrorCodeUnexpectedResponse:
                    // Handle MetaErrorCodeUnexpectedResponse
                    break;
                case MetaErrorCodeRequestFailed:
                    // Handle MetaErrorCodeRequestFailed
                    break;
                case MetaErrorCodeInvalidURL:
                    // Handle MetaErrorCodeInvalidURL
                    break;
                case MetaErrorCodeMetaserviceNotAvailable:
                    // Handle MetaErrorCodeMetaserviceNotAvailable
                    break;
                default:
                    // Handle other errors
                    break;
            }
        }
```
