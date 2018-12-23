//
//  NSMutableAttributedString+Category.m
//  sdkm
//
//  Created by Mobile on 19.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "NSMutableAttributedString+Category.h"

@implementation NSMutableAttributedString (Category)

- (NSMutableAttributedString *)append:(NSString *)text
                                 size:(CGFloat)size
                             fontName:(NSString *)fontName
                                align:(NSTextAlignment)align {
    
    UIFont *font = [UIFont fontWithName:fontName size:size];
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.alignment = align;
    para.lineSpacing = 5;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: para}];
    
    [self appendAttributedString:attrString];
    
    return self;
}

- (NSMutableAttributedString *)append:(NSString *)text
                                 size:(CGFloat)size
                             fontName:(NSString *)fontName
                                align:(NSTextAlignment)align
                            textColor:(UIColor *)textColor {
    
    UIFont *font = [UIFont fontWithName:fontName size:size];
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.alignment = align;
    para.lineSpacing = 5;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: para, NSForegroundColorAttributeName: textColor}];
    
    [self appendAttributedString:attrString];
    
    return self;
}

@end
