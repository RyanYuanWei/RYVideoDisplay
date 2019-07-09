//
//  RYStartPlayImageView.m
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/7/8.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import "RYStartPlayImageView.h"

@implementation RYStartPlayImageView

- (void)showStartPlayView {
    if (!self.hidden) return;
    self.hidden = NO;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:2.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.duration = .05;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:.3];
    opacityAnimation.toValue = [NSNumber numberWithFloat:.7];
    opacityAnimation.duration = .05;
    
    [self.layer addAnimation:scaleAnimation forKey:@"scale"];
    [self.layer addAnimation:opacityAnimation forKey:@"opacity"];
}

- (void)hiddenStartPlayView {
    self.hidden = YES;
}

@end
