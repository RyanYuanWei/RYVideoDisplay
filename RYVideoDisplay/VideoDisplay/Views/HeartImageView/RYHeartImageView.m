//
//  RYHeartImageView.m
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/7/8.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import "RYHeartImageView.h"

@implementation RYHeartImageView

- (void)showLikeAnimationWithClickPoint:(CGPoint)clickPoint isLike:(BOOL)isLike {
    
    // 点赞动画
    if (isLike) {
        
        self.center = clickPoint;
        BOOL randomBoolValue = arc4random() % 2;
        CGFloat angle;
        if (randomBoolValue) {
            angle = M_1_PI;
        } else {
            angle = -M_1_PI;
        }
        self.transform = CGAffineTransformIdentity;
        self.transform = CGAffineTransformRotate(self.transform, angle);
        
        // 创建缩放帧动画
        CAKeyframeAnimation *scaleKeyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        NSValue *stepOneValue = [NSNumber numberWithFloat:2.0];
        NSValue *stepTwoValue = [NSNumber numberWithFloat:1.0];
        NSValue *stepThreeValue = [NSNumber numberWithFloat:3.0];
        scaleKeyframeAnimation.values = @[stepOneValue, stepTwoValue, stepThreeValue];
        scaleKeyframeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        // 创建透明度帧动画
        CAKeyframeAnimation *opacityKeyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        NSValue *opacityOneValue = [NSNumber numberWithFloat:.5];
        NSValue *opacityTwoValue = [NSNumber numberWithFloat:1.0];
        NSValue *opacityThreeValue = [NSNumber numberWithFloat:0.1];
        opacityKeyframeAnimation.values = @[opacityOneValue, opacityTwoValue, opacityThreeValue];
        opacityKeyframeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        // 创建动画组
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.delegate = self;
        animationGroup.animations = @[scaleKeyframeAnimation, opacityKeyframeAnimation];
        animationGroup.duration = .3;
        animationGroup.fillMode = kCAFillModeForwards;
        animationGroup.removedOnCompletion = NO;
        
        [self.layer addAnimation:animationGroup forKey:@"heartImageViewAnimation"];
        
    // 取消点赞动画
    } else {
        
        
    }
}

@end
