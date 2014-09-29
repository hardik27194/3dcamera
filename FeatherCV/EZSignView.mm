//
//  EZSignView.m
//  3DCamera
//
//  Created by xietian on 14-9-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZSignView.h"
#import <QuartzCore/QuartzCore.h>
#import "EZCanvas.h"
#import "EZPathObject.h"

@implementation EZSignView


- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        //_signView = [[UIView alloc] initWithFrame:self.bounds];
    }
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) setSignType:(EZSignType)signType
{
    _signType = signType;
    [self removeAllSubviews];
    if(_signType == kPauseSign){
        CGFloat width = self.width / 3.0;
        UIView* firstCol = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, self.height)];
        UIView* secondCol = [[UIView alloc] initWithFrame:CGRectMake(width * 2.0, 0, width, self.height)];
        firstCol.backgroundColor = [UIColor whiteColor];
        secondCol.backgroundColor = [UIColor whiteColor];
        [self addSubview:firstCol];
        [self addSubview:secondCol];
    }else if(_signType == kPlaySign){
        EZCanvas* angleSign = [[EZCanvas alloc] initWithFrame:self.bounds];
        EZPathObject* pathObj = [EZPathObject createPath:[UIColor whiteColor] width:0 isFill:YES];
        [pathObj addPoints:@[pointValue(0, 0), pointValue(self.width, self.height/2.0), pointValue(0, self.height)]];
        [angleSign addShapeObject:pathObj];
        [self addSubview:angleSign];
        [angleSign setNeedsDisplay];
    }else if(_signType == kStopSign){
        //self.backgroundColor = [UIColor whiteColor];
        UIView* stopView = [[UIView alloc] initWithFrame:self.bounds];
        stopView.backgroundColor = [UIColor whiteColor];
        //stopView.layer.radius = 5;
        [self addSubview:stopView];
        EZDEBUG(@"Nothing to do");
    }
}

@end
