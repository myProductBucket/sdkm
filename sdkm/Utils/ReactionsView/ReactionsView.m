//
//  ReactionsView.m
//  urbanclout
//
//  Created by Mobile on 12.01.19.
//  Copyright © 2019 Singularity. All rights reserved.
//

#import "ReactionsView.h"

@interface ReactionsView() <CAAnimationDelegate> {
}

@end

@implementation ReactionsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showReaction:(UIImage *)image {
    UIImageView *imgReaction = [[UIImageView alloc] initWithImage:image];
    [imgReaction setContentMode:UIViewContentModeScaleAspectFit];
    
    CGFloat dimension = 35 + drand48() * 5; // 20 ~ 30
    [imgReaction setFrame:CGRectMake(-60, 0, dimension, dimension)];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setDelegate:self];
    [animation setPath:[self customPath].CGPath];
    [animation setDuration:2 + drand48() * 3]; //
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setValue:imgReaction forKey:@"imageView"];
    
    [imgReaction.layer addAnimation:animation forKey:nil];
    [self addSubview:imgReaction];
}

- (UIBezierPath *)customPath {
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, self.frame.size.height / 2)];
    CGPoint endPoint = CGPointMake(self.frame.size.width + 60, self.frame.size.height / 2);
    CGFloat minimumHeight = self.frame.size.height * 0.1; // 10%
    CGFloat maximumHeight = self.frame.size.height * 0.9; // 90%
    CGFloat minimumX = self.frame.size.width * 0.4; // 40%
    CGFloat maximumX = self.frame.size.width * 0.6; // 60%
    CGFloat randomYShift = minimumHeight + drand48() * maximumHeight;
    CGPoint cp1 = CGPointMake(minimumX, minimumHeight - randomYShift);
    CGPoint cp2 = CGPointMake(maximumX, maximumHeight + randomYShift);
    [path addCurveToPoint:endPoint controlPoint1:cp1 controlPoint2:cp2];
    
    return path;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([anim valueForKey:@"imageView"]
        && [[anim valueForKey:@"imageView"] isKindOfClass:[UIImageView class]]) {
        UIImageView *imgReaction = [anim valueForKey:@"imageView"];
        [imgReaction removeFromSuperview];
        [imgReaction setHidden:YES];
        imgReaction = nil;
    }
}

@end
