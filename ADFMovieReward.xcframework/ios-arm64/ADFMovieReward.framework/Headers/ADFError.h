//
//  ADFError.h
//  ADFMovieReword
//
//  Created by Toru Furuya on 2017/02/21.
//  (c) 2017 ADFULLY Inc.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ADFErrorType) {
    ADFErrorTypeOutOfStock = 100,
    ADFErrorTypeNoAdnetwork = 101,
    ADFErrorTypeInvalidAppId = 102,
    ADFErrorTypeNetworkDisconnect = 103,
    ADFErrorTypeApiRequestFailure = 104,
    ADFErrorTypeAlreadyLoading = 105,
    ADFErrorTypeExceedFrequency = 106,
    ADFErrorTypeShortInterval = 107,
    ADFErrorTypeAdNotReady = 1000,
    ADFErrorTypeAlreadyPlaying = 1001,
    ADFErrorTypeInternalError = 1002
};

static inline NSString *ADFErrorMessage(ADFErrorType type) {
    switch (type) {
        case ADFErrorTypeOutOfStock:
            return @"Ad request failed due to no inventory returned from the ADNW.\n\n"
                   "- Please refer to the manual: https://github.com/glossom-dev/AdfurikunSDK-iOS/wiki/広告取得に失敗する場合\n"
                   "- Ask the Adfurikun team to check the inventory status.\n"
                   "- Implement a retry mechanism with a delay.";
        case ADFErrorTypeNoAdnetwork:
            return @"No available ADNW was configured for delivery.\n\n"
                   "- Please refer to the manual: https://github.com/glossom-dev/AdfurikunSDK-iOS/wiki/広告取得に失敗する場合";
        case ADFErrorTypeInvalidAppId:
            return @"Invalid App ID.\n\n"
                   "- Please check your implementation.";
        case ADFErrorTypeNetworkDisconnect:
            return @"Network connection is not available.\n\n"
                   "- Please check your network connection.";
        case ADFErrorTypeApiRequestFailure:
            return @"Failed to fetch delivery configuration.\n\n"
                   "- Please check the network connection on the device.";
        case ADFErrorTypeAlreadyLoading:
            return @"Ad loading is already in progress.\n\n"
                   "- Please check your implementation to ensure that a new load is triggered only after the success or failure callback is received.";
        case ADFErrorTypeExceedFrequency:
            return @"AppOpenAd frequency has been exceeded.\n\n"
                   "- Please try again after some time.";
        case ADFErrorTypeShortInterval:
            return @"AppOpenAd interval has not been reached.\n\n"
                   "- Please try again after some time.";
        case ADFErrorTypeAdNotReady:
            return @"Ad is not ready.\n\n"
                   "- Please play it after it is ready.";
        case ADFErrorTypeAlreadyPlaying:
            return @"Ad playing is already in progress.\n\n"
                   "- Please play the ad, it is not currently playing.";
        case ADFErrorTypeInternalError:
            return @"Internal error occurred.\n\n"
                   "- Please check AdNetworkError for more information.";
        default:
            return @"Unknown error.";
    }
}

@interface ADFError : NSObject

@property (nonatomic, readonly) ADFErrorType errorType;
@property (nonatomic, readonly) int errorCode;
@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, readonly, copy) NSString *appId;

- (instancetype)initWithErrorType:(ADFErrorType)type appID:(NSString *)appId;

@end

@interface AdnetworkError : NSObject

@property NSString *adnetworkKey;
@property NSInteger errorCode;
@property NSString *errorMessage;

- (instancetype)initWithKey:(NSString *)key code:(NSInteger)errorCode message:(NSString *)errorMessage;

@end

@interface ADFMovieError : ADFError

@end
