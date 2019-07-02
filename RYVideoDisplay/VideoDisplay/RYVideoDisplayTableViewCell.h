//
//  RYVideoDisplayTableViewCell.h
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/6/24.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RYVideoDisplayModel;

@interface RYVideoDisplayTableViewCell : UITableViewCell

/**
 * 配置视频播放数据源
 */
- (void)configVideoPlayerWithModel:(RYVideoDisplayModel *)model;

/**
 * 配置视频信息
 */
- (void)configVideoInfoViewsWithModel:(RYVideoDisplayModel *)model;

/**
 * 将视频标记为需要播放
 */
- (void)needToStartPlayVideo;

/**
 * 暂停播放
 */
- (void)pausePlayVideo;

/**
 * 继续播放
 */
- (void)resumePlayVideo;

/**
 * 停止播放
 */
- (void)stopPlayVideo;

/**
 * 移除播放控件
 */
- (void)removePlayVideo;

@end

NS_ASSUME_NONNULL_END
