//
//  GVGroopviewController.m
//  sdkm
//
//  Created by Mobile on 19.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVGroopviewController.h"
#import "GVGroop.h"
#import "GVContactCell.h"
#import <TwilioVideo/TwilioVideo.h>
#import <Contacts/Contacts.h>
#import <AVKit/AVKit.h>

#define SEMI_WID 50.0f
#define MENU_BOTTOM 12.0f

#define FIRST @"first"
#define SECOND @"second"
#define THIRD @"third"

#define LOCAL_VIDEO_TRACK_NAME  @"local_video_track"

@interface GVGroopviewController () <TVICameraCapturerDelegate, TVIRoomDelegate, TVIRemoteParticipantDelegate, UITableViewDelegate, UITableViewDataSource> {
    CGFloat firstX;
    CGFloat firstY;
}

@property (weak, nonatomic) IBOutlet UIView *viewVideo;
@property (weak, nonatomic) IBOutlet TVIVideoView *viewParticipant3;
@property (weak, nonatomic) IBOutlet TVIVideoView *viewParticipant2;
@property (weak, nonatomic) IBOutlet TVIVideoView *viewParticipant1;
@property (weak, nonatomic) IBOutlet TVIVideoView *viewHost;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnMute;
@property (weak, nonatomic) IBOutlet UIButton *btnPause;

@property (weak, nonatomic) IBOutlet UILabel *lblPauseSharing;
@property (weak, nonatomic) IBOutlet UILabel *lblMuteAudio;

@property (weak, nonatomic) IBOutlet UIView *viewMenuMute;
@property (weak, nonatomic) IBOutlet UIView *viewMenuPause;
@property (weak, nonatomic) IBOutlet UIView *viewMenuStop;
@property (weak, nonatomic) IBOutlet UIView *viewMenuAdd;

// Contacts
@property (weak, nonatomic) IBOutlet UIView *viewContactsCover;
@property (weak, nonatomic) IBOutlet UIView *viewContacts;
@property (weak, nonatomic) IBOutlet UITableView *tblContacts;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segContacts;

#pragma mark - Constraints

/// Default - 195
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMuteViewBottom;
/// Default - 148
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAddViewBottom;
/// Default - 101
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPauseViewBottom;
/// Default - 54
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintStopViewBottom;

@property (strong, nonatomic) GVGroop *curGroopview;
@property Boolean isAdmin;
@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) NSString *accessToken;

@property (nonatomic, strong) TVICameraCapturer *camera;
@property (nonatomic, strong) TVILocalVideoTrack *localVideoTrack;
@property (nonatomic, strong) TVILocalAudioTrack *localAudioTrack;
@property (nonatomic, strong) TVIRoom *room;
@property (strong, nonatomic) TVILocalParticipant *localParticipant;

@property (strong, nonatomic) NSMutableDictionary *videoViewsDic;
@property (strong, nonatomic) NSMutableDictionary *participantsDic;

// -- Contact Management
@property (nonatomic, strong) NSMutableArray *arrAllContacts;
@property (nonatomic, strong) NSMutableArray *arrGroopviewContacts;

@end

