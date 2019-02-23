//
//  GVGroopviewController.m
//  sdkm
//
//  Created by Mobile on 19.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVGroopviewController.h"
#import "GVGroop.h"
#import "ReactionsView.h"
#import "GVContactCell.h"
#import <TwilioVideo/TwilioVideo.h>
#import <Contacts/Contacts.h>
#import <AVKit/AVKit.h>
@import Firebase;

//#define SEMI_WID 50.0f
#define MENU_BOTTOM 12.0f

#define FIRST @"first"
#define SECOND @"second"
#define THIRD @"third"

#define LOCAL_VIDEO_TRACK_NAME  @"local_video_track"

@interface GVGroopviewController () <TVICameraCapturerDelegate, TVIRoomDelegate, TVIRemoteParticipantDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    CGFloat firstX;
    CGFloat firstY;
    CGFloat chatWindowWid;
}

@property (weak, nonatomic) IBOutlet ReactionsView *viewContent;

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
@property (weak, nonatomic) IBOutlet UIView *viewMenuSendMessage;
@property (weak, nonatomic) IBOutlet UIView *viewMenuSendReaction;

// Contacts
@property (weak, nonatomic) IBOutlet UIView *viewContactsCover;
@property (weak, nonatomic) IBOutlet UIView *viewContacts;
@property (weak, nonatomic) IBOutlet UITableView *tblContacts;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segContacts;
@property (weak, nonatomic) IBOutlet UIView *viewSegment;

// Chat
@property (weak, nonatomic) IBOutlet UIView *viewChat;
@property (weak, nonatomic) IBOutlet UITextField *txtMessage;
@property (weak, nonatomic) IBOutlet UIView *viewMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblMsgSenderName;
@property (weak, nonatomic) IBOutlet UILabel *lblMsgText;
@property (weak, nonatomic) IBOutlet UIView *viewReactions;

#pragma mark - Constraints

/// Default - 270
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMuteViewBottom;
/// Default - 227
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAddViewBottom;
/// Default - 184
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPauseViewBottom;
/// Default - 141
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintStopViewBottom;
/// Default - 98
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSendMessageBottom;
/// Default - 55
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSendReactionBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMuteAudioTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAddParticipantTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPauseTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintStopTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMenuTrailing;

/// 12
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintChatViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintChatViewWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMessageViewTop;

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

// Play Video
@property (nonatomic, strong) AVPlayerViewController *playerVC;
@property (nonatomic, strong) id playbackTimeObserver;

// Firebase Database
@property (nonatomic, strong) FIRDatabaseReference *firRef;
@property (nonatomic, strong) FIRDatabaseReference *messagesRef;

// Chat Text Emoji
@property (strong, nonatomic) NSTimer *chatAppearanceTimer;
/// Indicate how long the chat view is visible for without editing
@property NSInteger chatAppearances;

@end

