//
//  ViewController.m
//  sdktest
//
//  Created by Mobile on 15.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "ViewController.h"
#import <Groopview/Groopview.h>

@interface ViewController () {
    GVGroopviewMenu *groopviewMenu;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    groopviewMenu = [[GVGroopviewMenu alloc] init];
    [groopviewMenu insertInView:self];
}

- (BOOL)shouldAutorotate {
    return NO;
}


@end
