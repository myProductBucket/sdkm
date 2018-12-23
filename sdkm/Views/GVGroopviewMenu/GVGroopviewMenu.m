//
//  GVGroopviewMenu.m
//
//  Created by Martin Manole on 15/12/18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVGroopviewMenu.h"
#import "GVConfirmCodeController.h"
#import "GVPhoneNumberController.h"
#import "GVNotificationsController.h"
#import "GVMyGroopsController.h"
#import "GVUpcomingController.h"
#import "GVLocationService.h"

@interface GVGroopviewMenu () {
    NSInteger selectedTag;
}
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, assign) CGPoint pointOfView;

@property (strong, nonatomic) UIButton *shortCutButton;
@property (strong, nonatomic) UIImageView *menuImage;

@property (strong, nonatomic) UIViewController *parentVC;

@end

@implementation GVGroopviewMenu
+ (GVGroopviewMenu *)radialMenu {
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil];
    GVGroopviewMenu *radialMenu = [nibViews firstObject];
    radialMenu.backgroundColor = [UIColor clearColor];
//    radialMenu.anchorView.layer.borderWidth = 3;
//    radialMenu.anchorView.layer.borderColor = [[UIColor whiteColor] CGColor];
//    radialMenu.anchorView.layer.cornerRadius = radialMenu.anchorView.bounds.size.width / 2;
    radialMenu.anchorView.alpha = 0.0;
    
    radialMenu.firstButton.layer.borderWidth = 3;
    radialMenu.firstButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    radialMenu.firstButton.layer.cornerRadius = radialMenu.firstButton.bounds.size.width / 2;
    radialMenu.firstButton.alpha = 0.0;
    
    radialMenu.secondButton.layer.borderWidth = 3;
    radialMenu.secondButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    radialMenu.secondButton.layer.cornerRadius = radialMenu.firstButton.bounds.size.width / 2;
    radialMenu.secondButton.alpha = 0.0;
    
    radialMenu.thirdButton.layer.borderWidth = 3;
    radialMenu.thirdButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    radialMenu.thirdButton.layer.cornerRadius = radialMenu.firstButton.bounds.size.width / 2;
    radialMenu.thirdButton.alpha = 0.0;
    
    return radialMenu;
}