@implementation GVGroopviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.firRef = [[FIRDatabase database] reference];
    self.messagesRef = [[[self.firRef child:[GVShared shared].clientId] child:FIR_MESSAGES_KEY] child:[NSString stringWithFormat:@"%@", self.groopviewId]];
    
    [self initLayout];
    
    // Start Preview
    [self hideContactsView];
    
    // --
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREF_GROOPVIEW_STARTED];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Get Groopview Detail
    [self getGroopviewDetail];
    
    // Listen new Text / Emoji for Chat
    [self listenChatTextEmoji];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [GVShared lockScreen:UIInterfaceOrientationMaskLandscape andRotateTo:UIInterfaceOrientationLandscapeLeft];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.room != nil) {
        [self.room disconnect];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
//    [[GVShared shared] setLockOrientation:UIInterfaceOrientationMaskAll];
    [GVShared lockScreen:UIInterfaceOrientationMaskPortrait andRotateTo:UIInterfaceOrientationPortrait];
    
    if (self.playerVC) {
        [self.playerVC.player removeTimeObserver:self.playbackTimeObserver];
        [self.playerVC.player replaceCurrentItemWithPlayerItem:nil];
        self.playerVC.player = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_GROOPVIEW_STARTED];
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
    
    // --
    [self layoutMenuButtons];
    
    if (GV_IPHONE) {
        chatWindowWid = GV_SCREEN_WIDTH * 70 / 320.0f;
    }
    else
        chatWindowWid = 140;
    
    [self.viewParticipant1 setFrame:CGRectMake(16, 16, chatWindowWid, chatWindowWid)];
    [self.viewParticipant2 setFrame:CGRectMake(16, 16 + chatWindowWid + 4, chatWindowWid, chatWindowWid)];
    [self.viewParticipant3 setFrame:CGRectMake(16, 16 + (chatWindowWid + 4) * 2.0f, chatWindowWid, chatWindowWid)];
    [self.viewHost setFrame:CGRectMake(16, 16 + (chatWindowWid + 4) * 3.0f, chatWindowWid, chatWindowWid)];
    
    // -- Participant View Layout
    [self.viewHost.layer setCornerRadius:self.viewHost.frame.size.height / 2];
    [self.viewParticipant1.layer setCornerRadius:self.viewParticipant1.frame.size.height / 2];
    [self.viewParticipant2.layer setCornerRadius:self.viewParticipant2.frame.size.height / 2];
    [self.viewParticipant3.layer setCornerRadius:self.viewParticipant3.frame.size.height / 2];
    
    [self.viewHost.layer setBorderWidth:1];
    [self.viewHost.layer setBorderColor:[GVShared shared].themeColor.CGColor];
    [self.viewParticipant1.layer setBorderWidth:1];
    [self.viewParticipant2.layer setBorderWidth:1];
    [self.viewParticipant3.layer setBorderWidth:1];
    
    [self.viewParticipant1 setHidden:YES];
    [self.viewParticipant2 setHidden:YES];
    [self.viewParticipant3 setHidden:YES];
    
    [self initParticipantBorders];
    
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
    [self.viewMenuSendMessage.layer setCornerRadius:wid];
    [self.viewMenuSendReaction.layer setCornerRadius:wid];
    
    [self.constraintMuteViewBottom setConstant:MENU_BOTTOM];
    [self.constraintPauseViewBottom setConstant:MENU_BOTTOM];
    [self.constraintStopViewBottom setConstant:MENU_BOTTOM];
    [self.constraintAddViewBottom setConstant:MENU_BOTTOM];
    [self.constraintSendMessageBottom setConstant:MENU_BOTTOM];
    [self.constraintSendReactionBottom setConstant:MENU_BOTTOM];
    
    [self.viewMenuStop setHidden:YES];
    [self.viewMenuPause setHidden:YES];
    [self.viewMenuMute setHidden:YES];
    [self.viewMenuAdd setHidden:YES];
    [self.viewMenuSendMessage setHidden:YES];
    [self.viewMenuSendReaction setHidden:YES];
    
    // Contact Management
    [self.tblContacts setDelegate:self];
    [self.tblContacts setDataSource:self];
    
    UIRefreshControl *refreshC = [[UIRefreshControl alloc] init];
    [refreshC addTarget:self action:@selector(refreshContacts:) forControlEvents:UIControlEventValueChanged];
    [self.tblContacts addSubview:refreshC];
    
    [self.viewSegment setBackgroundColor:[GVShared shared].themeColor];
    
    // Chat
    [self.viewChat.layer setCornerRadius:self.viewChat.frame.size.height / 2];
    [self.viewChat.layer setBorderWidth:1.0f];
    [self.viewChat.layer setBorderColor:[UIColor colorWithRed:26.0 / 255.0 green:56.0 / 255.0 blue:67.0 / 255.0 alpha:1].CGColor];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureOnChatView:)];
    [self.viewChat addGestureRecognizer:panGesture];
    
    [self.txtMessage setKeyboardAppearance:UIKeyboardAppearanceDark];
    [self.txtMessage setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Type here..." attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:143.0 / 255.0 green:153.0 / 255.0 blue:160.0 / 255.0 alpha:1]}]];
    [self.txtMessage setDelegate:self];
    [self.txtMessage addTarget:self action:@selector(didChangeMessage:) forControlEvents:UIControlEventEditingChanged];
    [self.txtMessage setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [self.constraintChatViewWidth setConstant:GV_SCREEN_HEIGHT * 2 / 3];
    [self.constraintChatViewBottom setConstant:-60];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        NSValue *value = [note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect rect = value.CGRectValue;
        
        [self moveChatView:MENU_BOTTOM + rect.size.height];
        
        [self.chatAppearanceTimer invalidate];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        [self moveChatView:MENU_BOTTOM];
        
        [self startTimerForChatAppearance];
    }];
    
    [self.viewReactions setHidden:YES];
    [self.viewReactions.layer setCornerRadius:self.viewReactions.frame.size.height / 2];
    
    [self.viewMessage setHidden:YES];
    [self.viewMessage.layer setCornerRadius:5.0f];
    [self.lblMsgSenderName setText:@""];
    [self.lblMsgText setText:@""];
}