@implementation GVGroopviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initLayout];
    
    // Start Preview
    [self hideContactsView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Get Groopview Detail
    [self getGroopviewDetail];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [GVShared lockScreen:UIInterfaceOrientationMaskLandscape andRotateTo:UIInterfaceOrientationLandscapeLeft];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
//    [[GVShared shared] setLockOrientation:UIInterfaceOrientationMaskAll];
    [GVShared lockScreen:UIInterfaceOrientationMaskPortrait andRotateTo:UIInterfaceOrientationPortrait];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - My Methods

- (void)initLayout {
    // -- Participant View Layout
    [self.viewHost.layer setCornerRadius:self.viewHost.frame.size.height / 2];
    [self.viewParticipant1.layer setCornerRadius:self.viewParticipant1.frame.size.height / 2];
    [self.viewParticipant2.layer setCornerRadius:self.viewParticipant2.frame.size.height / 2];
    [self.viewParticipant3.layer setCornerRadius:self.viewParticipant3.frame.size.height / 2];
    
    [self.viewHost.layer setBorderWidth:1];
    [self.viewHost.layer setBorderColor:[GVShared shared].themeColor.CGColor];
    [self.viewParticipant1.layer setBorderWidth:1];
    [self.viewParticipant1.layer setBorderColor:[GVShared shared].themeColor.CGColor];
    [self.viewParticipant2.layer setBorderWidth:1];
    [self.viewParticipant2.layer setBorderColor:[GVShared shared].themeColor.CGColor];
    [self.viewParticipant3.layer setBorderWidth:1];
    [self.viewParticipant3.layer setBorderColor:[GVShared shared].themeColor.CGColor];
    [self.viewParticipant1 setHidden:YES];
    [self.viewParticipant2 setHidden:YES];
    [self.viewParticipant3 setHidden:YES];
    
    self.participantsDic = [NSMutableDictionary dictionary];
    self.videoViewsDic = [NSMutableDictionary dictionary];
    [self.videoViewsDic setObject:self.viewParticipant1 forKey:FIRST];
    [self.videoViewsDic setObject:self.viewParticipant2 forKey:SECOND];
    [self.videoViewsDic setObject:self.viewParticipant3 forKey:THIRD];
    
    // -- Participant View Gesture
    UIPanGestureRecognizer *panGestureHost = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveParticipantView:)];
    [panGestureHost setMinimumNumberOfTouches:1];
    [panGestureHost setMaximumNumberOfTouches:1];
    [self.viewHost addGestureRecognizer:panGestureHost];
    
    UIPanGestureRecognizer *panGesture1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveParticipantView:)];
    [panGesture1 setMinimumNumberOfTouches:1];
    [panGesture1 setMaximumNumberOfTouches:1];
    [self.viewParticipant1 addGestureRecognizer:panGesture1];
    
    UIPanGestureRecognizer *panGesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveParticipantView:)];
    [panGesture2 setMinimumNumberOfTouches:1];
    [panGesture2 setMaximumNumberOfTouches:1];
    [self.viewParticipant2 addGestureRecognizer:panGesture2];
    
    UIPanGestureRecognizer *panGesture3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveParticipantView:)];
    [panGesture3 setMinimumNumberOfTouches:1];
    [panGesture3 setMaximumNumberOfTouches:1];
    [self.viewParticipant3 addGestureRecognizer:panGesture3];
    
    // -- Menu
    CGFloat wid = 17.5;
    [self.viewMenuMute.layer setCornerRadius:wid];
    [self.viewMenuPause.layer setCornerRadius:wid];
    [self.viewMenuStop.layer setCornerRadius:wid];
    [self.viewMenuAdd.layer setCornerRadius:wid];
    
    [self.constraintMuteViewBottom setConstant:MENU_BOTTOM];
    [self.constraintPauseViewBottom setConstant:MENU_BOTTOM];
    [self.constraintStopViewBottom setConstant:MENU_BOTTOM];
    [self.constraintAddViewBottom setConstant:MENU_BOTTOM];
    
    [self.viewMenuStop setHidden:YES];
    [self.viewMenuPause setHidden:YES];
    [self.viewMenuMute setHidden:YES];
    [self.viewMenuAdd setHidden:YES];
    
    // Contact Management
    [self.tblContacts setDelegate:self];
    [self.tblContacts setDataSource:self];
    
    UIRefreshControl *refreshC = [[UIRefreshControl alloc] init];
    [refreshC addTarget:self action:@selector(refreshContacts:) forControlEvents:UIControlEventValueChanged];
    [self.tblContacts addSubview:refreshC];
}

- (void)refreshContacts:(UIRefreshControl *)sender {
    [self contactScan];
    [sender endRefreshing];
}

