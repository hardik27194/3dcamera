//
//  EZProfileHeader.m
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZProfileHeader.h"
//#import "EZShapeCover.h"

@implementation EZProfileHeader


+ (EZProfileHeader*) createHeader
{
    return [[EZProfileHeader alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, EZProfileCellHeight)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _name = [UILabel createLabel:CGRectMake(112, 61, 200, 20) font:[UIFont boldSystemFontOfSize:18] color:[UIColor whiteColor]];
        _middleInfo =[UILabel createLabel:CGRectMake(112, 91, 200, 16) font:[UIFont boldSystemFontOfSize:14] color:[UIColor whiteColor]];
        _bottomInfo = [UILabel createLabel:CGRectMake(112, 109, 200, 14) font:[UIFont boldSystemFontOfSize:12] color:[UIColor whiteColor]];
        
        _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(24, 49, 82, 82)];
        _avatar.contentMode = UIViewContentModeScaleAspectFill;
        _avatar.layer.borderColor = [UIColor whiteColor].CGColor;
        _avatar.layer.borderWidth = 2.0;
        [_avatar enableRoundImage];

        [self addSubview:_name];
        [self addSubview:_middleInfo];
        [self addSubview:_bottomInfo];
        [self addSubview:_avatar];
        //[self addSubview:_avatarCover];
        
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