- (void)layoutMenuButtons {
    BOOL isPhoneX = NO;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                break;
            case 1920:
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                break;
            case 2436:
                printf("iPhone X, Xs");
            case 2688:
                printf("iPhone Xs Max");
            case 1792:
                printf("iPhone Xr");
                isPhoneX = YES;
                break;
            default:
                printf("unknown");
        }
    }
    CGFloat trailing = 12;
    if (isPhoneX) {
        trailing = 32;
    }
    [self.constraintMuteAudioTrailing setConstant:trailing];
    [self.constraintAddParticipantTrailing setConstant:trailing];
    [self.constraintPauseTrailing setConstant:trailing];
    [self.constraintStopTrailing setConstant:trailing];
    [self.constraintMenuTrailing setConstant:trailing];
}

- (void)initParticipantBorders {
    [self.viewHost.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.viewParticipant1.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.viewParticipant2.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.viewParticipant3.layer setBorderColor:[UIColor darkGrayColor].CGColor];
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
        
        CGFloat semiWid = chatWindowWid / 2.0f;
        if (finalX < semiWid) {
            finalX = semiWid;
        } else if (finalX > self.view.frame.size.width - semiWid) {
            finalX = self.view.frame.size.width - semiWid;
        }
        
        if (finalY < semiWid) { // to avoid status bar
            finalY = semiWid;
        } else if (finalY > self.view.frame.size.height - semiWid) {
            finalY = self.view.frame.size.height - semiWid;
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
    [self.viewMenuSendMessage setHidden:NO];
    [self.viewMenuSendReaction setHidden:NO];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.constraintMuteViewBottom setConstant:270];
        [self.constraintAddViewBottom setConstant:227];
        [self.constraintPauseViewBottom setConstant:184];
        [self.constraintStopViewBottom setConstant:141];
        [self.constraintSendMessageBottom setConstant:98];
        [self.constraintSendReactionBottom setConstant:55];
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
        [self.constraintSendMessageBottom setConstant:MENU_BOTTOM];
        [self.constraintSendReactionBottom setConstant:MENU_BOTTOM];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.viewMenuStop setHidden:YES];
        [self.viewMenuPause setHidden:YES];
        [self.viewMenuMute setHidden:YES];
        [self.viewMenuAdd setHidden:YES];
        [self.viewMenuSendMessage setHidden:YES];
        [self.viewMenuSendReaction setHidden:YES];
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
                    [self.viewHost.layer setBorderColor:[GVShared shared].themeColor.CGColor];
                }
                else {
                    self.isAdmin = NO;
                }
                // Get Twilio Access Token from Groopview Server
                [self getTwilioAccessToken];
                // Play Video on Main Video View
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
                    // Listen Room info from Firebase
                    [self listenRoomInfo];
                }
            }
            else {
                [GVGlobal showAlertWithTitle:GROOPVIEW
                                     message:@"Something went wrong.\nWould you retry now?"
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

#pragma mark - Text / Emoji Chat

- (void)panGestureOnChatView:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint vel = [gestureRecognizer velocityInView:self.viewChat];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (vel.y > 0) { // to bottom
            if (self.constraintChatViewBottom.constant == MENU_BOTTOM) {
                [self hideChatView];
            }
            else {
                [self.view endEditing:YES];
            }
        }
    }
}

- (void)didChangeMessage:(id)sender {
    self.chatAppearances = 0;
}

- (void)hideChatView {
    [self moveChatView:-60];
    
    if (self.chatAppearanceTimer) {
        [self.chatAppearanceTimer invalidate];
    }
    [self.txtMessage setText:@""];
}

- (void)showChatView {
    [self moveChatView:MENU_BOTTOM];
    
    [self startTimerForChatAppearance];
}

- (void)startTimerForChatAppearance {
    self.chatAppearances = 0;
    self.chatAppearanceTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.chatAppearances++;
        if (self.chatAppearances > 5) {
            [self.chatAppearanceTimer invalidate];
            if (self.constraintChatViewBottom.constant == MENU_BOTTOM) {
                [self hideChatView];
            }
        }
    }];
}

