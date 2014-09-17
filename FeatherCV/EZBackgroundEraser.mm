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
#import "EZCanvas.h"
#import "EZRectObject.h"
#import "EZRoundObject.h"
#import "EZPathObject.h"
#import "EZPoint.h"

#define FrontSelectColor RGBACOLOR(255,64 ,64,128)
#define BackgroundSelectColor RGBACOLOR(64, 64, 255, 128)

#define ExtensionColor RGBACOLOR(255, 255, 255, 200)

@interface  EZBackgroundEraser(){
    UIButton* undoBtn;
    UIButton* redoBtn;
}
@end

@implementation EZBackgroundEraser

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = RGBCOLOR(255, 255, 255);//RGBCOLOR(70, 70, 70);//[UIColor whiteColor];
        _strokeSize = 5;
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
        //_selectRegion = [[UIView alloc] initWithFrame:CGRectZero];
        //_selectRegion.backgroundColor = FrontSelectColor;//RGBACOLOR(255, 64, 64, 128);
        //_selectRegion.hidden = YES;
       
        _horizonBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 2)];
        _verticalBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, self.height)];
        _horizonBar.hidden = YES;
        _verticalBar.hidden = YES;
        //[_imageView addSubview:_scratchView];
        [_imageView addSubview:_horizonBar];
        [_imageView addSubview:_verticalBar];
        //[_imageView addSubview:_selectRegion];
       
        _canvas = [[EZCanvas alloc] initWithFrame:_imageView.frame];
        [self addSubview:_canvas];
        
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.height - 44, self.width, 44)];
        
        [self addSubview:_toolBar];
        UIBarButtonItem* toggleType = [[UIBarButtonItem alloc] initWithTitle:@"智能背景" style:UIBarButtonItemStylePlain target:self action:@selector(toggleMask)];
        UIBarButtonItem* toggleShape = [[UIBarButtonItem alloc] initWithTitle:@"方型" style:UIBarButtonItemStylePlain target:self action:@selector(toggleShape)];
        
        UIBarButtonItem* strokeSize = [[UIBarButtonItem alloc] initWithTitle:@"笔画宽度" style:UIBarButtonItemStylePlain target:self action:@selector(changeStrokeSize)];
        
        UIBarButtonItem* confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"开始处理" style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
        _items = @[toggleType, toggleShape, strokeSize, confirmBtn];
        _toolBar.items = _items;
        
        undoBtn = [UIButton createButton:CGRectMake(0, self.height - 100, 100, 44) title:NSLocalizedString(@"撤销", @"") font:[UIFont boldSystemFontOfSize:17] color:ClickedColor align:NSTextAlignmentLeft];
        
        [self addSubview:undoBtn];
        [undoBtn addTarget:self action:@selector(undo) forControlEvents:UIControlEventTouchUpInside];
        
        redoBtn = [UIButton createButton:CGRectMake(self.width - 100, self.height - 100, 100, 44) title:NSLocalizedString(@"恢复", @"") font:[UIFont boldSystemFontOfSize:17] color:ClickedColor align:NSTextAlignmentLeft];
        [self addSubview:redoBtn];
        [redoBtn addTarget:self action:@selector(redo) forControlEvents:UIControlEventTouchUpInside];
        
        //_currentMaskMode = kManualForeground;
        [self setCurrentMaskMode:kManualForeground];
        
        EZRectObject* background = [EZRectObject createRect:_imageView.bounds isStroke:NO color:[self maskModeToColor:kManualBackground] borderWidth:0];
        [_canvas insertShape:background pos:0];
        [_canvas setNeedsDisplay];
        
    }
    return self;
}

- (void) undo
{
    [_canvas undo];
}

- (void) redo
{
    [_canvas redo];
}

- (void) toggleShape
{
    _shapeType = (EZMaskShapeType)(1 + (int)_shapeType);
    if(_shapeType > kStrokeShape){
        _shapeType = kSquareShape;
    }
    UIBarButtonItem* item = [_toolBar.items objectAtIndex:1];
    if(_shapeType == kSquareShape){
        [item setTitle:@"方形"];
    }else if(_shapeType == kRoundShape){
        [item setTitle:@"圆形"];
    }else if(_shapeType == kPolygon){
        [item setTitle:@"多变形"];
    }
    else if(_shapeType == kStrokeShape){
        [item setTitle:@"画线"];
    }
}

- (void) setSlideValue:(UISlider*)slide
{
    slide.value = (_strokeSize - 1) / 29.0;
}

#define StrokeSlideTag 9998
#define StrokeWidthTag 9999


