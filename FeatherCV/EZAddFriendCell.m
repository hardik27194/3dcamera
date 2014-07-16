//
//  EZAddFriendCell.m
//  FeatherCV
//
//  Created by xietian on 14-7-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZAddFriendCell.h"

@implementation EZAddFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, EZMainCellHeight)];
        [_addButton addTarget:self action:@selector(addClicked:) forControlEvents:UIControlEventTouchUpInside];
        _addButton.showsTouchWhenHighlighted = YES;
        
        UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 35)/2.0, 20, 35, 35)];
        icon.contentMode = UIViewContentModeScaleAspectFill;
        icon.image = [UIImage imageNamed:@"demo_avatar_cook"];
        
        UILabel* addText = [[UILabel alloc] initWithFrame:CGRectMake(0, 58, CurrentScreenWidth, 13)];
        addText.textAlignment = NSTextAlignmentCenter;
        addText.textColor = GrayTextColor;
        addText.text = macroControlInfo(@"add friend");
        addText.font = [UIFont systemFontOfSize:12];
        [_addButton addSubview:icon];
        [_addButton addSubview:addText];
        [self.contentView addSubview:_addButton];
        
    }
    return self;
}

- (void) addClicked:(id)sender
{
    if(_addClicked){
        _addClicked(sender);
    }
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
