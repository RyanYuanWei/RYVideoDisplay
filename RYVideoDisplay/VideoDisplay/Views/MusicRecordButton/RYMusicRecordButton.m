//
//  RYMusicRecordButton.m
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/7/16.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import "RYMusicRecordButton.h"

@implementation RYMusicRecordButton

- (void)startMusicRecordButtonAnimation {
    
    CABasicAnimation *rotationAnimation = (CABasicAnimation *)[self.layer animationForKey:@"rotationAnimationKey"];
    if (rotationAnimation) {
        CALayer *layer = self.layer;
        if (layer.timeOffset != 0) {
            CFTimeInterval pauseTime = layer.timeOffset;
            layer.beginTime = CACurrentMediaTime() - pauseTime;
            layer.timeOffset = 0;
            layer.speed = 1.0;
        }
    } else {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue = @0;
        rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
        rotationAnimation.duration = 6.0;
        rotationAnimation.repeatCount = ULLONG_MAX;
        rotationAnimation.removedOnCompletion = NO;
        rotationAnimation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimationKey"];
    }
}

- (void)pauseMusicRecordButtonAnimation {
    
    CABasicAnimation *rotationAnimation = (CABasicAnimation * )[self.layer animationForKey:@"rotationAnimationKey"];
    if (rotationAnimation) {
        CALayer *layer = self.layer;
        CFTimeInterval time = CACurrentMediaTime() - layer.beginTime;
        layer.timeOffset = time;
        layer.speed = 0.0;
    }
}

@end
