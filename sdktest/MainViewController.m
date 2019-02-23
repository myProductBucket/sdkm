//
//  MainViewController.m
//  sdktest
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "MainViewController.h"
#import "ViewController.h"
#import <Groopview/Groopview.h>

@interface MainViewController () {
}
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:PREF_CURRENT_USER]) {
        [self presentViewController];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didClickStart:(id)sender {
    
    NSString *username = self.txtUserName.text;
    NSString *email = self.txtEmail.text;
    
    if (username == nil || username.length == 0) {
        [self showAlert:@"Please input your name."];
        return;
    }
    if (email == nil || email.length == 0) {
        [self showAlert:@"Please input your email address."];
        return;
    }
    
    NSArray<NSString *> *names = [username componentsSeparatedByString:@" "];
    NSString *firstName, *lastName;
    if (names.count > 1) {
        firstName = names[0];
        lastName = [username substringFromIndex:firstName.length + 1];
    }
    else {
        firstName = username;
        lastName = @"";
    }
    
    // Let's suppose that you logged in successfully
    // Actually, it should be stored immediately after log in
    GVUser *user = [[GVUser alloc] init];
    [user setAvatar:@""];
    [user setUserName:username];
    [user setFirstName:firstName];
    [user setLastName:lastName];
    [user setEmail:email];
    
    [[GVShared shared] setUserInfo:user];
    
    
    [self presentViewController];
}

- (void)presentViewController {
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showAlert:(NSString *)msg {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Error" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertC animated:YES completion:nil];
}

@end
