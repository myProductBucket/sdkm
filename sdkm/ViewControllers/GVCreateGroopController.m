//
//  GVCreateGroopController.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVCreateGroopController.h"
#import "GVSetTimeController.h"
#import "GVContactCell.h"
#import <Contacts/Contacts.h>

@interface GVCreateGroopController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
    UISearchBar *searchBar;
    Boolean isSearch;
}

@property (nonatomic, strong) NSMutableArray *groopUsers;

@property (nonatomic, strong) NSMutableArray *arrAllContacts;
@property (nonatomic, strong) NSMutableArray *arrGroopviewContacts;
@property (nonatomic, strong) NSMutableArray *filteredContacts;

@end

@implementation GVCreateGroopController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initLayout];
    [self initGroop];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [[GVShared shared] setLockOrientation:UIInterfaceOrientationMaskLandscape];
//    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:@"orientation"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [[GVShared shared] setLockOrientation:UIInterfaceOrientationMaskAll];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self contactScan];
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
    [self.navigationItem setTitle:@"Create a Groop"];
    
    // Navigation Bar
    self.navigationItem.rightBarButtonItem = [self searchNavItem];
    [self.navigationItem setTitle:@"My Groups"];
    
    // Search Bar
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor darkGrayColor]];
    searchBar = [[UISearchBar alloc] init];
    [searchBar setPlaceholder:@"Search"];
    [searchBar setDelegate:self];
    [searchBar setReturnKeyType:UIReturnKeySearch];
    
    [self.tblContacts setDelegate:self];
    [self.tblContacts setDataSource:self];
    
    [self.viewBottom setShadow:3];
    
    if (self.viewType == CREATE_GROOP_FROM_GROOP_DETAIL) {
        [self.constraintBottomViewHeight setConstant:0];
        [self.viewBottom setHidden:YES];
    }
}

- (UIBarButtonItem *)searchNavItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IconSearch" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(searchClicked:)];
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

- (void)refreshGroop {
    [self initGroop];
    
    if (self.groopUsers == nil
        || self.groopUsers.count == 0) {
        return;
    }
    
    NSInteger i = 0;
    for (GVUser *user in self.groopUsers) {
        UIButton *button = self.removeButtons[i];
        [button setHidden:NO];
        
        UILabel *label = self.groopShortNames[i];
        [label setHidden:NO];
        [label setText:user.shortName];
        
        i++;
    }
}

- (void)initGroop {
    for (NSInteger i = 0; i < 3; i++) {
        UILabel *label = self.groopShortNames[i];
        [label.layer setMasksToBounds:YES];
        [label.layer setCornerRadius:label.frame.size.height / 2];
        [label setHidden:YES];
        
        UIButton *button = self.removeButtons[i];
        [button setHidden:YES];
        [button setTag:i];
        
        GVCircleImageView *imgAvatar = self.groopAvatars[i];
        [imgAvatar setImage:[UIImage imageNamed:@"add_contact_bottom.png" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil]];
    }
}

- (void)getUsers:(NSMutableArray *)contacts {
    [self.groopUsers removeAllObjects];
    [self refreshGroop];
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
         } else if ([res isKindOfClass:[NSError class]]) {
             NSError *error = res;
             [GVGlobal showAlertWithTitle:GROOPVIEW message:[NSString stringWithFormat:@"%@", error.localizedDescription] fromView:self withCompletion:nil];
         }
     }];
}

- (void)removeSearchBar {
    [searchBar setText:@""];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.navigationItem.titleView = nil;
    self.navigationItem.rightBarButtonItem = [self searchNavItem];
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)searchContacts:(NSString *)searchText {
    if (searchText == nil || [searchText isEqualToString:@""]) {
        isSearch = NO;
        [self.tblContacts reloadData];
    } else {
        isSearch = YES;
        NSMutableArray *arrContacts;
        if (self.segSection.selectedSegmentIndex == 0) {
            arrContacts = self.arrAllContacts;
        } else {
            arrContacts = self.arrGroopviewContacts;
        }
        if (arrContacts == nil) {
            return;
        }
        
        self.filteredContacts = [NSMutableArray new];
        for (GVUser *user in arrContacts) {
            if (user.userName != nil
                && [[user.userName lowercaseString] containsString:[searchText lowercaseString]]) {
                [self.filteredContacts addObject:user];
            }
        }
        [self.tblContacts reloadData];
    }
}

