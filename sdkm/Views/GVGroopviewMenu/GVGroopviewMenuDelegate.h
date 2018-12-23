//
//  GVGroopviewMenuDelegate.h
//
//  Created by Martin Manole on 16/12/18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@class GVGroopviewMenu;

@protocol GVGroopviewMenuDelegate <NSObject>

- (void)radialMenu:(GVGroopviewMenu *)radialMenu didSelectButton:(UIButton *)selectedButton;
- (void)radialMenuDidCancel:(GVGroopviewMenu *)radialMenu;

@end
