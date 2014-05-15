//
//  EZMotionImage.m
//  FeatherCV
//
//  Created by xietian on 14-5-12.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZMotionImage.h"
#import "EZMotionUtility.h"
#import "EZMotionRecord.h"


@implementation EZMotionImage

- (void) play
{
    if(!_motionImages.count){
        return;
    }
    EZMotionRecord* mr = [_motionImages objectAtIndex:0];
    if(!_container.image){
        _container.image = mr.image;
    }
    __weak EZMotionImage* weakSelf = self;
    //[[EZMotionUtility getInstance] storedMotions]
    EZDEBUG(@"register motion handler");
    [[EZMotionUtility getInstance] registerHandler:^(EZMotionData* md){
        //EZDEBUG(@"motion start update");
        if(!weakSelf.startData){
            weakSelf.startData = md;
            return;
            
        }
        [weakSelf switchImage:md];
    } key:int2str((int)self) type:kEZRotation];
}

- (void) switchImage:(EZMotionData*)md
{
    double deltaY = _startData.currentMotion.quaternion.y - md.currentMotion.quaternion.y;
    //EZDEBUG(@"deltaY is:%f", deltaY);
    for(int i = 1; i < _motionImages.count; i++){
        EZMotionRecord* mr = [_motionImages objectAtIndex:i];
        if(deltaY < mr.deltaY){
            _container.image = mr.image;
            break;
        }
    }
}


- (void) dealloc
{
    [[EZMotionUtility getInstance] unregisterHandler:int2str((int)self)];
}

- (void) stop
{
    EZDEBUG(@"unregister the motion");
    [[EZMotionUtility getInstance] unregisterHandler:int2str((int)self)];
    if(_motionImages.count){
        EZMotionRecord* mr = [_motionImages objectAtIndex:0];
        _container.image = mr.image;
    }
}

@end
