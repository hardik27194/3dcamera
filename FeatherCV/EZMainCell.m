//
//  EZMainCell.m
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZMainCell.h"
#import "UIImageView+AFNetworking.h"
#import "EZMenuItem.h"

#define EZNoteColor RGBCOLOR(52, 163, 195)
#define EZMainSelectColor RGBCOLOR(255, 27, 129)

@implementation EZMainCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self setupView];
    }
    return self;
}

- (void) setupView
{
    EZDEBUG(@"setupView get called");
    _icon = [[UIImageView alloc] initWithFrame:CGRectMake(25, 12, 21, 20)];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.contentView addSubview:_icon];
    
    _title = [UILabel createLabel:CGRectMake(59, 14, 200, 18) font:[UIFont boldSystemFontOfSize:15] color:[UIColor whiteColor]];
    [self.contentView addSubview:_title];
    
    _notesCount = [UILabel createLabel:CGRectMake(280, 15, 17, 17) font:[UIFont boldSystemFontOfSize:12] color:EZNoteColor];
    _notesCount.backgroundColor = [UIColor whiteColor];
    _notesCount.textAlignment = NSTextAlignmentCenter;
    [_notesCount enableRoundImage];
    [self.contentView addSubview:_notesCount];
    _notesCount.hidden = YES;
    
    
    _selectIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 46)];
    _selectIndicator.backgroundColor = EZMainSelectColor;
    _selectIndicator.hidden = YES;
    [self.contentView addSubview:_selectIndicator];
    
}

- (void)awakeFromNib
{
    // Initialization code
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    EZDEBUG(@"select get called %i", selected);
    if(selected){
        _selectIndicator.hidden = false;
        _title.textColor = EZMainSelectColor;
        [_icon setImageWithURL:str2url(_menuItem.selectedIconURL)];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }else{
        _selectIndicator.hidden = true;
        _title.textColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [_icon setImageWithURL:str2url(_menuItem.iconURL)];

    }
    // Configure the view for the selected state
}

@end
