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
        [_container addSubview:_frontImage];
        [_container addSubview:_frontNoEffects];
        //[self.contentView addSubview:_imageClick];
        //[self.contentView addSubview:_likeButton];
        //[self.contentView addSubview:_talkButton];
        //[self.contentView addSubview:_name];
        
    }
    return self;
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
    CGSize imgSize = img.size;
    CGFloat adjustedHeight = [self calHeight:imgSize];
    //CGFloat deltaHeight = adjustedHeight - 320;
    //EZDEBUG(@"imageSize:%f,%f, adjustedHeight:%f", imgSize.width, imgSize.height, adjustedHeight);
    CGSize updatedSize = CGSizeMake(320, adjustedHeight);
    [_container setSize:updatedSize];
    //[_frontImage setSize:updatedSize];
    [_frontNoEffects setSize:updatedSize];
    [_frontNoEffects setImage:img];
}

- (CGFloat) calHeight:(CGSize)size
{
    return 320 * size.height/size.width;
}

- (void) backToOriginSize
{
    [_container setSize:CGSizeMake(320, 320)];
    [_frontImage setSize:CGSizeMake(320, 320)];
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
