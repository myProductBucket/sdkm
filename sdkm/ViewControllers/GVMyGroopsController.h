//
//  GVMyGroopsController.h
//  sdkm
//
//  Created by Mobile on 17.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVBaseNavController.h"

//NS_ASSUME_NONNULL_BEGIN

@interface GVMyGroopsController : GVBaseNavController

@property (weak, nonatomic) IBOutlet UICollectionView *colGroops;
@property (weak, nonatomic) IBOutlet UILabel *lblNotFound;

@end

//NS_ASSUME_NONNULL_END
