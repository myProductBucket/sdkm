//
//  GVGroopCell.h
//  sdkm
//
//  Created by Mobile on 17.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVCircleImageView.h"

//NS_ASSUME_NONNULL_BEGIN

@interface GVGroopCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet GVCircleImageView *imgAdmin;
@property (weak, nonatomic) IBOutlet UILabel *lblAdmin;
@property (weak, nonatomic) IBOutlet GVCircleImageView *imgFirst;
@property (weak, nonatomic) IBOutlet UILabel *lblFirst;
@property (weak, nonatomic) IBOutlet GVCircleImageView *imgSecond;
@property (weak, nonatomic) IBOutlet UILabel *lblSecond;
@property (weak, nonatomic) IBOutlet GVCircleImageView *imgThird;
@property (weak, nonatomic) IBOutlet UILabel *lblThird;
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UILabel *lblGroopTitle;

@end

//NS_ASSUME_NONNULL_END
