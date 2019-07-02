//
//  RYVideoDisplayViewController.m
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/6/24.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import "RYVideoDisplayViewController.h"
#import "RYVideoDisplayTableViewCell.h"
#import "RYVideoDisplayModel.h"
#import <MJRefresh.h>
#import <SDWebImage.h>

static const NSInteger kVideoDisplayViewControllerPageSize = 7;

@interface RYVideoDisplayViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, assign) NSUInteger loadingPage;
@property (nonatomic, assign) BOOL isHaveMoreData;
@property (nonatomic, assign) BOOL isLoadingData;

@property (nonatomic, assign) NSUInteger playingVideoRow;
@property (nonatomic, assign) NSUInteger lastVideoRow;

@end

@implementation RYVideoDisplayViewController

#pragma mark public method

-(BOOL)prefersStatusBarHidden{
    [super prefersStatusBarHidden];
    return YES;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeSubviews];
    [self initializeDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

/**
 * 获取当前 cell 并播放
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.playingVideoRow = self.tableView.contentOffset.y / [UIScreen mainScreen].bounds.size.height;
    if (self.playingVideoRow != self.lastVideoRow) {
        self.lastVideoRow = self.playingVideoRow;
        RYVideoDisplayTableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.playingVideoRow inSection:0]];
        [currentCell needToStartPlayVideo];
        [self startRunTimer];
    }

    // 最后一条数据时请求下一页数据，代替 MJRefreshFooter
    if (self.playingVideoRow == self.dataArr.count - 1) {
        [self getRecommendVideoList];
    }
}

/**
 * 在 cell 刚出现时就会调用，但实际需求需要等待 cell 完全展示后才会播放视频
 */
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//}

/**
 * 停止已消失 cell 播放
 */
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    RYVideoDisplayTableViewCell *lastCell = (RYVideoDisplayTableViewCell *)cell;
    [lastCell stopPlayVideo];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.height;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RYVideoDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RYVideoDisplayTableViewCell" forIndexPath:indexPath];
    RYVideoDisplayModel *videoModel = self.dataArr[indexPath.row];
    [cell configVideoPlayerWithModel:videoModel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - private method

/**
 初始化视图
 */
- (void)initializeSubviews {
    
    // 熄屏处理
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.view.backgroundColor = [UIColor blackColor];
    
    // 初始化 tableView
    self.tableView = [UITableView new];
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.pagingEnabled = YES;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.bounces = YES;
    self.tableView.scrollsToTop = NO;
    self.tableView.backgroundColor = [UIColor blackColor];
    [self.tableView registerClass:[RYVideoDisplayTableViewCell class] forCellReuseIdentifier:@"RYVideoDisplayTableViewCell"];
    [self.view addSubview:self.tableView];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // 下拉刷新
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header  = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf.tableView.mj_header endRefreshing];
        });
    }];
}

/**
 初始化数据源
 */
- (void)initializeDataSource {
    self.loadingPage = 0;
    self.playingVideoRow = 0;
    self.lastVideoRow = -1;
    self.isHaveMoreData = YES;
    self.isLoadingData = NO;
    [self getRecommendVideoList];
}

/**
 获取推荐小视频列表
 */
- (void)getRecommendVideoList {
    
    if (self.isHaveMoreData == NO) {
        return;
    }
    
    if (self.isLoadingData == YES) {
        return;
    }
    
    self.isLoadingData = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];
        self.isLoadingData = NO;
        
        // mock video model
        NSArray *videoList = [self mockVideoListWithPage:(self.loadingPage)];
        
        // 更新上拉状态
        if (videoList.count < kVideoDisplayViewControllerPageSize) {
            self.isHaveMoreData = NO;
        } else {
            self.isHaveMoreData = YES;
        }
        
        // 首页重置数据源
        if (self.loadingPage == 0) {
            [self.dataArr removeAllObjects];
        }
        
        // 重构视频列表
        [self reformVideoList:videoList];
        
        // 填充数据源
        [self.dataArr addObjectsFromArray:videoList];
        [self.tableView reloadData];
        self.loadingPage++;
        
        // tableView reloadData 后视频变为stop状态，重新播放
        RYVideoDisplayTableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.playingVideoRow inSection:0]];
        [currentCell needToStartPlayVideo];
    });
}

/**
 * 重构视频列表
 */
- (NSArray<RYVideoDisplayModel *> *)reformVideoList:(NSArray<RYVideoDisplayModel *> *)videoList {
    
    // 提前利用 SDWebImageManager 缓存首帧图
    for (RYVideoDisplayModel *model in videoList) {
        NSString *firstCoverUrlString = model.videoFirstCover;
        if (firstCoverUrlString && ![firstCoverUrlString isEqualToString:@""]) {
            SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
            [imageManager loadImageWithURL:[NSURL URLWithString:firstCoverUrlString] options:SDWebImageProgressiveLoad progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                
            }];
        }
    }
    return videoList;
}

/**
 * 单个视频播放后浏览量+1
 */
- (void)startRunTimer {
    
    RYVideoDisplayModel *oldVideoModel = self.dataArr[self.playingVideoRow];
    NSString *oldVideoId = [NSString stringWithFormat:@"%tu", oldVideoModel.videoId];
    
    // 0.5s后对比播放视频与调用时播放视频为同一个 发送浏览量+1请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RYVideoDisplayModel *videoModel = self.dataArr[self.playingVideoRow];
        NSString *newVideoId = [NSString stringWithFormat:@"%@", videoModel.videoId];
        if ([oldVideoId isEqualToString:newVideoId]) {
            NSDictionary *params = @{@"id": newVideoId};
            NSLog(@"视频%@ 浏览量+1", params[@"id"]);
        }
    });
}