- (void)baseInit {
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat cs = GV_SCREEN_WIDTH * 40 / 375.0; // Button Width
    CGFloat cb = GV_SCREEN_WIDTH * 135 / 375.0; // Menu Width
    CGFloat cd = GV_SCREEN_WIDTH * 30 / 375.0; // Description Label Height
    CGFloat fd = GV_SCREEN_WIDTH * 15 / 375.0; // Description Label FontSize
    if (GV_IPAD) {
        cs = 60;
        cb = 200;
        cd = 37;
        fd = 22;
    }
    NSString *dStr = @""; // Description Label
    
    self.menuBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cb, cb)];
    [self addSubview:self.menuBackground];
    [self.menuBackground setImage:[UIImage imageNamed:@"menu_background.png" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil]];
    [self.menuBackground setAlpha:0];
    
    dStr = @"    Notifications";
    self.firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [dStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fd]}].width + 20, cd)];
    self.firstLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
    [self.firstLabel setAlpha:0];
    [self.firstLabel setTag:0];
    [self.firstLabel.layer setCornerRadius:cd / 2.0];
    [self.firstLabel.layer setMasksToBounds:YES];
    [self.firstLabel setTextAlignment:NSTextAlignmentLeft];
    [self.firstLabel setText:dStr];
    [self.firstLabel setFont:[UIFont systemFontOfSize:fd]];
    [self addSubview:self.firstLabel];
    
    self.firstButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cs, cs)];
    [self addSubview:self.firstButton];
    self.firstButton.layer.borderWidth = 1;
    self.firstButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.firstButton.layer.cornerRadius = self.firstButton.bounds.size.width / 2;
    [self.firstButton setTag:0];
    [self.firstButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.firstButton.alpha = 0.0;
    [self.firstButton setImage:[UIImage imageNamed:@"menu_star.png" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    dStr = @"    Upcoming Groopviews";
    self.secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [dStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fd]}].width + 20, cd)];
    self.secondLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
    [self.secondLabel setAlpha:0];
    [self.secondLabel setTag:1];
    [self.secondLabel.layer setCornerRadius:cd / 2.0];
    [self.secondLabel.layer setMasksToBounds:YES];
    [self.secondLabel setTextAlignment:NSTextAlignmentLeft];
    [self.secondLabel setText:dStr];
    [self.secondLabel setFont:[UIFont systemFontOfSize:fd]];
    [self addSubview:self.secondLabel];
    
    self.secondButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cs, cs)];
    [self addSubview:self.secondButton];
    self.secondButton.layer.borderWidth = 1;
    self.secondButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.secondButton.layer.cornerRadius = self.firstButton.bounds.size.width / 2;
    [self.secondButton setTag:1];
    [self.secondButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.secondButton.alpha = 0.0;
    [self.secondButton setImage:[UIImage imageNamed:@"menu_future.png" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    dStr = @"    Start a Groopview";
    self.thirdLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [dStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fd]}].width + 20, cd)];
    self.thirdLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
    [self.thirdLabel setAlpha:0];
    [self.thirdLabel setTag:2];
    [self.thirdLabel.layer setCornerRadius:cd / 2];
    [self.thirdLabel.layer setMasksToBounds:YES];
    [self.thirdLabel setTextAlignment:NSTextAlignmentLeft];
    [self.thirdLabel setText:dStr];
    [self.thirdLabel setFont:[UIFont systemFontOfSize:fd]];
    [self addSubview:self.thirdLabel];
    
    self.thirdButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cs, cs)];
    [self addSubview:self.thirdButton];
    self.thirdButton.layer.borderWidth = 1;
    self.thirdButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.thirdButton.layer.cornerRadius = self.firstButton.bounds.size.width / 2;
    [self.thirdButton setTag:2];
    [self.thirdButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.thirdButton.alpha = 0.0;
    [self.thirdButton setImage:[UIImage imageNamed:@"menu_start.png" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    self.buttons = @[self.firstButton, self.secondButton, self.thirdButton];
    
    self.anchorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cs, cs)];
    [self addSubview:self.anchorView];
    //    self.anchorView.layer.borderWidth = 3;
    //    self.anchorView.layer.borderColor = [[UIColor whiteColor] CGColor];
    //    self.anchorView.layer.cornerRadius = self.anchorView.bounds.size.width / 2;
    self.anchorView.alpha = 0.0;
    
    self.displayBackgroundView = YES;
    self.animationTime = 0.3;
    
    // --
}

- (id)init {
    self = [super init];
    if (self) {
//        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil];
//        GVGroopviewMenu *radialMenu = [nibViews firstObject];
//        self = radialMenu;
        [self baseInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseInit];
    }
    return self;
}

- (void)configureWithButtons:(NSArray *)buttons view:(UIView *)view delegate:(NSObject<GVGroopviewMenuDelegate> *)delegate {
    [self configureButtons:buttons];
//    [self insertInView:view];
    [self configureGesture];
    
//    self.delegate = delegate;
}

- (void)configureButtons:(NSArray *)buttons {
    if (buttons.count > 3) {
        NSLog(@"Too many buttons in radial menu: ignoring the last %td", buttons.count - 3);
    }
    self.buttons = @[buttons[0]
                     , buttons[1]
                     , buttons[2]];
    for (NSInteger i = 0; i < self.buttons.count; i++) {
        UIButton *button = (UIButton*)[buttons objectAtIndex:i];
        if (i == 0) {
            if (!CGRectIsEmpty(button.frame)) {
//                self.firstButton.frame = button.frame;
            }
            [self.firstButton setTitle:button.titleLabel.text forState:UIControlStateNormal];
            [self.firstButton setImage:button.imageView.image forState:UIControlStateNormal];
            self.firstButton.backgroundColor = button.backgroundColor;
            self.firstButton.tag = button.tag;
        }
        else if (i == 1) {
            if (!CGRectIsEmpty(button.frame)) {
//                self.secondButton.frame = button.frame;
            }
            [self.secondButton setTitle:button.titleLabel.text forState:UIControlStateNormal];
            [self.secondButton setImage:button.imageView.image forState:UIControlStateNormal];
            self.secondButton.backgroundColor = button.backgroundColor;
            self.secondButton.tag = button.tag;
        }
        else if (i == 2) {
            if (!CGRectIsEmpty(button.frame)) {
//                self.thirdButton.frame = button.frame;
            }
            [self.thirdButton setTitle:button.titleLabel.text forState:UIControlStateNormal];
            [self.thirdButton setImage:button.imageView.image forState:UIControlStateNormal];
            self.thirdButton.backgroundColor = button.backgroundColor;
            self.thirdButton.tag = button.tag;
        }
    }
}

