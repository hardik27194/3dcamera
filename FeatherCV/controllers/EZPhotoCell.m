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
#import "EZShapeButton.h"
#import "EZScrollViewer.h"
#import "EZDataUtil.h"
#import "EZEnlargedView.h"

#define kHeartRadius 35

@implementation EZPhotoCell



- (void) buttonClick:(id)obj
{
    EZDEBUG(@"like clicked");
    [UIView animateWithDuration:0.2 animations:^(){
        _likeButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL completed){
        [UIView animateWithDuration:0.3 animations:^(){
            _likeButton.transform = CGAffineTransformIdentity;
        }];
    }];
    if(_buttonClicked){
        _buttonClicked(nil);
    }
}


- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    EZDEBUG(@"InitStyle get called:%i, id:%@", style, reuseIdentifier);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = VinesGray;//[UIColor clearColor];
        // Initialization code
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
        _container.backgroundColor = VinesGray;
        
        //Then I can adjust it once for all.
        CGFloat startPos = -100;
        //_container.backgroundColor = [UIColor clearColor];
        
        //_container.layer.cornerRadius = 5;
        //_container.clipsToBounds = true;
        //_container.backgroundColor = [UIColor greenColor];
        //UIImage* img = [UIImage imageNamed:@"featherpage.jpg"];
       
        _rotateContainer = [self createRotateContainer:CGRectMake(0, 0, CurrentScreenWidth,CurrentScreenHeight)];
        _rotateContainer.backgroundColor = VinesGray;
        //_rotateContainer.backgroundColor = [UIColor clearColor];
        
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
        _gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];   //[[EZUIUtility sharedEZUIUtility] createGradientView];
        _gradientView.backgroundColor = RGBA(0, 0, 0, 60);
        _gradientView.userInteractionEnabled = NO;
        [self.container addSubview:_gradientView];
        
        _otherSliverLine = [[UIView alloc] initWithFrame:CGRectMake(10-1, CurrentScreenHeight - 300 - startPos-1, smallIconRadius+2, smallIconRadius+2)];
        _otherSliverLine.layer.borderColor = [UIColor whiteColor].CGColor;
        _otherSliverLine.layer.borderWidth = 1;
        [_otherSliverLine enableRoundImage];
        //[self.container addSubview:_otherSliverLine];
        
        _otherIcon = [[EZEnlargedView alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 305 - startPos, smallIconRadius, smallIconRadius) enlargeRatio:EZEnlargeIconRatio];
        //_otherIcon.backgroundColor = randBack(nil);
        [_otherIcon enableRoundImage];
        [_otherIcon enableTouchEffects];
        [_otherIcon enableShadow:[UIColor blackColor]];
        
        [self.container addSubview:_otherIcon];
        //_otherIcon.layer.borderColor = [UIColor whiteColor].CGColor;
        //_otherIcon.layer.borderWidth = 1.0;
        
        
        _otherName = [[UILabel alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 270 - startPos, 300, 30)];
        [_otherName setTextColor:[UIColor whiteColor]];
        _otherName.font = [UIFont boldSystemFontOfSize:13];
        //[_otherName enableShadow:[UIColor blackColor]];
        [self.container addSubview:_otherName];
        
        _otherTalk = [[UILabel alloc] initWithFrame:CGRectMake(7, CurrentScreenHeight - 245 - startPos, 300, 19)];
        [_otherTalk setTextColor:[UIColor whiteColor]];
        _otherTalk.font = [UIFont systemFontOfSize:13];
        //[_otherTalk enableShadow:[UIColor blackColor]];
        [_otherTalk enableTextWrap];
        _otherTalk.textAlignment = NSTextAlignmentCenter;
        _otherTalk.layer.cornerRadius = 4;
        _otherTalk.clipsToBounds = true;
        [self.container addSubview:_otherTalk];

        _andSymbol = [[UILabel alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 225 - startPos, 20, 20)];
        [_andSymbol setTextColor:[UIColor whiteColor]];
        _andSymbol.font = [UIFont systemFontOfSize:13];
        //[andSymbol enableShadow:[UIColor blackColor]];
        _andSymbol.text = @"&";
        [self.container addSubview:_andSymbol];
        
        _headIcon = [[EZEnlargedView alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 198 - startPos, smallIconRadius, smallIconRadius) enlargeRatio:EZEnlargeIconRatio];
        _homeSliverLine = [[UIView alloc] initWithFrame:CGRectMake(10-1, CurrentScreenHeight - 198 - startPos-1, smallIconRadius+2, smallIconRadius+2)];
        _homeSliverLine.layer.borderColor = [UIColor whiteColor].CGColor;
        _homeSliverLine.layer.borderWidth = 1;
        [_homeSliverLine enableRoundImage];

        //_headIcon.backgroundColor = randBack(nil);
        [_headIcon enableRoundImage];
        [_headIcon enableTouchEffects];
        //[self.container addSubview:_homeSliverLine];
        [self.container addSubview:_headIcon];
        [_headIcon enableShadow:[UIColor blackColor]];
        
        _authorName = [[UILabel alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 163 - startPos, 300, 30)];
        [_authorName setTextColor:[UIColor whiteColor]];
        _authorName.font = [UIFont boldSystemFontOfSize:13];
        [_authorName enableShadow:[UIColor blackColor]];
        [self.container addSubview:_authorName];

        
        _ownTalk = [[UILabel alloc] initWithFrame:CGRectMake(7, CurrentScreenHeight - 138 - startPos, 300, 19)];
        [_ownTalk setTextColor:[UIColor whiteColor]];
        _ownTalk.font = [UIFont systemFontOfSize:13];
        [_ownTalk enableShadow:[UIColor blackColor]];
        _ownTalk.textAlignment = NSTextAlignmentCenter;
        [_ownTalk enableTextWrap];
        _ownTalk.layer.cornerRadius = 4;
        _ownTalk.clipsToBounds = true;
        [self.container addSubview:_ownTalk];
        
        _likeButton =  [[UIButton alloc] initWithFrame:CGRectMake(249, CurrentScreenHeight - 220 - startPos, 80, 80)]; //[[EZClickView alloc] initWithFrame:CGRectMake(255, CurrentScreenHeight - 105, 45,45)]; //[[EZCenterButton alloc] initWithFrame:CGRectMake(255, 23, 60,60) cycleRadius:21 lineWidth:2];
        //_likeButton.backgroundColor = [UIColor redColor];
        _likeButton.backgroundColor = [UIColor clearColor];
        //[_likeButton setImage:EmptyHeartImage forState:UIControlStateNormal];
        //[_likeButton setImage:PressedHeartImage forState:UIControlStateHighlighted];
        [_likeButton setTitle:EZHeartSymbol forState:UIControlStateNormal];
        _likeButton.titleLabel.font = [UIFont boldSystemFontOfSize:40];
        [_likeButton setTitleColor:EZEmptyColor forState:UIControlStateNormal];
        //[_likeButton setTitleColor:ClickedColor forState:UIControlStateHighlighted];
        //[_likeButton enableRoundImage];
        [_likeButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _leftHalf = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 80)];
        UILabel* leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        leftLabel.font = [UIFont boldSystemFontOfSize:40];
        leftLabel.textAlignment = NSTextAlignmentCenter;
        leftLabel.textColor = ClickedColor;
        leftLabel.text = EZHeartSymbol;
        [_leftHalf addSubview:leftLabel];
        _leftHalf.clipsToBounds = YES;
        [_likeButton addSubview:_leftHalf];
        _leftHalf.userInteractionEnabled = NO;
        
        _rightHalf = [[UIView alloc] initWithFrame:CGRectMake(40, 0, 40, 80)];
        UILabel* rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(-40, 0, 80, 80)];
        rightLabel.font = [UIFont boldSystemFontOfSize:40];
        rightLabel.textAlignment = NSTextAlignmentCenter;
        rightLabel.textColor = ClickedColor;
        rightLabel.text = EZHeartSymbol;
        [_rightHalf addSubview:rightLabel];
        _rightHalf.clipsToBounds = YES;
        _rightHalf.userInteractionEnabled = NO;
        [_likeButton addSubview:_rightHalf];
        //_otherLike = [[EZClickView alloc] initWithFrame:CGRectMake(255, CurrentScreenHeight - 105, 45, 45)];
        //_otherLike.layer.borderColor = [UIColor whiteColor].CGColor;
        //_otherLike.layer.borderWidth = 2;
        //[_otherLike enableRoundImage];
        //[self.container addSubview:_otherLike];
        
        //_likeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        //_likeButton.layer.borderWidth = 2;
        //_likeButton.backgroundColor = [UIColor clearColor];
        //_likeButton.enableTouchEffects = FALSE;
        //[self.container addSubview:_likeButton];
        
        _moreButton = [[EZShapeButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _moreButton.center = CGPointMake(CurrentScreenWidth - 30, CurrentScreenHeight - 27);
        
        
        _cameraView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
        _cameraView.center = CGPointMake(CurrentScreenWidth/2.0, CurrentScreenHeight/2.0 + 20);
        _cameraView.backgroundColor = [UIColor clearColor]; //RGBCOLOR(, 128, 0);
        _cameraView.hidden = YES;
        //[_container addSubview:_cameraView];
        
        _requestFixInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 50)];
        _requestFixInfo.font = [UIFont systemFontOfSize:15];
        [_requestFixInfo setTextAlignment:NSTextAlignmentCenter];
        _requestFixInfo.textColor = [UIColor whiteColor];
        _requestFixInfo.center = CGPointMake(_cameraView.bounds.size.width/2.0, _cameraView.bounds.size.height/2.0 + 40);
        [_cameraView addSubview:_requestFixInfo];
        
        _requestInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 50)];
        _requestInfo.font = [UIFont systemFontOfSize:15];
        [_requestInfo setTextAlignment:NSTextAlignmentCenter];
        _requestInfo.textColor = [UIColor whiteColor];
        _requestInfo.center = CGPointMake(_cameraView.bounds.size.width/2.0, _cameraView.bounds.size.height/2.0 + 60);
        [_cameraView addSubview:_requestInfo];
        [_requestInfo enableTextWrap];
        
        _waitingInfo = [EZPhotoCell createWaitingInfo];
        _waitingInfo.hidden = TRUE;
        [_frontImage addSubview:_waitingInfo];
        [_frontImage addSubview:_cameraView];
        _frontImage.layer.zPosition = 2000;
        [self.contentView addSubview:_container];
        //[self.contentView addSubview:_toolRegion];
        //[self.contentView addSubview:_feedbackRegion];
        [_rotateContainer addSubview:_frontImage];
        
        
        _shotPhoto = [[EZUIUtility sharedEZUIUtility] createLargeShotButton];
        
        _shotPhoto.center = CGPointMake(CurrentScreenWidth/2.0, CurrentScreenHeight/2.0 - 20);
        [_container addSubview:_shotPhoto];
        _shotPhoto.enableTouchEffects = true;
        _shotPhoto.hidden = YES;
        _shotPhoto.pressedColor = ClickedColor;
        
        //[self createTimeLabel];
        //[_frontImage addSubview:_toolRegion];
        //[_rotateContainer addSubview:_toolRegion];
        //_container.enableTouchEffects = NO;
        //_chatUnit = [[EZChatUnit alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 200, CurrentScreenWidth, 40)];
        //[_container addSubview:_chatUnit];
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.center = CGPointMake(_frontImage.width/2.0, _frontImage.height/2.0);
        [_frontImage addSubview:_activityView];
        
        //_scrollView = [[EZScrollViewer alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
        //[_frontImage addSubview:_scrollView];
        
        //_firstTimeView = [[EZUIUtility sharedEZUIUtility] createNumberLabel];
        //[_firstTimeView setPosition:CGPointMake(30, 70)];
        //[self.contentView addSubview:_firstTimeView];
        [self.contentView addSubview:_frontImage.pageControl];
        [self.contentView addSubview:_moreButton];
        [self.contentView addSubview:_likeButton];
        //weakCell.activityView = ai;

        
    }
    EZDEBUG(@"PhotoCell init completed");
    return self;
}

