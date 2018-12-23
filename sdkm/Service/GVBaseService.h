//
//  GVBaseService.h
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

//NS_ASSUME_NONNULL_BEGIN

@interface GVBaseService: NSObject

+ (instancetype)shared;

- (void)requestGetWithURL:(NSString *)url
                   atPath:(NSString *)path
               withParams:(NSDictionary *)params
             withResponse:(void(^)(BOOL success,id res))block;

- (void)requestPostWithURL:(NSString *)url
                    atPath:(NSString *)path
                withParams:(NSDictionary *)params
              withResponse:(void(^)(BOOL success,id res))block;

- (void)requestPostURL:(NSString *)url
                atPath:(NSString *)path
               headers:(NSDictionary *)headers
                params:(NSDictionary *)params
          withResponse:(void(^)(BOOL success,id res))block;

- (void)requestDeleteWithURL:(NSString *)url
                      atPath:(NSString *)path
                  withParams:(NSDictionary *)params
                withResponse:(void(^)(BOOL success,id res))block;

- (void)requestPutWithURL:(NSString *)url
                   atPath:(NSString *)path
               withParams:(NSDictionary *)params
             withResponse:(void(^)(BOOL success,id res))block;

@end

//NS_ASSUME_NONNULL_END
