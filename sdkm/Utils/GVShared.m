//
//  GVShared.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVShared.h"
#import "GVMyGroopsController.h"
#import "GVUpcomingController.h"
#import "GVStartGroopviewController.h"
#import "GVSetTimeController.h"

@interface GVShared() {
    
}

@end

@implementation GVShared

+ (instancetype)shared {
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    //static id sharedObject = nil;  //if you're not using ARC
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
        //sharedObject = [[[self alloc] init] retain]; // if you're not using ARC
        [sharedObject initData];
    });
    return sharedObject;
}

#pragma mark - Init

- (void)initData {
    self.themeColor = [UIColor appRed];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_GROOPVIEW_STARTED];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_GROOPVIEW_ALERT_PRESENTED];
}

#pragma mark -

+ (NSBundle *)getBundle {
    return [NSBundle bundleWithIdentifier:@"com.groopview.sdkm"];
}

+ (UIStoryboard *)getStoryboard {
    return [UIStoryboard storyboardWithName:@"Groopview" bundle:[GVShared getBundle]];
}

#pragma mark - Session

- (NSString *)clientKeys {
    return [NSString stringWithFormat:@"%@ %@", self.clientId, self.clientSecret];
}

#pragma mark - Screen Orientation

+ (void)lockScreen:(UIInterfaceOrientationMask)orientationMask andRotateTo:(UIInterfaceOrientation)orientation {
    [[GVShared shared] setLockOrientation:orientationMask];
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
}

#pragma mark - Present View Controllers

+ (void)presentMyGroops:(UIViewController *)from {
    GVMyGroopsController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVMyGroopsController"];
    if (from.navigationController) {
        [from.navigationController pushViewController:vc animated:YES];
    }
    else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [nav setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [nav setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [from presentViewController:nav animated:YES completion:nil];
    }
}

+ (void)presentUpcomingGroopviews:(UIViewController *)from {
    GVUpcomingController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVUpcomingController"];
    if (from.navigationController) {
        [from.navigationController pushViewController:vc animated:YES];
    }
    else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [nav setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [nav setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [from presentViewController:nav animated:YES completion:nil];
    }
}

+ (void)presentGroopviewStart:(UIViewController *)from {
    
    // Init CreateGroopview Info
    [GVShared shared].createGroopviewInfo = [NSMutableDictionary dictionary];
    
    GVStartGroopviewController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVStartGroopviewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [nav setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [nav setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [from presentViewController:nav animated:YES completion:nil];
}

+ (void)presentSetTime:(UIViewController *)from {
    GVSetTimeController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVSetTimeController"];
    if (from.navigationController) {
        [from.navigationController pushViewController:vc animated:YES];
    }
    else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [nav setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [nav setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [from presentViewController:nav animated:YES completion:nil];
    }
}

@end