- (void)moveParticipantView:(UIPanGestureRecognizer *)sender {
    [self.view bringSubviewToFront:sender.view];
    CGPoint translatedPoint = [sender translationInView:sender.view.superview];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        firstX = sender.view.center.x;
        firstY = sender.view.center.y;
    }
    
    
    translatedPoint = CGPointMake(sender.view.center.x + translatedPoint.x, sender.view.center.y + translatedPoint.y);
    
    [sender.view setCenter:translatedPoint];
    [sender setTranslation:CGPointZero inView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGFloat velocityX = (0.2 * [sender velocityInView:self.view].x);
        CGFloat velocityY = (0.2 * [sender velocityInView:self.view].y);
        
        CGFloat finalX = translatedPoint.x + velocityX;
        CGFloat finalY = translatedPoint.y + velocityY;// translatedPoint.y + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
        
        if (finalX < SEMI_WID) {
            finalX = SEMI_WID;
        } else if (finalX > self.view.frame.size.width - SEMI_WID) {
            finalX = self.view.frame.size.width - SEMI_WID;
        }
        
        if (finalY < SEMI_WID) { // to avoid status bar
            finalY = SEMI_WID;
        } else if (finalY > self.view.frame.size.height - SEMI_WID) {
            finalY = self.view.frame.size.height - SEMI_WID;
        }
        
        CGFloat animationDuration = (ABS(velocityX) * .0002) + .2;
        
        NSLog(@"the duration is: %f", animationDuration);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
        [[sender view] setCenter:CGPointMake(finalX, finalY)];
        [UIView commitAnimations];
    }
}

- (void)animationDidFinish {
    
}

- (void)showMenu {
    [self.viewMenuStop setHidden:NO];
    [self.viewMenuPause setHidden:NO];
    [self.viewMenuMute setHidden:NO];
    [self.viewMenuAdd setHidden:NO];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.constraintMuteViewBottom setConstant:195];
        [self.constraintAddViewBottom setConstant:148];
        [self.constraintPauseViewBottom setConstant:101];
        [self.constraintStopViewBottom setConstant:54];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)hideMenu {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.constraintStopViewBottom setConstant:MENU_BOTTOM];
        [self.constraintPauseViewBottom setConstant:MENU_BOTTOM];
        [self.constraintMuteViewBottom setConstant:MENU_BOTTOM];
        [self.constraintAddViewBottom setConstant:MENU_BOTTOM];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.viewMenuStop setHidden:YES];
        [self.viewMenuPause setHidden:YES];
        [self.viewMenuMute setHidden:YES];
        [self.viewMenuAdd setHidden:YES];
    }];
}