- (void)moveChatView:(CGFloat)value {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.constraintChatViewBottom setConstant:value];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)sendMessageBySenderId:(NSString *)senderId
                   senderName:(NSString *)senderName
                      message:(NSString *)message
                      isEmoji:(BOOL)isEmoji {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:senderId forKey:FIR_SENDER_ID];
    [dictionary setObject:senderName forKey:FIR_SENDER_NAME];
    [dictionary setObject:message forKey:FIR_SENDER_MESSAGE];
    [dictionary setObject:isEmoji? @"1": @"0" forKey:FIR_IS_EMOJI];
    
    [[self.messagesRef childByAutoId] setValue:dictionary withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
    }];
}

- (void)showReactions {
    [self.viewReactions setHidden:NO];
    [self.viewReactions setTransform:CGAffineTransformMakeScale(0.01, 0.01)];
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.viewReactions setTransform:CGAffineTransformIdentity];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.viewReactions setUserInteractionEnabled:YES];
    }];
}

- (void)hideReactions {
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.viewReactions setTransform:CGAffineTransformMakeScale(0.00, 0.00)];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.viewReactions setUserInteractionEnabled:NO];
        [self.viewReactions setHidden:YES];
    }];
}

- (void)showViewMessage:(NSString *)message
                 sender:(NSString *)senderName {
    
    [self.viewMessage.layer removeAllAnimations];
    
    [self.lblMsgSenderName setText:senderName];
    [self.lblMsgText setText:message];
    [self.viewMessage setAlpha:1];
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.constraintMessageViewTop setConstant:GV_SCREEN_WIDTH / 2];
        [self.viewMessage layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.viewMessage setHidden:NO];
        [UIView animateWithDuration:5 animations:^{
            [self.viewMessage setAlpha:0];
            [self.constraintMessageViewTop setConstant:0];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.viewMessage setHidden:YES];
        }];
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger maxLength = 30;
    NSString *curString = textField.text;
    NSString *newString = [curString stringByReplacingCharactersInRange:range withString:string];
    return newString.length <= maxLength;
}

#pragma mark - Interact with Firebase

- (void)listenRoomInfo {
    if (!self.isAdmin
        && self.roomName) {
        [[[[self.firRef child:[GVShared shared].clientId] child:FIR_GROOPVIEWS] child:self.roomName] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.value
                && ![snapshot.value isEqual:[NSNull null]]
                && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                NSDictionary *roomInfo = snapshot.value;
                
                // Video State: Play/Pause
                NSString *videoStatus = [roomInfo objectForKey:FIR_VIDEO_STATE];
                if ([videoStatus integerValue] == 0) {
                    [self.playerVC.player pause];
                }
                else if ([videoStatus integerValue] == 1) {
                    [self.playerVC.player play];
                }
                
                // Seek to Time
                NSString *playbackTime = [roomInfo objectForKey:FIR_PLAYBACK_TIME];
                if (labs([playbackTime integerValue] / 1000 - (long)CMTimeGetSeconds(self.playerVC.player.currentItem.currentTime)) > 5) {
                    [self.playerVC.player.currentItem seekToTime:CMTimeMakeWithSeconds([playbackTime doubleValue] / 1000, 60000) completionHandler:^(BOOL finished) {
                        
                    }];
                }
            }
        }];
    }
}

- (void)listenChatTextEmoji {
    
    [self.messagesRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if ([snapshot exists]) {
            NSDictionary *dic = snapshot.value;
//            NSString *senderId = [dic objectForKey:FIR_SENDER_ID];
            NSString *senderName = [dic objectForKey:FIR_SENDER_NAME];
            NSString *message = [dic objectForKey:FIR_SENDER_MESSAGE];
            BOOL isEmoji = (![GVGlobal isNull:[dic objectForKey:FIR_IS_EMOJI]] && [[dic objectForKey:FIR_IS_EMOJI] isEqualToString:@"1"])? YES: NO;
            
            if (isEmoji) {
                [self.viewContent showReaction:[UIImage imageNamed:message inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil]];
            }
            else {
                [self showViewMessage:message
                               sender:senderName];
            }
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"Firebase: %@", error.localizedDescription);
    }];
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
//    [player setMuted:YES];
    
    self.playerVC = [[AVPlayerViewController alloc] init];
    [self.playerVC setPlayer:player];
    [self addChildViewController:self.playerVC];
    [self.viewVideo addSubview:self.playerVC.view];
    [self.playerVC.view setFrame:self.viewVideo.bounds];
    
    if (self.isAdmin) {
        [self.playerVC setShowsPlaybackControls:YES];
    }
    else {
        [self.playerVC setShowsPlaybackControls:NO];
    }
    
    [self.playerVC.player play];