- (void)createGroop:(NSString *)groopTitle {
    NSString *firstPhone = GV_NULL, *firstCode = GV_NULL;
    if (self.groopUsers.count > 0) {
        firstPhone = ((GVUser *)self.groopUsers[0]).phoneNumber;
        firstCode = ((GVUser *)self.groopUsers[0]).countryCode;
    }
    NSString *friend1 = [GVGlobal getJsonForFriend:firstCode phoneNumber:firstPhone];
    
    NSString *secondPhone = GV_NULL, *secondCode = GV_NULL;
    if (self.groopUsers.count > 1) {
        secondPhone = ((GVUser *)self.groopUsers[1]).phoneNumber;
        secondCode = ((GVUser *)self.groopUsers[1]).countryCode;
    }
    NSString *friend2 = [GVGlobal getJsonForFriend:secondCode phoneNumber:secondPhone];
    
    NSString *thirdPhone = GV_NULL, *thirdCode = GV_NULL;
    if (self.groopUsers.count > 2) {
        thirdPhone = ((GVUser *)self.groopUsers[2]).phoneNumber;
        thirdCode = ((GVUser *)self.groopUsers[2]).countryCode;
    }
    NSString *friend3 = [GVGlobal getJsonForFriend:thirdCode phoneNumber:thirdPhone];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GVService shared] createGroopWithName:groopTitle first:friend1 second:friend2 third:friend3 withCompletion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            if (res[@"groop_id"]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else if (res[@"status"]) {
                [GVGlobal showAlertWithTitle:GROOPVIEW message:res[@"status"] fromView:self withCompletion:nil];
            }
        }
        else if ([res isKindOfClass:[NSError class]]) {
            NSError *error = res;
            [GVGlobal showAlertWithTitle:GROOPVIEW message:error.localizedDescription fromView:self withCompletion:nil];
        }
    }];
}

- (void)presentChooseVideo {
    if ([GVShared shared].createGroopviewInfo == nil) {
        [GVShared shared].createGroopviewInfo = [NSMutableDictionary dictionary];
    }
    
    if ([GVShared shared].chooseVideoController == nil) {
        [GVGlobal showAlertWithTitle:GROOPVIEW
                             message:@"There is no view controller to choose the video."
                            fromView:self
                      withCompletion:nil];
        return;
    }
    // Go to next
    id vc;
    if ([[GVShared shared].createGroopviewInfo objectForKey:GV_VIDEO_URL]) { // Set Time
        vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVSetTimeController"];
    }
    else {
        vc = [GVShared shared].chooseVideoController;
    }
    
    if (self.groopUsers && self.groopUsers.count > 0) {
        GVUser *user = [self.groopUsers objectAtIndex:0];
        if (user.phoneNumber.length > 0
            && user.countryCode.length > 0) {
            [[GVShared shared].createGroopviewInfo setObject:user.phoneNumber forKey:GV_FIRST_PHONE];
            [[GVShared shared].createGroopviewInfo setObject:user.countryCode forKey:GV_FIRST_CODE];
        }
        if (self.groopUsers.count > 1) {
            user = [self.groopUsers objectAtIndex:1];
            if (user.phoneNumber.length > 0
                && user.countryCode.length > 0) {
                [[GVShared shared].createGroopviewInfo setObject:user.phoneNumber forKey:GV_SECOND_PHONE];
                [[GVShared shared].createGroopviewInfo setObject:user.countryCode forKey:GV_SECOND_CODE];
            }
        }
        if (self.groopUsers.count > 2) {
            user = [self.groopUsers objectAtIndex:2];
            if (user.phoneNumber.length > 0
                && user.countryCode.length > 0) {
                [[GVShared shared].createGroopviewInfo setObject:user.phoneNumber forKey:GV_THIRD_PHONE];
                [[GVShared shared].createGroopviewInfo setObject:user.countryCode forKey:GV_THIRD_CODE];
            }
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        [GVGlobal showAlertWithTitle:GROOPVIEW
                             message:@"Please add at least one participant."
                            fromView:self
                      withCompletion:nil];
    }
}

#pragma mark - Actions

- (void)searchClicked:(id)sender {
    // Show Search Bar
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar becomeFirstResponder];
    
    self.navigationItem.titleView = searchBar;
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
}

- (IBAction)didSwitchSection:(id)sender {
    isSearch = NO;
    [self removeSearchBar];
    [self.tblContacts reloadData];
}