- (void)getGroopviewDetail {
    if (self.groopviewId != nil) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[GVService shared] getGroopviewById:self.groopviewId withCompletion:^(BOOL success, id res) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                NSLog(@"Groop Detail: %@", res);
                self.curGroopview = [[GVGroop alloc] initWithDictionary:res[@"data"]];
                NSString *adminPhone = self.curGroopview.adminPhone;
                NSString *myPhone = [GVGlobal shared].mUser.phoneNumber;
                if ([adminPhone isEqualToString:myPhone]) {
                    self.isAdmin = YES;
                }
                else {
                    self.isAdmin = NO;
                }
                
//                [self listenRoomInfo];
                
                [self getTwilioAccessToken];
                
                [self playVideo];
                
            }
            else if ([res isKindOfClass:[NSError class]]) {
                NSError *error = res;
                [GVGlobal showAlertWithTitle:GROOPVIEW
                                     message:error.localizedDescription
                                    fromView:self
                              withCompletion:nil];
            }
            else {
                [GVGlobal showAlertWithTitle:GROOPVIEW
                                     message:GV_ERROR_MESSAGE
                                    fromView:self
                              withCompletion:nil];
            }
        }];
    }
    else {
        [GVGlobal showAlertWithTitle:GROOPVIEW
                             message:GV_ERROR_MESSAGE
                            fromView:self
                      withCompletion:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (void)getTwilioAccessToken {
    if (self.groopviewId != nil) {
        [[GVService shared] getTwilioAccessTokenByGroopviewId:self.groopviewId withCompletion:^(BOOL success, id res) {
            if (success) {
                if (res[@"token"]) {
                    
                    self.accessToken = res[@"token"];
                    self.roomName = res[@"room_name"];
                    
                    // Prepare the local media
                    [self prepareLocalMedia];
                    // Connect to Room
                    [self connectToRoom];
                }
            }
            else {
                [GVGlobal showAlertWithTitle:GROOPVIEW
                                     message:@"Failed to get the token.\nWould you retry now?"
                              yesButtonTitle:@"Yes" noButtonTitle:@"Later"
                                    fromView:self
                               yesCompletion:^(UIAlertAction *action) {
                    [self getTwilioAccessToken];
                }];
            }
        }];
    }
    else {
        NSLog(@"Invalid Groopview ID...");
    }
}

- (void)connectToRoom {
    TVIConnectOptions *connectOptions = [TVIConnectOptions optionsWithToken:self.accessToken block:^(TVIConnectOptionsBuilder * _Nonnull builder) {
        // Use the local media that we prepared earlier.
        builder.audioTracks = self.localAudioTrack ? @[self.localAudioTrack]: @[];
        builder.videoTracks = self.localVideoTrack ? @[self.localVideoTrack]: @[];
        
        // The name of the Room where the Client will attempt to connect to. Please note that if you pass an empty
        // Room `name`, the Client will create one for you. You can get the name or sid from any connected Room.
        builder.roomName = self.roomName;
    }];
    
    self.room = [TwilioVideo connectWithOptions:connectOptions delegate:self];
}

- (NSString *)getFreeParticipantKey {
    if ([GVGlobal isNull:[self.participantsDic objectForKey:FIRST]]) {
        return FIRST;
    }
    else if ([GVGlobal isNull:[self.participantsDic objectForKey:SECOND]]) {
        return SECOND;
    }
    else if ([GVGlobal isNull:[self.participantsDic objectForKey:THIRD]]) {
        return THIRD;
    }
    return nil;
}

#pragma mark - Video Management

- (void)playVideo {
    if (self.curGroopview == nil) {
        return;
    }
    
    NSString *defaultVideoURL = @"https://s3.amazonaws.com/groopview-play/output/hls/9e67f585d3ac50ac99ab4ffbdf1924970831eef3f496478ec31fbdb883444693/hls_9e67f585d3ac50ac99ab4ffbdf1924970831eef3f496478ec31fbdb883444693.m3u8";
    NSString *defaultVideoThumb = @"https://s3.amazonaws.com/groopview-thumbnails/output/hls/9e67f585d3ac50ac99ab4ffbdf1924970831eef3f496478ec31fbdb883444693/d1a32_Lebron_James_Career_Highlights-00001.png";
    
    if (self.curGroopview.videoURL.length > 0) {
        defaultVideoURL = self.curGroopview.videoURL;
    }
    if (self.curGroopview.videoThumbnail.length > 0) {
        defaultVideoThumb = self.curGroopview.videoThumbnail;
    }
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:defaultVideoURL]];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    
//    CALayer *superLayer = self.viewVideo.layer;
//    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
//    [playerLayer setFrame:self.viewVideo.bounds];
//    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//    [superLayer addSublayer:playerLayer];
    
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    [playerVC setPlayer:player];
    [self addChildViewController:playerVC];
    [self.viewVideo addSubview:playerVC.view];
    [playerVC.view setFrame:self.viewVideo.bounds];
    
    [playerVC.player play];
}

#pragma mark - Contact Management

- (void)hideContactsView {
    [self.viewContactsCover setHidden:YES];
    [self.viewContacts setAlpha:0];
}

- (void)showContactsView {
    [self.viewContactsCover setHidden:NO];
    [self.viewContacts setTransform:CGAffineTransformMakeScale(0.01, 0.01)];
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.viewContacts setAlpha:1];
        [self.viewContacts setTransform:CGAffineTransformIdentity];
        [self.viewContacts layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.viewContacts setUserInteractionEnabled:YES];
        
        [self contactScan];
    }];
}

- (void)contactScan {
    if ([CNContactStore class]) {
        //ios9 or later
        CNEntityType entityType = CNEntityTypeContacts;
        if ([CNContactStore authorizationStatusForEntityType:entityType] == CNAuthorizationStatusNotDetermined) {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:entityType completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if(granted){
                    [self readContacts];
                }
            }];
        }
        else if ([CNContactStore authorizationStatusForEntityType:entityType] ==  CNAuthorizationStatusAuthorized) {
            [self readContacts];
        }
    }
}

