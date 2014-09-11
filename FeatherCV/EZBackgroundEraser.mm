//
//  EZBackgroundEraser.m
//  3DCamera
//
//  Created by xietian on 14-9-4.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZBackgroundEraser.h"
#import <opencv2/highgui/ios.h>
//#import "EZGrabCut.h"
#import "EZGrabHandler.h"
#import "EZExtender.h"
#import "EZImageConverter.h"
#import "EZDataUtil.h"
#import "EZThreadUtility.h"
#import "DAScratchPadView.h"


#define FrontSelectColor RGBACOLOR(255,64 ,64,128)
#define BackgroundSelectColor RGBACOLOR(64, 64, 255, 128)

@implementation EZBackgroundEraser

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = RGBCOLOR(64, 255, 32);//[UIColor whiteColor];
        _orgImage = image;
        // Initialization code
        //grabCut = new EZGrabCut;
        grabHandler = new EZGrabHandler;
        grabHandler->setImage([EZImageConverter cvMatFromUIImage:image]);
        CGFloat ratio = image.size.height/image.size.width;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, ratio * self.width)];
        [self addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.image = image;
        _selectRegion = [[UIView alloc] initWithFrame:CGRectZero];
        _selectRegion.backgroundColor = FrontSelectColor;//RGBACOLOR(255, 64, 64, 128);
        _selectRegion.hidden = YES;
        _scratchView = [[DAScratchPadView alloc] initWithFrame:_imageView.frame];
        _scratchView.drawColor = BackgroundSelectColor;
        _scratchView.drawWidth = 5;
        _horizonBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 2)];
        _verticalBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, self.height)];
        _horizonBar.hidden = YES;
        _verticalBar.hidden = YES;
        [_imageView addSubview:_scratchView];
        [_imageView addSubview:_horizonBar];
        [_imageView addSubview:_verticalBar];
        [_imageView addSubview:_selectRegion];
       
        
        _confirmSelect = [UIButton createButton:CGRectMake(0, 64, 60, 44) font:[UIFont systemFontOfSize:14] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
        [_confirmSelect setTitle:@"Start" forState:UIControlStateNormal];
        [self addSubview:_confirmSelect];
        [_confirmSelect addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void) confirm
{
    EZDEBUG(@"confirmed clicked");
    [self imageToMask];
    
}

- (void) dealloc{
    if(grabHandler){
        delete grabHandler;
    }
    grabHandler = NULL;
}


- (CGPoint) normalize:(CGPoint)pt size:(CGSize)size
{
    CGPoint res = pt;
    if(res.x < 0){
        res.x = 0;
    }
    
    if(res.y < 0){
        res.y = 0;
    }
    
    if(res.x > size.width){
        res.x = size.width;
    }
    
    if(res.y > size.height){
        res.y = size.height;
    }
    return res;
}

- (CGRect) calcFrame:(CGPoint)begin delta:(CGSize)delta
{
    CGPoint start = begin;
    if(delta.width < 0){
        start.x = delta.width + start.x;
    }
    if(delta.height < 0){
        start.y = delta.height + start.y;
    }
    return CGRectMake(start.x, start.y, abs(delta.width), abs(delta.height));
}

- (cv::Rect) toImageRect:(CGRect)rect size:(CGSize)size imageSize:(CGSize)imageSize
{
    cv::Rect res;
    res.x = rect.origin.x/size.width * imageSize.width;
    res.y = rect.origin.y/size.height * imageSize.height;
    res.width = rect.size.width/size.width * imageSize.width;
    res.height = rect.size.height/size.height * imageSize.height;
    return res;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:_imageView];
    if(pt.x < _imageView.width && pt.y < _imageView.height){
        if(_selectStatus == kSelectRough){
            _effectiveTouch = true;
            _selectRegion.frame = CGRectMake(pt.x, pt.y, 2, 2);
            _selectRegion.hidden = NO;
            _touchBegin = pt;
        }else if(_selectStatus == kSelectPartialFront || _selectStatus == kSelectParticlBack){
            [_scratchView touchesBegan:touches withEvent:event];
            /**
            _horizonBar.y = pt.y;
            _verticalBar.x = pt.x;
            _horizonBar.hidden = false;
            _verticalBar.hidden = false;
            UIColor* color = _selectStatus == kSelectPartialFront?FrontSelectColor:BackgroundSelectColor;
            _horizonBar.backgroundColor = color;
            _verticalBar.backgroundColor = color;
             **/
        }
        
    }else{
        _effectiveTouch = false;
        _selectRegion.hidden = true;
        _horizonBar.hidden = false;
        _verticalBar.hidden = true;
    }
    
}


- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:_imageView];
    if(_effectiveTouch){
        if(_selectStatus == kSelectRough){
            CGPoint np = [self normalize:pt size:_imageView.bounds.size];
            CGSize delta = CGSizeMake(np.x - _touchBegin.x, np.y - _touchBegin.y);
            _selectRegion.frame = [self calcFrame:_touchBegin delta:delta];
        }else if(_selectStatus == kSelectPartialFront || _selectStatus == kSelectParticlBack){
            /**
            CGPoint np = [self normalize:pt size:_imageView.bounds.size];
            _horizonBar.y = np.y;
            _verticalBar.x = np.x;
             **/
            [_scratchView touchesMoved:touches withEvent:event];
        }
    }else{
        EZDEBUG(@"do nothing");
    }
}

