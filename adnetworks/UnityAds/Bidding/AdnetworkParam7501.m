//
//  AdnetworkParam7501.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2026/03/03.
//  Copyright © 2026 GREE X, Inc. All rights reserved.
//

#import "AdnetworkParam7501.h"
#include <CommonCrypto/CommonDigest.h>

@implementation AdnetworkParam7501

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        NSDictionary *content = [param objectForKey:@"content"];
        if (content && [content isKindOfClass:[NSDictionary class]]) {
            NSDictionary *adValues = [content objectForKey:@"ad_values"];
            if (adValues && [adValues isKindOfClass:[NSDictionary class]]) {
                NSString *adm = [adValues objectForKey:@"adm"];
                if ([self isString:adm]) {
                    self.adm = [NSString stringWithFormat:@"%@", adm];
                }
                NSString *contentId = [param objectForKey:@"content_id"];
                if ([self isString:contentId] && contentId.length > 0) {
                    self.objectId = [self createObjectId:contentId];
                }

                [self commonParamParse:adValues];
            }
        }
    }
    return self;
}

- (NSString * _Nullable)createObjectId:(NSString *)contentId {
    NSData *data = [contentId dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    // 同一contentIdの場合は、同一のobjectIdが生成される
    // SHA256の先頭32文字をUUID形式(8-4-4-4-12)に変換する
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
            digest[0],  digest[1],  digest[2],  digest[3],
            digest[4],  digest[5],
            digest[6],  digest[7],
            digest[8],  digest[9],
            digest[10], digest[11], digest[12], digest[13], digest[14], digest[15]];
}

- (bool)isValid {
    return (self.gameId && self.placementId && self.adm && self.objectId);
}

@end
