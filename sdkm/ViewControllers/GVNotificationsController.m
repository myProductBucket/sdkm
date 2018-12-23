//
//  GVNotificationsController.m
//  sdkm
//
//  Created by Mobile on 18.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVNotificationsController.h"
#import "GVNotificationCell.h"
#import "GVNotification.h"

@interface GVNotificationsController () <UITableViewDelegate, UITableViewDataSource> {
}

@property (weak, nonatomic) IBOutlet UITableView *tblNotifications;
@property (weak, nonatomic) IBOutlet UILabel *lblNotFound;

@property (strong, nonatomic) NSMutableArray *arrNotifications;

@end

@implementation GVNotificationsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getUserNotifications:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [self.navigationItem setTitle:@"Notifications"];
    
    [self.tblNotifications setDelegate:self];
    [self.tblNotifications setDataSource:self];
    
    UIRefreshControl *refreshC = [[UIRefreshControl alloc] init];
    [refreshC addTarget:self action:@selector(refreshNotifications:) forControlEvents:UIControlEventValueChanged];
    [self.tblNotifications addSubview:refreshC];
}

- (void)refreshNotifications:(UIRefreshControl *)sender {
    [self getUserNotifications:^(BOOL success, id res) {
        [sender endRefreshing];
    }];
}

- (void)getUserNotifications:(void(^)(BOOL success, id res))completion {
    
    [self.lblNotFound setHidden:YES];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GVService shared] getUserNotificationsWithCompletion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            if (res[@"data"] && ![res[@"data"] isEqual:[NSNull null]]) {
                self.arrNotifications = [NSMutableArray array];
                for (NSDictionary *dic in res[@"data"]) {
                    GVNotification *notification = [[GVNotification alloc] initWithDictionary:dic];
                    [self.arrNotifications addObject:notification];
                }
                if (self.arrNotifications.count == 0) {
                    [self.lblNotFound setHidden:NO];
                } else {
                    [self.lblNotFound setHidden:YES];
                }
                [self.tblNotifications reloadData];
            }
        } else if ([res isKindOfClass:[NSError class]]) {
            NSError *error = res;
            [GVGlobal showAlertWithTitle:GROOPVIEW
                                 message:error.localizedDescription
                                fromView:self
                          withCompletion:nil];
        } else {
            [GVGlobal showAlertWithTitle:GROOPVIEW
                                 message:GV_ERROR_MESSAGE
                                fromView:self
                          withCompletion:nil];
        }
        if (completion) {
            completion(success, res);
        }
    }];
    
    //    [[AppDelegate appDelegate] getCountOfUnreadNotifications];
}

- (void)removeNotification:(NSInteger)index {
    
    if (index >= self.arrNotifications.count) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.arrNotifications removeObjectAtIndex:index];
    [self.tblNotifications deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tblNotifications reloadData];
    
    GVNotification *notification = [self.arrNotifications objectAtIndex:index];
    [[GVService shared] removeUserNotificationById:notification.notificationId withCompletion:^(BOOL success, id res) {
        
        if (success) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//            [self.arrNotifications removeObjectAtIndex:index];
//            [self.tblNotifications deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [self.tblNotifications reloadData];
            
            // Get Unread Notifications
        }
        else {
            if ([res isKindOfClass:[NSError class]]) {
                NSError *error = res;
                NSLog(@"Failed to remove the notification:%@, Error:%@", notification.notificationId, error.localizedDescription);
            }
            else {
                NSLog(@"Failed to remove the notification:%@", notification.notificationId);
            }
        }
    }];
}

- (void)readNotification:(GVNotification *)notification {
    [[GVService shared] readUserNotificationById:notification.notificationId withCompletion:^(BOOL success, id res) {
        if (success) {
            if (res[@"status"]) {
                NSLog(@"Read Notification Status: %@", res[@"status"]);
            }
        }
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.arrNotifications) {
        return self.arrNotifications.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GVNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GVNotificationCell" forIndexPath:indexPath];
    if (cell) {
        GVNotification *notification = [self.arrNotifications objectAtIndex:indexPath.row];
        if (notification.isRead) {
            [cell.imgStatus setHidden:YES];
        }
        else {
            [cell.imgStatus setHidden:NO];
        }
        
        [cell.lblDescription setText:notification.notificationText];
        [cell.lblDate setText:notification.notificationTime];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= self.arrNotifications.count) {
        return;
    }
    // Present Notification Alert Controller
    GVNotification *notification = [self.arrNotifications objectAtIndex:indexPath.row];
//    NotificationAlertController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationAlertController"];
//    [vc setNotification:notification];
//    [self presentViewController:vc animated:YES completion:nil];
    
    // Read Notification
    [self readNotification:notification];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeNotification:indexPath.row];
    }
}

@end
