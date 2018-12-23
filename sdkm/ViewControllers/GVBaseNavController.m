//
//  GVBaseNavController.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVBaseNavController.h"

@interface GVBaseNavController ()

@end

@implementation GVBaseNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor redColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
