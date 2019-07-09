//
//  UIButton+XKEnlargeHitArea.m
//  XKSquare
//
//  Created by RyanYuan on 2019/2/19.
//  Copyright © 2019 xk. All rights reserved.
//

#import "UIButton+XKEnlargeHitArea.h"
#import <objc/runtime.h>

static const NSString *KEY_RELATED_HIT_EDGE_INSETS = @"relatedHitEdgeInsets";

@implementation UIButton (XKEnlargeHitArea)

@dynamic hitEdgeInsets;

// Setter
-(void)setHitEdgeInsets:(UIEdgeInsets)hitEdgeInsets {
    NSValue *value = [NSValue value:&hitEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    
    /*
    将一个对象关联到其它对象
    key：要保证全局唯一，key与关联的对象是一一对应关系。必须全局唯一。通常用@selector(methodName)作为key。
    value：要关联的对象。
    policy：关联策略。有五种关联策略。
    OBJC_ASSOCIATION_ASSIGN  等价于 @property(assign)。
    OBJC_ASSOCIATION_RETAIN_NONATOMIC等价于 @property(strong, nonatomic)。
    OBJC_ASSOCIATION_COPY_NONATOMIC等价于@property(copy, nonatomic)。
    OBJC_ASSOCIATION_RETAIN等价于@property(strong,atomic)。
    OBJC_ASSOCIATION_COPY等价于@property(copy, atomic)。
    */
    objc_setAssociatedObject(self, &KEY_RELATED_HIT_EDGE_INSETS, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter
-(UIEdgeInsets)hitEdgeInsets {
    
    // 获取关联对象的值
    NSValue *value = objc_getAssociatedObject(self, &KEY_RELATED_HIT_EDGE_INSETS);
    if(value) {
        UIEdgeInsets edgeInsets;
        [value getValue:&edgeInsets];
        return edgeInsets;
    }else {
        return UIEdgeInsetsZero;
    }
}

// 判断传入过来的点在不在方法调用者的坐标系上
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(UIEdgeInsetsEqualToEdgeInsets(self.hitEdgeInsets, UIEdgeInsetsZero) || !self.enabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.hitEdgeInsets);
    
    return CGRectContainsPoint(hitFrame, point);
}

@end
