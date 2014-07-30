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
    //UIImageView* starImg = (UIImageView*)[_starButton viewWithTag:1677];
    _starImg.hidden = hide;
}

- (void) setStarred:(BOOL)starred
{
    //UIImageView* starImg = (UIImageView*)[_starButton viewWithTag:1677];
    if(starred){
        _starImg.image = [UIImage imageNamed:@"icon_star"];
    }else{
        _starImg.image = [UIImage imageNamed:@"header_btn_star"];
    }
}


- (void) enableTapView
{
    if(_tapView == nil){
        _tapView = [[UIView alloc] initWithFrame:self.bounds];
        _tapView.backgroundColor = [UIColor clearColor];//RGBA(255, 0, 0, 40);
        [self addSubview:_tapView];
    }
}

- (void) nameClicked:(id)obj
{
    if(_nameClicked){
        _nameClicked(nil);
    }
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //_starButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        //_starButton.showsTouchWhenHighlighted = YES;
        _starImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_star"]];
        [_starImg setPosition:CGPointMake(3, 4)];
        //[_starButton addSubview:starImg];
        _starImg.tag = 1677;
        //[_starButton addTarget:self action:@selector(starClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _measurement = [UILabel createLabel:CGRectMake(20, 13, frame.size.width - 2*20, 16) font:[UIFont boldSystemFontOfSize:14] color:RGBCOLOR(94, 94, 94)];
        _measurement.textAlignment = NSTextAlignmentCenter;
        
        _name = [UIButton createButton:CGRectMake(5, 90, frame.size.width - 10, 14) font:[UIFont boldSystemFontOfSize:12] color:RGBCOLOR(58, 178, 223) align:NSTextAlignmentCenter];
        [_name addTarget:self action:@selector(nameClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _iconButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width - 50)/2.0, 35, 50, 50)];
        _iconButton.showsTouchWhenHighlighted = YES;
        [_iconButton addTarget:self action:@selector(iconClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_starImg];
        [self.contentView addSubview:_measurement];
        [self.contentView addSubview:_name];
        [self.contentView addSubview:_iconButton];
        self.contentView.backgroundColor = [UIColor whiteColor];
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
