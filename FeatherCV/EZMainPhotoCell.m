//
//  EZMainPhotoCell.m
//  3DCamera
//
//  Created by xietian on 14-8-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZMainPhotoCell.h"

@implementation EZMainPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //_starButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        //_starButton.showsTouchWhenHighlighted = YES;
        _photo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)];
        _photo.contentMode = UIViewContentModeScaleAspectFit;
        //[_starImg setPosition:CGPointMake(3, 4)];
        //[_starButton addSubview:starImg];
        //_starImg.tag = 1677;
        //[_starButton addTarget:self action:@selector(starClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIView* grayCover = [[UIView alloc] initWithFrame:self.bounds];
        grayCover.backgroundColor = RGBA(0, 0, 0, 45);
        
        _name = [UILabel createLabel:CGRectMake(5, 5, frame.size.width - 10, 16) font:[UIFont boldSystemFontOfSize:16] color:[UIColor whiteColor]];
        _name.textAlignment = NSTextAlignmentLeft;
        
        _photoCount = [UILabel createLabel:CGRectMake(5, 25, frame.size.width - 10, 14) font:[UIFont systemFontOfSize:12] color:RGBCOLOR(190, 190, 190)];
        _photoCount.textAlignment = NSTextAlignmentLeft;
        
        /**
        _updateDate = [UILabel createLabel:CGRectMake(20, _name.bottom + 8, frame.size.width - 2*20, 16) font:[UIFont systemFontOfSize:14] color:RGBCOLOR(200, 200, 200)];
        _updateDate.textAlignment = NSTextAlignmentCenter;
        **/
        
        
        _editBtn = [UIButton createButton:CGRectMake(5, self.bounds.size.height - 48, 60, 40) font:[UIFont boldSystemFontOfSize:16] color:EZBarButtonColor align:NSTextAlignmentLeft];
        [_editBtn addTarget:self action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        
        _shareBtn = [UIButton createButton:CGRectMake(self.bounds.size.width - 60 - 5, self.bounds.size.height - 48, 60, 40) font:[UIFont boldSystemFontOfSize:16] color:EZBarButtonColor align:NSTextAlignmentRight];
        [_shareBtn addTarget:self action:@selector(shareClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_shareBtn setTitle:@"分享" forState:UIControlStateNormal];
        [self.contentView addSubview:_photo];
        [self.contentView addSubview:grayCover];
        [self.contentView addSubview:_name];
        [self.contentView addSubview:_photoCount];
        //[self.contentView addSubview:_updateDate];
        [self.contentView addSubview:_editBtn];
        [self.contentView addSubview:_shareBtn];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void) shareClicked:(id)obj
{
    EZDEBUG(@"Share clicked");
    if(_shareClicked){
        _shareClicked(obj);
    }
}

- (void) editClicked:(id)obj
{
    EZDEBUG(@"Edit clicked");
    if(_editClicked){
        _editClicked(obj);
    }
}
    


@end