- (void)insertInView:(UIViewController *)vc {
    
    self.parentVC = vc;
    
    self.radialMenuContainer = [[UIView alloc] init];
    self.radialMenuContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.radialMenuContainer addGestureRecognizer:tapGesture];
    self.radialMenuContainer.alpha = 0.0;
    
    [vc.view addSubview:self.radialMenuContainer];
    
    [self.radialMenuContainer addSubview:self];
    
    NSDictionary *views = @{ @"radialMenuContainer": self.radialMenuContainer, @"radialMenu" : self };
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.radialMenuContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    [vc.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[radialMenuContainer]-0-|" options:kNilOptions metrics:nil views:views]];
    [vc.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[radialMenuContainer]-0-|" options:kNilOptions metrics:nil views:views]];
    
    [self.radialMenuContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[radialMenu]-0-|" options:kNilOptions metrics:nil views:views]];
    [self.radialMenuContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[radialMenu]-0-|" options:kNilOptions metrics:nil views:views]];
    
    // -- Menu Image and Button
    CGFloat cw = GV_SCREEN_HEIGHT * 110 / 667.0;
    CGFloat ch = GV_SCREEN_HEIGHT * 65 / 667.0;
    
    CGSize size = vc.view.frame.size;
    UIImageView *menuImage = [[UIImageView alloc] initWithFrame:CGRectMake(size.width - cw, size.height - cw, cw, cw)];
    [menuImage setImage:[UIImage imageNamed:@"menu_button.png" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil]];
    [vc.view addSubview:menuImage];
    
    UIButton *shortCutButton = [[UIButton alloc] initWithFrame:CGRectMake(size.width - ch, size.height - ch, ch, ch)];
    [shortCutButton addTarget:self action:@selector(shortCutClicked:) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:shortCutButton];
    
    // NSNotification
    [[NSNotificationCenter defaultCenter] addObserverForName:GV_NS_REGISTERED object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self startGroopviewFlow:self->selectedTag];
    }];
}

- (void)configureGesture {
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPressGestureRecognizer.minimumPressDuration = 0.5;
    [self.radialMenuContainer.superview addGestureRecognizer:longPressGestureRecognizer];
    
}

- (void) longPressAction: (UILongPressGestureRecognizer *)gesture {
    if (self.actionView) {
        self.pointOfView = [gesture locationInView:self.actionView];
    }
    [self handleLongPress:gesture point:[gesture locationInView:self.radialMenuContainer.superview]];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer point:(CGPoint)touchedPoint {
    
    if(UIGestureRecognizerStateBegan == gestureRecognizer.state) {
        
        self.anchorView.center = touchedPoint;
        self.firstButton.center = touchedPoint;
        self.secondButton.center = touchedPoint;
        self.thirdButton.center = touchedPoint;
        
        if (!self.displayBackgroundView) {
            self.radialMenuContainer.backgroundColor = [UIColor clearColor];
        }
        
        [UIView animateWithDuration:self.animationTime animations:^(void){
            self.radialMenuContainer.alpha = 1.0;
            self.anchorView.alpha = 1.0;
        }];
        
        CGFloat distance = GV_SCREEN_HEIGHT * 90 / 667.0;
        NSArray *anglesArray = [self anglesArrayWithTouchedPoint:touchedPoint distance:distance];
        
        if (anglesArray.count > 0) [self moveButton:self.firstButton fromPoint:touchedPoint distance:distance angle:[anglesArray[0] integerValue] delay:0.1];
        if (anglesArray.count > 1)[self moveButton:self.secondButton fromPoint:touchedPoint distance:distance angle:[anglesArray[1] integerValue] delay:0.15];
        if (anglesArray.count > 2)[self moveButton:self.thirdButton fromPoint:touchedPoint distance:distance angle:[anglesArray[2] integerValue] delay:0.2];
    }
    
    if(UIGestureRecognizerStateEnded == gestureRecognizer.state) {
        if (self.selectedButton) {
//            [self.delegate radialMenu:self didSelectButton:self.selectedButton];
        }
        else {
//            [self.delegate radialMenuDidCancel:self];
        }
        
        [UIView animateWithDuration:self.animationTime animations:^(void){
            if (self.radialMenuContainer.alpha > 0.0) {
                self.radialMenuContainer.alpha = 0.0;
            }
            self.anchorView.alpha = 0.0;
            self.firstButton.center = self.anchorView.center;
            self.firstButton.alpha = 0.0;
            self.secondButton.center = self.anchorView.center;
            self.secondButton.alpha = 0.0;
            self.thirdButton.center = self.anchorView.center;
            self.thirdButton.alpha = 0.0;
        }];
    }
    
    if ([self touchPoint:touchedPoint isInsideView:self.firstButton]) {
        self.selectedButton = self.firstButton;
        [self scaleView:self.firstButton value:1.5];
    }
    else {
        [self scaleView:self.firstButton value:1.0];
    }
    
    if ([self touchPoint:touchedPoint isInsideView:self.secondButton]) {
        self.selectedButton = self.secondButton;
        [self scaleView:self.secondButton value:1.5];
    }
    else {
        [self scaleView:self.secondButton value:1.0];
    }
    
    if ([self touchPoint:touchedPoint isInsideView:self.thirdButton]) {
        self.selectedButton = self.thirdButton;
        [self scaleView:self.thirdButton value:1.5];
    }
    else {
        [self scaleView:self.thirdButton value:1.0];
    }
    
    if (![self touchPoint:touchedPoint isInsideView:self.firstButton] && ![self touchPoint:touchedPoint isInsideView:self.secondButton] && ![self touchPoint:touchedPoint isInsideView:self.thirdButton]) {
        self.selectedButton = nil;
    }
}

#pragma mark - Groopview ShortCut

- (void)shortCutClickedForShowing:(BOOL)showing {
    self.isShowed = showing;
    CGSize size = self.radialMenuContainer.frame.size;
    CGPoint touchedPoint = CGPointMake(size.width - GV_SCREEN_HEIGHT * 30 / 667.0, size.height - GV_SCREEN_HEIGHT * 30 / 667.0);
    
    if(showing) {
        
        self.anchorView.center = touchedPoint;
        self.firstButton.center = touchedPoint;
        self.secondButton.center = touchedPoint;
        self.thirdButton.center = touchedPoint;
        [self.firstLabel setCenter:touchedPoint];
        [self.secondLabel setCenter:touchedPoint];
        [self.thirdLabel setCenter:touchedPoint];
        
        self.menuBackground.center = CGPointMake(size.width - self.menuBackground.frame.size.width / 2, size.height - self.menuBackground.frame.size.height / 2);
        
        if (!self.displayBackgroundView) {
            self.radialMenuContainer.backgroundColor = [UIColor clearColor];
        }
        
        [UIView animateWithDuration:self.animationTime animations:^(void){
            self.radialMenuContainer.alpha = 1.0;
            self.anchorView.alpha = 1.0;
        }];
        
        CGFloat distance = GV_SCREEN_HEIGHT * 100 / 667.0;
        CGFloat distanceC = GV_SCREEN_HEIGHT * 90 / 667.0;
        NSArray *anglesArray = [self anglesArrayWithTouchedPoint:touchedPoint distance:distance];
        
        if (anglesArray.count > 0)
            [self moveButton:self.firstButton label:self.firstLabel fromPoint:touchedPoint distance:distance angle:[anglesArray[0] integerValue] delay:0.1];
        if (anglesArray.count > 1)
            [self moveButton:self.secondButton label:self.secondLabel fromPoint:touchedPoint distance:distanceC angle:[anglesArray[1] integerValue] delay:0.15];
        if (anglesArray.count > 2)
            [self moveButton:self.thirdButton label:self.thirdLabel fromPoint:touchedPoint distance:distance angle:[anglesArray[2] integerValue] delay:0.2];
        [UIView animateWithDuration:self.animationTime animations:^{
            [self.menuBackground setAlpha:1];
        }];
    }
    
    if(showing == NO) {
//        [self.delegate radialMenuDidCancel:self];
        
        [UIView animateWithDuration:self.animationTime animations:^(void){
            if (self.radialMenuContainer.alpha > 0.0) {
                self.radialMenuContainer.alpha = 0.0;
            }
            self.anchorView.alpha = 0.0;
            self.firstButton.center = self.anchorView.center;
            self.firstButton.alpha = 0.0;
            self.secondButton.center = self.anchorView.center;
            self.secondButton.alpha = 0.0;
            self.thirdButton.center = self.anchorView.center;
            self.thirdButton.alpha = 0.0;
            [self.firstLabel setCenter:self.anchorView.center];
            [self.firstLabel setAlpha:0];
            [self.secondLabel setCenter:self.anchorView.center];
            [self.secondLabel setAlpha:0];
            [self.thirdLabel setCenter:self.anchorView.center];
            [self.thirdLabel setAlpha:0];
            [self.menuBackground setAlpha:0];
        }];
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)sender {
    CGPoint touchedPoint = [sender locationInView:self.radialMenuContainer];
    if (![self touchPoint:touchedPoint isInsideView:self.firstButton] && ![self touchPoint:touchedPoint isInsideView:self.secondButton] && ![self touchPoint:touchedPoint isInsideView:self.thirdButton]) {
        self.selectedButton = nil;
        [self shortCutClickedForShowing:NO];
    }
}

- (void)menuButtonClicked:(UIButton *)sender {
//    [self.delegate radialMenu:self didSelectButton:sender];
    if ([GVGlobal shared].tokenType
        && [GVGlobal shared].accessToken) {
        [self startGroopviewFlow:sender.tag];
        return;
    }
    
    selectedTag = sender.tag;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:PREF_SIGN_UP_INFO]) {
        [[GVGlobal shared] setMUser:[GVUser loadUser:PREF_SIGN_UP_INFO]];
        if ([GVGlobal shared].mUser.phoneNumber
            && [GVGlobal shared].mUser.countryCode) { // Present Confirm Code
            [self presentConfirmCode];
        }
        else { // Present Phone Number
            [self presentPhoneNumber];
        }
    }
    else if ([[NSUserDefaults standardUserDefaults] objectForKey:PREF_CURRENT_USER]) {
        [[GVGlobal shared] setMUser:[GVUser loadUser:PREF_CURRENT_USER]];
        if ([GVGlobal isNull:[GVGlobal shared].tokenType]
            || [GVGlobal isNull:[GVGlobal shared].accessToken]) { // Get Access Token
            [self authenticate:[GVGlobal shared].mUser.phoneNumber];
        }
    }
    else
        [self presentPhoneNumber];
}

- (void)shortCutClicked:(UIButton *)sender {
    if (self.isShowed == NO) {
        [self shortCutClickedForShowing:YES];
        
        // Location Tracking
        [[GVLocationService shared] startTracking];
        
        // Manage the Access Token
        if ([GVGlobal shared].accessToken == nil
            || [GVGlobal shared].accessToken.length == 0) { //
            if ([[NSUserDefaults standardUserDefaults] objectForKey:PREF_CURRENT_USER]) {
                [[GVGlobal shared] setMUser:[GVUser loadUser:PREF_CURRENT_USER]];
                [self authenticate:[GVGlobal shared].mUser.phoneNumber];
            }
            else if ([GVShared shared].userInfo) {
                [self authenticate:[GVShared shared].userInfo.email];
            }
            else {
                [GVGlobal showAlertWithTitle:GROOPVIEW message:@"Please pass the user info to use the Groopview." fromView:self.parentVC withCompletion:nil];
            }
        }
    }
    else {
        [self shortCutClickedForShowing:NO];
    }
}

#pragma mark - Groopview Flow

- (void)startGroopviewFlow:(NSInteger)tag {
    if (tag == 0) { // Notifications
        [self presentNotifications];
    }
    else if (tag == 1) { // Upcoming Groopviews
        [self presentUpcomingGroopviews];
    }
    else if (tag == 2) { // Start a Groopview
        [GVShared presentGroopviewStart:self.parentVC];
    }
}

- (void)presentConfirmCode {
    GVConfirmCodeController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVConfirmCodeController"];
    if (self.parentVC.navigationController) {
        [self.parentVC.navigationController pushViewController:vc animated:YES];
    }
    else {
        [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self.parentVC presentViewController:vc animated:YES completion:nil];
    }
}

- (void)presentPhoneNumber {
    GVPhoneNumberController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVPhoneNumberController"];
    if (self.parentVC.navigationController) {
        [self.parentVC.navigationController pushViewController:vc animated:YES];
    }
    else {
        [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self.parentVC presentViewController:vc animated:YES completion:nil];
    }
}

- (void)presentNotifications {
    GVNotificationsController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVNotificationsController"];
    if (self.parentVC.navigationController) {
        [self.parentVC.navigationController pushViewController:vc animated:YES];
    }
    else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [nav setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [nav setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self.parentVC presentViewController:vc animated:YES completion:nil];
    }
}

- (void)presentUpcomingGroopviews {
    GVUpcomingController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVUpcomingController"];
    if (self.parentVC.navigationController) {
        [self.parentVC.navigationController pushViewController:vc animated:YES];
    }
    else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [nav setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [nav setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self.parentVC presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - Authenticate

- (void)authenticate:(NSString *)userId {
    if (userId == nil
        || userId.length == 0) {
        [GVGlobal showAlertWithTitle:GROOPVIEW message:@"Please pass your email address to use the Groopview." fromView:self.parentVC withCompletion:nil];
        return;
    }

    [MBProgressHUD showHUDAddedTo:self.parentVC.view animated:YES];
    [[GVService shared] authenticate:userId completion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.parentVC.view animated:YES];
        if (success) {
            NSLog(@"res");
            if ([res isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = res;
                if (dic[@"token_type"]) {
                    [[GVGlobal shared] setTokenType:dic[@"token_type"]];
                }
                if (dic[@"access_token"]) {
                    [[GVGlobal shared] setAccessToken:dic[@"access_token"]];
                }
                if (dic[@"refresh_token"]) {
                    [[GVGlobal shared] setRefreshToken:dic[@"refresh_token"]];
                }
                
                // Get User Info
                [MBProgressHUD showHUDAddedTo:self.viewForLastBaselineLayout animated:YES];
                [[GVService shared] getUserInfoWithCompletion:^(BOOL success, id res) {
                    [MBProgressHUD hideHUDForView:self.viewForLastBaselineLayout animated:YES];
                    if (success) {
                        if (res[@"data"]
                            && [res[@"data"] isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *dic = res[@"data"];
                            GVUser *user = [[GVUser alloc] init];
                            user.firstName = [dic objectForKey:@"first_name"];
                            user.lastName = [dic objectForKey:@"last_name"];
                            user.email = [dic objectForKey:@"email"];
                            user.countryCode = [dic objectForKey:@"country_code"];
                            user.phoneNumber = [dic objectForKey:@"phone_number"];
                            user.avatar = [dic objectForKey:@"avatar_url"];
                            [user save:PREF_CURRENT_USER];
                        }
                    }
                }];
            }
        }
    }];
}

#pragma mark - ////

- (void)moveButton:(UIButton *)button fromPoint:(CGPoint)point distance:(CGFloat)distance angle:(CGFloat)angle delay:(CGFloat)delay {
    CGFloat x = distance * cosf(angle / 180.0 * M_PI);
    CGFloat y = distance * sinf(angle / 180.0 * M_PI);
    
    [UIView animateWithDuration:self.animationTime delay:delay usingSpringWithDamping:0.7 initialSpringVelocity:5 options:0 animations:^ (void){
        button.alpha = 1.0;
        button.center = CGPointMake(point.x + x, point.y + y);
    } completion:nil];
}

- (void)moveButton:(UIButton *)button label:(UILabel *)label fromPoint:(CGPoint)point distance:(CGFloat)distance angle:(CGFloat)angle delay:(CGFloat)delay {
    CGFloat x = distance * cosf(angle / 180.0 * M_PI);
    CGFloat y = distance * sinf(angle / 180.0 * M_PI);
    
    [UIView animateWithDuration:self.animationTime delay:delay usingSpringWithDamping:0.7 initialSpringVelocity:5 options:0 animations:^ (void){
        button.alpha = 1.0;
        button.center = CGPointMake(point.x + x, point.y + y);
        [label setAlpha:1.0];
        [label setCenter:CGPointMake(point.x + x - label.frame.size.width / 2, point.y + y)];
    } completion:nil];
}

- (void)scaleView:(UIView *)view value:(CGFloat)value {
    
    [UIView animateWithDuration:self.animationTime delay:0.0 usingSpringWithDamping:7 initialSpringVelocity:5 options:0 animations:^(void){
        view.transform = CGAffineTransformMakeScale(value, value);
    } completion:nil];
}

- (BOOL)touchPoint:(CGPoint)point isInsideView:(UIView *)view {
    return ( (point.x > view.center.x - view.frame.size.width/2 && point.x < view.center.x + view.frame.size.width/2) &&
            (point.y > view.center.y - view.frame.size.height/2 && point.y < view.center.y + view.frame.size.height/2) );
    
}

- (NSArray *)anglesArrayWithTouchedPoint:(CGPoint)touchedPoint distance:(NSInteger)distance {
    
    if (self.actionView) {
        touchedPoint = self.pointOfView;
    }
    
    NSArray *positionArray = [[NSArray alloc] init];
    
//    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    NSInteger times = self.buttons.count;
    NSInteger step = 40;
    
//    NSString *position = @"right";
    positionArray = [self generateArrayFrom:265 times:times step:-step];
   
    /// Commented for Groopview
//    if (touchedPoint.x + distance > screenWidth) {
//        position = @"right";
//        positionArray = [self generateArrayFrom:270 times:times step:-step];
//
//        if (touchedPoint.y + distance > screenHeight) {
//            position = @"bottom right";
//            positionArray = [self generateArrayFrom:270 times:times step:-step];
//        }
//
//        if (touchedPoint.y - distance < 60) {
//            position = @"top right";
//            positionArray = [self generateArrayFrom:180 times:times step:-step];
//        }
//    }
//
//    if (touchedPoint.x - distance < 0) {
//        position = @"left";
//        positionArray = [self generateArrayFrom:0 times:times step:-step];
//
//        if (touchedPoint.y + distance > screenHeight) {
//            position = @"bottom left";
//            positionArray = [self generateArrayFrom:0 times:times step:-step];
//        }
//
//        if (touchedPoint.y - distance < 60) {
//            position = @"top left";
//            positionArray = [self generateArrayFrom:90 times:times step:-step];
//        }
//    }
//
//    if (touchedPoint.y - distance < 60) {
//        position = @"top";
//        positionArray = [self generateArrayFrom:180 times:times step:-step];
//
//        if (touchedPoint.x + distance > screenWidth) {
//            position = @"top right";
//            positionArray = [self generateArrayFrom:180 times:times step:-step];
//        }
//
//        if (touchedPoint.x - distance < 0) {
//            position = @"top left";
//            positionArray = [self generateArrayFrom:90 times:times step:-step];
//        }
//    }
//
//    if (touchedPoint.y + distance > screenHeight) {
//        position = @"bottom";
//        positionArray = [self generateArrayFrom:270 times:times step:-step];
//
//        if (touchedPoint.x + distance > screenWidth) {
//            position = @"bottom right";
//            positionArray = [self generateArrayFrom:270 times:times step:-step];
//        }
//
//        if (touchedPoint.x - distance < 0) {
//            position = @"bottom left";
//            positionArray = [self generateArrayFrom:0 times:times step:-step];
//        }
//    }
    
    return positionArray;
}

- (NSArray *)generateArrayFrom:(NSInteger)from times:(NSInteger)times step:(NSInteger)step {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (step > 0) {
        for (NSInteger i = from; array.count < times; i += step) {
            [array addObject:@(i)];
        }
    }
    else {
        for (NSInteger i = from; array.count < times; i += step) {
            [array addObject:@(i)];
        }
    }
    return array;
}
@end
