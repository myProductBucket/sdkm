//
//  NSMutableAttributedString+Category.h
//  sdkm
//
//  Created by Mobile on 19.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (Category)

- (NSMutableAttributedString *)append:(NSString *)text
                                 size:(CGFloat)size
                             fontName:(NSString *)fontName
                                align:(NSTextAlignment)align;

- (NSMutableAttributedString *)append:(NSString *)text
                                 size:(CGFloat)size
                             fontName:(NSString *)fontName
                                align:(NSTextAlignment)align
                            textColor:(UIColor *)textColor;

@end

//NS_ASSUME_NONNULL_END
