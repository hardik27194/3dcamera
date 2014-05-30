//
//  EZChatCell.m
//  FeatherCV
//
//  Created by xietian on 14-5-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZChatCell.h"
#import "EZClickImage.h"

@implementation EZChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _chatLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 240, 44)];
        _chatLabel.backgroundColor = [UIColor clearColor];
        _chatLabel.font = [UIFont systemFontOfSize:13];
        _chatLabel.textColor = [UIColor whiteColor];
        [self addSubview:_chatLabel];
        
        _headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(310 - smallIconRadius, 10, smallIconRadius, smallIconRadius)];
        [_headIcon enableRoundImage];
        [self addSubview:_headIcon];
        
        _chatTime = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 100, 15)];
        _chatTime.backgroundColor = [UIColor clearColor];
        _chatTime.textColor = [UIColor whiteColor];
        _chatTime.font = [UIFont systemFontOfSize:10];
        _chatTime.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_chatTime];
    }
    return self;
}


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