- (void) setStrokeValueFromSlider:(UISlider*)slide
{
    _strokeSize = 1 + slide.value * 29;
    //UISlider* slider = (UISlider*)[[self viewWithTag:StrokeSlideTag] viewWithTag:StrokeWidthTag];
    //slider.height = _strokeSize;
    _strokeWidthDemo.height = _strokeSize;
    _strokeWidthDemo.center = CGPointMake(_strokeWidthDemo.superview.width/2.0, _strokeWidthDemo.superview.height/2.0);
    UIColor* slideColor = [UIColor blackColor]; //[self maskModeToColor:_currentMaskMode];
    _strokeWidthDemo.backgroundColor = slideColor;
}


- (UIColor*) maskModeToColor:(EZMaskMode)mode
{
    if(mode == kSmartBackground){
        return BackProbableColor;
    }else if(mode == kManualBackground){
        return BackSureColor;
    }else if(mode == kSmartForeground){
        return FrontProbableColor;
    }
    //else if(mode == kManualForeground){
    return FrontSureColor;
    //}
}

- (void) changeStrokeSize
{
    UIView* tapView = [[UIView alloc] initWithFrame:self.bounds];
    tapView.tag = StrokeSlideTag;
    
    UIView* sliderBack = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 88, self.width,44)];
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 0, self.width - 40, 44)];
    [sliderBack addSubview:_slider];
    UIView* strokeWidthView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 132, self.width, 44)];
    strokeWidthView.backgroundColor = RGBACOLOR(255, 255, 255, 200);
    sliderBack.backgroundColor = RGBACOLOR(255, 255, 255, 200);
    _strokeWidthDemo = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.width - 40, _strokeSize)];
    //strokeWidthView.center = CGPointMake((self.width - strokeWidthView.width)/2.0, self.height - 118);
    strokeWidthView.tag = StrokeWidthTag;
    _strokeWidthDemo.center = CGPointMake(strokeWidthView.width/2.0, 44/2.0);
    _strokeWidthDemo.backgroundColor = [self maskModeToColor:_currentMaskMode];
    [strokeWidthView addSubview:_strokeWidthDemo];
    
    tapView.backgroundColor = [UIColor clearColor];
    [tapView addSubview:sliderBack];
    [self setSlideValue:_slider];
    [tapView addSubview:strokeWidthView];
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapView addGestureRecognizer:tapGesture];
    [self addSubview:tapView];
    [_slider addTarget:self action:@selector(slideChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void) slideChanged:(UISlider*)slider
{
    [self setStrokeValueFromSlider:slider];
}

- (void) tapped:(id)obj
{
    EZDEBUG(@"Tapped object:%@", obj);
    [UIView animateWithDuration:0.3 animations:^(){
        [self viewWithTag:StrokeSlideTag].alpha = 0;
    } completion:^(BOOL completed){
        [[self viewWithTag:StrokeSlideTag] removeFromSuperview];
    }];
    
}

- (void) toggleMask
{
    _currentMaskMode =(EZMaskMode)(1 +(int)_currentMaskMode);
    if(_currentMaskMode > kManualForeground){
        _currentMaskMode = kSmartBackground;
    }
    [self setCurrentMaskMode:_currentMaskMode];
}

- (void) setCurrentMaskMode:(EZMaskMode)currentMaskMode
{
    _currentMaskMode = currentMaskMode;
    UIColor* maskColor = [self maskModeToColor:currentMaskMode];
    UIBarButtonItem* item = [_toolBar.items objectAtIndex:0];
    if(_currentMaskMode == kSmartBackground){
        [item setTitle:@"智能背景"];
        [item setTintColor:maskColor];
    }else if(_currentMaskMode == kManualBackground){
        [item setTitle:@"手动背景"];
        [item setTintColor:maskColor];
    }else if(_currentMaskMode == kSmartForeground){
        [item setTitle:@"智能前景"];
        [item setTintColor:maskColor];
    }else if(_currentMaskMode == kManualForeground){
        [item setTitle:@"手动前景"];
        [item setTintColor:maskColor];
    }

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

- (CGRect) calcFrame:(CGPoint)begin delta:(CGPoint)delta
{
    CGPoint start = begin;
    if(delta.x < 0){
        start.x = delta.x + start.x;
    }
    if(delta.y < 0){
        start.y = delta.y + start.y;
    }
    return CGRectMake(start.x, start.y, abs(delta.x), abs(delta.y));
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


- (void) setDragMode:(EZDrawable*)drawable
{
    _selectStatus = kDragAndDrop;
    [_canvas removeShape:_drawable];
    _drawable = drawable;
    _drawable.selected = true;
    [_canvas setNeedsDisplay];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:_imageView];
    UIColor* maskColor = [self maskModeToColor:_currentMaskMode];
    if(pt.x < _imageView.width && pt.y < _imageView.height){
        dispatch_later(0.5, ^(){
            EZDEBUG(@"_pressed:%i, _notMoved:%i", _pressed, _notMoved);
            if(_pressed && _notMoved){
                EZDrawable* drawable = [_canvas getShapeAtPoint:_lastTouch];
                if(drawable){
                    [self setDragMode:drawable];
                }
            }
        });
        
        if(_selectStatus == kSelectRough || _selectStatus == kDragAndDrop){
            _selectStatus = kSelectRough;
            _effectiveTouch = true;
            _notMoved = true;
            _pressed = true;
            _lastTouch = pt;
            if(_shapeType == kRoundShape){
                //[_selectRegion enableRoundEdge];
                _drawable = [EZRoundObject createRound:CGRectMake(pt.x, pt.y, 2, 2) isStroke:NO color:maskColor borderWidth:2];
                
            }else if(_shapeType == kSquareShape){
                //_selectRegion.layer.cornerRadius = 0;
                _drawable = [EZRectObject createRect:CGRectMake(pt.x, pt.y, 2, 2) isStroke:NO color:maskColor borderWidth:2];
            }else{
                
                _drawable = [EZPathObject createPath:maskColor width:_strokeSize isFill:_shapeType == kPolygon];
                //_scratchView.drawColor = maskColor;
                //_scratchView.drawWidth = _strokeSize;
            }
            [_canvas addShapeObject:_drawable];
            [_canvas setNeedsDisplay];
            _touchBegin = pt;
        }else if(_selectStatus == kSelectPartialFront || _selectStatus == kSelectParticlBack){
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
        //_selectRegion.hidden = true;
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
            CGPoint delta = CGPointMake(np.x - _touchBegin.x, np.y - _touchBegin.y);
            
            if(abs(delta.x) > 4 || abs(delta.y) > 4){
                _notMoved = false;
            }
            if(_shapeType == kRoundShape || _shapeType == kSquareShape){
                //_selectRegion.layer.cornerRadius = 0;
                [(id)_drawable setFrame:[self calcFrame:_touchBegin delta:delta]];
            }else{
                EZPathObject* pathObj = (EZPathObject*)_drawable;
                [pathObj addPoint:pt];
                //[(EZPathObject*)_drawable addPoint:pt];
            }
            _lastTouch = np;
            [_canvas setNeedsDisplay];
            
        }else if(_selectStatus == kDragAndDrop){
            CGPoint np = [self normalize:pt size:_imageView.bounds.size];
            CGPoint delta = CGPointMake(np.x - _touchBegin.x, np.y - _touchBegin.y);
            _drawable.shift = delta;
            [_canvas setNeedsDisplay];
        }
        else if(_selectStatus == kSelectPartialFront || _selectStatus == kSelectParticlBack){
            /**
            CGPoint np = [self normalize:pt size:_imageView.bounds.size];
            _horizonBar.y = np.y;
            _verticalBar.x = np.x;
             **/
            //[_scratchView touchesMoved:touches withEvent:event];
        }
    }else{
        EZDEBUG(@"do nothing");
    }
}

- (void) handleTouchEnd:(NSSet*)touches
{
    _pressed = false;
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:_imageView];
    if(_effectiveTouch){
        if(_selectStatus == kSelectRough){
            //[self selectRect:pt];
            if(_currentMaskMode == kManualForeground &&  _canvas.shapes.count == 1){
               
            }
        }else if(_selectStatus == kDragAndDrop){
            _drawable.selected = false;
            [_drawable mergeShift];
            [_canvas setNeedsDisplay];
        }else if(_selectStatus == kSelectParticlBack || _selectStatus == kSelectPartialFront){
            //[self selectPoint:pt];
        }
    }else{
        EZDEBUG(@"do nothing");
    }
    
}


- (void) selectRect:(CGPoint)pt
{
    CGPoint np = [self normalize:pt size:_imageView.bounds.size];
    CGSize delta = CGSizeMake(np.x - _touchBegin.x, np.y - _touchBegin.y);
    //_selectRegion.frame = [self calcFrame:_touchBegin delta:delta];
    //cv::Rect maskRect = [self toImageRect:_selectRegion.frame size:_imageView.frame.size imageSize:_imageView.image.size];
    //EZDEBUG(@"ratio Rect %i, %i, %i, %i", maskRect.x, maskRect.y, maskRect.width, maskRect.height);
    
    
    //grabHandler->setMaskRect(maskRect);
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
             //_selectRegion.hidden = YES;
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
    //UIImageToMat([_scratchView getSketch], imageMat);
    Mat maskMat;

    UIImage* canvasImage = [_canvas contentAsImage];
    [EZImageConverter imageMaskToMat:maskMat image:canvasImage];
    //grabHandler->
    
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
             //[_scratchView clearToColor:[UIColor clearColor]];
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

- (void) setStartProcessing:(EZEventBlock)completed
{
    EZDEBUG(@"Start processing");
}

//I guess the last position already updated, I love this game. 

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