- (void)readContacts {
    NSMutableArray *contacts = [NSMutableArray new];
    //    id<CNKeyDescriptor> key = [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName];
    NSArray *keysToFetch =@[CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPostalAddressesKey];
    //    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    
    NSMutableArray *containers = [NSMutableArray new];
    containers = [[contactStore containersMatchingPredicate:nil error:nil] mutableCopy];
    
    for (CNContainer *container in containers) {
        
        NSPredicate *fetchPredicate = [CNContact predicateForContactsInContainerWithIdentifier:container.identifier];
        NSArray *containerResults = [contactStore unifiedContactsMatchingPredicate:fetchPredicate keysToFetch:keysToFetch error:nil];
        [contacts addObjectsFromArray:[containerResults mutableCopy]];
    }
    
    [self getUsers:contacts];
    
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
    //
    //        if (!*stop) {
    //            [contacts addObject:contact];
    //        }
    //        else { // at the end
    //            [MBProgressHUD hideHUDForView:self.view animated:YES];
    //            [self getUsers:contacts];
    //        }
    //    }];
}

- (void)getUsers:(NSMutableArray *)contacts {
    self.arrAllContacts = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *phoneNumbers = [[NSMutableDictionary alloc] init];
    for (CNContact *contact in contacts) {
        GVUser *user = [[GVUser alloc] init];
        if ([GVGlobal isNull:contact.familyName]
            && [GVGlobal isNull:contact.givenName]) {
            continue;
        }
        user.firstName = contact.givenName;
        user.lastName = contact.familyName;
        user.userName = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        [user createShortName];
        
        for (CNLabeledValue *labeledValue in contact.phoneNumbers) {
            
            if ([GVGlobal isNull:labeledValue]
                || [GVGlobal isNull:labeledValue.value]) {
                continue;
            }
            CNPhoneNumber *phone = labeledValue.value;
            if (phone.stringValue.length < 6) {
                continue;
            }
            
            NSMutableDictionary *phoneDic = [GVGlobal extractPhoneNumberFrom:phone.stringValue];
            if ([phoneDic objectForKey:@"phone_number"]) {
                NSString *pn = [phoneDic objectForKey:@"phone_number"];
                NSString *cc = [phoneDic objectForKey:@"country_code"];
                if ([GVGlobal isNull:pn]) {
                    continue;
                }
                NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
                NSString *regionCode = [phoneUtil getRegionCodeForCountryCode:[NSNumber numberWithInteger:cc.integerValue]];
                if ([GVGlobal isNull:cc]
                    || cc.length == 0
                    || [regionCode isEqualToString:@"ZZ"]) {
                    cc = [NSString stringWithFormat:@"%@", [phoneUtil getCountryCodeForRegion:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]]];
                }
                if ([pn isEqualToString:[GVGlobal shared].mUser.phoneNumber]
                    && [cc isEqualToString:[GVGlobal shared].mUser.countryCode]) {
                    continue;
                }
                if ([phoneNumbers objectForKey:pn] == nil) {
                    [phoneNumbers setObject:pn forKey:pn];
                    user.phoneNumber = pn;
                    user.countryCode = cc;
                    break;
                }
            }
        }
        if (user.phoneNumber != nil
            && user.countryCode != nil) {
            if (self.curGroopview) {
                for (GVParticipant *participant in self.curGroopview.members) {
                    if ([user.phoneNumber isEqualToString:participant.phoneNumber]) {
                        [user setIsAdded:YES];
                        break;
                    }
                }
            }
            [self.arrAllContacts addObject:user];
        }
    }
    
    self.arrGroopviewContacts = [NSMutableArray array];
    // --
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GVService shared] checkPhonenumbersExist:[NSMutableArray arrayWithArray:phoneNumbers.allKeys] withCompletion:^(BOOL success, id res) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            if (res[@"phone_numbers"]) {
                for (GVUser *user in self.arrAllContacts) {
                    for (NSString *phoneNumber in res[@"phone_numbers"]) {
                        if ([user.phoneNumber isEqualToString:phoneNumber]) {
                            [user setIsGroopview:YES];
                            [self.arrGroopviewContacts addObject:user];
                            break;
                        }
                    }
                }
                [self.tblContacts reloadData];
            }
        }
        else if ([res isKindOfClass:[NSError class]]) {
            NSError *error = res;
            [GVGlobal showAlertWithTitle:GROOPVIEW message:[NSString stringWithFormat:@"%@", error.localizedDescription] fromView:self withCompletion:nil];
        }
    }];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segContacts.selectedSegmentIndex == 0) {
        return self.arrAllContacts.count;
    }
    else {
        return self.arrGroopviewContacts.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GVContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SessionContactCell" forIndexPath:indexPath];
    if (cell) {
        GVUser *user;
        if (self.segContacts.selectedSegmentIndex == 0
            && self.arrAllContacts.count > indexPath.row) {
            user = [self.arrAllContacts objectAtIndex:indexPath.row];
        }
        else if (self.segContacts.selectedSegmentIndex == 1
                   && self.arrGroopviewContacts.count > indexPath.row) {
            user = [self.arrGroopviewContacts objectAtIndex:indexPath.row];
        }
        
        if ([GVGlobal isNull:user]) {
            return nil;
        }
        
        if (user.isAdded) {
            [cell.btnInvite setHidden:YES];
            [cell.btnAdd setBackgroundImage:[UIImage imageNamed:@"AddContactRed"] forState:UIControlStateNormal];
        }
        else {
            [cell.btnInvite setHidden:NO];
            [cell.btnAdd setBackgroundImage:[UIImage imageNamed:@"AddContactGray"] forState:UIControlStateNormal];
        }
        
        [cell.btnAdd setTag:indexPath.row];
        [cell.btnInvite setTag:indexPath.row];
        [cell.lblAvatar setText:user.shortName];
        [cell.lblName setText:user.userName];
    }
    return cell;
}

