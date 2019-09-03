//
//  XKLWebpButton.h
//  XKXiaoShiPing
//
//  Created by XiaoKe on 2019/4/25.
//  Copyright © 2019 smkj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface XKLWebpButton : UIButton

@property (nonatomic, strong) UIImageView *defImageView;

@property (nonatomic, strong) YYAnimatedImageView *webPimageView;

// 显示webp的图片动画，path：路径， scale：缩放放大倍数
- (void)showWebPAnimateWithPath:(NSString *)path scale:(CGFloat)scale;
- (void)removeWebAnimate;
@end

NS_ASSUME_NONNULL_END
