//
//  RYLoadingLineLayer.h
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/7/8.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface RYLoadingLineLayer : CALayer

- (void)startLoadingLineAnimation;
- (void)stopLoadingLineAnimation;

@end

NS_ASSUME_NONNULL_END
