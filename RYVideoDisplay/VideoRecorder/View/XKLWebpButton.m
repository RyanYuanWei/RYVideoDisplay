//
//  XKLWebpButton.m
//  XKXiaoShiPing
//
//  Created by XiaoKe on 2019/4/25.
//  Copyright © 2019 smkj. All rights reserved.
//

#import "XKLWebpButton.h"

@interface XKLWebpButton ()

@property(nonatomic, assign) BOOL isAnimating;
@property(nonatomic, strong) UIImageView * tempImageView;
@end

@implementation XKLWebpButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIImageView *)defImageView {
    if (!_defImageView) {
        _defImageView = [[UIImageView alloc] init];
        [self addSubview:_defImageView];
        _defImageView.frame = self.bounds;
        _defImageView.layer.masksToBounds = YES;
        _defImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_defImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    [self bringSubviewToFront:_defImageView];
    return _defImageView;
}

- (YYAnimatedImageView *)webPimageView {
    if (!_webPimageView) {
        _webPimageView = [[YYAnimatedImageView alloc] init];
        _webPimageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _webPimageView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
        [self addSubview:_webPimageView];
    }
    return _webPimageView;
}

- (UIImageView *)tempImageView {
    if (!_tempImageView) {
        _tempImageView = [[UIImageView alloc] init];
        _tempImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _tempImageView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
        [self addSubview:_tempImageView];
    }
    return _tempImageView;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    self.defImageView.image = image;
}

// 显示webp的图片动画，path：路径， scale：缩放放大倍数
- (void)showWebPAnimateWithPath:(NSString *)path scale:(CGFloat)scale {
    if (path.length == 0) {
        [self removeWebAnimate];
        return ;
    }
    [_webPimageView stopAnimating];
    
    self.webPimageView.image = [YYImage imageWithContentsOfFile:path];
    _webPimageView.alpha = 0.1;
    _defImageView.hidden = YES;
    _isAnimating = YES;
    self.tempImageView.image = self.defImageView.image;
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _webPimageView.frame = CGRectMake(0, 0, self.frame.size.width * scale, self.frame.size.height * scale);
        _webPimageView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
        _webPimageView.alpha = 1;
        _tempImageView.frame = CGRectMake(0, 0, self.frame.size.width * 0, self.frame.size.height * 0);
        _tempImageView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
        _tempImageView.alpha = 0;
    } completion:^(BOOL finished) {
        _isAnimating = NO;
        [_webPimageView startAnimating];
    }];
}

- (void)removeWebAnimate {
    self.enabled = NO;
    [_webPimageView stopAnimating];
    _isAnimating = YES;
    [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _webPimageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _webPimageView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
        _webPimageView.alpha = 0;
        
        _tempImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _tempImageView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
        _tempImageView.alpha = 1;
    } completion:^(BOOL finished) {
        [_webPimageView removeFromSuperview];
        _webPimageView = nil;
        _isAnimating = NO;
        
        [_tempImageView removeFromSuperview];
        _tempImageView = nil;
        
        _defImageView.hidden = NO;
        self.enabled = YES;
    }];
}
@end