//    [self.playerVC.player setMuted:YES];
    
    // Capturing the Playback Time
    __weak typeof(self) weakSelf = self;
    CMTime interval = CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC); // 1 second
    self.playbackTimeObserver = [self.playerVC.player addPeriodicTimeObserverForInterval:interval queue:nil usingBlock:^(CMTime time) {
        
//        NSLog(@"Play Video: %lld", time.value);
        if (self.isAdmin
            && self.roomName) {
            
            NSString *videoStatus = @"0";
            if (weakSelf.playerVC.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
                NSLog(@"Play Video: Paused...");
                videoStatus = @"0"; // Paused
            }
            else if (weakSelf.playerVC.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
                NSLog(@"Play Video: Playing...");
                videoStatus = @"1"; // Playing
            }
            else
                NSLog(@"Waiting to Play with Specific Rate...");
            
            NSMutableDictionary *playbackInfo = [NSMutableDictionary dictionary];
            [playbackInfo setObject:[NSString stringWithFormat:@"%f", 1000 * CMTimeGetSeconds(time)] forKey:FIR_PLAYBACK_TIME];
            [playbackInfo setObject:weakSelf.groopviewId forKey:FIR_GROOPVIEW_ID];
            [playbackInfo setObject:videoStatus forKey:FIR_VIDEO_STATE];

            [[[[weakSelf.firRef child:[GVShared shared].clientId] child:FIR_GROOPVIEWS] child:weakSelf.roomName] updateChildValues:playbackInfo withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {

            }];
        }
    }];
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
                    [self readContactsForOrder];
                }
            }];
        }
        else if ([CNContactStore authorizationStatusForEntityType:entityType] ==  CNAuthorizationStatusAuthorized) {
            [self readContactsForOrder];
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
}

- (void)readContactsForOrder {
    NSMutableArray *contacts = [NSMutableArray new];
    NSArray *keysToFetch = @[CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPostalAddressesKey];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    [fetchRequest setSortOrder:CNContactSortOrderGivenName];
    
    NSError *error;
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        if (*stop == NO
            && contact)
            [contacts addObject:contact];
    }];
    
    if (error)
        [GVGlobal showAlertWithTitle:GROOPVIEW message:error.localizedDescription fromView:self withCompletion:nil];
    else
        [self getUsers:contacts];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
    [[GVService shared] checkPhonenumbersExist:[NSMutableArray arrayWithArray:phoneNumbers.allKeys] withCompletion:^(BOOL success, id res) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
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
            [cell.btnAdd setBackgroundImage:[UIImage imageNamed:@"AddContactRed" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        }
        else {
            [cell.btnInvite setHidden:NO];
            [cell.btnAdd setBackgroundImage:[UIImage imageNamed:@"AddContactGray" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
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
    
    self.localVideoTrack = [TVILocalVideoTrack trackWithCapturer:self.camera enabled:YES constraints:videoConstraints name:[NSString stringWithFormat:@"%@", [GVGlobal shared].mUser.phoneNumber]];
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
    if (self.btnMenu.isSelected) { // Expand Menu
        [self showMenu];
        [self hideChatView];
    }
    else { // Collapse Menu
        [self hideMenu];
        [self hideReactions];
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
            [self.viewHost setHidden:YES];
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
            [self.viewHost setHidden:NO];
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
    if (self.curGroopview.numberOfParticipants > 3) {
        [GVGlobal showAlertWithTitle:GROOPVIEW message:@"This groopview is full and you can not add more." fromView:self withCompletion:nil];
        return;
    }
    
    Boolean isAdded = NO;
    NSString *first = GV_NULL, *firstCode = GV_NULL, *second = GV_NULL, *secondCode = GV_NULL, *third = GV_NULL, *thirdCode = GV_NULL;
    if (self.curGroopview.members.count > 0) {
        GVParticipant *participant = [self.curGroopview.members objectAtIndex:0];
        if (participant.phoneNumber.length > 0
            && participant.countryCode.length > 0) {
            first = participant.phoneNumber;
            firstCode = participant.countryCode;
        }
    }
    if ([first isEqualToString:GV_NULL]) {
        first = user.phoneNumber;
        firstCode = user.countryCode;
        isAdded = YES;
    }
    NSString *friend1 = [GVGlobal getJsonForFriend:firstCode phoneNumber:first];
    
    if (self.curGroopview.members.count > 1) {
        GVParticipant *participant = [self.curGroopview.members objectAtIndex:1];
        if (participant.phoneNumber.length > 0
            && participant.countryCode.length > 0) {
            second = participant.phoneNumber;
            secondCode = participant.countryCode;
        }
    }
    if (!isAdded
        && [second isEqualToString:GV_NULL]) {
        second = user.phoneNumber;
        secondCode = user.countryCode;
        isAdded = YES;
    }
    NSString *friend2 = [GVGlobal getJsonForFriend:secondCode phoneNumber:second];
    
    if (self.curGroopview.members.count > 2) {
        GVParticipant *participant = [self.curGroopview.members objectAtIndex:2];
        if (participant.phoneNumber.length > 0
            && participant.countryCode.length > 0) {
            third = participant.phoneNumber;
            thirdCode = participant.countryCode;
        }
    }
    if (!isAdded
        && [third isEqualToString:GV_NULL]) {
        third = user.phoneNumber;
        thirdCode = user.countryCode;
        isAdded = YES;
    }
    NSString *friend3 = [GVGlobal getJsonForFriend:thirdCode phoneNumber:third];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GVService shared] updateGroopviewWithId:self.groopviewId groopId:@"" videoURL:self.curGroopview.videoURL videoThumb:self.curGroopview.videoThumbnail isJoinNow:self.curGroopview.isRightNow joinTime:self.curGroopview.joinTime friend1:friend1 friend2:friend2 friend3:friend3 withCompletion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            [user setIsAdded:YES];
            [self.tblContacts reloadData];
        }
    }];
    
}

- (IBAction)didClickSend:(id)sender {
    // Send message to the Groop Participants
    NSString *message = self.txtMessage.text;
    if (message.length == 0) {
        return;
    }
    
    NSString *senderId = [GVGlobal shared].mUser.phoneNumber;
    NSString *senderName = [GVGlobal shared].mUser.userName;
    
    [self sendMessageBySenderId:senderId
                     senderName:senderName
                        message:message
                        isEmoji:NO];
    
    [self.txtMessage setText:@""];
    [self.view endEditing:YES];
}

- (IBAction)didClickSendMessage:(UIButton *)sender {
    [self showChatView];
    [self didClickMenu:self.btnMenu];
}

- (IBAction)didClickSendReaction:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    if (sender.isSelected) {
        [self showReactions];
    }
    else {
        [self hideReactions];
    }
}

