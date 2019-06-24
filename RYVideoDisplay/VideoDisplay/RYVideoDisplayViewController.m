//
//  RYVideoDisplayViewController.m
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/6/24.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import "RYVideoDisplayViewController.h"
#import "RYVideoDisplayTableViewCell.h"
#import <MJRefresh.h>

@interface RYVideoDisplayViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation RYVideoDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeViews];
}

-(BOOL)prefersStatusBarHidden{
    [super prefersStatusBarHidden];
    return YES;
}

/**
 初始化视图
 */
- (void)initializeViews {
    
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.height;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RYVideoDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RYVideoDisplayTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