+ (UILabel*) createWaitingInfo
{
    UILabel* waitInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    waitInfo.font = [UIFont systemFontOfSize:15];
    [waitInfo setTextAlignment:NSTextAlignmentCenter];
    waitInfo.textColor = [UIColor whiteColor];
    waitInfo.center = CGPointMake(CurrentScreenWidth/2.0, CurrentScreenHeight/2.0);
    waitInfo.text = @"等待朋友的照片";
    return waitInfo;
}

+ (UIView*) createWaitView:(NSString*)name;
{
    UIView* waitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    waitView.backgroundColor = ClickedColor;
    UILabel* waitInfo = [self createWaitingInfo];
    waitInfo.text = [NSString stringWithFormat:macroControlInfo(@"等待%@的照片"), name];
    [waitView addSubview:waitInfo];
    return waitView;
}

- (void) setFrontFormat:(BOOL)front
{
    CGFloat otherAlpha = 0.48;
    CGFloat ownAlpha = 1.0;
    UIColor* otherColor = [UIColor clearColor];
    UIColor* ownColor = ClickedColor;
    ;
    if(!front){
        otherAlpha = 1.0;
        ownAlpha = 0.48;
        otherColor = ClickedColor;
        ownColor = [UIColor clearColor];
        [_ownTalk disableShadow];
        [_authorName disableShadow];
        [_headIcon disableShadow];
        [_otherIcon enableShadow:[UIColor blackColor]];
        [_otherTalk enableShadow:[UIColor blackColor]];
        [_otherName enableShadow:[UIColor blackColor]];
        [_frontImage setFront:NO];
        //_frontImage.pageControl.hidden = NO;
    }else{
        [_otherName disableShadow];
        [_otherTalk disableShadow];
        [_otherIcon disableShadow];
        [_headIcon enableShadow:[UIColor blackColor]];
        [_ownTalk enableShadow:[UIColor blackColor]];
        [_authorName enableShadow:[UIColor blackColor]];
        [_frontImage setFront:YES];
    }
    
    _otherIcon.alpha = otherAlpha;
    _otherName.alpha = otherAlpha;
    _otherTalk.alpha = otherAlpha;

    _ownTalk.alpha = ownAlpha;
    _authorName.alpha = ownAlpha;
    _headIcon.alpha = ownAlpha;
    
    if([_otherTalk.text isNotEmpty]){
        CGSize actualSize = [_otherTalk sizeThatFits:CGSizeMake(200, _otherTalk.height)];
        _otherTalk.width = actualSize.width + 6;
        _otherTalk.backgroundColor = otherColor;
        
    }else{
        _otherTalk.backgroundColor = [UIColor clearColor];
    }
    
    if([_ownTalk.text isNotEmpty]){
        CGSize actualSize = [_ownTalk sizeThatFits:CGSizeMake(200, _ownTalk.height)];
        _ownTalk.width = actualSize.width + 6;
        _ownTalk.backgroundColor = ownColor;
    }else{
        _ownTalk.backgroundColor = [UIColor clearColor];
    }
    //_headIcon.alpha = ownAlpha;
}


