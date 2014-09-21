//
//  EZImageUtil.h
//  3DCamera
//
//  Created by xietian on 14-9-19.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZImageUtil : NSObject

@property (nonatomic, strong) NSOperationQueue* imageOperationQueue;

SINGLETON_FOR_HEADER(EZImageUtil);

- (void) preloadImageURL:(NSURL *)url success:(EZEventBlock)success failed:(EZEventBlock)failed;

@end
