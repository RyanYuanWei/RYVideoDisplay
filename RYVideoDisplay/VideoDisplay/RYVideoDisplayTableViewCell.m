//
//  RYVideoDisplayTableViewCell.m
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/6/24.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import "RYVideoDisplayTableViewCell.h"

@implementation RYVideoDisplayTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initializeVideoPlayer];
        [self initializeVideoInfoViews];
    }
    return self;
}

/**
 * 初始化播放器
 */
- (void)initializeVideoPlayer {
    
}

/**
 * 初始化用户相关视图
 */
- (void)initializeVideoInfoViews {
    self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
}


@end
