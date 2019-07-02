//
//  RYVideoDisplayTableViewCell.m
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/6/24.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import "RYVideoDisplayTableViewCell.h"
#import "RYVideoDisplayModel.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import <SDWebImage.h>

@interface RYVideoDisplayTableViewCell () <PLPlayerDelegate>

@property (nonatomic, strong) RYVideoDisplayModel *model; /** 数据源 */
@property (nonatomic, assign) BOOL isVideoNeedsToPlay; /** 是否需要播放视频 */
@property (nonatomic, assign) BOOL isEnableToPlay; /** 是否可以播放视频 */
@property (nonatomic, strong) PLPlayer *player; /** 播放器 */
@property (nonatomic, strong) UIView *videoInfoContainerView; /** 视频信息容器视图 */
@property (nonatomic, strong) UIImage *blackImage;  /** 黑色背景图 */

@end

@implementation RYVideoDisplayTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initializeVideoPlayer];
        [self initializeVideoInfoViews];
    }
    return self;
}

#pragma mark - public method

- (void)configVideoPlayerWithModel:(RYVideoDisplayModel *)model {
    
    // 初始化视频状态
    self.model = model;
    self.isVideoNeedsToPlay = NO;
    self.isEnableToPlay = NO;
    
    // 配置首帧图
    NSString *firstCoverUrlString = model.videoFirstCover;
    if (firstCoverUrlString && ![firstCoverUrlString isEqualToString:@""]) {
        [self.player.launchView sd_setImageWithURL:[NSURL URLWithString:firstCoverUrlString] placeholderImage:self.blackImage];
    }
    
    // 配置视频URL
    NSString *videoUrlSting = model.videoUrl;
    if (videoUrlSting && ![videoUrlSting isEqualToString:@""]) {
        NSURL *videoUrl = [NSURL URLWithString:videoUrlSting];
        [self.player openPlayerWithURL:videoUrl];
    }
}

- (void)configVideoInfoViewsWithModel:(RYVideoDisplayModel *)model{
    
}

- (void)needToStartPlayVideo{
    self.isVideoNeedsToPlay = YES;
}

- (void)pausePlayVideo{
    self.isVideoNeedsToPlay = NO;
    PLPlayerStatus status = self.player.status;
    if (status == PLPlayerStatusPlaying || status == PLPlayerStatusCaching) {
        [self.player pause];
    }
}

- (void)resumePlayVideo{
    self.isVideoNeedsToPlay = YES;
    PLPlayerStatus status = self.player.status;
    if (status == PLPlayerStatusPaused) {
        [self.player resume];
    }
}

- (void)stopPlayVideo{
    self.isVideoNeedsToPlay = NO;
    [self.player stop];
}

- (void)removePlayVideo{
    self.isVideoNeedsToPlay = NO;
}

#pragma mark - PLPlayerDelegate

- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    
    // 这里会返回流的各种状态，你可以根据状态做 UI 定制及各类其他业务操作
    // 除了 Error 状态，其他状态都会回调这个方法
    // 开始播放，当连接成功后，将收到第一个 PLPlayerStatusCaching 状态
    // 第一帧渲染后，将收到第一个 PLPlayerStatusPlaying 状态
    // 播放过程中出现卡顿时，将收到 PLPlayerStatusCaching 状态
    // 卡顿结束后，将收到 PLPlayerStatusPlaying 状态
    
    // loading视图状态
    if (state == PLPlayerStatusPlaying ||
        state == PLPlayerStatusPaused ||
        state == PLPlayerStatusStopped ||
        state == PLPlayerStatusError) {
//        [self pauseLoadingLineAnimation];
    } else {
//        [self startLoadingLineAnimation];
    }
    
    // 播放准备是否完成
    if (state == PLPlayerStatusOpen || state == PLPlayerStatusPaused) {
        self.isEnableToPlay = YES;
    } else {
        self.isEnableToPlay = NO;
    }
}

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    // 当发生错误，停止播放时，会回调这个方法
}

