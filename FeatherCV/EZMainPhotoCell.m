//
//  EZMainPhotoCell.m
//  3DCamera
//
//  Created by xietian on 14-8-5.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZMainPhotoCell.h"
#import "EZEventEater.h"

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
        UIView* grayCover = [[UIView alloc] initWithFrame:_photo.frame];
        grayCover.backgroundColor = RGBA(0, 0, 0, 90);
        self.contentView.backgroundColor = CellBackgroundColor;
        
        _name = [UILabel createLabel:CGRectMake(5, 5, frame.size.width - 10, 16) font:[UIFont boldSystemFontOfSize:16] color:RGBCOLOR(230, 230, 230)];
        _name.textAlignment = NSTextAlignmentLeft;
        
        _photoCount = [UILabel createLabel:CGRectMake(5, 25, frame.size.width - 10, 14) font:[UIFont systemFontOfSize:12] color:RGBCOLOR(210, 210, 210)];
        _photoCount.textAlignment = NSTextAlignmentLeft;
        
        
        _clickInfo = [UILabel createLabel:CGRectMake(5, 60, frame.size.width - 10, 16) font:[UIFont systemFontOfSize:16] color:RGBCOLOR(210, 210, 210)];
        _clickInfo.textAlignment = NSTextAlignmentCenter;
        _clickInfo.text = @"Click to view";
        _clickInfo.hidden = YES;
        
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
        [self.contentView addSubview:_clickInfo];
        //[self.contentView addSubview:_updateDate];
        [self.contentView addSubview:_editBtn];
        [self.contentView addSubview:_shareBtn];
        //self.contentView.backgroundColor = [UIColor whiteColor];
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity.center = CGPointMake(self.width/2, self.height/2);
        [self.contentView addSubview:_activity];
        _eventEater = [[EZEventEater alloc] initWithFrame:self.bounds];
        _eventEater.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_eventEater];
        _eventEater.userInteractionEnabled = NO;
        _activity.hidden = YES;
    }
    return self;
}

- (void) setUploading:(BOOL)uploading
{
    if(uploading){
        //self.contentView.userInteractionEnabled = false;
        _activity.hidden = false;
        _eventEater.userInteractionEnabled = YES;
        [_activity startAnimating];
    }else{
        //self.contentView.userInteractionEnabled = true;
        _eventEater.userInteractionEnabled = NO;
        _activity.hidden = true;
        [_activity stopAnimating];
    }
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
