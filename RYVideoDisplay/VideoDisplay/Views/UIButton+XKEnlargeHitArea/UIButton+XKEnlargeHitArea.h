//
//  UIButton+XKEnlargeHitArea.h
//  XKSquare
//
//  Created by RyanYuan on 2019/2/19.
//  Copyright © 2019 xk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (XKEnlargeHitArea)

/** 设置按钮点击扩大的点击范围 */
@property(nonatomic, assign) UIEdgeInsets hitEdgeInsets;

@end

NS_ASSUME_NONNULL_END
