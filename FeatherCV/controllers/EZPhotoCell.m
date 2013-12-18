//
//  EZPhotoCell.m
//  Feather
//
//  Created by xietian on 13-9-17.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZPhotoCell.h"
#import "EZClickView.h"
#import "EZClickImage.h"
#import "EZExtender.h"
#import "AFNetworking.h"
#import "EZExtender.h"


#define ToolRegionHeight 60
#define InitialFeedbackRegion 60

#define ToolRegionRect CGRectMake(0, 320, 320, 60)

#define FeedbackRegionRect CGRectMake(0,380, 320, 40)

@implementation EZPhotoCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    EZDEBUG(@"InitStyle get called:%i, id:%@", style, reuseIdentifier);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _container = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        //_frontImage = [EZStyleImage createFilteredImage:CGRectMake(0, 0, 320, 320)];
        //_frontImage.contentMode = UIViewContentModeScaleAspectFill;
        
        _frontNoEffects = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        _frontNoEffects.contentMode = UIViewContentModeScaleAspectFill;
        
        
        _toolRegion = [[UIView alloc] initWithFrame:ToolRegionRect];
        _toolRegion.backgroundColor = RGBCOLOR(128, 128, 255);
        //My feedback will grow gradually.
        _headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(15, (ToolRegionHeight-40)/2, 40, 40)];
        [_headIcon enableRoundImage];
        _headIcon.backgroundColor = [UIColor grayColor];
        
        _linkIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(15+40+10, (ToolRegionHeight - 40)/2, 40, 40)];
        [_linkIcon enableRoundImage];
        _linkIcon.backgroundColor = [UIColor grayColor];
        
        _backIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(15+80+20, (ToolRegionHeight - 40)/2, 40, 40)];
        [_backIcon enableRoundImage];
        _backIcon.backgroundColor = [UIColor grayColor];
        
        _countIcon = [[UILabel alloc] initWithFrame:CGRectMake(15+120+30, (ToolRegionHeight - 40)/2, 40, 40)];
        _countIcon.font = [UIFont systemFontOfSize:16];
        _countIcon.textAlignment = NSTextAlignmentCenter;
        _countIcon.backgroundColor = [UIColor grayColor];
        [_countIcon enableRoundImage];
        
        [_toolRegion addSubview:_headIcon];
        [_toolRegion addSubview:_linkIcon];
        [_toolRegion addSubview:_backIcon];
        [_toolRegion addSubview:_countIcon];
        _toolRegion.alpha = 0.5;
        
        _feedbackRegion = [[UIView alloc] initWithFrame:FeedbackRegionRect];
        _feedbackRegion.backgroundColor = RGBCOLOR(255, 128, 128);
        _feedbackRegion.alpha = 0.5;
        //_frontImage.layer.cornerRadius = 5;
        _frontImage.clipsToBounds = true;
        _backImage = [EZStyleImage createFilteredImage:CGRectMake(0, 0, 320, 320)];
        _backImage.contentMode = UIViewContentModeScaleAspectFill;
        //_backImage.layer.cornerRadius = 5;
        _backImage.clipsToBounds = true;

        //_imageClick = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        
        //_imageClick.backgroundColor = [UIColor clearColor];
        //[_imageClick addSubview:_frontImage];
        //[self addSubview:_frontImage];
        //[self.contentView addSubview:_backImage];
        [self.contentView addSubview:_container];
        [self.contentView addSubview:_toolRegion];
        [self.contentView addSubview:_feedbackRegion];
        [_container addSubview:_frontImage];
        [_container addSubview:_frontNoEffects];
        //[self.contentView addSubview:_imageClick];
        //[self.contentView addSubview:_likeButton];
        //[self.contentView addSubview:_talkButton];
        //[self.contentView addSubview:_name];
        
    }
    return self;
}

//Newly added method.
//I will adjust the image size and layout accordingly.
- (void) adjustCellSize:(CGSize)size
{
    CGFloat adjustedHeight = [self calHeight:size];
    //CGRect adjustedFrame = CGRectMake(0, 0, 320, adjustedHeight);
    [_container setSize:CGSizeMake(320, adjustedHeight)];
    [_frontNoEffects setSize:CGSizeMake(320, adjustedHeight)];
    [_toolRegion setPosition:CGPointMake(0, adjustedHeight)];
    [_feedbackRegion setPosition:CGPointMake(0, adjustedHeight+_toolRegion.frame.size.height)];
    
}

- (void) displayEffectImage:(UIImage*)img
{
    CGSize imgSize = img.size;
    CGFloat adjustedHeight = [self calHeight:imgSize];
    CGRect adjustedFrame = CGRectMake(0, 0, 320, adjustedHeight);
    if(!_frontImage){
        _frontImage = [EZStyleImage createFilteredImage:adjustedFrame];
        //_frontImage.contentMode = UIViewContentModeScaleAspectFill;
        [_container setFrame:adjustedFrame];
        [_container addSubview:_frontImage];
    }else{
        [_frontImage setFrame:adjustedFrame];
        [_container setFrame:adjustedFrame];
        [_container addSubview:_frontImage];
    }
    [_frontImage setImage:img];
}


- (void) displayImage:(UIImage*)img
{
    [_frontImage removeFromSuperview];
    //CGSize imgSize = img.size;
    //CGFloat adjustedHeight = [self calHeight:imgSize];
    //CGFloat deltaHeight = adjustedHeight - 320;
    //EZDEBUG(@"imageSize:%f,%f, adjustedHeight:%f", imgSize.width, imgSize.height, adjustedHeight);
    //CGSize updatedSize = CGSizeMake(320, adjustedHeight);
    //[_container setSize:updatedSize];
    //[_frontImage setSize:updatedSize];
    //[_frontNoEffects setSize:updatedSize];
    [_frontNoEffects setImage:img];
}

//Why not get the size directly?
//This is hard.
- (CGFloat) calHeight:(CGSize)size
{
    return 320 * size.height/size.width;
}

- (void) backToOriginSize
{
    [_container setSize:CGSizeMake(320, 320)];
    [_frontImage setSize:CGSizeMake(320, 320)];
    [_toolRegion setFrame:ToolRegionRect];
    [_feedbackRegion setFrame:FeedbackRegionRect];
}

//What's the purpose of this method?
//Is to display an image on the cell, right?
//Cool, I will be clicked and display again.
//Let's just keep it simple and stupid.
//Make sure front image is always on the front.
- (void) displayPhoto:(NSString*)url
{
    //[self addSubview:_frontImage];
    //[_frontImage setImageWithURL:str2url(url) placeholderImage:PlaceHolderLargest];
}


//I am happy that define a good interface to handle the image switch action
- (void) switchImageTo:(NSString*)url
{
    __weak EZPhotoCell* weakSelf = self;
    //[_backImage setImageWithURL:str2url(url) placeholderImage:PlaceHolderLargest];
    [UIView flipTransition:_frontImage dest:_backImage container:_container isLeft:YES duration:1.0 complete:^(id obj){
        //UIImageView* tmp = _frontImage;
        //_frontImage = _backImage;
        //_backImage = tmp;
        if(weakSelf.flippedCompleted){
            weakSelf.flippedCompleted(nil);
        }
    }];
    //make the front image always there to recieve the image url.
    //I love this game, right?
    //UIImageView* tmp = _frontImage;
    //_frontImage = _backImage;
    //_backImage = tmp;
    
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