- (void) selectRect:(CGPoint)pt
{
    CGPoint np = [self normalize:pt size:_imageView.bounds.size];
    CGSize delta = CGSizeMake(np.x - _touchBegin.x, np.y - _touchBegin.y);
    _selectRegion.frame = [self calcFrame:_touchBegin delta:delta];
    cv::Rect maskRect = [self toImageRect:_selectRegion.frame size:_imageView.frame.size imageSize:_imageView.image.size];
    EZDEBUG(@"ratio Rect %i, %i, %i, %i", maskRect.x, maskRect.y, maskRect.width, maskRect.height);
    
    grabHandler->setMaskRect(maskRect);
    EZDEBUG(@"before call next iteration");
    _selectStatus = kProcessing;
    [[EZThreadUtility getInstance] executeBlockInQueue:
     ^(){
         int itCount = grabHandler->nextIter();
         dispatch_main(^(){
             Mat imageMat;
             grabHandler->showImage(NO, imageMat);
             ///UIImage* converted = [EZImageConverter matToImage:imageMat];
             UIImage* converted =[EZImageConverter matToImageEx:imageMat];
             _imageView.image = converted;
             _selectRegion.hidden = YES;
             _selectStatus = kSelectParticlBack;
             //grabHandler->setImageOnly(imageMat);
             
         });
     } isConcurrent:NO];
    //EZDEBUG(@"before converted");
    
    //EZDEBUG(@"converted is done");
    //EZDEBUG(@"itCount is:%i, converted size:%@", itCount, NSStringFromCGSize(converted.size));
    
    
}

- (CGPoint) toImagePoint:(CGPoint)point size:(CGSize)size imageSize:(CGSize)imageSize
{
    return CGPointMake(point.x/size.width * imageSize.width, point.y/size.height * imageSize.height);
}

- (void) imageToMask
{
    Mat imageMat;
    UIImageToMat([_scratchView getSketch], imageMat);
    Mat maskMat;
    cvtColor(imageMat, maskMat, CV_BGR2GRAY);
    EZDEBUG(@"mask row, col:%i, %i", maskMat.rows, maskMat.cols);
    grabHandler->mergeMask(maskMat);
    
    _selectStatus = kProcessing;
    [[EZThreadUtility getInstance] executeBlockInQueue:
     ^(){
         int itCount = grabHandler->renderByMask();
         EZDEBUG("render point completed %i", itCount);
         dispatch_main(^(){
             Mat imageMat;
             grabHandler->showImage(NO, imageMat);
             UIImage* converted = [EZImageConverter matToImageEx:imageMat];
             _imageView.image = converted;
             //_selectRegion.hidden = YES;
             _verticalBar.hidden = YES;
             _horizonBar.hidden = YES;
             _selectStatus = kSelectParticlBack;
             [_scratchView clearToColor:[UIColor clearColor]];
             //grabHandler->setImageOnly(imageMat);
             //grabHandler->setImage(im)
             //grabHandler->setImage(imageMat);
         });
     } isConcurrent:NO];

    
}

- (void) selectPoint:(CGPoint)point
{
    CGPoint np = [self normalize:point size:_imageView.bounds.size];
    CGPoint imagePt = [self toImagePoint:(CGPoint)np size:_imageView.bounds.size imageSize:_orgImage.size];
    
    grabHandler->setLblsInMask(_selectStatus == kSelectPartialFront, cv::Point(imagePt.x, imagePt.y), YES);
    EZDEBUG(@"before call next iteration");
    _selectStatus = kProcessing;
    [[EZThreadUtility getInstance] executeBlockInQueue:
     ^(){
         int itCount = grabHandler->renderByMask();
         EZDEBUG("render point completed %i", itCount);
         dispatch_main(^(){
             Mat imageMat;
             grabHandler->showImage(NO, imageMat);
             UIImage* converted = [EZImageConverter matToImageEx:imageMat];
             _imageView.image = converted;
             //_selectRegion.hidden = YES;
             _verticalBar.hidden = YES;
             _horizonBar.hidden = YES;
             _selectStatus = kSelectParticlBack;
             //grabHandler->setImageOnly(imageMat);
             //grabHandler->setImage(im)
             //grabHandler->setImage(imageMat);
         });
     } isConcurrent:NO];

    
}

- (void) handleTouchEnd:(NSSet*)touches
{
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:_imageView];
    if(_effectiveTouch){
        if(_selectStatus == kSelectRough){
            [self selectRect:pt];
        }else if(_selectStatus == kSelectParticlBack || _selectStatus == kSelectPartialFront){
            //[self selectPoint:pt];
        }
    }else{
        EZDEBUG(@"do nothing");
    }

}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouchEnd:touches];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouchEnd:touches];
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
