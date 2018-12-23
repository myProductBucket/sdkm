//
//  GVStartGroopviewController.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVStartGroopviewController.h"
#import "GVCreateGroopController.h"
#import "GVMyGroopsController.h"

@interface GVStartGroopviewController ()

@end

@implementation GVStartGroopviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initLayout];
    
    [self showContentView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private Methods

- (void)initLayout {
    [self.viewCreateGroop setShadow:3];
    [self.viewUseExisting setShadow:3];
    
    [self.viewContent setAlpha:0];
    
    // Gesture
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapExtraView:)];
    [self.viewBackground addGestureRecognizer:gesture];
}

- (void)showContentView {
    [self.viewContent setTransform:CGAffineTransformMakeScale(0.01, 0.01)];
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.viewContent setAlpha:1];
        [self.viewContent setTransform:CGAffineTransformIdentity];
        [self.viewContent layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.viewContent setUserInteractionEnabled:YES];
    }];
}

#pragma mark - Actions

- (void)didTapExtraView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didClickCreateGroop:(id)sender {
    GVCreateGroopController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVCreateGroopController"];
    [vc setViewType:CREATE_GROOP_FROM_START];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didClickExisting:(id)sender {
    GVMyGroopsController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVMyGroopsController"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
