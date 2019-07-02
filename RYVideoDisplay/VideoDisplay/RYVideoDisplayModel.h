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

@end

NS_ASSUME_NONNULL_END
