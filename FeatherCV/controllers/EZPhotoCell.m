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
#import "UIImageView+AFNetworking.h"
#import "EZSimpleClick.h"

#define kHeartRadius 35

@implementation EZPhotoCell



- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    EZDEBUG(@"InitStyle get called:%i, id:%@", style, reuseIdentifier);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = VinesGray;
        // Initialization code
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 310 + ToolRegionHeight)];
        _container.backgroundColor = VinesGray;
        //_container.layer.cornerRadius = 5;
        //_container.clipsToBounds = true;
        //_container.backgroundColor = [UIColor greenColor];
        
        _rotateContainer = [self createRotateContainer:CGRectMake(5, 5, 310, 310)];
        _rotateContainer.backgroundColor = VinesGray;
        [_container addSubview:_rotateContainer];
        //_rotateContainer.backgroundColor = [UIColor redColor];
        //[_container makeInsetShadowWithRadius:20 Color:RGBA(255, 255, 255, 128)];
        _frontImage = [self createFrontImage];
        //_frontImage.backgroundColor = RGBCOLOR(255, 255, 0);
        //_toolRegion = [self createToolRegion:ToolRegionRect];
        /**
        _photoTalk = (UILabel*)[_toolRegion viewWithTag:MainLabelTag];
        
        _clickHeart = [[EZClickImage alloc] initWithFrame:CGRectMake(310 - kHeartRadius, _frontImage.frame.size.height - kHeartRadius, kHeartRadius, kHeartRadius)];
        [_clickHeart enableRoundImage];
        [_container addSubview:_clickHeart];
        //_clickHeart.backgroundColor = randBack(nil);
        **/
        
        [self.contentView addSubview:_container];
        //[self.contentView addSubview:_toolRegion];
        //[self.contentView addSubview:_feedbackRegion];
        [_rotateContainer addSubview:_frontImage];
        //[_frontImage addSubview:_toolRegion];
        //[_rotateContainer addSubview:_toolRegion];
        //_container.enableTouchEffects = NO;
        _chatUnit = [[EZChatUnit alloc] initWithFrame:CGRectMake(0, 330, 320, 40)];
        [_container addSubview:_chatUnit];
        
    }
    return self;
}

- (UIView*) createRotateContainer:(CGRect)rect
{
    UIView* rotateContainer = [[UIView alloc] initWithFrame:rect];
    rotateContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    rotateContainer.clipsToBounds = true;
    [rotateContainer enableRoundImage];
    return rotateContainer;
}

- (EZSimpleClick*) createFrontImage
{
    EZSimpleClick* frontImage = [[EZSimpleClick alloc] initWithFrame:CGRectMake(0, 0, 310, 310)];
    frontImage.contentMode = UIViewContentModeScaleAspectFit;
    frontImage.clipsToBounds = true;
    frontImage.backgroundColor = [UIColor whiteColor];
    [frontImage enableRoundImage];
    return frontImage;
}

- (EZBarRegion*) createToolRegion:(CGRect)rect
{
    
    EZBarRegion* res = [[EZBarRegion alloc] initWithFrame:rect];
    res.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    res.location.text = @"上海, 张江";
    res.time.text = @"10:20";
    /**
    UIView* toolRegion = [[UIView alloc] initWithFrame:rect];
    toolRegion.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    toolRegion.backgroundColor = [UIColor whiteColor];//randBack(nil);
    //_toolRegion.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    //_toolRegion.backgroundColor = [UIColor clearColor];//RGBCOLOR(128, 128, 255);
    //My feedback will grow gradually.
    UILabel* photoTalk = [[UILabel alloc] initWithFrame:CGRectMake(15, (ToolRegionHeight - 20)/2.0, 290, 20)];
    photoTalk.font = [UIFont systemFontOfSize:10];
    photoTalk.tag = MainLabelTag;
    photoTalk.textAlignment = NSTextAlignmentLeft;
    photoTalk.textColor = [UIColor blackColor];
    photoTalk.backgroundColor = [UIColor clearColor];
    photoTalk.text = @"I love you 我爱大萝卜 哈哈 1234";
    [toolRegion addSubview:photoTalk];
     **/
    return res;
}

- (UIView*) createDupContainerTest:(UIImage *)img
{
    CGFloat adjustedHeight = [self calHeight:img.size];
    UIView* rt = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ContainerWidth, adjustedHeight + ToolRegionHeight)];
    rt.backgroundColor = RGBCOLOR(128, 128, 128);
    return rt;
}


