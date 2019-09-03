//
//  RYVideoRecordeViewController.m
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/7/16.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import "RYVideoRecordeViewController.h"
#import <PLShortVideoKit/PLShortVideoKit.h>
#import "PLSProgressBar.h"
#import "PLSRateButtonView.h"
#import "XKLWebpButton.h"

@interface RYVideoRecordeViewController () <PLShortVideoRecorderDelegate>

/**
 PLShortVideoKit
 */
@property (strong, nonatomic) PLSVideoConfiguration *videoConfiguration;
@property (strong, nonatomic) PLSAudioConfiguration *audioConfiguration;
@property (strong, nonatomic) PLShortVideoRecorder *shortVideoRecorder;

/**
 自定义视图
 */
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) XKLWebpButton *recordBtn;             // 录制按钮
@property (strong, nonatomic) PLSProgressBar *progressBar;          // 录制进度条
@property (strong, nonatomic) PLSRateButtonView *rateButtonView;    // 倍速View

@property (nonatomic, strong) NSURL *audioURL;                      // 音乐URL

@end

@implementation RYVideoRecordeViewController

-(BOOL)prefersStatusBarHidden {
    [super prefersStatusBarHidden];
    return YES;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeShortVideoRecorder];
    [self initializeSubviews];
}

- (void)dealloc {
    [self.shortVideoRecorder stopCaptureSession];
}

#pragma mark - private method

- (void)initializeShortVideoRecorder {
    
    // 将预览视图添加为当前视图的子视图
    [self.view addSubview:self.shortVideoRecorder.previewView];
}

