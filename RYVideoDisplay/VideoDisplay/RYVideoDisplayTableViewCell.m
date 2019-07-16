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
#import "VDFlashLabel.h"
#import "XKMusicAnimationPlayView.h"
#import "UIButton+XKEnlargeHitArea.h"
#import "RYLoadingLineLayer.h"
#import "RYHeartImageView.h"
#import "RYStartPlayImageView.h"
#import "VDFlashLabel.h"
#import "RYMusicRecordButton.h"

@interface RYVideoDisplayTableViewCell () <PLPlayerDelegate>

@property (nonatomic, strong) RYVideoDisplayModel *model; /** 数据源 */
@property (nonatomic, assign) BOOL isVideoNeedsToPlay; /** 是否需要播放视频 */
@property (nonatomic, assign) BOOL isEnableToPlay; /** 是否可以播放视频 */

@property (nonatomic, strong) PLPlayer *player; /** 播放器 */
@property (nonatomic, strong) UIView *videoInfoContainerView; /** 视频信息容器视图 */
@property (nonatomic, strong) UIImage *blackImage;  /** 黑色背景图 */
@property (nonatomic, strong) RYStartPlayImageView *startPlayView; /** 播放按钮视图 */
@property (nonatomic, strong) RYHeartImageView *heartImageView; /** 点赞动画视图 */
@property (nonatomic, strong) RYLoadingLineLayer *loadingLineLayer; /** 视频 loading 视图 */
@property (nonatomic, strong) VDFlashLabel *flashLabel; /** 跑马灯 */
@property (nonatomic, strong) UILabel *nameLabel; /** 作者名字 */
@property (nonatomic, strong) UILabel *videoDescribeLabel; /** 视频描述 */
@property (nonatomic, strong) RYMusicRecordButton *musicRecordButton; /** 唱片按钮 */
@property (nonatomic, strong) XKMusicAnimationPlayView *musicAnimationView; /** 音符动画视图 */
@property (nonatomic, strong) UILabel *shareCountLabel; /** 分享数量 */
@property (nonatomic, strong) UIButton *shareButton; /** 分享按钮 */
@property (nonatomic, strong) UILabel *commentCountLabel; /** 评论数量 */
@property (nonatomic, strong) UIButton *commentButton;; /** 评论按钮 */
@property (nonatomic, strong) UILabel *likeCountLabel; /** 点赞数量 */
@property (nonatomic, strong) UIButton *likeButton; /** 点赞按钮 */
@property (nonatomic, strong) UIButton *headerButton; /** 作者头像按钮 */
@property (nonatomic, strong) UIButton *attentionButton; /** 关注按钮 */
@property (nonatomic, strong) UILabel *attentionLabel; /** 关注标签 */

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

/**
 配置视频

 @param model 视频 model
 */
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

/**
 配置视频相关信息

 @param model 视频 model
 */
