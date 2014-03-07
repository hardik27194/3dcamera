//
//  EZContactTableCell.m
//  FeatherCV
//
//  Created by xietian on 13-12-12.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZContactTableCell.h"
#import "EZClickImage.h"
#import "EZClickView.h"

@implementation EZContactTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    CGFloat cellHeight = 60;
    if (self) {
        // Initialization code
        _name = [[UILabel alloc] initWithFrame:CGRectMake(20, (cellHeight - 20)/2, 220, 17)];
        _name.font = [UIFont systemFontOfSize:20];
        _name.textColor = RGBCOLOR(128, 128, 128);//RGBCOLOR(128, 128, 128);
        [self.contentView addSubview:_name];
        
        _clickRegion = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 320, cellHeight)];
        [self.contentView addSubview:_clickRegion];

        _headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(265, (cellHeight - 40)/2.0, 40, 40)];
        [_headIcon enableRoundImage];
        [self.contentView addSubview:_headIcon];
        
        _inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(200, (cellHeight - 40)/2.0, 40, 60)];
        [_inviteButton setTitle:@"邀请" forState:UIControlStateNormal];
        [_inviteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_inviteButton addTarget:self action:@selector(inviteClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_inviteButton];
        self.backgroundColor =[UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) inviteClicked:(id)obj
{
    if(_inviteClicked){
        _inviteClicked(self);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