- (UIView*) createDupContainer:(UIImage*)img
{
    CGFloat adjustedHeight = [self calHeight:img.size];
    UIView* rotateContainer = [self createRotateContainer:CGRectMake(0, 0, ContainerWidth, adjustedHeight + ToolRegionHeight)];
    UIImageView* frontImage = [self createFrontImage];
    frontImage.image = img;
    //[frontImage setSize:CGSizeMake(ContainerWidth, adjustedHeight)];
    [rotateContainer addSubview:frontImage];
    UIView* toolRegion = [self createToolRegion:CGRectMake(0, adjustedHeight, ContainerWidth, ToolRegionHeight)];
    [rotateContainer addSubview:toolRegion];
    [frontImage setSize:CGSizeMake(ContainerWidth, adjustedHeight)];
    return rotateContainer;
}
//Newly added method.
//I will adjust the image size and layout accordingly.
- (void) adjustInnerSize:(CGSize)size
{
    CGFloat adjustedHeight = [self calHeight:size];
    [_rotateContainer setSize:CGSizeMake(ContainerWidth, adjustedHeight+ToolRegionHeight)];
    //[_frontNoEffects setSize:CGSizeMake(320, adjustedHeight)];
    [_frontImage setSize:CGSizeMake(ContainerWidth, adjustedHeight)];
}

- (void) adjustCellSize:(CGSize)size
{
    CGFloat adjustedHeight = [self calHeight:size];
    //CGRect adjustedFrame = CGRectMake(0, 0, 320, adjustedHeight);
    [_container setSize:CGSizeMake(ContainerWidth, adjustedHeight+ToolRegionHeight)];
    [_rotateContainer setSize:CGSizeMake(ContainerWidth, adjustedHeight+ToolRegionHeight)];
    //[_frontNoEffects setSize:CGSizeMake(320, adjustedHeight)];
    [_frontImage setSize:CGSizeMake(ContainerWidth, adjustedHeight)];
    //[_frontImage adjustShadowSize:CGSizeMake(320, adjustedHeight)];
    //[_frontImage adjustImageShadowSize:CGSizeMake(320, adjustedHeight)];
    //[_toolRegion setPosition:CGPointMake(0, adjustedHeight)];
    //[_feedbackRegion setPosition:CGPointMake(0, adjustedHeight+_toolRegion.frame.size.height)];
    
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

}

//Why not get the size directly?
//This is hard.
//The name is just misleading.
//Mean I only the size for the image.
- (CGFloat) calHeight:(CGSize)size
{
    return  ceilf((size.height/size.width) * ContainerWidth);
}

- (void) backToOriginSize
{
    [_container setSize:CGSizeMake(ContainerWidth, ContainerWidth+ToolRegionHeight)];
    [_frontImage setSize:CGSizeMake(ContainerWidth, ContainerWidth)];
    //[_toolRegion setFrame:ToolRegionRect];
    //[_feedbackRegion setFrame:FeedbackRegionRect];
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


- (void) switchImage:(EZPhoto*)photo photo:(EZDisplayPhoto*)dp complete:(EZEventBlock)blk tableView:(UITableView*)tableView index:(NSIndexPath*)path
{
    
        EZPhoto* curPhoto = photo;
  
        UIView* srcView = [_rotateContainer snapshotViewAfterScreenUpdates:YES];
        srcView.tag = animateCoverViewTag;
        EZDEBUG(@"Will come up with the old animation.src:%i, _rotatePointer:%i, isFront:%i, screenURL:%@",(int)srcView, (int)_rotateContainer, dp.isFront, curPhoto.screenURL);
        [_container addSubview:srcView];
        //_rotateContainer.hidden = TRUE;
        EZDEBUG(@"Assume the switch is ready");
        if(dp.isFront){
            [_frontImage setImage:curPhoto.getScreenImage];
        }else{
            //[_frontImage setImageWithURL:str2url(curPhoto.screenURL) placeholderImage:placeholdImage];
            [_frontImage setImageWithURL:str2url(curPhoto.screenURL)];
        }
        [UIView flipTransition:srcView dest:_rotateContainer container:_container isLeft:YES duration:2 complete:^(id obj){
            [srcView removeFromSuperview];
        }];
      
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