- (void)configVideoInfoViewsWithModel:(RYVideoDisplayModel *)model {
    
    // 数据源
    self.model = model;
    
    // 作者名字
    NSString *nameString = model.authorName;
    if (nameString && ![nameString isEqualToString:@""]) {
        self.nameLabel.hidden = NO;
        self.nameLabel.text = [NSString stringWithFormat:@"@%@", nameString];
    } else {
        self.nameLabel.hidden = YES;
        self.nameLabel.text = @"";
    }
    
    // 视频描述
    NSString *describeString = model.describe;
    if (describeString && ![describeString isEqualToString:@""]) {
        self.videoDescribeLabel.hidden = NO;
        self.videoDescribeLabel.text = describeString;
    } else {
        self.videoDescribeLabel.hidden = YES;
        self.videoDescribeLabel.text = @"";
    }
    
    // 音乐名字
    NSString *musicName = model.musicName;
    if (musicName && ![musicName isEqualToString:@""]) {
        NSArray *attStrArr = @[[[NSAttributedString alloc] initWithString:musicName attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor whiteColor]}]];
        self.flashLabel.stringArray = attStrArr;
    } else {
        self.flashLabel.stringArray = nil;
    }
    [self.flashLabel reloadData];
    
    // 作者头像
    NSString *userImage = model.authorPortrait;
    if (userImage && ![userImage isEqualToString:@""]) {
        [self.headerButton sd_setImageWithURL:[NSURL URLWithString:userImage] forState:UIControlStateNormal];
    } else {
        [self.headerButton setImage:[UIImage imageNamed:@"ry_ic_defult_head"] forState:UIControlStateNormal];
    }
    
    // 点赞图片
    self.likeButton.enabled = YES;
    if (model.isPraised) {
        [self.likeButton setBackgroundImage:[UIImage imageNamed:@"ry_ic_heart_red"] forState:UIControlStateNormal];
    } else {
        [self.likeButton setBackgroundImage:[UIImage imageNamed:@"ry_ic_heart"] forState:UIControlStateNormal];
    }
    
    // 点赞数
    NSInteger likeCount = model.likeCount.integerValue;
    NSString *likeCountString;
    if (likeCount < 10000) {
        likeCountString = [NSString stringWithFormat:@"%@", @(likeCount)];
    } else if (likeCount >= 10000) {
        CGFloat tempLikeCount = likeCount / 10000.0;
        likeCountString = [NSString stringWithFormat:@"%.1fW", tempLikeCount];
    }
    self.likeCountLabel.text = likeCountString;
    
    // 评论数
    NSInteger commentCount = model.commentCount.integerValue;
    NSString *commentCountString;
    if (commentCount < 10000) {
        commentCountString = [NSString stringWithFormat:@"%@", @(commentCount)];
    } else if (commentCount >= 10000) {
        CGFloat tempCommentCount = commentCount / 10000.0;
        commentCountString = [NSString stringWithFormat:@"%.1fW", tempCommentCount];
    }
    self.commentCountLabel.text = commentCountString;
    
    // 分享数
    NSInteger shareCount = model.shareCount.integerValue;
    NSString *shareCountString;
    //    shareCount = 341;
    if (shareCount < 10000) {
        shareCountString = [NSString stringWithFormat:@"%@", @(shareCount)];
    } else if (shareCount >= 10000) {
        CGFloat tempShareCount = shareCount / 10000.0;
        shareCountString = [NSString stringWithFormat:@"%.1fW", tempShareCount];
    }
    self.shareCountLabel.text = shareCountString;
    
    // 原创音乐头像
    NSString *musicRecordImageUrlString = model.musicImage;
    if (musicRecordImageUrlString && ![musicRecordImageUrlString isEqualToString:@""]) {
        [self.musicRecordButton sd_setImageWithURL:[NSURL URLWithString:musicRecordImageUrlString] forState:UIControlStateNormal];
    } else {
        [self.musicRecordButton setImage:[UIImage imageNamed:@"ry_ic_defult_head"] forState:UIControlStateNormal];
    }
}

- (void)needToStartPlayVideo {
    self.isVideoNeedsToPlay = YES;
}

- (void)pausePlayVideo {
    self.isVideoNeedsToPlay = NO;
    PLPlayerStatus status = self.player.status;
    if (status == PLPlayerStatusPlaying || status == PLPlayerStatusCaching) {
        [self.player pause];
        [self.startPlayView showStartPlayView];
        [self.flashLabel stopAutoScroll];
        [self.musicAnimationView stopAnimation];
        [self.musicRecordButton pauseMusicRecordButtonAnimation];
    }
}

- (void)resumePlayVideo {
    self.isVideoNeedsToPlay = YES;
    PLPlayerStatus status = self.player.status;
    if (status == PLPlayerStatusPaused) {
        [self.player resume];
        [self.startPlayView hiddenStartPlayView];
        [self.flashLabel continueAutoScroll];
        [self.musicAnimationView startAnimation];
        [self.musicRecordButton startMusicRecordButtonAnimation];
    }
}

- (void)stopPlayVideo {
    self.isVideoNeedsToPlay = NO;
    [self.player stop];
}

