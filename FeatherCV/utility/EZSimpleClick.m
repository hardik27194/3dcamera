//
//  EZSimpleClick.m
//  FeatherCV
//
//  Created by xietian on 14-2-24.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZSimpleClick.h"

@implementation EZSimpleClick

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        self.userInteractionEnabled = TRUE;
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void) longPress:(id)obj
{
    if(_longPressed){
        _longPressed(obj);
    }
}

- (void) tap:(id)obj
{
    if(_tappedBlock){
        _tappedBlock(obj);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