- (void) createTimeLabel
{

    _photoDate = [[UILabel alloc] initWithFrame:CGRectMake(150, CurrentScreenHeight - 80, 160, 21)];
    _photoDate.font = [UIFont systemFontOfSize:13];
    _photoDate.textAlignment = NSTextAlignmentRight;
    _photoDate.textColor = [UIColor whiteColor];
    _photoDate.backgroundColor = [UIColor clearColor];
    //[self addSubview:_textDate];
    [_photoDate enableShadow:[UIColor blackColor]];
    _photoDate.layer.cornerRadius = 3.0;
    [_container addSubview:_photoDate];

}

- (UIView*) createRotateContainer:(CGRect)rect
{
    UIView* rotateContainer = [[UIView alloc] initWithFrame:rect];
    rotateContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    rotateContainer.clipsToBounds = true;
    //[rotateContainer enableRoundImage];
    return rotateContainer;
}


- (EZScrollViewer*) createFrontImage
{
    EZScrollViewer* frontImage = [[EZScrollViewer alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    frontImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
    frontImage.imageView.backgroundColor = ClickedColor;
    frontImage.imageView.clipsToBounds = true;
    //frontImage.clipsToBounds = true;
    frontImage.backgroundColor = ClickedColor;
    //[frontImage enableRoundImage];
    return frontImage;
}

- (EZSimpleClick*) createFrontImageOld
{
    EZSimpleClick* frontImage = [[EZSimpleClick alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    frontImage.contentMode = UIViewContentModeScaleAspectFill;
    frontImage.clipsToBounds = true;
    frontImage.backgroundColor = ClickedColor;
    //[frontImage enableRoundImage];
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
           // NSString* localFull = preloadimage(curPhoto.screenURL);
            //[_frontImage setImage:]
            
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
