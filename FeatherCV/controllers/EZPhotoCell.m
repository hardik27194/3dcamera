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


#define ToolRegionHeight 20
#define InitialFeedbackRegion 60

#define ToolRegionRect CGRectMake(0, 320-ToolRegionHeight, 320, ToolRegionHeight)

#define FeedbackRegionRect CGRectMake(0,380, 320, 40)

@implementation EZPhotoCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    EZDEBUG(@"InitStyle get called:%i, id:%@", style, reuseIdentifier);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _container = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        //[_container makeInsetShadowWithRadius:20 Color:RGBA(255, 255, 255, 128)];
        _frontImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        _frontImage.contentMode = UIViewContentModeScaleAspectFill;
        //[_frontImage makeInsetShadowWithRadius:20 Color:RGBA(255, 255, 255, 128)];
        //_frontNoEffects = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        //_frontNoEffects.contentMode = UIViewContentModeScaleAspectFill;
        //_toolHolder = [[ILTranslucentView alloc] initWithFrame:CGRectMake(0, 320 - 40, 320, 40)];
        //_toolHolder.constraints
        
        _toolRegion = [[UIView alloc] initWithFrame:ToolRegionRect];
        _toolRegion.backgroundColor = randBack(nil);
        _toolRegion.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        //_toolRegion.backgroundColor = [UIColor clearColor];//RGBCOLOR(128, 128, 255);
        //My feedback will grow gradually.
        _headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(15, (ToolRegionHeight-40)/2, 40, 40)];
        [_headIcon enableRoundImage];
        _headIcon.backgroundColor = randBack(nil);
        
        _linkIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(15+40+10, (ToolRegionHeight - 40)/2, 40, 40)];
        [_linkIcon enableRoundImage];
        _linkIcon.backgroundColor = randBack(nil);
        
        _backIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(15+80+20, (ToolRegionHeight - 40)/2, 40, 40)];
        [_backIcon enableRoundImage];
        _backIcon.backgroundColor = randBack(nil);
        
        _countIcon = [[UILabel alloc] initWithFrame:CGRectMake(15+120+30, (ToolRegionHeight - 40)/2, 40, 40)];
        _countIcon.font = [UIFont systemFontOfSize:14];
        _countIcon.textAlignment = NSTextAlignmentCenter;
        _countIcon.backgroundColor = randBack(nil);
        [_countIcon enableRoundImage];
        
        _photoTalk = [[UILabel alloc] initWithFrame:CGRectMake(15, (ToolRegionHeight - 20)/2.0, 290, 20)];
        _photoTalk.font = [UIFont systemFontOfSize:10];
        _photoTalk.textAlignment = NSTextAlignmentLeft;
        _photoTalk.textColor = [UIColor whiteColor];
        _photoTalk.text = @"I love you 我爱大萝卜 哈哈 1234";
        
        //[_toolRegion addSubview:_headIcon];
        //[_toolRegion addSubview:_linkIcon];
        //[_toolRegion addSubview:_backIcon];
        //[_toolRegion addSubview:_countIcon];
        [_toolRegion addSubview:_photoTalk];
        //_toolRegion.alpha = 0.5;
        //[_toolHolder addSubview:_toolRegion];
        _feedbackRegion = [[UIView alloc] initWithFrame:FeedbackRegionRect];
        _feedbackRegion.backgroundColor = [UIColor whiteColor];//RGBCOLOR(255, 128, 128);
        _feedbackRegion.alpha = 0.5;
        //_frontImage.layer.cornerRadius = 5;
        _frontImage.clipsToBounds = true;
        //_backImage = [EZStyleImage createFilteredImage:CGRectMake(0, 0, 320, 320)];
        //_backImage.contentMode = UIViewContentModeScaleAspectFill;
        //_backImage.layer.cornerRadius = 5;
        //_backImage.clipsToBounds = true;

        //_imageClick = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        //_imageClick.backgroundColor = [UIColor clearColor];
        //[_imageClick addSubview:_frontImage];
        //[self addSubview:_frontImage];
        //[self.contentView addSubview:_backImage];
        [self.contentView addSubview:_container];
        //[self.contentView addSubview:_toolRegion];
        //[self.contentView addSubview:_feedbackRegion];
        [_container addSubview:_frontImage];
        [_frontImage addSubview:_toolRegion];
        //[_container addSubview:_toolRegion];
        //[_container addSubview:_frontNoEffects];
        _container.enableTouchEffects = NO;
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
    //[_frontNoEffects setSize:CGSizeMake(320, adjustedHeight)];
    [_frontImage setSize:CGSizeMake(320, adjustedHeight)];
    [_frontImage adjustShadowSize:CGSizeMake(320, adjustedHeight)];
    [_toolRegion setPosition:CGPointMake(0, adjustedHeight-ToolRegionHeight)];
    [_feedbackRegion setPosition:CGPointMake(0, adjustedHeight+_toolRegion.frame.size.height)];
    
}

