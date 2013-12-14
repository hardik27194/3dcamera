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
        _name = [[UILabel alloc] initWithFrame:CGRectMake(15, (cellHeight - 17)/2, 220, 17)];
        _name.font = [UIFont systemFontOfSize:16];
        _name.textColor = [UIColor blackColor];//RGBCOLOR(128, 128, 128);
        [self.contentView addSubview:_name];
        
        _clickRegion = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 320, cellHeight)];
        [self.contentView addSubview:_clickRegion];

        _headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(265, (cellHeight - 40)/2, 40, 40)];
        [_headIcon enableRoundImage];
        [self.contentView addSubview:_headIcon];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
