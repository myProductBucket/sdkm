//
//  GVBaseService.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVBaseService.h"

@interface GVBaseService() {
    
}

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation GVBaseService

+ (instancetype)shared{
    static GVBaseService *shared;
    if (!shared) {
        shared = [[GVBaseService alloc] init];
        NSURL *baseUrl = [NSURL URLWithString:GV_BASE_URL];
        shared.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
        shared.manager.requestSerializer  = [AFHTTPRequestSerializer serializer];
        shared.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return shared;
}

- (void)requestGetWithURL:(NSString *)url
                   atPath:(NSString *)path
               withParams:(NSDictionary *)params
             withResponse:(void(^)(BOOL success,id res))block
{
    
    [[GVBaseService shared].manager GET:[NSString stringWithFormat:@"%@%@", url, path] parameters:params headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(YES, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(NO, error);
    }];
}

- (void)requestPostWithURL:(NSString *)url
                    atPath:(NSString *)path
                withParams:(NSDictionary *)params
              withResponse:(void(^)(BOOL success,id res))block
{
    [[GVBaseService shared].manager POST:[NSString stringWithFormat:@"%@%@", url, path] parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(YES, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(NO, error);
    }];
}

- (void)requestPostURL:(NSString *)url
                atPath:(NSString *)path
               headers:(NSDictionary *)headers
                params:(NSDictionary *)params
          withResponse:(void(^)(BOOL success,id res))block
{
    
    [[GVBaseService shared].manager POST:[NSString stringWithFormat:@"%@%@", url, path] parameters:params headers:headers progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(YES, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(NO, error);
    }];
    
//    NSError *serializationError = nil;
//
//    NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url, path] relativeToURL:self.manager.baseURL] absoluteString] parameters:params error:&serializationError];
//
//    for (NSString *key in headers.allKeys) {
//        [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
//    }
//
//    if (serializationError) {
//        if (block) {
//            dispatch_async(self.manager.completionQueue ?: dispatch_get_main_queue(), ^{
//                block(NO, serializationError);
//            });
//        }
//    }
//
//    __block NSURLSessionDataTask *dataTask = nil;
//    dataTask = [self.manager dataTaskWithRequest:request
//                                  uploadProgress:nil
//                                downloadProgress:nil
//                               completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
//                                   if (error) {
//                                       if (block) {
//                                           block(NO, error);
//                                       }
//                                   } else {
//                                       if (block) {
//                                           block(YES, responseObject);
//                                       }
//                                   }
//                               }];
//    [dataTask resume];
}

- (void)requestDeleteWithURL:(NSString *)url
                      atPath:(NSString *)path
                  withParams:(NSDictionary *)params
                withResponse:(void(^)(BOOL success,id res))block
{
    [[GVBaseService shared].manager DELETE:[NSString stringWithFormat:@"%@%@", url, path] parameters:params headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(YES, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(NO, error);
    }];
    
}

- (void)requestPutWithURL:(NSString *)url
                   atPath:(NSString *)path
               withParams:(NSDictionary *)params
             withResponse:(void(^)(BOOL success,id res))block
{
    [[GVBaseService shared].manager DELETE:[NSString stringWithFormat:@"%@%@", url, path] parameters:params headers:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(YES, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(NO, error);
    }];    
}

@end