- (IBAction)didClickReactions:(UIButton *)sender {
    
    NSString *imageName = @"reaction_smile";
    switch (sender.tag) {
        case 0:
            imageName = @"reaction_angry";
            break;
        case 1:
            imageName = @"reaction_sad";
            break;
        case 2:
            imageName = @"reaction_surprise";
            break;
        case 3:
            imageName = @"reaction_smile";
            break;
        case 4:
            imageName = @"reaction_laugh";
            break;
        case 5:
            imageName = @"reaction_heart";
            break;
        case 6:
            imageName = @"reaction_thumbup";
            break;
            
        default:
            break;
    }
    NSString *senderId = [GVGlobal shared].mUser.phoneNumber;
    NSString *senderName = [GVGlobal shared].mUser.userName;
    
    [self sendMessageBySenderId:senderId
                     senderName:senderName
                        message:imageName
                        isEmoji:YES];
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
        [self.participantsDic setObject:participant.identity forKey:participantKey];
        
        TVIVideoView *videoView = [self.videoViewsDic objectForKey:participantKey];
        [videoView setMirror:YES];
        [videoView setHidden:NO];
        [videoTrack addRenderer:videoView];
        
        NSString *trackName = videoTrack.name;
        NSString *adminPhone = [NSString stringWithFormat:@"%@", self.curGroopview.adminPhone];
        if ([trackName isEqualToString:adminPhone]) {
            [self initParticipantBorders];
            [videoView.layer setBorderColor:[GVShared shared].themeColor.CGColor];
        }
    }
}

- (void)unsubscribedFromVideoTrack:(TVIRemoteVideoTrack *)videoTrack publication:(TVIRemoteVideoTrackPublication *)publication forParticipant:(TVIRemoteParticipant *)participant {
    
    for (NSString *key in self.participantsDic.allKeys) {
        NSString *remoteIdentity = [self.participantsDic objectForKey:key];
        if ([participant.identity isEqualToString:remoteIdentity]) {
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
