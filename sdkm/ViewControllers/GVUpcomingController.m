//
//  GVUpcomingController.m
//  sdkm
//
//  Created by Mobile on 19.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVUpcomingController.h"
#import "GVGroopDetailController.h"
#import "iCarousel.h"
#import "GVGroop.h"
#import "GVUpcomingView.h"

@interface GVUpcomingController () <iCarouselDelegate, iCarouselDataSource> {
}

@property (weak, nonatomic) IBOutlet iCarousel *iCarouselView;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *beforeButton;

@property (strong, nonatomic) NSMutableArray *allGroopviews;

@end

@implementation GVUpcomingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initLayout];
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
    
    [self.navigationItem setTitle:@"Upcoming Groopviews"];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(didClickBack)]];
    
    [self.noResultsLabel setHidden:YES];
    
    [self.iCarouselView setDelegate:self];
    [self.iCarouselView setDataSource:self];
    [self.iCarouselView setType:iCarouselTypeRotary];
    
    [self.indexLabel setText:@""];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getGroopviews];
}

- (void)getGroopviews {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GVService shared] getGroopviewsWithCompletion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            NSLog(@"Groopviews: %@", res);
            if (res[@"data"]) {
                self.allGroopviews = [NSMutableArray array];
                for (NSDictionary *dic in res[@"data"]) {
                    GVGroop *groop = [[GVGroop alloc] initWithDictionary:dic];
                    [self.allGroopviews addObject:groop];
//                    [self putObserverWithGroopviewID:groopModel.groopID];
                }
                if (self.allGroopviews.count == 0) {
                    [self.noResultsLabel setHidden:NO];
                    [self.beforeButton setEnabled:NO];
                    [self.nextButton setEnabled:NO];
                }
                else {
                    [self.noResultsLabel setHidden:YES];
                    [self.beforeButton setEnabled:YES];
                    [self.nextButton setEnabled:YES];
                    if (self.allGroopviews.count == 1) {
                        [self.iCarouselView setScrollEnabled:NO];
                    }
                    [self updateIndexLabel];
                }
                [self.iCarouselView reloadData];
            }
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

- (void)updateIndexLabel {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    [attrStr append:[NSString stringWithFormat:@"%ld ", ((long)self.iCarouselView.currentItemIndex + 1)]
               size:GV_SCREEN_HEIGHT * 17 / 667.0
           fontName:self.indexLabel.font.fontName
              align:NSTextAlignmentCenter];
    [attrStr append:[NSString stringWithFormat:@"of %lu", (unsigned long)self.allGroopviews.count]
               size:GV_SCREEN_HEIGHT * 12 / 667.0
           fontName:self.indexLabel.font.fontName
              align:NSTextAlignmentCenter];
    [self.indexLabel setAttributedText:attrStr];
}

- (void)removeGroopviewAtIndex:(NSInteger)index {
    if (index < self.allGroopviews.count) {
        GVGroop *groopview = [self.allGroopviews objectAtIndex:index];
        NSString *groopviewId = groopview.groopId;
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[GVService shared] removeGroopviewWithId:groopviewId withCompletion:^(BOOL success, id res) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                if (res[@"status"]) { // Successfull deleted
                    [self getGroopviews];
                }
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
}

#pragma mark - Actions

- (void)didClickBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)beforeClicked:(UIButton *)sender {
    NSInteger itemCount = self.allGroopviews.count;
    NSInteger beforeIndex = self.iCarouselView.currentItemIndex - 1;
    if (beforeIndex < 0) {
        beforeIndex = itemCount + beforeIndex;
    }
    [self.iCarouselView scrollToItemAtIndex:beforeIndex animated:YES];
}

- (IBAction)nextClicked:(UIButton *)sender {
    NSInteger itemCount = self.allGroopviews.count;
    NSInteger nextIndex = self.iCarouselView.currentItemIndex + 1;
    if (nextIndex >= 10) {
        nextIndex = itemCount - nextIndex;
    }
    [self.iCarouselView scrollToItemAtIndex:nextIndex animated:YES];
}

