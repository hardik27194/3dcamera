//
//  EZContactCell.m
//  Feather
//
//  Created by xietian on 13-10-16.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZContactCell.h"
#import "EZClickImage.h"
#import "EZExtender.h"

@implementation EZContactCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _name = [[UILabel alloc] initWithFrame:CGRectMake(18, (frame.size.height - 17)/2, 150, 17)];
        _name.textColor = [UIColor blackColor];
        _name.font = [UIFont systemFontOfSize:17];
        [self.contentView addSubview:_name];
        _border = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-1, frame.size.width,1)];
        _border.backgroundColor = RGBCOLOR(220, 220, 224);
        [self.contentView addSubview:_border];
        
        _headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(270, (frame.size.height - 35)/2, 35, 35)];
        [self.contentView addSubview:_headIcon];
        _headIcon.enableTouchEffects = true;
        [_headIcon enableRoundImage];
        
        _inviteButton = [[EZClickView alloc] initWithFrame:CGRectMake(270, (frame.size.height - 40)/2, 80, 40)];
        UILabel* inviteTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        inviteTitle.textColor = RGBCOLOR(200, 200, 204);
        inviteTitle.font = [UIFont systemFontOfSize:14];
        inviteTitle.text = @"邀请";
        [_inviteButton addSubview:inviteTitle];
        [self.contentView addSubview:_inviteButton];
    }
    
    self.backgroundColor = [UIColor whiteColor];
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