#pragma mark - Twilio

- (void)startPreview {
    self.camera = [[TVICameraCapturer alloc] initWithSource:TVICameraCaptureSourceFrontCamera delegate:self];
    
    // Setup the video constraints
    TVIVideoConstraints *videoConstraints = [TVIVideoConstraints constraintsWithBlock:
                                             ^(TVIVideoConstraintsBuilder * _Nonnull builder) {
                                                 builder.maxSize = TVIVideoConstraintsSize960x540;
                                                 builder.minSize = TVIVideoConstraintsSize480x360;
                                                 builder.maxFrameRate = TVIVideoConstraintsFrameRateNone;
                                                 builder.minFrameRate = TVIVideoConstraintsFrameRateNone;
                                             }];
    
    self.localVideoTrack = [TVILocalVideoTrack trackWithCapturer:self.camera enabled:YES constraints:videoConstraints name:LOCAL_VIDEO_TRACK_NAME];
    if (!self.localVideoTrack) {
    } else {
        [self.viewHost setMirror:YES];
        [self.viewHost setContentMode:UIViewContentModeScaleAspectFill];
        // Add renderer to video track for local preview
        [self.localVideoTrack addRenderer:self.viewHost];
    }
}

- (void)prepareLocalMedia {
    
    // We will share local audio and video when we connect to room.
    
    // Create an audio track.
    if (!self.localAudioTrack) {
        self.localAudioTrack = [TVILocalAudioTrack trackWithOptions:nil enabled:YES name:@"Audio"];
        
        if (!self.localAudioTrack) {
            NSLog(@"Failed to add Audio Track");
        }
    }
    
    // Create a video track which captures from the camera.
    if (!self.localVideoTrack) {
        [self startPreview];
    }
}

#pragma mark - Actions