- (void)didClickRemove:(UIButton *)sender {
    [GVGlobal showAlertWithTitle:GROOPVIEW message:@"Are you sure you want to remove this Groopview?" yesButtonTitle:@"Yes" noButtonTitle:@"No" fromView:self yesCompletion:^(UIAlertAction *action) {
        
        // Remove Groopview
        [self removeGroopviewAtIndex:sender.tag];
    }];
}

#pragma mark - iCarouselDelegate & iCarouselDataSource

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    if (self.allGroopviews) {
        return self.allGroopviews.count;
    }
    return 0;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    //create new view if no view is available for recycling
    if (view == nil) {
        GVGroop *groop = [self.allGroopviews objectAtIndex:index];
        
        CGFloat cellHei = GV_SCREEN_HEIGHT * 500 / 667.0;
        CGFloat cellWid = cellHei * 300 / 535;
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWid, cellHei)];
        GVUpcomingView *upcomingView = [[[GVShared getBundle] loadNibNamed:@"GVUpcomingView" owner:self options:nil] lastObject];
        [upcomingView setFrame:CGRectMake(0, 0, cellWid, cellHei)];
        
        NSString *myNumber = [GVGlobal shared].mUser.phoneNumber;
        NSString *hostNumber = groop.adminPhone;
        if ([myNumber isEqualToString:hostNumber]) { // if you are a host of this groopview
            [upcomingView.btnRemove setHidden:NO];
            [upcomingView.btnRemove setTag:index];
            [upcomingView.btnRemove addTarget:self action:@selector(didClickRemove:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
            [upcomingView.btnRemove setHidden:YES];
        
        // Layout
        [upcomingView.imgAdminAvatar.layer setBorderWidth:1];
        [upcomingView.imgAdminAvatar.layer setBorderColor:[GVShared shared].themeColor.CGColor];
        
        for (GVCircleImageView *imgAvatar in upcomingView.imgAvatars) {
            [imgAvatar.layer setBorderWidth:1];
            [imgAvatar.layer setBorderColor:[GVShared shared].themeColor.CGColor];
        }
        [upcomingView.imgVideo.layer setBorderWidth:1];
        [upcomingView.imgVideo.layer setBorderColor:[GVShared shared].themeColor.CGColor];
        
        // Values
        NSTimeInterval interval = [groop.joinTime doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd"];
        [upcomingView.lblDate setText:[formatter stringFromDate:date]];
        [formatter setDateFormat:@"hh:mm aa"];
        [upcomingView.lblTime setText:[formatter stringFromDate:date]];
        
        [upcomingView.lblGroopTitle setText:groop.groopName];
        [upcomingView.lblVideoTitle setText:groop.videoTitle];
        [upcomingView.imgVideo setImageWithURL:[NSURL URLWithString:groop.videoThumbnail]];
        
//        NSString *statusStr = @"Pending";
//        if (groop.status == G_PENDING) {
//            statusStr = @"Pending";
//        } else if (groopModel.status == G_WATCHING) {
//            statusStr = @"Watching";
//        } else {
//            statusStr = @"Expired";
//        }
//        [groopView.groopStatusLabel setText:statusStr];
        
        if (groop.adminAvatarURL
            && groop.adminAvatarURL.length > 0) {
            [upcomingView.imgAdminAvatar setImageWithURL:[NSURL URLWithString:groop.adminAvatarURL]];
        }
        else {
            NSString *shortName = @"AD";
            if (groop.adminName.length > 1)
                shortName = [[groop.adminName substringToIndex:2] uppercaseString];
            else if (groop.adminName.length > 0)
                shortName = [[groop.adminName substringToIndex:1] uppercaseString];
            [upcomingView.lblAdminShortName setText:shortName];
        }
        
        NSInteger ind = 0;
        NSInteger numberofMembers = 0;
        for (GVCircleImageView *imgAvatar in upcomingView.imgAvatars) {
            GVParticipant *participant = [groop.members objectAtIndex:ind];
            if (participant.phoneNumber
                && participant.phoneNumber.length > 0) {
                [imgAvatar setHidden:NO];
                numberofMembers++;
                if (participant.avatarURL == nil
                    || participant.avatarURL.length == 0) {
                    UILabel *label = [upcomingView.lblParticipantShortNames objectAtIndex:ind];
                    NSString *shortName = @"PA";
                    if (participant.name.length > 1)
                        shortName = [[participant.name substringToIndex:2] uppercaseString];
                    else
                        shortName = [[participant.name substringToIndex:1] uppercaseString];
                    [label setText:shortName];
                }
                else {
                    [imgAvatar setImageWithURL:[NSURL URLWithString:participant.avatarURL]];
                }
            }
            else {
                [imgAvatar setHidden:YES];
            }
            ind++;
        }
        
        [upcomingView.lblParticipant setText:[NSString stringWithFormat:@"%ld participants", (long)numberofMembers + 1]];
        ind = 0;
        
        [upcomingView.lblAdminName setText:groop.adminName];
        
        for (UILabel *label in upcomingView.lblParticipantStatus) {
            GVParticipant *participant = [groop.members objectAtIndex:ind];
            if (participant.name
                && participant.name.length > 0
                && participant.phoneNumber
                && participant.phoneNumber.length > 0) {
                if (participant.isAccepted) {
                    [label setText:@"Accepted"];
                    [label setTextColor:[UIColor blackColor]];
                }
                else if (!participant.isAccepted
                         && participant.isReplied) {
                    [label setText:@"Rejected"];
                    [label setTextColor:[UIColor redColor]];
                }
                else if (!participant.isAccepted
                         && !participant.isReplied) {
                    [label setText:@"Pending"];
                    [label setTextColor:[UIColor blueColor]];
                }
            }
            ind++;
        }
        
        [view addSubview:upcomingView];
    }
    else {
        //--
    }
    
    return view;
}

- (NSInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel {
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300.0, 500.0)];
        ((UIImageView *)view).image = [UIImage imageNamed:@"test_avatar.png"];
        [((UIImageView *)view) setContentMode:UIViewContentModeScaleToFill];
        view.contentMode = UIViewContentModeScaleToFill;
        
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:50.0];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = (index == 0)? @"[": @"]";
    
    return view;
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0, 0.0, 1.0, 0.0);
    return CATransform3DTranslate(transform, 0.0, 0.0, offset * self.iCarouselView.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    
    //customize carousel display
    switch (option) {
        case iCarouselOptionWrap: {
            //normally you would hard-code this to YES or NO
            return YES;//self.wrap;
        }
        case iCarouselOptionSpacing: {
            //add a bit of spacing between the item views
            return value * 1;
        }
        case iCarouselOptionFadeMax: {
            if (self.iCarouselView.type == iCarouselTypeCustom) {
                //set opacity based on distance from camera
                return 0.0;
            }
            return value;
        }
        case iCarouselOptionShowBackfaces:
        case iCarouselOptionRadius:
        case iCarouselOptionAngle:
        case iCarouselOptionArc:
        case iCarouselOptionTilt:
        case iCarouselOptionCount:
        case iCarouselOptionFadeMin:
        case iCarouselOptionFadeMinAlpha:
        case iCarouselOptionFadeRange:
        case iCarouselOptionOffsetMultiplier: {
            return value;
        }
        case iCarouselOptionVisibleItems: {
            return 3;
        }
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    
    [self updateIndexLabel];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
    if (index >= self.allGroopviews.count) {
        return;
    }
    GVGroop *groopview = [self.allGroopviews objectAtIndex:index];
    
    GVGroopDetailController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVGroopDetailController"];
    [vc setViewType:GROOP_DETAIL_FROM_UPCOMING_GROOPVIEWS];
    [vc setGroop:groopview];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
