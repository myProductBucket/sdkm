//
//  GVBaseController.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVBaseController.h"

@interface GVBaseController ()

@end

@implementation GVBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GVShared lockScreen:UIInterfaceOrientationMaskPortrait andRotateTo:UIInterfaceOrientationPortrait];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[GVShared shared] setLockOrientation:UIInterfaceOrientationMaskAll];
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
