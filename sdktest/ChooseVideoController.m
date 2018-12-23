//
//  ChooseVideoController.m
//  sdktest
//
//  Created by Mobile on 19.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "ChooseVideoController.h"
#import <sdkm/Groopview.h>

@interface ChooseVideoController () <GVStartButtonDelegate> {
    
    NSString *defaultVideoURL;
    NSString *defaultVideoThumb;
    
}
@property (weak, nonatomic) IBOutlet UITextField *txtVideoTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblVideoURL;
@property (weak, nonatomic) IBOutlet GVStartButton *btnGVStart;

@end

@implementation ChooseVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnGVStart setDelegate:self];
    
    defaultVideoURL = @"https://s3.amazonaws.com/groopview-play/output/hls/9e67f585d3ac50ac99ab4ffbdf1924970831eef3f496478ec31fbdb883444693/hls_9e67f585d3ac50ac99ab4ffbdf1924970831eef3f496478ec31fbdb883444693.m3u8";
    defaultVideoThumb = @"https://s3.amazonaws.com/groopview-thumbnails/output/hls/9e67f585d3ac50ac99ab4ffbdf1924970831eef3f496478ec31fbdb883444693/d1a32_Lebron_James_Career_Highlights-00001.png";
    
    [self.lblVideoURL setText:defaultVideoURL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - GVStartButtonDelegate

- (void)didClickGroopviewStart:(id)sender {
    if (self.txtVideoTitle.text.length == 0) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Groopview" message:@"Please input the video title to test the app." preferredStyle:UIAlertControllerStyleAlert];
        [alertC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
    if ([GVShared shared].createGroopviewInfo == nil) {
        [GVShared shared].createGroopviewInfo = [NSMutableDictionary dictionary];
    }
    [[GVShared shared].createGroopviewInfo setObject:self.txtVideoTitle.text forKey:GV_VIDEO_TITLE];
    [[GVShared shared].createGroopviewInfo setObject:defaultVideoURL forKey:GV_VIDEO_URL];
    [[GVShared shared].createGroopviewInfo setObject:defaultVideoThumb forKey:GV_VIDEO_THUMBNAIL];
    
    if ([[GVShared shared].createGroopviewInfo objectForKey:GV_GROOP_ID]) { // Already Selected Groop
        [GVShared presentSetTime:self];
    }
    else { // Start Groopview from first
        [GVShared presentGroopviewStart:self];
    }
}

@end
