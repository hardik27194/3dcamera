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
        _container = [[UIView alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10)];
        // Initialization code
        //_starButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        //_starButton.showsTouchWhenHighlighted = YES;
        //_container.layer.cornerRadius = 8;
        //_container.clipsToBounds = true;
        _container.backgroundColor = [EZColorScheme sharedEZColorScheme].generalBackgroundColor;
        //[_container enableShadow:RGBCOLOR(0, 0, 0)];
        
        
        
        [self.contentView addSubview:_container];
        _photo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _container.width, _container.width)];
        _photo.contentMode = UIViewContentModeScaleAspectFit;
        _clippingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _container.width, _container.width + 8)];
        _clippingView.backgroundColor = [UIColor clearColor];
        [_container addSubview:_photo];
        _photo.layer.cornerRadius = 5;
        _photo.clipsToBounds = true;
        //[_container addSubview:_clippingView];
        //[_clippingView addSubview:_photo];
        //_clippingView.layer.cornerRadius = 8;
        //_clippingView.clipsToBounds = true;
        
        //[_starImg setPosition:CGPointMake(3, 4)];
        //[_starButton addSubview:starImg];
        //_starImg.tag = 1677;
        //[_starButton addTarget:self action:@selector(starClicked:) forControlEvents:UIControlEventTouchUpInside];
        //UIView* grayCover = [[UIView alloc] initWithFrame:_photo.frame];
        //grayCover.backgroundColor = RGBA(0, 0, 0, 90);
        //self.contentView.backgroundColor = MainBackgroundColor;
        
        _name = [UILabel createLabel:CGRectMake(5, _photo.height + 5, frame.size.width - 10, 16) font:[UIFont boldSystemFontOfSize:14] color:[EZColorScheme sharedEZColorScheme].mainCellNameColor];
        _name.textAlignment = NSTextAlignmentLeft;
        
        _photoCount = [UILabel createLabel:CGRectMake(5, _name.bottom + 4, frame.size.width - 10, 14) font:[UIFont systemFontOfSize:12] color:[EZColorScheme sharedEZColorScheme].mainCellTimeColor];
        _photoCount.textAlignment = NSTextAlignmentLeft;
        
        
        _clickInfo = [UILabel createLabel:CGRectMake(5, 60, frame.size.width - 10, 16) font:[UIFont systemFontOfSize:16] color:RGBCOLOR(210, 210, 210)];
        _clickInfo.textAlignment = NSTextAlignmentCenter;
        _clickInfo.text = @"点击查看";
        _clickInfo.hidden = YES;
        
        /**
        _updateDate = [UILabel createLabel:CGRectMake(20, _name.bottom + 8, frame.size.width - 2*20, 16) font:[UIFont systemFontOfSize:14] color:RGBCOLOR(200, 200, 200)];
        _updateDate.textAlignment = NSTextAlignmentCenter;
        **/
        
        
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, _photo.height, self.width,44)];
        
        [_toolBar setBackgroundImage:[UIImage new]
                      forToolbarPosition:UIToolbarPositionAny
                              barMetrics:UIBarMetricsDefault];
        
        [_toolBar setBackgroundColor:[UIColor clearColor]];
        //[self.contentView addSubview:_toolBar];
        //_toolBar.backgroundColor = [UIColor clearColor];
        
        /**
        _editBtn = [UIButton createButton:CGRectMake(5, self.bounds.size.height - 48, 60, 40) font:[UIFont boldSystemFontOfSize:16] color:EZBarButtonColor align:NSTextAlignmentLeft];
        [_editBtn addTarget:self action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        
        _shareBtn = [UIButton createButton:CGRectMake(self.bounds.size.width - 60 - 5, self.bounds.size.height - 48, 60, 40) font:[UIFont boldSystemFontOfSize:16] color:EZBarButtonColor align:NSTextAlignmentRight];
        [_shareBtn addTarget:self action:@selector(shareClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_shareBtn setTitle:@"分享" forState:UIControlStateNormal];
        **/
        UIBarButtonItem* editBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(editClicked:)];
        
        UIBarButtonItem* sepBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* shareBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareClicked:)];
        _toolBar.items = @[editBar,sepBar,shareBar];
        
        _toolBar.tintColor = ClickedColor;
        //_photo.layer.cornerRadius = 5.0;
        _photo.clipsToBounds = true;
        //[_container addSubview:_photo];
        //[self.contentView addSubview:grayCover];
        [_container addSubview:_name];
        //[_container addSubview:_photoCount];
        [_container addSubview:_clickInfo];
        //[self.contentView addSubview:_updateDate];
        //[self.contentView addSubview:_editBtn];
        //[self.contentView addSubview:_shareBtn];
        //[self.contentView addSubview:_toolBar];
        //self.contentView.backgroundColor = [UIColor whiteColor];
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity.center = CGPointMake(self.width/2, self.height/2);
        [_container addSubview:_activity];
        _eventEater = [[EZEventEater alloc] initWithFrame:self.bounds];
        _eventEater.backgroundColor = [UIColor clearColor];
        [_container addSubview:_eventEater];
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