- (void)removePlayVideo {
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
        [self.loadingLineLayer stopLoadingLineAnimation];
    } else {
        [self.loadingLineLayer startLoadingLineAnimation];
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

#pragma mark - event handler


/**
 单击屏幕
 */
- (void)singleTapContainerView:(UITapGestureRecognizer *)sender {
    PLPlayerStatus status = self.player.status;
    if (status == PLPlayerStatusPlaying || status == PLPlayerStatusCaching) {
        [self pausePlayVideo];
    } else if (status == PLPlayerStatusPaused) {
        [self resumePlayVideo];
    }
}

/**
 双击屏幕
 */
- (void)doubleTapContainerView:(UITapGestureRecognizer *)sender {
    
}

- (void)clickHeaderButton:(UIButton *)sender {
    
}

- (void)clickAttentionButton:(UIButton *)sender {
    
}

- (void)clickLikeButton:(UIButton *)sender {
    
}

- (void)clickCommentButton:(UIButton *)sender {
    
}

- (void)clickShareButton:(UIButton *)sender {
    
}

- (void)clickMusicRecordButton:(UIButton *)sender {
    
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
    
// =================================== 视频信息容器视图 ===================================
    
    // 容器视图
    UIView *videoInfoContainerView = [UIView new];
    videoInfoContainerView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapContainerView:)];
    [videoInfoContainerView addGestureRecognizer:singleTap];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapContainerView:)];
    doubleTap.numberOfTapsRequired = 2;
    [videoInfoContainerView addGestureRecognizer:singleTap];
    [videoInfoContainerView addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self.contentView addSubview:videoInfoContainerView];
    [videoInfoContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.offset(0);
    }];
    self.videoInfoContainerView = videoInfoContainerView;
    
    // 播放按钮
    RYStartPlayImageView *startPlayView = [RYStartPlayImageView new];
    startPlayView.hidden = YES;
    [startPlayView setImage:[UIImage imageNamed:@"ry_ic_video_play"]];
    [videoInfoContainerView addSubview:startPlayView];
    [startPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(64);
        make.center.equalTo(self.contentView);
    }];
    self.startPlayView = startPlayView;
    
    // 点赞/取消点赞动画视图
    RYHeartImageView *heartImageView = [[RYHeartImageView alloc] initWithImage:[UIImage imageNamed:@"ry_ic_heart_red_big"]];
    heartImageView.frame = CGRectMake(0, 0, 53, 34);
    heartImageView.hidden = YES;
    [videoInfoContainerView addSubview:heartImageView];
    self.heartImageView = heartImageView;
    
    // 底部加载视图
    UIView *loadingLineContainerView = [UIView new];
    loadingLineContainerView.backgroundColor = [UIColor clearColor];
    [videoInfoContainerView addSubview:loadingLineContainerView];
    [loadingLineContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.trailing.offset(0);
        make.height.offset(1);
        make.bottom.offset(-44);
    }];
    RYLoadingLineLayer *loadingLineLayer = [RYLoadingLineLayer new];
    loadingLineLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [loadingLineContainerView.layer addSublayer:loadingLineLayer];
    loadingLineLayer.frame = CGRectMake(SCREEN_WIDTH / 2, 0, 1, 1);
    loadingLineLayer.hidden = YES;
    self.loadingLineLayer = loadingLineLayer;
    
    // 滚动label
    UIImageView *musicImageView = [[UIImageView alloc] init];
    musicImageView.image = [UIImage imageNamed:@"ry_ic_note"];
    musicImageView.contentMode = UIViewContentModeScaleAspectFit;
    [videoInfoContainerView addSubview:musicImageView];
    [musicImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(8);
        make.bottom.equalTo(loadingLineContainerView.mas_top).offset(-10);
        make.width.height.equalTo(@(16));
    }];
    
    VDFlashLabel *flashLabel = [VDFlashLabel new];
    flashLabel.scrollDirection = VDFlashLabelScrollDirectionLeft;
    flashLabel.backColor = [UIColor clearColor];
    flashLabel.lineHeight = 18;
    flashLabel.userScroolEnabled = NO;
    flashLabel.hspace = 0;
    [videoInfoContainerView addSubview:flashLabel];
    [flashLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(musicImageView.mas_right).offset(5);
        make.centerY.equalTo(musicImageView.mas_centerY);
        make.width.equalTo(@(127));
        make.height.equalTo(@(18));
    }];
    [flashLabel showAndStartTextContentScroll];
    [flashLabel stopAutoScroll];
    self.flashLabel = flashLabel;
    
    // 视频描述Label
    UILabel *videoDescribeLabel = [UILabel new];
    videoDescribeLabel.textColor = [UIColor whiteColor];
    videoDescribeLabel.font = [UIFont systemFontOfSize:13];
    videoDescribeLabel.numberOfLines = 2;
    [videoInfoContainerView addSubview:videoDescribeLabel];
    [videoDescribeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(8);
        make.bottom.mas_equalTo(musicImageView.mas_top).offset(-9);
        make.width.offset(265);
    }];
    self.videoDescribeLabel = videoDescribeLabel;
    
    // 作者名Label
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:15];
    [videoInfoContainerView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(8);
        make.bottom.equalTo(videoDescribeLabel.mas_top).offset(-10);
        make.height.offset(21);
    }];
    self.nameLabel = nameLabel;
    
    // 音符动画视图
    XKMusicAnimationPlayView *musicAnimationView = [XKMusicAnimationPlayView new];
    [videoInfoContainerView addSubview:musicAnimationView];
    [musicAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(loadingLineContainerView.mas_top).offset(-15);
        make.right.offset(-6);
        make.width.height.offset(100);
    }];
    self.musicAnimationView = musicAnimationView;
    
    // 底部唱片按钮
    RYMusicRecordButton *musicRecordButton = [RYMusicRecordButton new];
    musicRecordButton.layer.cornerRadius = 22;
    musicRecordButton.layer.masksToBounds = YES;
    musicRecordButton.adjustsImageWhenDisabled = NO;
    musicRecordButton.adjustsImageWhenHighlighted = NO;
    musicRecordButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [musicRecordButton addTarget:self action:@selector(clickMusicRecordButton:) forControlEvents:UIControlEventTouchUpInside];
    [videoInfoContainerView addSubview:musicRecordButton];
    [musicRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(musicAnimationView.mas_bottom);
        make.right.equalTo(musicAnimationView.mas_right);
        make.width.and.height.offset(46);
    }];
    self.musicRecordButton = musicRecordButton;
    
    // 分享数量
    UILabel *shareCountLabel = [[UILabel alloc] init];
    shareCountLabel.font = [UIFont systemFontOfSize:14];
    shareCountLabel.textColor = [UIColor whiteColor];
    shareCountLabel.textAlignment = NSTextAlignmentCenter;
    [videoInfoContainerView addSubview:shareCountLabel];
    [shareCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(musicRecordButton.mas_centerX);
        make.bottom.mas_equalTo(musicRecordButton.mas_top).offset(-25);
        make.height.offset(12);
    }];
    self.shareCountLabel = shareCountLabel;
    
    // 分享按钮
    UIButton *shareButton = [[UIButton alloc] init];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"ry_ic_sharearrow"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(clickShareButton:) forControlEvents:UIControlEventTouchUpInside];
    [videoInfoContainerView addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(40);
        make.height.offset(40);
        make.centerX.mas_equalTo(musicRecordButton.mas_centerX);
        make.bottom.mas_equalTo(shareCountLabel.mas_top).offset(-5);
    }];
    self.shareButton = shareButton;
    
    // 评论数量
    UILabel *commentCountLabel = [UILabel new];
    commentCountLabel.font = [UIFont systemFontOfSize:14];
    commentCountLabel.textColor = [UIColor whiteColor];
    commentCountLabel.textAlignment = NSTextAlignmentCenter;
    [videoInfoContainerView addSubview:commentCountLabel];
    [commentCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(musicRecordButton.mas_centerX);
        make.bottom.mas_equalTo(shareButton.mas_top).offset(-13.7);
        make.height.offset(12);
    }];
    self.commentCountLabel = commentCountLabel;
    
    // 评论按钮
    UIButton *commentButton = [[UIButton alloc] init];
    [commentButton setBackgroundImage:[UIImage imageNamed:@"ry_ic_comment"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(clickCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    [videoInfoContainerView addSubview:commentButton];
    [commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(35);
        make.height.offset(35);
        make.centerX.mas_equalTo(musicRecordButton.mas_centerX);
        make.bottom.mas_equalTo(commentCountLabel.mas_top).offset(-5);
    }];
    self.commentButton = commentButton;
    
    // 点赞数量
    UILabel *likeCountLabel = [UILabel new];
    likeCountLabel.font = [UIFont systemFontOfSize:14];
    likeCountLabel.textColor = [UIColor whiteColor];
    likeCountLabel.textAlignment = NSTextAlignmentCenter;
    [videoInfoContainerView addSubview:likeCountLabel];
    [likeCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(musicRecordButton.mas_centerX);
        make.bottom.mas_equalTo(commentButton.mas_top).offset(-14.6);
        make.height.offset(12);
    }];
    self.likeCountLabel = likeCountLabel;
    
    // 点赞按钮
    UIButton *likeButton = [UIButton new];
    [likeButton addTarget:self action:@selector(clickLikeButton:) forControlEvents:UIControlEventTouchUpInside];
    [likeButton setBackgroundImage:[UIImage imageNamed:@"ry_ic_heart"] forState:UIControlStateDisabled];
    [videoInfoContainerView addSubview:likeButton];
    [likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(37);
        make.height.offset(37);
        make.centerX.mas_equalTo(musicRecordButton.mas_centerX);
        make.bottom.mas_equalTo(likeCountLabel.mas_top).offset(-5);
    }];
    likeButton.enabled = NO;
    self.likeButton = likeButton;
    
    // 头像背景
    UIImageView *headerBgImageView = [[UIImageView alloc] init];
    headerBgImageView.image = [UIImage imageNamed:@"ry_ic_head_background"];
    [videoInfoContainerView addSubview:headerBgImageView];
    [headerBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(likeButton.mas_top).offset(-14.6);
        make.width.height.offset(53);
        make.centerX.mas_equalTo(musicRecordButton.mas_centerX);
    }];
    
    // 头像
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    headerButton.layer.cornerRadius = 43 * 0.5;
    headerButton.layer.masksToBounds = YES;
    headerButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [headerButton setImage:[UIImage imageNamed:@"ry_ic_defult_head"] forState:UIControlStateNormal];
    [headerButton addTarget:self action:@selector(clickHeaderButton:) forControlEvents:UIControlEventTouchUpInside];
    [videoInfoContainerView addSubview:headerButton];
    [headerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(43);
        make.centerX.mas_equalTo(headerBgImageView.mas_centerX).offset(-1);
        make.centerY.mas_equalTo(headerBgImageView.mas_centerY).offset(-1);
    }];
    self.headerButton = headerButton;
    
    // 关注按钮
    UIButton *attentionButton = [UIButton new];
    [attentionButton setBackgroundImage:[UIImage imageNamed:@"ry_ic_add"] forState:UIControlStateNormal];
    [attentionButton addTarget:self action:@selector(clickAttentionButton:) forControlEvents:UIControlEventTouchUpInside];
    [videoInfoContainerView addSubview:attentionButton];
    [attentionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(20);
        make.centerX.mas_equalTo(headerButton.mas_centerX).offset(1.5);
        make.centerY.mas_equalTo(headerButton.mas_centerY).offset(21.5);
    }];
    self.attentionButton = attentionButton;
}

/**
 * 开始播放视频
 */
- (void)startPlayVideo {
    PLPlayerStatus status = self.player.status;
    if (status == PLPlayerStatusOpen) {
        [self.player play];
        [self.startPlayView hiddenStartPlayView];
        [self.flashLabel continueAutoScroll];
        [self.musicAnimationView startAnimation];
        [self.musicRecordButton startMusicRecordButtonAnimation];
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
