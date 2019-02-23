//
//  GVGroopviewMenu.h
//
//  Created by Martin Manole on 15/12/18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVGroopviewMenuDelegate.h"

@interface GVGroopviewMenu : UIView

@property (strong, nonatomic) UIView *anchorView;
@property (strong, nonatomic) UIImageView *menuBackground;
@property (strong, nonatomic) UIButton *firstButton;
@property (strong, nonatomic) UIButton *secondButton;
@property (strong, nonatomic) UIButton *thirdButton;
@property (strong, nonatomic) UILabel *firstLabel;
@property (strong, nonatomic) UILabel *secondLabel;
@property (strong, nonatomic) UILabel *thirdLabel;
@property (strong, nonatomic) UIView *radialMenuContainer;

//@property (nonatomic, strong) NSObject <GVGroopviewMenuDelegate> *delegate;

@property (assign, nonatomic) BOOL displayBackgroundView;
@property (assign, nonatomic) CGFloat animationTime;
@property (strong, nonatomic) UIView *actionView;

@property BOOL isShowed;

//- (void)configureWithButtons:(NSArray *) buttons view:(UIView *)view delegate:(NSObject <GVGroopviewMenuDelegate> *) delegate;
//- (void)configureButtons:(NSArray *) buttons;
- (void)insertInView:(UIViewController *)view;
//- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer point:(CGPoint)touchedPoint;
//- (void)shortCutClickedForShowing:(BOOL)showing; /// For Groopview
//- (void)configureGesture;
@end
