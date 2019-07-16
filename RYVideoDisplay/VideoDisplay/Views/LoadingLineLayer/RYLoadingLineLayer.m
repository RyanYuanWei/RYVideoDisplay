//
//  RYLoadingLineLayer.m
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/7/8.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import "RYLoadingLineLayer.h"

@implementation RYLoadingLineLayer

- (void)startLoadingLineAnimation {
    
    if (self.hidden == NO) {
        return;
    }
    
    self.hidden = NO;
    CABasicAnimation *boundsAnimation = (CABasicAnimation * )[self animationForKey:@"loadingLineBoundsAnimation"];
    //    CABasicAnimation *opacityAnimation = (CABasicAnimation * )[self.loadingLineLayer animationForKey:@"loadingLineOpacityAnimation"];
    
    if (!boundsAnimation) {
        CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation.fromValue = [NSValue valueWithCGRect:CGRectMake(SCREEN_WIDTH / 2, 0, 1, 1)];
        boundsAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        boundsAnimation.duration = .5;
        boundsAnimation.removedOnCompletion = NO;
        boundsAnimation.repeatCount = ULLONG_MAX;
        
        //    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        //    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        //    opacityAnimation.toValue = [NSNumber numberWithFloat:1.0];
        //    opacityAnimation.duration = .5;
        //    opacityAnimation.removedOnCompletion = NO;
        //    opacityAnimation.repeatCount = ULLONG_MAX;
        
        [self addAnimation:boundsAnimation forKey:@"loadingLineBoundsAnimation"];
        //    [self.loadingLineLayer addAnimation:opacityAnimation forKey:@"loadingLineOpacityAnimation"];
    }
    
    if (self.timeOffset != 0) {
        CFTimeInterval pauseTime = self.timeOffset;
        self.beginTime = CACurrentMediaTime() - pauseTime;
        self.timeOffset = 0;
        self.speed = 1.0;
    }
}

- (void)stopLoadingLineAnimation {
    self.hidden = YES;
    [self removeAllAnimations];
}

@end
