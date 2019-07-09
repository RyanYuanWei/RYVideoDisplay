//
//  RYHeartImageView.h
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/7/8.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RYHeartImageView : UIImageView

- (void)showLikeAnimationWithClickPoint:(CGPoint)clickPoint isLike:(BOOL)isLike;

@end

NS_ASSUME_NONNULL_END