- (void)player:(nonnull PLPlayer *)player codecError:(nonnull NSError *)error {
    // 当解码器发生错误时，会回调这个方法
    // 当 videotoolbox 硬解初始化或解码出错时
    // error.code 值为 PLPlayerErrorHWCodecInitFailed/PLPlayerErrorHWDecodeFailed
    // 播发器也将自动切换成软解，继续播放
}

/**
 * 即将开始进入后台播放任务
 */
- (void)playerWillBeginBackgroundTask:(PLPlayer *)player {
//    [self pausePlayVideo];
}

/**
 * 即将结束后台播放状态任务
 */
- (void)playerWillEndBackgroundTask:(nonnull PLPlayer *)player {
//    [self resumePlayVideo];
}

#pragma mark - private method

/**
 * 初始化播放器相关视图
 */
- (void)initializeVideoPlayer {
    
    // =================================== 初始化 PLPlayerOption ===================================
    
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    
    // 接收/发送数据包超时时间间隔所对应的键值，单位为 s ，默认配置为 10s
    [option setOptionValue:@10 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
    
    // 一级缓存大小，单位为 ms，默认为 2000ms，增大该值可以减小播放过程中的卡顿率，但会增大弱网环境的最大累积延迟
    [option setOptionValue:@2000 forKey:PLPlayerOptionKeyMaxL1BufferDuration];
    
    // 默认二级缓存大小，单位为 ms，默认为 300ms，增大该值可以减小播放过程中的卡顿率，但会增大弱网环境的最大累积延迟
    [option setOptionValue:@300 forKey:PLPlayerOptionKeyMaxL2BufferDuration];
    
    // 是否使用 video toolbox 硬解码
    [option setOptionValue:@(YES) forKey:PLPlayerOptionKeyVideoToolbox];
    
    // 配置 log 级别
    [option setOptionValue:@(kPLLogError) forKey:PLPlayerOptionKeyLogLevel];
    
    // 视频预设值播放 URL 格式类型
    PLPlayFormat videoPreferFormat = kPLPLAY_FORMAT_MP4;
    [option setOptionValue:@(videoPreferFormat) forKey:PLPlayerOptionKeyVideoPreferFormat];
    
    // =================================== 初始化 PLPlayer ===================================
    
    self.player = [[PLPlayer alloc] initWithURL:nil option:option];
    
    // 设置代理 (optional)
    self.player.delegate = self;
    
    // 设置视频填充模式
    self.player.playerView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 设置首帧图填充模式
    self.player.launchView.contentMode = UIViewContentModeScaleAspectFit;
    self.player.launchView.backgroundColor = [UIColor blackColor];
    self.player.launchView.image = self.blackImage;
    
    // 设置循环播放
    self.player.loopPlay = YES;
    
    // 设置允许缓存
    self.player.bufferingEnabled = YES;
    
    // 是否开启重连，默认为 NO
    self.player.autoReconnectEnable = YES;
    
    // 获取视频输出视图并添加为到当前 UIView 对象的 Subview
    [self.contentView addSubview:self.player.playerView];
}

/**
 * 初始化视频信息相关视图
 */
- (void)initializeVideoInfoViews {
//    self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
}

/**
 * 开始播放视频
 */
- (void)startPlayVideo {
    PLPlayerStatus status = self.player.status;
    if (status == PLPlayerStatusOpen) {
        [self.player play];
    }
}

#pragma mark - setter & getter

- (void)setIsVideoNeedsToPlay:(BOOL)isVideoNeedsToPlay {
    _isVideoNeedsToPlay = isVideoNeedsToPlay;
    if (_isVideoNeedsToPlay && _isEnableToPlay) {
        [self startPlayVideo];
    }
}

- (void)setIsEnableToPlay:(BOOL)isEnableToPlay {
    _isEnableToPlay = isEnableToPlay;
    if (_isVideoNeedsToPlay && _isEnableToPlay) {
        [self startPlayVideo];
    }
}

/**
 * 黑色背景图片
 */
- (UIImage *)blackImage {
    if (!_blackImage) {
        UIColor *color = [UIColor blackColor];
        CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        _blackImage = theImage;
    }
    return _blackImage;
}

@end
