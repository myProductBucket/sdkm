//
//  GVLocationService.m
//  sdkm
//
//  Created by Mobile on 22.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVLocationService.h"
#import <CoreLocation/CoreLocation.h>

@interface GVLocationService() <CLLocationManagerDelegate> {
    
}

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation GVLocationService

+ (instancetype)shared {
    static GVLocationService *singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[GVLocationService alloc] init];
    });
    
    return singleton;
    
}

- (void)startTracking {
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
}

- (void)updateLocationWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    NSString *lat = @"44.4328293";//[NSString stringWithFormat:@"%f", latitude];
    NSString *lon = @"26.0985472";//[NSString stringWithFormat:@"%f", longitude];
    
    [[GVService shared] updateLocationWithLatitude:lat longitude:lon withCompletion:^(BOOL success, id res) {
        if (success) {
            NSLog(@"Location Updated Successfully...");
        }
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject;
    NSLog(@"Location Updated: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
    [self updateLocationWithLatitude:location.coordinate.latitude
                           longitude:location.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"LocationManager Error: %@", error.localizedDescription);
}

@end