/**
 * mock video model
 */
- (NSArray *)mockVideoListWithPage:(NSUInteger)page {
    
    NSMutableArray <RYVideoDisplayModel *>*videoList = @[].mutableCopy;
    RYVideoDisplayModel *mockVideo = [RYVideoDisplayModel new];
    mockVideo.videoId = [NSString stringWithFormat:@"%@01", @(page)];
    mockVideo.videoFirstCover = @"https://p1.pstatp.com/large/292a60006a6b1298a5430.jpg";
    mockVideo.videoUrl = @"https://aweme.snssdk.com/aweme/v1/playwm/?s_vid=93f1b41336a8b7a442dbf1c29c6bbc56628898e4fd48bfb5d166718688e836b3c0a09eeb2e6d6f44891b75e7bf15174cbdfcd7481f6c1b2c286f7dc9f87d66e4&line=0";
    [videoList addObject:mockVideo];
    {
        RYVideoDisplayModel *mockVideo = [RYVideoDisplayModel new];
        mockVideo.videoId = [NSString stringWithFormat:@"%@02", @(page)];
        mockVideo.videoFirstCover = @"https://p3.pstatp.com/large/2310e0005ad3aeaa55bc7.jpg";
        mockVideo.videoUrl = @"https://aweme.snssdk.com/aweme/v1/playwm/?s_vid=93f1b41336a8b7a442dbf1c29c6bbc563c103cc9f4349d53f746ad630b60aa681d33a5b43660f544eaf4c5801cc7a76e6c02d1d87ab5620f4a5454d73fa0a5a7&line=0";
        [videoList addObject:mockVideo];
    }
    {
        RYVideoDisplayModel *mockVideo = [RYVideoDisplayModel new];
        mockVideo.videoId = [NSString stringWithFormat:@"%@03", @(page)];
        mockVideo.videoFirstCover = @"https://p9.pstatp.com/large/279d3000baf9fc151bbe7.jpg";
        mockVideo.videoUrl = @"https://aweme.snssdk.com/aweme/v1/playwm/?s_vid=93f1b41336a8b7a442dbf1c29c6bbc568b05694b87b49370e6ce61ec8beb3b01da15c15ba2f168be86a5c96bb5d86708f455381a16953fe526374e16d84992f4&line=0";
        [videoList addObject:mockVideo];
    }
    {
        RYVideoDisplayModel *mockVideo = [RYVideoDisplayModel new];
        mockVideo.videoId = [NSString stringWithFormat:@"%@04", @(page)];
        mockVideo.videoFirstCover = @"https://p3.pstatp.com/large/273760003def77e017a22.jpg";
        mockVideo.videoUrl = @"https://aweme.snssdk.com/aweme/v1/playwm/?s_vid=93f1b41336a8b7a442dbf1c29c6bbc561d14c81a619ea0613fef0a657f61303e482c027a6ab024faf9a3ffcd9090a282c86c32f5a55e6af2d9e6b19268a62060&line=0";
        [videoList addObject:mockVideo];
    }
    {
        RYVideoDisplayModel *mockVideo = [RYVideoDisplayModel new];
        mockVideo.videoId = [NSString stringWithFormat:@"%@05", @(page)];
        mockVideo.videoFirstCover = @"https://p3.pstatp.com/large/28fbd00046bb22757a8db.jpg";
        mockVideo.videoUrl = @"https://aweme.snssdk.com/aweme/v1/playwm/?s_vid=93f1b41336a8b7a442dbf1c29c6bbc56cfcf8204cfca96fa670fc3ea1e06e587d90f090b591c034a776958406fc3f0915123359f610608b50cb1379559669ccf&line=0";
        [videoList addObject:mockVideo];
    }
    {
        RYVideoDisplayModel *mockVideo = [RYVideoDisplayModel new];
        mockVideo.videoId = [NSString stringWithFormat:@"%@06", @(page)];
        mockVideo.videoFirstCover = @"https://p9.pstatp.com/large/274870002cabbda8f072f.jpg";
        mockVideo.videoUrl = @"https://aweme.snssdk.com/aweme/v1/playwm/?s_vid=93f1b41336a8b7a442dbf1c29c6bbc56cc3104f79f6639102fc76ca985c4d88f0ddb1855ced975b1f117aa55243e8386399e0a058644c654249a56f29bada1c6&line=0";
        [videoList addObject:mockVideo];
    }
    {
        RYVideoDisplayModel *mockVideo = [RYVideoDisplayModel new];
        mockVideo.videoId = [NSString stringWithFormat:@"%@07", @(page)];
        mockVideo.videoFirstCover = @"https://p1.pstatp.com/large/2348d00084bd03b6c0f27.jpg";
        mockVideo.videoUrl = @"https://aweme.snssdk.com/aweme/v1/playwm/?s_vid=93f1b41336a8b7a442dbf1c29c6bbc56332148bbc08b43fa9ee656ae4e4f1e800850e46d1ddd91011a50a09c7459ad112cd1e54218f9653dab5ec4a7ba419765&line=0";
        [videoList addObject:mockVideo];
    }
    return videoList.copy;
}

#pragma mark - setter and getter

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[].mutableCopy;
    }
    return _dataArr;
}

@end
