//
//  EZContactCell.m
//  FeatherCV
//
//  Created by xietian on 14-6-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZContactMainCell.h"
#import "EZLineDrawingView.h"



@implementation EZContactMainCell


//The purpose of this class is to pervent the delete button from covering up by the
//Up content.
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self sendSubviewToBack:self.contentView];
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        _photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, EZPersonCellHeight)];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_photoView];
        _paintTouchView = [[EZLineDrawingView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, EZPersonCellHeight)];
        [self.contentView addSubview:_paintTouchView];
        _name = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, CurrentScreenWidth, 24)];
        _name.font = [UIFont systemFontOfSize:22];
        _name.textColor = [UIColor whiteColor];
        _name.textAlignment = NSTextAlignmentCenter;
        _otherName = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 18)];
        _otherName.font = [UIFont systemFontOfSize:16];
        _otherName.textColor = [UIColor whiteColor];
        _otherName.textAlignment = NSTextAlignmentLeft;
        
        _signature = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 200, 17)];
        _signature.font = [UIFont boldSystemFontOfSize:15];
        _signature.textColor = [UIColor whiteColor];
        _signature.textAlignment = NSTextAlignmentLeft;
        
        
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(CurrentScreenWidth - 30, (EZMainCellHeight - 44)/2.0, 120, 44)];
        _addButton.titleLabel.textAlignment = NSTextAlignmentRight;
        _addButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _addButton.showsTouchWhenHighlighted = YES;
        [_addButton addTarget:self action:@selector(addClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_name];
        [self.contentView addSubview:_otherName];
        [self.contentView addSubview:_signature];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
