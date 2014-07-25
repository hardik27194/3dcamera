//
//  EZDetailHeader.m
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZDetailHeader.h"

@implementation EZDetailHeader

+ (EZDetailHeader*) createDetailHeader
{
    return [[EZDetailHeader alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, 89)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _detailName = [UILabel createLabel:CGRectMake(124, 21, 180, 14) font:[UIFont boldSystemFontOfSize:12] color:[UIColor whiteColor]];
        
        _countInfo = [UILabel createLabel:CGRectMake(124, 43, 100, 23) font:[UIFont boldSystemFontOfSize:21] color:[UIColor whiteColor]];
        
        _countUnit = [UILabel createLabel:CGRectMake(165, 50, 80, 14) font:[UIFont systemFontOfSize:12] color:[UIColor whiteColor]];
        
        _icon = [[UIImageView alloc] initWithFrame:CGRectMake(52, 18, 50, 50)];
        _icon.contentMode = UIViewContentModeScaleAspectFill;
        [_icon enableRoundImage];
        
        
        _graph = [[UIImageView alloc] initWithFrame:CGRectMake(211, 18, 80, 48)];
        _graph.contentMode = UIViewContentModeScaleAspectFill;
        _graph.clipsToBounds = YES;

        [self addSubview:_detailName];
        [self addSubview:_countInfo];
        [self addSubview:_countUnit];
        [self addSubview:_icon];
        [self addSubview:_graph];
    }
    return self;
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
