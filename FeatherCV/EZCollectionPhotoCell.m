/*
     File: APLCollectionViewCell.m
 Abstract: 
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import "EZCollectionPhotoCell.h"
#import "AFNetworking.h"
#import "EZClickImage.h"
#import "EZClickView.h"
#import "EZExtender.h"
#import "EZStyleImage.h"

@implementation EZCollectionPhotoCell

/**
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.borderWidth = 1.0;
        self.imageView.clipsToBounds = TRUE;
        self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.imageView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
        [[self contentView] addSubview:self.imageView];
    }
    return self;
}
**/

- (void) tapped:(UITapGestureRecognizer*)recog
{
    EZDEBUG(@"talk get clicked");
    if(_talkClicked){
        _talkClicked(nil);
    }
}

- (void) showCorner:(EZCornerType)type
{
    EZDEBUG(@"cornerType:%i", type);
    _leftUp.hidden = !(type & kLeftUp);
    _rightUp.hidden = !(type & kRightUp);
    _leftBottom.hidden = !(type & kLeftBottom);
    _rightBottom.hidden = !(type & kRightBottom);
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if(frame.size.width > 120){
        // Initialization code
            _container = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
            //_frontImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
            _frontImage = [EZStyleImage createFilteredImage:CGRectMake(0, 0, 320, 320)];
            _frontImage.contentMode = UIViewContentModeScaleAspectFill;
            //_frontImage.layer.cornerRadius = 5;
            _frontImage.clipsToBounds = true;
            _backImage = [EZStyleImage createFilteredImage:CGRectMake(0, 0, 320, 320)];
            _backImage.contentMode = UIViewContentModeScaleAspectFill;
            //_backImage.layer.cornerRadius = 5;
            _backImage.clipsToBounds = true;
            //_imageClick = [[EZClickView alloc] initWithFrame:CGRectMake(5, 5, 310, 310)];
        
            //_name = [[UILabel alloc] initWithFrame:CGRectMake(5, 320 + 10, 120, 20)];
            _likeButton = [[EZClickImage alloc] initWithImage:[UIImage imageNamed:@"not_love"]];
            _likeButton.enableTouchEffects = true;
            float toolPadding = 46;
            float textPadding = 6;
            [_likeButton setPosition:CGPointMake(141, 320+toolPadding)];
        
            _shareButton = [[EZClickImage alloc] initWithImage:[UIImage imageNamed:@"share_btn"]];
            
            [_shareButton setPosition:CGPointMake(191, 320+toolPadding)];
            
            _headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(91, 320+toolPadding+6, 35, 35)];
            //[_headIcon setPosition:CGPointMake(5, 320+2)];
            _headIcon.enableTouchEffects = true;
            [_headIcon enableRoundImage];
            
            _lastestWord = [[UILabel alloc] initWithFrame:CGRectMake(0, 320+textPadding, 320, 40)];
            _lastestWord.textAlignment = NSTextAlignmentCenter;
            _lastestWord.font = [UIFont systemFontOfSize:16];
            _lastestWord.userInteractionEnabled = true;
            _lastestWord.textColor = RGBCOLOR(127, 127, 127);
            UITapGestureRecognizer* tapTalk = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
            [_lastestWord addGestureRecognizer:tapTalk];
            //_imageClick.backgroundColor = [UIColor clearColor];
            //[self addSubview:_frontImage];
            //[self.contentView addSubview:_backImage];
            [self.contentView addSubview:_container];
            [_container addSubview:_frontImage];
            //[self.contentView addSubview:_imageClick];
            [self.contentView addSubview:_likeButton];
            //_shareButton.backgroundColor = [UIColor greenColor];
            [self.contentView addSubview:_shareButton];
            [self.contentView addSubview:_lastestWord];
            [self.contentView addSubview:_headIcon];
            [self.contentView addSubview:_lastestWord];
            //UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, 320, 1)];
            //sep.backgroundColor = RGBCOLOR(220, 220, 224);
            //[self.contentView addSubview:sep];
            //[self.contentView addSubview:_name];
        }        
    }
    return self;
}


//What's the purpose of this method?
//Is to display an image on the cell, right?
//Cool, I will be clicked and display again.
//Let's just keep it simple and stupid.
//Make sure front image is always on the front.
- (void) displayPhoto:(NSString*)url
{
    //[self addSubview:_frontImage];
    _dateContainer.hidden = true;
    //[_frontImage setImageWithURL:str2url(url) placeholderImage:PlaceHolderLargest];
}

- (void) displayPhotoImage:(UIImage *)photo
{
    _dateContainer.hidden = true;
    //[_frontImage setImageWithURL:str2url(url) placeholderImage:PlaceHolderLargest];
    [_frontImage setImage:photo];
}

- (void) showDate:(NSDate *)date
{
    _dateContainer.hidden = false;
    _dayLabel.text = [NSString stringWithFormat:@"%i", [date monthDay]];
    _monthLabel.text = [NSString stringWithFormat:@"%i月", [date getMonth]];
}
//I am happy that define a good interface to handle the image switch action
- (void) switchImageTo:(NSString*)url
{
    __weak EZCollectionPhotoCell* weakSelf = self;
    //[_backImage setImageWithURL:str2url(url) placeholderImage:PlaceHolderLargest];
    [UIView flipTransition:_frontImage dest:_backImage container:self.contentView isLeft:YES duration:1.0 complete:^(id obj){
        //UIImageView* tmp = _frontImage;
        //_frontImage = _backImage;
        //_backImage = tmp;
        if(weakSelf.flippedCompleted){
            weakSelf.flippedCompleted(nil);
        }
    }];
    //make the front image always there to recieve the image url.
    //I love this game, right?
    UIImageView* tmp =(UIImageView*) _frontImage;
    _frontImage = _backImage;
    _backImage = (EZStyleImage*)tmp;
    
}



@end
