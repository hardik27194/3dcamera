//
//  EZRecorderCell.m
//  BabyCare
//
//  Created by xietian on 14-7-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZRecorderCell.h"

@implementation EZRecorderCell


- (void) setSelected:(BOOL)selected
{
    EZDEBUG(@"Selected get called");
}

- (void) hideStar:(BOOL)hide
{
    UIImageView* starImg = (UIImageView*)[_starButton viewWithTag:1677];
    starImg.hidden = hide;
}

- (void) setStarred:(BOOL)starred
{
    UIImageView* starImg = (UIImageView*)[_starButton viewWithTag:1677];
    if(starred){
        starImg.image = [UIImage imageNamed:@"icon_star"];
    }else{
        starImg.image = [UIImage imageNamed:@"header_btn_star"];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _starButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        _starButton.showsTouchWhenHighlighted = YES;
        UIImageView* starImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_star"]];
        [starImg setPosition:CGPointMake(3, 4)];
        [_starButton addSubview:starImg];
        starImg.tag = 1677;
        [_starButton addTarget:self action:@selector(starClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _measurement = [UILabel createLabel:CGRectMake(30, 13, frame.size.width - 2*30, 16) font:[UIFont boldSystemFontOfSize:14] color:RGBCOLOR(94, 94, 94)];
        _measurement.textAlignment = NSTextAlignmentCenter;
        
        _name = [UILabel createLabel:CGRectMake(30, 90, frame.size.width - 2 * 30, 14) font:[UIFont boldSystemFontOfSize:12] color:RGBCOLOR(58, 178, 223)];
        
        _iconButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width - 50)/2.0, 35, 50, 50)];
        _iconButton.showsTouchWhenHighlighted = YES;
        [_iconButton addTarget:self action:@selector(iconClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_starButton];
        [self.contentView addSubview:_measurement];
        [self.contentView addSubview:_name];
        [self.contentView addSubview:_iconButton];
    }
    return self;
}

- (void) starClicked:(id)obj
{
    if(_starClicked){
        _starClicked(obj);
    }
}

- (void) iconClicked:(id)obj
{
    if(_iconClicked){
        _iconClicked(obj);
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