- (void) displayEffectImage:(UIImage*)img
{
    CGSize imgSize = img.size;
    CGFloat adjustedHeight = [self calHeight:imgSize];
    CGRect adjustedFrame = CGRectMake(0, 0, 320, adjustedHeight);
    if(!_frontImage){
        //_frontImage = [EZStyleImage createFilteredImage:adjustedFrame];
        _frontImage = [[UIImageView alloc] initWithFrame:adjustedFrame];
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
    [_frontImage setImage:img];
    //[_frontImage removeFromSuperview];
    //CGSize imgSize = img.size;
    //CGFloat adjustedHeight = [self calHeight:imgSize];
    //CGFloat deltaHeight = adjustedHeight - 320;
    //EZDEBUG(@"imageSize:%f,%f, adjustedHeight:%f", imgSize.width, imgSize.height, adjustedHeight);
    //CGSize updatedSize = CGSizeMake(320, adjustedHeight);
    //[_container setSize:updatedSize];
    //[_frontImage setSize:updatedSize];
    //[_frontNoEffects setSize:updatedSize];
    //[_frontNoEffects setImage:img];
}

//Why not get the size directly?
//This is hard.
- (CGFloat) calHeight:(CGSize)size
{
    return  ceilf((size.height/size.width) * 320.0);
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

- (void) switchImage:(UIImage*)img photo:(EZDisplayPhoto*)dp complete:(EZEventBlock)blk
{
    //_backImage = [[UIImageView alloc] initWithFrame:_frontImage.frame];
    //_backImage.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat height = [self calHeight:img.size];
    //Mean I will need to shrink the size.
    //What should I do?
    //Go the old way.
    EZDEBUG(@"current frame:%f, %f", _frontImage.frame.size.height, height);
    if(_frontImage.frame.size.height >= height){
        EZDEBUG(@"Will come up with the old animation.");
        [_frontImage makeInsetShadowWithRadius:20 Color:RGBA(255, 255, 255, 128)];
        UIView* tmpView = [_frontImage snapshotViewAfterScreenUpdates:NO];
        //[_frontImage removeInsetShadow];
        [_container addSubview:tmpView];
        [_container bringSubviewToFront:tmpView];
        _frontImage.image = img;
        [self adjustCellSize:img.size];
        //[_frontImage makeInsetShadowWithRadius:20 Color:RGBA(255, 255, 255, 128)];
        
        [UIView flipTransition:tmpView dest:_frontImage container:_container isLeft:YES duration:0.6 complete:^(id obj){
             [tmpView removeFromSuperview];
             [_frontImage removeInsetShadow];
            if(blk){
                blk(nil);
            }
        }];
    }else{
        EZDEBUG(@"Will start the new animation");
        dp.turningImageHeight = height;
        dp.oldTurnedImage = _frontImage.image;
        dp.turningAnimation = ^(EZPhotoCell* photoCell){
            [photoCell.frontImage makeInsetShadowWithRadius:20 Color:RGBA(255, 255, 255, 128)];
            UIView* tmpView = [photoCell.frontImage snapshotViewAfterScreenUpdates:NO];
            [photoCell.frontImage removeInsetShadow];
            [photoCell.container addSubview:tmpView];
            [photoCell.container bringSubviewToFront:tmpView];
            photoCell.frontImage.image = img;
            
            
            [UIView flipTransition:tmpView dest:photoCell.frontImage container:photoCell.container isLeft:YES duration:0.6 complete:^(id obj){
                [tmpView removeFromSuperview];
                [photoCell.frontImage removeInsetShadow];
            }];
            [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
                [photoCell adjustCellSize:img.size];
            } completion:^(BOOL completed){
                
            }];
        };
        blk(nil);
    }
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