- (IBAction)didClickContinue:(id)sender {
    if (self.groopUsers == nil
        || self.groopUsers.count == 0) {
        [GVGlobal showAlertWithTitle:GROOPVIEW
                             message:@"Please add one or more users to create a Groop."
                            fromView:self
                      withCompletion:nil];
        return;
    }
    
    if (self.viewType == CREATE_GROOP_FROM_GROOP_DETAIL) {
        return;
    }
    else if (self.viewType == CREATE_GROOP_FROM_START) {
        [self presentChooseVideo];
//        SetTimeController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SetTimeController"];
//        [vc setGroopUsers:self.groopUsers];
//        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (self.viewType == CREATE_GROOP_FROM_MY_GROOPS) {
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Groop Title" message:@"Please set the title of your Groop" preferredStyle:UIAlertControllerStyleAlert];
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setPlaceholder:@"Groop Title"];
        }];
        [alertC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UITextField *textField = alertC.textFields[0];
            if (textField.text == nil
                || textField.text.length == 0) {
                [self presentViewController:alertC
                                   animated:YES
                                 completion:nil];
                return;
            }
            
            NSString *groopTitle = [textField.text removeSpacesOnLeadAndTrail];
            if (groopTitle == nil
                || groopTitle.length == 0) {
                [textField setText:@""];
                [self presentViewController:alertC
                                   animated:YES
                                 completion:nil];
                return;
            }
            
            [self createGroop:groopTitle];
            
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertC
                           animated:YES
                         completion:nil];
        
    }
}

- (IBAction)didClickAdd:(UIButton *)sender {
    NSInteger index = sender.tag;
    GVUser *user;
    if (self.segSection.selectedSegmentIndex == 0
        && self.arrAllContacts.count > index) { // All Contacts
        user = [self.arrAllContacts objectAtIndex:index];
    } else if (self.segSection.selectedSegmentIndex == 1
               && self.arrGroopviewContacts.count > index) {
        user = [self.arrGroopviewContacts objectAtIndex:index];
    }
    
    if (user == nil) {
        return;
    }
    
    if (self.viewType == CREATE_GROOP_FROM_GROOP_DETAIL) {
        // --
        [self.delegate didSelectParticipant:user];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (self.groopUsers == nil) {
            self.groopUsers = [NSMutableArray array];
        } else if (self.groopUsers.count > 2) {
            return;
        }
        
        for (GVUser *groopUser in self.groopUsers) {
            if ([groopUser.phoneNumber isEqualToString:user.phoneNumber]) {
                return;
            }
        }
        
        [user setIsAdded:YES];
        [self.tblContacts reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:index inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.groopUsers addObject:user];
        
        [self refreshGroop];
    }
}

- (IBAction)didClickDelete:(UIButton *)sender {
    NSInteger index = sender.tag;
    if (self.groopUsers != nil
        && self.groopUsers.count > index) {
        
        GVUser *user = [self.groopUsers objectAtIndex:index];
        [user setIsAdded:NO];
        [self.tblContacts reloadData];
        
        [self.groopUsers removeObjectAtIndex:index];
        [self refreshGroop];
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearch) {
        if (self.filteredContacts) {
            return self.filteredContacts.count;
        }
    }
    else {
        if (self.segSection.selectedSegmentIndex == 0
            && ![GVGlobal isNull:self.arrAllContacts]) {
            return self.arrAllContacts.count;
        }
        else if (self.segSection.selectedSegmentIndex == 1
                   && ![GVGlobal isNull:self.arrGroopviewContacts]) {
            return self.arrGroopviewContacts.count;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GVContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GVContactCell" forIndexPath:indexPath];
    if (cell) {
        GVUser *user;
        if (isSearch) {
            if (self.filteredContacts != nil
                && self.filteredContacts.count > indexPath.row) {
                user = [self.filteredContacts objectAtIndex:indexPath.row];
            }
        }
        else {
            if (self.segSection.selectedSegmentIndex == 0
                && self.arrAllContacts.count > indexPath.row) {
                user = [self.arrAllContacts objectAtIndex:indexPath.row];
            }
            else if (self.segSection.selectedSegmentIndex == 1
                       && self.arrGroopviewContacts.count > indexPath.row) {
                user = [self.arrGroopviewContacts objectAtIndex:indexPath.row];
            }
        }
        
        if (user == nil) {
            return nil;
        }
        
        NSString *inviteLabel;
        if (user.isGroopview) {
            if (user.isAdded)
                inviteLabel = @"Added";
            else
                inviteLabel = @"Add";
        } else {
            if (user.isAdded)
                inviteLabel = @"Invited";
            else
                inviteLabel = @"Invite";
        }
        [cell.btnInvite setTitle:inviteLabel forState:UIControlStateNormal];
        
        [cell.btnAdd setTag:indexPath.row];
        [cell.btnInvite setTag:indexPath.row];
        if (user.isAdded) {
            [cell.btnAdd setBackgroundImage:[UIImage imageNamed:@"add_contact_red.png" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        } else {
            [cell.btnAdd setBackgroundImage:[UIImage imageNamed:@"add_contact_dark_gray.png" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        }
        
        [cell.lblAvatar setText:user.shortName];
        [cell.lblName setText:user.userName];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [searchBar resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self removeSearchBar];
    [self searchContacts:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchStr = searchBar.text;
    [self searchContacts:searchStr];
    [searchBar resignFirstResponder];
    //    [self removeSearchBar];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchContacts:searchText];
}

@end
