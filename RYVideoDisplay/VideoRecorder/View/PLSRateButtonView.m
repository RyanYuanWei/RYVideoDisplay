//
//  PLSRateButtonView.m
//  PLShortVideoKitDemo
//
//  Created by 冯文秀 on 2017/8/21.
//  Copyright © 2017年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "PLSRateButtonView.h"
//#import "XKColor.h"

#define KINDICATORHEIGHT 2.f
#define PLS_SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define PLS_SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)
#define COLOR_RGB(a,b,c,d) [UIColor colorWithRed:a/255.0 green:b/255.0 blue:c/255.0 alpha:d]
#define BUTTON_BACKGROUNDCOLOR COLOR_RGB(30, 30, 30, 0.8)
#define SELECTED_COLOR COLOR_RGB(60, 157, 191, 1)

@interface PLSRateButtonView ()
//@property (nonatomic, strong) UILabel *staticLabel;
@property (nonatomic, strong) UILabel *selectedLabel;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, assign) CGFloat totalWidth;


@end

@implementation PLSRateButtonView

- (NSMutableArray *)totalTitleArray
{
    if (_totalLabelArray == nil) {
        _totalLabelArray = [NSMutableArray array];
    }
    return _totalLabelArray;
}

- (instancetype)initWithFrame:(CGRect)frame defaultIndex:(NSInteger)defaultIndex
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        self.layer.cornerRadius = 36 * 0.5;
        self.layer.masksToBounds = YES;
        self.totalWidth = frame.size.width;
        self.index = defaultIndex;
    }
    return self;
}

- (void)setStaticTitleArray:(NSArray *)staticTitleArray
{
    _staticTitleArray = staticTitleArray;
    CGFloat scrollViewWith = _totalWidth;
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    CGFloat labelWidth = scrollViewWith/staticTitleArray.count;
    CGFloat labelHeight = self.frame.size.height;
    self.totalLabelArray = [NSMutableArray array];
    for (int i = 0; i < staticTitleArray.count; i++) {
        UILabel *staticLabel = [[UILabel alloc]init];
        staticLabel.userInteractionEnabled = YES;
        staticLabel.textAlignment = NSTextAlignmentCenter;
        staticLabel.text = staticTitleArray[i];
        staticLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14];

        staticLabel.tag = i+1;
        staticLabel.textColor = [UIColor whiteColor];
        
        staticLabel.highlightedTextColor = [UIColor colorWithHexString:@"9f9f9f"];
        labelX = i * labelWidth;
        staticLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
        [self.totalLabelArray addObject:staticLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(staticLabelClick:)];
        [staticLabel addGestureRecognizer:tap];
        
        if (i == self.index) {
            staticLabel.highlighted = YES;
            staticLabel.textColor = [UIColor colorWithHexString:@"9f9f9f"];;
            staticLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14];
            _selectedLabel = staticLabel;
        }
        [self addSubview:staticLabel];
    }
    
    self.indicatorView = [[UIView alloc] init];
    _indicatorView.backgroundColor = [UIColor whiteColor];
    
    CGFloat XSpace = 0;
    XSpace = labelWidth * self.index;
    _indicatorView.frame = CGRectMake(XSpace, 0, labelWidth, labelHeight);
    [self addSubview:_indicatorView];
    [self sendSubviewToBack:_indicatorView];
}

- (void)staticLabelClick:(UITapGestureRecognizer *)tap
{
    UILabel *titleLabel = (UILabel *)tap.view;
    [self staticLabelSelectedColor:titleLabel];
    
    NSInteger index = titleLabel.tag - 1;
    if (self.rateDelegate != nil && [self.rateDelegate respondsToSelector:@selector(rateButtonView:didSelectedTitleIndex:)]) {
        [self.rateDelegate rateButtonView:self didSelectedTitleIndex:index];
        for (UILabel *titleLab in self.totalLabelArray) {
            if (titleLab.tag == index + 1) {
                [self staticLabelSelectedColor:titleLab];
            }
        }
    }
}

- (void)staticLabelSelectedColor:(UILabel *)titleLabel
{
    _selectedLabel.highlighted = NO;
    _selectedLabel.textColor = [UIColor whiteColor];
    _selectedLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14];
    
    titleLabel.highlighted = YES;
    titleLabel.textColor = SELECTED_COLOR;
    titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14];

    _selectedLabel = titleLabel;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.20 animations:^{
        CGFloat XSpace = 0;
        XSpace = weakSelf.totalWidth/weakSelf.staticTitleArray.count * (titleLabel.tag - 1);
        weakSelf.indicatorView.frame = CGRectMake(XSpace, 0,weakSelf.totalWidth/weakSelf.staticTitleArray.count, weakSelf.frame.size.height);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
