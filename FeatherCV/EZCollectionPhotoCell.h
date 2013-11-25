/*
     File: APLCollectionViewCell.h
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

//@import UIKit;
#import <UIKit/UIKit.h>
#import "EZAppConstants.h"
#import "EZStyleImage.h"

typedef enum {
    kLeftUp = 1,
    kLeftBottom = 2,
    kRightUp = 4,
    kRightBottom = 8,
    kHiddenAll = 0
} EZCornerType;

@class EZClickImage;
@class EZClickView;
@interface EZCollectionPhotoCell : UICollectionViewCell

//When asynchonizly load resource, this could be used to confirm that we need to load again.
@property (nonatomic, assign) int currentID;

@property (nonatomic, strong) EZStyleImage* frontImage;

@property (nonatomic, strong) EZStyleImage* backImage;

//The purpose of the container is to limit the scope of the flip animation.
//Otherwise the whole thing rotate together, this is not what I expected.
@property (nonatomic, strong) EZClickView* container;

@property (nonatomic, strong) EZClickImage* headIcon;

@property (nonatomic, strong) UILabel* lastestWord;
//Once the user clicked, this view will get clicked
//@property (nonatomic, strong) EZClickView* imageClick;

@property (nonatomic, strong) EZClickImage* likeButton;

//You can talk as you like.
@property (nonatomic, strong) EZClickImage* shareButton;

@property (nonatomic, strong) EZEventBlock clicked;

@property (nonatomic, strong) UIImageView* leftUp;

@property (nonatomic, strong) UIImageView* leftBottom;

@property (nonatomic, strong) UIImageView* rightUp;

@property (nonatomic, strong) UIImageView* rightBottom;

@property (nonatomic, strong) UIView* dateContainer;

@property (nonatomic, strong) UILabel* dayLabel;

@property (nonatomic, strong) UILabel* monthLabel;

- (void) showCorner:(EZCornerType)type;

//Name of the current image
@property (nonatomic, strong) UILabel* name;

//Used to record the status of the photo cell, so when I turn I knew which one is on the front.
@property (nonatomic, assign) BOOL isFrontImage;

//The flipped status will be with the EZCombinedPhotot object itself, then the flipped will
//Decouple the logic. I love this game.
@property (nonatomic, strong) EZEventBlock flippedCompleted;

@property (nonatomic, strong) EZEventBlock talkClicked;

- (void) displayPhoto:(NSString*)photo;

- (void) displayPhotoImage:(UIImage *)photo;
//I am happy that define a good interface to handle the image switch action
- (void) switchImageTo:(NSString*)url;

- (void) showDate:(NSDate*)date;

@end