// 初始化视图
- (void)initializeSubviews {
    
    // 容器视图
    UIView *containerView = [UIView new];
    containerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.containerView = containerView;

    // 录制按钮
    XKLWebpButton *recordBtn = [XKLWebpButton buttonWithType:UIButtonTypeCustom];
    recordBtn.adjustsImageWhenHighlighted = NO;
    recordBtn.selected = NO;
    [recordBtn setImage:[UIImage imageNamed:@"ry_ic_record_2"] forState:UIControlStateNormal];
    [containerView addSubview:recordBtn];
    [recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(50);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
    }];
    [recordBtn addTarget:self action:@selector(recordButtonEventTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [recordBtn addTarget:self action:@selector(recordButtonEventTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [recordBtn addTarget:self action:@selector(recordButtonEventTouchDown:) forControlEvents:UIControlEventTouchDown];
    [recordBtn addTarget:self action:@selector(recordButtonEventTouchCancel:) forControlEvents:UIControlEventTouchCancel];
    self.recordBtn = recordBtn;
    
    // 翻转按钮
    UIButton *overturnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [overturnBtn setTitle:@"翻转" forState:UIControlStateNormal];
    [overturnBtn setImage:[UIImage imageNamed:@"ry_ic_record_2"] forState:UIControlStateNormal];
    
    
    
    [overturnBtn layoutIfNeeded];
    CGFloat interImageTitleSpacing = 5;
    overturnBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, overturnBtn.titleLabel.frame.size.height + interImageTitleSpacing, -(overturnBtn.titleLabel.frame.size.width));
    overturnBtn.titleEdgeInsets = UIEdgeInsetsMake(overturnBtn.imageView.frame.size.height + interImageTitleSpacing, -(overturnBtn.imageView.frame.size.width), 0, 0);
    
    
    
    [overturnBtn addTarget:self action:@selector(clickOverturnBtn:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:overturnBtn];
    [overturnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(50);
        make.right.offset(-10);
        make.top.offset(10);
    }];
}

#pragma mark - PLShortVideoRecorderDelegate

// 获取到摄像头原数据时的回调, 便于开发者添加滤镜或美颜处理，需要注意的是这个回调在 camera 数据的输出线程，请不要做过于耗时的操作，否则可能会导致帧率下降
//- (CVPixelBufferRef __nonnull)shortVideoRecorder:(PLShortVideoRecorder *__nonnull)recorder cameraSourceDidGetPixelBuffer:(CVPixelBufferRef __nonnull)pixelBuffer {
//
//}

// 开始录制一段视频时
- (void)shortVideoRecorder:(PLShortVideoRecorder *__nonnull)recorder didStartRecordingToOutputFileAtURL:(NSURL *__nonnull)fileURL {
    
}

// 正在录制的过程中。在完成该段视频录制前会一直回调，可用来更新所有视频段加起来的总时长 totalDuration UI
- (void)shortVideoRecorder:(PLShortVideoRecorder *__nonnull)recorder didRecordingToOutputFileAtURL:(NSURL *__nonnull)fileURL fileDuration:(CGFloat)fileDuration totalDuration:(CGFloat)totalDuration {
    
}

// 完成一段视频的录制时
- (void)shortVideoRecorder:(PLShortVideoRecorder *__nonnull)recorder didFinishRecordingToOutputFileAtURL:(NSURL *__nonnull)fileURL fileDuration:(CGFloat)fileDuration totalDuration:(CGFloat)totalDuration {
    
}

// 删除了某一段视频
- (void)shortVideoRecorder:(PLShortVideoRecorder *__nonnull)recorder didDeleteFileAtURL:(NSURL *__nonnull)fileURL fileDuration:(CGFloat)fileDuration totalDuration:(CGFloat)totalDuration {
    
}

// 在达到指定的视频录制时间 maxDuration 后，如果再调用 [PLShortVideoRecorder startRecording]，那么会立即执行该回调。该回调功能是用于页面跳转
- (void)shortVideoRecorder:(PLShortVideoRecorder *__nonnull)recorder didFinishRecordingMaxDuration:(CGFloat)maxDuration {
    
}

#pragma mark - events

// 点击录制按钮
- (void)clickRecordButton:(UIButton *)sender {
    if (self.shortVideoRecorder.isRecording) {
        [self.shortVideoRecorder stopRecording];
    } else {
        [self.shortVideoRecorder startRecording];
    }
}

- (void)recordButtonEventTouchUpInside:(UIButton *)sender {
    NSLog(@"111111 TouchUpInside 111111");
}

- (void)recordButtonEventTouchUpOutside:(UIButton *)sender {
    NSLog(@"222222 TouchUpOutside 222222");
}

- (void)recordButtonEventTouchDown:(UIButton *)sender {
    NSLog(@"333333 TouchDown 333333");
}

- (void)recordButtonEventTouchCancel:(UIButton *)sender {
    NSLog(@"444444 TouchCancel 444444");
}

- (void)clickOverturnBtn:(UIButton *)sender {
    [self.shortVideoRecorder toggleCamera];
}

#pragma mark - setter & getter

- (PLShortVideoRecorder *)shortVideoRecorder {
    if (!_shortVideoRecorder) {
        
        // 创建拍摄 recorder 对象
        _shortVideoRecorder = [[PLShortVideoRecorder alloc] initWithVideoConfiguration:self.videoConfiguration audioConfiguration:self.audioConfiguration];
        
        // 设置代理
        _shortVideoRecorder.delegate = self;
        
        // 在开始录制前需要开启采集，开启采集后才能看到摄像头预览
        [_shortVideoRecorder startCaptureSession];
        
        // 设置实际拍摄过程中的最大拍摄时长，最小拍摄时长
        _shortVideoRecorder.maxDuration = 60.0f;
        _shortVideoRecorder.minDuration = 2.0f;
        
        // 视频的文件类型，默认为 PLSFileTypeMPEG4(.mp4)
        _shortVideoRecorder.outputFileType = PLSFileTypeMPEG4;
        
        // 设置是否根据设备的方向自动确定竖屏、横屏拍摄
        _shortVideoRecorder.adaptationRecording = YES;
        
        // 根据监听到 Application 的前后台状态自动停止和开始录制视频
        // 默认YES 从后台进入前台自动开始录制
        _shortVideoRecorder.backgroundMonitorEnable = YES;
        
        // 手动对焦的视图动画。该属性默认开启
        _shortVideoRecorder.innerFocusViewShowEnable = YES;
        
        // 设置拍摄的快／慢速率，支持5种拍摄速率 PLSVideoRecoderRateTopSlow、PLSVideoRecoderRateSlow、PLSVideoRecoderRateNormal、PLSVideoRecoderRateFast、PLSVideoRecoderRateTopFast
        // 默认为 PLSVideoRecoderRateNormal
        _shortVideoRecorder.recoderRate = PLSVideoRecoderRateNormal;
    }
    return _shortVideoRecorder;
}

- (PLSVideoConfiguration *)videoConfiguration {
    if (!_videoConfiguration) {
        
        // 创建视频的采集和编码配置对象
        _videoConfiguration = [PLSVideoConfiguration defaultConfiguration];
        
        // 自定义视频采集参数
        _videoConfiguration.sessionPreset = AVCaptureSessionPreset1280x720;
        _videoConfiguration.position = AVCaptureDevicePositionBack;
        _videoConfiguration.videoFrameRate = 30;
        _videoConfiguration.averageVideoBitRate = 1024*1000;
        _videoConfiguration.videoOrientation = AVCaptureVideoOrientationPortrait;
        
        // 自定义视频编码参数
        _videoConfiguration.videoProfileLevel = AVVideoProfileLevelH264HighAutoLevel;
        _videoConfiguration.videoSize = CGSizeMake(720, 1280);
    }
    return _videoConfiguration;
}

- (PLSAudioConfiguration *)audioConfiguration {
    if (!_audioConfiguration) {
        
        // 创建音频的采集和编码配置对象
        _audioConfiguration = [PLSAudioConfiguration defaultConfiguration];
    }
    return _audioConfiguration;
}

@end
