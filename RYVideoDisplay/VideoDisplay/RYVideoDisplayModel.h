//
//  RYVideoDisplayModel.h
//  RYVideoDisplay
//
//  Created by RyanYuan on 2019/6/24.
//  Copyright © 2019 RyanYuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RYVideoDisplayModel : NSObject

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *videoFirstCover;
@property (nonatomic, copy) NSString *videoUrl;

@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *describe;
@property (nonatomic, copy) NSString *musicName;
@property (nonatomic, copy) NSString *authorPortrait;
@property (nonatomic, copy) NSString *likeCount;
@property (nonatomic, copy) NSString *commentCount;
@property (nonatomic, copy) NSString *shareCount;
@property (nonatomic, copy) NSString *musicImage;
@property (nonatomic, assign) BOOL isPraised;

@end

NS_ASSUME_NONNULL_END
