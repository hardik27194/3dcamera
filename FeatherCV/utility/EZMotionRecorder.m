//
//  EZMotionRecorder.m
//  FeatherCV
//
//  Created by xietian on 14-5-12.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZMotionRecorder.h"
#import "EZMotionUtility.h"
#import "EZMotionRecord.h"
//#import "EZMotionData.h"

@implementation EZMotionRecorder

- (id) init
{
    self = [super init];
    _storedMotionImages = [[NSMutableArray alloc] init];
    return  self;
}

- (void) start{
    __weak EZMotionRecorder* weakSelf = self;
    //[[EZMotionUtility getInstance] storedMotions]
    EZDEBUG(@"register motion handler");
    [[EZMotionUtility getInstance] registerHandler:^(EZMotionData* md){
        //EZDEBUG(@"motion start update");
        if(!weakSelf.startMotion){
            weakSelf.startMotion = md;
            //weakSelf.currentMotion = md;
            //return;
        }
        weakSelf.currentMotion = md;
        //[weakSelf switchImage:md];
    } key:int2str((int)self) type:kEZRotation];
}

- (void) stop{
    [[EZMotionUtility getInstance] unregisterHandler:int2str((int)self)];
}


- (void)dealloc
{
    [self stop];
}

- (NSArray*) getSortedImages
{
    EZMotionRecord* mr = [_storedMotionImages objectAtIndex:0];
    NSMutableArray* res = [[NSMutableArray alloc] initWithArray:_storedMotionImages];
    [res sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        EZMotionRecord* mr1 = (EZMotionRecord*)obj1;
        EZMotionRecord* mr2 = (EZMotionRecord*)obj2;
        return mr1.deltaY - mr2.deltaY;
    }];
    [res insertObject:mr atIndex:0];
    return res;
}

- (void) addImage:(UIImage*)image{
    EZMotionRecord* md = [[EZMotionRecord alloc] init];
    md.image = image;
    md.deltaY = _currentMotion.currentMotion.quaternion.y - _startMotion.currentMotion.quaternion.y;
    [_storedMotionImages addObject:md];
}
@end
