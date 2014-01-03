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


#define MainLabelTag 20140103

#define ToolRegionHeight 40
#define InitialFeedbackRegion 60

#define ToolRegionRect CGRectMake(0, 300, 300, ToolRegionHeight)

#define FeedbackRegionRect CGRectMake(0,380, 300, 40)

@implementation EZPhotoCell

- (void) setupIcon
{
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
    
    //[_toolRegion addSubview:_headIcon];
    //[_toolRegion addSubview:_linkIcon];
    //[_toolRegion addSubview:_backIcon];
    //[_toolRegion addSubview:_countIcon];
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    EZDEBUG(@"InitStyle get called:%i, id:%@", style, reuseIdentifier);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = VinesGray;
        // Initialization code
        _container = [[EZClickView alloc] initWithFrame:CGRectMake(10, 10, 300, 300 + ToolRegionHeight)];
        //_container.layer.cornerRadius = 5;
        _container.clipsToBounds = true;
        _container.backgroundColor = [UIColor clearColor];
        
        _rotateContainer = [self createRotateContainer:_container.bounds];
        [_container addSubview:_rotateContainer];
        //[_container makeInsetShadowWithRadius:20 Color:RGBA(255, 255, 255, 128)];
        _frontImage = [self createFrontImage];
        _toolRegion = [self createToolRegion:ToolRegionRect];
        _photoTalk = (UILabel*)[_toolRegion viewWithTag:MainLabelTag];
        [self.contentView addSubview:_container];
        //[self.contentView addSubview:_toolRegion];
        //[self.contentView addSubview:_feedbackRegion];
        [_rotateContainer addSubview:_frontImage];
        //[_frontImage addSubview:_toolRegion];
        [_rotateContainer addSubview:_toolRegion];
        _container.enableTouchEffects = NO;
        [self setupIcon];
        
    }
    return self;
}

- (UIView*) createRotateContainer:(CGRect)rect
{
    UIView* rotateContainer = [[UIView alloc] initWithFrame:rect];
    rotateContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    rotateContainer.clipsToBounds = true;
    rotateContainer.layer.cornerRadius = 5;
    return rotateContainer;
}

- (UIImageView*) createFrontImage
{
    UIImageView* frontImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    frontImage.contentMode = UIViewContentModeScaleAspectFit;
    frontImage.clipsToBounds = true;
    return frontImage;
}

- (UIView*) createToolRegion:(CGRect)rect
{
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
    return toolRegion;
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
- (void) adjustCellSize:(CGSize)size
{
    CGFloat adjustedHeight = [self calHeight:size];
    //CGRect adjustedFrame = CGRectMake(0, 0, 320, adjustedHeight);
    [_container setSize:CGSizeMake(ContainerWidth, adjustedHeight+ToolRegionHeight)];
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


- (void) switchImage:(UIImage*)img photo:(EZDisplayPhoto*)dp complete:(EZEventBlock)blk tableView:(UITableView*)tableView index:(NSIndexPath*)path
{
    //_backImage = [[UIImageView alloc] initWithFrame:_frontImage.frame];
    //_backImage.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat height = [self calHeight:img.size];
    //Mean I will need to shrink the size.
    //What should I do?
    //Go the old way.
    
    EZDEBUG(@"_frontImage height:%f, calculated height:%f", _frontImage.frame.size.height, height);
    if(_frontImage.frame.size.height >= height){
        EZDEBUG(@"Will come up with the old animation.");
        //[_frontImage makeInsetShadowWithRadius:20 Color:RGBA(255, 255, 255, 128)];
        //UIView* tmpView = [_rotateContainer snapshotViewAfterScreenUpdates:YES];
        //[_frontImage removeInsetShadow];
        //[_container addSubview:tmpView];
        //[_container bringSubviewToFront:tmpView];
        //[_frontImage makeInsetShadowWithRadius:20 Color:RGBA(255, 255, 255, 128)];
        UIView* destView = [self createDupContainer:img];
        destView.tag = animateCoverViewTag;
        //_rotateContainer.hidden = YES;
        //dispatch_later(0.1,^(){
        //[UIView animateWithDuration:1.0 animations:^(){
        //}];
            //_frontImage.image = img;
            //[self adjustCellSize:img.size];
            //dispatch_later(0.1, ^(){
            //UIView* destView = [_rotateContainer snapshotViewAfterScreenUpdates:NO];
            [_container addSubview:destView];
            //_rotateContainer.hidden = TRUE;
        [UIView flipTransition:_rotateContainer dest:destView container:_container isLeft:YES duration:1 complete:^(id obj){
            //[tmpView removeFromSuperview];
            //[destView removeFromSuperview];
            //_frontImage.image = img;
            //[self adjustCellSize:img.size];
            //_container.hidden = NO;
            //_rotateContainer.hidden = NO;
            if(blk){
                blk(nil);
            }
        }];
         //   });
        //});
    }else{
        EZDEBUG(@"Will start the new animation");
        dp.turningImageSize = CGSizeMake(ContainerWidth, height);
        
        UIView* oldView = [_rotateContainer snapshotViewAfterScreenUpdates:NO];
        dp.oldTurnedImage = oldView;
        UIView* destView = [self createDupContainer:img];
        dp.turningAnimation = ^(EZPhotoCell* photoCell){
            //[photoCell.frontImage makeInsetShadowWithRadius:20 Color:RGBA(255, 255, 255, 128)];
            //double delayInSeconds = 0.1;
            //dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            //photoCell.frontImage.hidden = YES;
            //[_rotateContainer removeFromSuperview];
            
            //photoCell.frontImage.image = img;
            //[photoCell adjustCellSize:img.size];
            //[photoCell.rotateContainer removeFromSuperview];
            //dispatch_later(0.1, ^(void){
                //UIView* tmpView = [photoCell.rotateContainer snapshotViewAfterScreenUpdates:NO];
                //UIView* destView = [photoCell.rotateContainer snapshotViewAfterScreenUpdates:NO];
                //photoCell.rotateContainer.hidden = YES;
                //[photoCell.frontImage removeInsetShadow];
                //[photoCell.container addSubview:tmpView];
                //[photoCell.container bringSubviewToFront:tmpView];
                [photoCell.container addSubview:destView];
                [photoCell.container bringSubviewToFront:destView];
                [UIView flipTransition:oldView dest:destView container:photoCell.container isLeft:YES duration:1 complete:^(id obj){
                    //photoCell.rotateContainer.hidden = NO;
                    //photoCell.frontImage.hidden = NO;
                    //[photoCell.container addSubview:_rotateContainer];
                    [destView removeFromSuperview];
                    [oldView removeFromSuperview];
                    photoCell.frontImage.image = img;
                    [photoCell adjustCellSize:img.size];
                }];
            //});

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