- (IBAction)didClickStop:(id)sender {
    [GVGlobal showAlertWithTitle:GROOPVIEW message:@"Are you sure you want to stop this groopview?" yesButtonTitle:@"Yes" noButtonTitle:@"Cancel" fromView:self yesCompletion:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)didClickMenu:(id)sender {
    [self.btnMenu setSelected:!self.btnMenu.isSelected];
    if (self.btnMenu.isSelected) {
        [self showMenu];
    }
    else {
        [self hideMenu];
    }
}

- (IBAction)didClickMuteAudio:(UIButton *)sender {
    // We will toggle the mic to mute/unmute and change the title according to the user action.
    
    if (self.localAudioTrack) {
        self.localAudioTrack.enabled = !self.localAudioTrack.isEnabled;
        
        [sender setSelected:!self.localAudioTrack.enabled];
        
        // Toggle the button title
        if (self.localAudioTrack.isEnabled) {
            [self.lblMuteAudio setText:@"Mute Audio"];
        }
        else {
            [self.lblMuteAudio setText:@"Unmute Audio"];
        }
    }
}

- (IBAction)didClickPauseSharing:(UIButton *)sender {
    if (self.localParticipant) {
        [sender setSelected:!sender.isSelected];
        if (sender.isSelected) { // Pause Sharing
            [self.lblPauseSharing setText:@"Resume Sharing"];
            
            for (TVILocalVideoTrackPublication *trackPublication in self.localParticipant.localVideoTracks) {
                if ([trackPublication.videoTrack.name isEqualToString:self.localVideoTrack.name]) {
                    [self.localParticipant unpublishVideoTrack:self.localVideoTrack];
                }
            }
        }
        else { // Resume
            [self.lblPauseSharing setText:@"Pause Sharing"];
            
            Boolean isExisted = NO;
            for (TVILocalVideoTrackPublication *trackPublication in self.localParticipant.localVideoTracks) {
                if ([trackPublication.videoTrack.name isEqual:self.localVideoTrack.name]) {
                    [self.localParticipant unpublishVideoTrack:self.localVideoTrack];
                    isExisted = YES;
                    break;
                }
            }
            if (!isExisted) {
                [self.localParticipant publishVideoTrack:self.localVideoTrack];
            }
        }
    }
}

- (IBAction)didClickAddParticipant:(id)sender {
    if ([GVGlobal isNull:self.curGroopview]) {
        return;
    }
    if (!self.isAdmin) {
        [GVGlobal showAlertWithTitle:GROOPVIEW
                             message:@"The only host can add new participant."
                            fromView:self
                      withCompletion:nil];
        return;
    }
    [self showContactsView];
}

- (IBAction)didClickCloseContacts:(id)sender {
    [self hideContactsView];
}

- (IBAction)didValueChangedSegContacts:(id)sender {
    [self.tblContacts reloadData];
}

- (IBAction)didClickInvite:(UIButton *)sender {
    NSInteger index = sender.tag;
    GVUser *user;
    if (self.segContacts.selectedSegmentIndex == 0
        && self.arrAllContacts.count > index) {
        user = [self.arrAllContacts objectAtIndex:index];
    } 
    else if (self.segContacts.selectedSegmentIndex == 1
               && self.arrGroopviewContacts.count > index) {
        user = [self.arrGroopviewContacts objectAtIndex:index];
    }
    
    if (user == nil
        || user.isAdded) {
        return;
    }
    
    //
}

#pragma mark - TVIRoomDelegate

- (void)didConnectToRoom:(TVIRoom *)room {
    NSLog(@"Connected to Room - %@", room.name);
    self.localParticipant = room.localParticipant;
    
    for (TVIRemoteParticipant *participant in room.remoteParticipants) {
        [participant setDelegate:self];
    }
}

- (void)room:(TVIRoom *)room didDisconnectWithError:(NSError *)error {
    NSLog(@"Disconnected to Room - %@ Error - %@", room.name, error? error.localizedDescription: @"");
    self.localParticipant = nil;
    self.room = nil;
    if (error) {
        [GVGlobal showAlertWithTitle:GROOPVIEW
                             message:[NSString stringWithFormat:@"%@\n\n%@", error.localizedDescription, @"Would you like to reconnect now?"]
                      yesButtonTitle:@"Yes"
                       noButtonTitle:@"Later"
                            fromView:self
                       yesCompletion:^(UIAlertAction *action) {
            [self connectToRoom];
        }];
    }
}

- (void)room:(TVIRoom *)room didFailToConnectWithError:(NSError *)error {
    if (error) {
        [GVGlobal showAlertWithTitle:GROOPVIEW
                             message:[NSString stringWithFormat:@"%@\n\n%@", error.localizedDescription, @"Would you like to try again now?"]
                      yesButtonTitle:@"Yes"
                       noButtonTitle:@"Later"
                            fromView:self
                       yesCompletion:^(UIAlertAction *action) {
            [self connectToRoom];
        }];
    }
}

- (void)room:(TVIRoom *)room participantDidConnect:(TVIRemoteParticipant *)participant {
    [participant setDelegate:self];
    if (self.room && self.room.remoteParticipants) {
        Boolean isExisted = NO;
        for (TVIRemoteParticipant *item in self.room.remoteParticipants) {
            if ([participant.identity isEqualToString:item.identity]) {
                isExisted = YES;
                break;
            }
        }
        if (!isExisted) {
            [self.room.remoteParticipants arrayByAddingObject:participant];
        }
    }
}

- (void)room:(TVIRoom *)room participantDidDisconnect:(TVIRemoteParticipant *)participant {
    
}

#pragma mark - TVIRemoteParticipantDelegate

- (void)subscribedToVideoTrack:(TVIRemoteVideoTrack *)videoTrack publication:(TVIRemoteVideoTrackPublication *)publication forParticipant:(TVIRemoteParticipant *)participant {
    
    NSString *participantKey = [self getFreeParticipantKey];
    if (participantKey) {
        [self.participantsDic setObject:participant forKey:participantKey];
        
        TVIVideoView *videoView = [self.videoViewsDic objectForKey:participantKey];
        [videoView setMirror:YES];
        [videoView setHidden:NO];
        [videoTrack addRenderer:videoView];
    }
}

- (void)unsubscribedFromVideoTrack:(TVIRemoteVideoTrack *)videoTrack publication:(TVIRemoteVideoTrackPublication *)publication forParticipant:(TVIRemoteParticipant *)participant {
    
    for (NSString *key in self.participantsDic.allKeys) {
        TVIRemoteParticipant *remoteParticipant = [self.participantsDic objectForKey:key];
        if ([participant.identity isEqualToString:remoteParticipant.identity]) {
            TVIVideoView *videoView = [self.videoViewsDic objectForKey:key];
            [videoView setHidden:YES];
            [videoTrack removeRenderer:videoView];
            [self.participantsDic removeObjectForKey:key];
            break;
        }
    }
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant publishedAudioTrack:(TVIRemoteAudioTrackPublication *)publication {
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant unpublishedAudioTrack:(TVIRemoteAudioTrackPublication *)publication {
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant publishedVideoTrack:(TVIRemoteVideoTrackPublication *)publication {
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant unpublishedVideoTrack:(TVIRemoteVideoTrackPublication *)publication {
}

- (void)subscribedToAudioTrack:(TVIRemoteAudioTrack *)audioTrack publication:(TVIRemoteAudioTrackPublication *)publication forParticipant:(TVIRemoteParticipant *)participant {
}

- (void)unsubscribedFromAudioTrack:(TVIRemoteAudioTrack *)audioTrack publication:(TVIRemoteAudioTrackPublication *)publication forParticipant:(TVIRemoteParticipant *)participant {
}

- (void)subscribedToDataTrack:(TVIRemoteDataTrack *)dataTrack publication:(TVIRemoteDataTrackPublication *)publication forParticipant:(TVIRemoteParticipant *)participant {
}

- (void)unsubscribedFromDataTrack:(TVIRemoteDataTrack *)dataTrack publication:(TVIRemoteDataTrackPublication *)publication forParticipant:(TVIRemoteParticipant *)participant {
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant enabledAudioTrack:(TVIRemoteAudioTrackPublication *)publication {
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant disabledAudioTrack:(TVIRemoteAudioTrackPublication *)publication {
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant enabledVideoTrack:(TVIRemoteVideoTrackPublication *)publication {
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant disabledVideoTrack:(TVIRemoteVideoTrackPublication *)publication {
}

- (void)failedToSubscribeToAudioTrack:(TVIRemoteAudioTrackPublication *)publication error:(NSError *)error forParticipant:(TVIRemoteParticipant *)participant {
}

- (void)failedToSubscribeToVideoTrack:(TVIRemoteVideoTrackPublication *)publication error:(NSError *)error forParticipant:(TVIRemoteParticipant *)participant {
}

- (void)failedToSubscribeToDataTrack:(TVIRemoteDataTrackPublication *)publication error:(NSError *)error forParticipant:(TVIRemoteParticipant *)participant {
}



@end
