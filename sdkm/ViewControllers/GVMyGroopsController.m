//
//  GVMyGroopsController.m
//  sdkm
//
//  Created by Mobile on 17.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVMyGroopsController.h"
#import "GVCreateGroopController.h"
#import "GVGroopDetailController.h"
#import "GVGroopCell.h"
#import "GVGroop.h"

@interface GVMyGroopsController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    
}

@property (weak, nonatomic) IBOutlet UICollectionView *colGroops;
@property (weak, nonatomic) IBOutlet UILabel *lblNotFound;

@property (strong, nonatomic) NSMutableArray *allGroops;

@end

@implementation GVMyGroopsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIRefreshControl *refreshC = [[UIRefreshControl alloc] init];
    [refreshC addTarget:self action:@selector(refreshGroops:) forControlEvents:UIControlEventValueChanged];
    [self.colGroops addSubview:refreshC];
    
    [self initLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Get My Groops
    [self getGroops:^{
    }];
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
    [self.navigationItem setTitle:@"My Groops"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IconCreateGroop" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(didClickCreateGroop:)];
    
    [self.colGroops setDelegate:self];
    [self.colGroops setDataSource:self];
    [self.lblNotFound setHidden:YES];
}

- (void)refreshGroops:(UIRefreshControl *)sender {
    [self getGroops:^{
        [sender endRefreshing];
    }];
}

- (void)getGroops:(void (^)(void))completion {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GVService shared] getGroopsWithCompletion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            NSLog(@"%@", res);
            if (res[@"data"]) {
                self.allGroops = [NSMutableArray new];
                for (NSDictionary *dic in res[@"data"]) {
                    GVGroop *model = [[GVGroop alloc] initWithDictionary:dic];
                    [self.allGroops addObject:model];
                }
                
                if (self.allGroops.count == 0) {
                    [self.lblNotFound setHidden:NO];
                }
                else {
                    [self.lblNotFound setHidden:YES];
                }
                [self.colGroops reloadData];
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
        completion();
    }];
}

#pragma mark - Actions

- (void)didClickCreateGroop:(id)sender {
    GVCreateGroopController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GVCreateGroopController"];
    [vc setViewType:CREATE_GROOP_FROM_MY_GROOPS];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - UICollectionViewDelegate UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.allGroops) {
        return self.allGroops.count;
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(120, 160);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GVGroopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GVGroopCell" forIndexPath:indexPath];
    if (cell) {
        GVGroop *groop = [self.allGroops objectAtIndex:indexPath.row];
        [cell.lblGroopTitle setText:groop.groopName];
        
        NSString *shortAdmin;
        if (groop.adminName == nil
            || [groop.adminName isEqualToString:@""]) {
            shortAdmin = @"A";
        }
        else if (groop.adminName.length == 1) {
            shortAdmin = [groop.adminName uppercaseString];
        }
        else {
            shortAdmin = [[groop.adminName substringToIndex:2] uppercaseString];
        }
        [cell.lblAdmin setText:shortAdmin];
        
        [cell.imgFirst setHidden:YES];
        [cell.imgSecond setHidden:YES];
        [cell.imgThird setHidden:YES];
        [cell.lblFirst setHidden:YES];
        [cell.lblSecond setHidden:YES];
        [cell.lblThird setHidden:YES];
        if (groop.members.count > 0) {
            GVParticipant *participant = [groop.members objectAtIndex:0];
            if (participant.name != nil && ![participant.name isEqualToString:@""]) {
                NSString *shortName;
                if (participant.name.length == 1) {
                    shortName = [participant.name uppercaseString];
                }
                else {
                    shortName = [[participant.name substringToIndex:2] uppercaseString];
                }
                [cell.lblFirst setText:shortName];
                [cell.lblFirst setHidden:NO];
            }
        }
        if (groop.members.count > 1) {
            GVParticipant *participant = [groop.members objectAtIndex:1];
            if (participant.name != nil && ![participant.name isEqualToString:@""]) {
                NSString *shortName;
                if (participant.name.length == 1) {
                    shortName = [participant.name uppercaseString];
                } else {
                    shortName = [[participant.name substringToIndex:2] uppercaseString];
                }
                [cell.lblSecond setText:shortName];
                [cell.lblSecond setHidden:NO];
            }
        }
        if (groop.members.count > 2) {
            GVParticipant *participant = [groop.members objectAtIndex:2];
            if (participant.name != nil && ![participant.name isEqualToString:@""]) {
                NSString *shortName;
                if (participant.name.length == 1) {
                    shortName = [participant.name uppercaseString];
                } else {
                    shortName = [[participant.name substringToIndex:2] uppercaseString];
                }
                [cell.lblThird setText:shortName];
                [cell.lblThird setHidden:NO];
            }
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.allGroops.count > indexPath.row) {
        GVGroop *groop = [self.allGroops objectAtIndex:indexPath.row];

        GVGroopDetailController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVGroopDetailController"];
        [vc setViewType:GROOP_DETAIL_FROM_MY_GROOPS];
        [vc setGroop:groop];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
