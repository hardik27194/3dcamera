//
//  EZBgEditPage.m
//  3DCamera
//
//  Created by xietian on 14-9-4.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZBgEditPage.h"
#import "EZGrabHandler.h"
#import "EZExtender.h"
#import "EZImageConverter.h"
#import "EZDataUtil.h"
#import "EZThreadUtility.h"

@interface EZBgEditPage ()

@end

@implementation EZBgEditPage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

- (id) initWithImage:(UIImage*)image
{
    self = [super initWithNibName:nil bundle:nil];
    _orgImage = image;
    // Initialization code
    //grabCut = new EZGrabCut;
    grabHandler = new EZGrabHandler;
    grabHandler->setImage([EZImageConverter cvMatFromUIImage:image]);
    CGFloat ratio = _orgImage.size.height/_orgImage.size.width;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, ratio * self.view.width)];
    [self.view addSubview:_imageView];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.image = _orgImage;
    _selectRegion = [[UIView alloc] initWithFrame:CGRectZero];
    _selectRegion.backgroundColor = RGBACOLOR(255, 64, 64, 128);
    _selectRegion.hidden = YES;
    [_imageView addSubview:_selectRegion];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    // Do any additional setup after loading the view.
}

- (void) dealloc{
    if(grabHandler){
        delete grabHandler;
    }
    grabHandler = NULL;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:_imageView];
    if(pt.x < _imageView.width && pt.y < _imageView.height){
        _effectiveTouch = true;
        _selectRegion.frame = CGRectMake(pt.x, pt.y, 4, 4);
        _selectRegion.hidden = NO;
        _touchBegin = pt;
    }else{
        _effectiveTouch = false;
        _selectRegion.hidden = true;
    }
    
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

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:_imageView];
    if(_effectiveTouch){
        CGPoint np = [self normalize:pt size:_imageView.bounds.size];
        CGPoint delta = CGPointMake(np.x - _touchBegin.x, np.y - _touchBegin.y);
        _selectRegion.frame = [self calcFrame:_touchBegin delta:delta];
    }else{
        EZDEBUG(@"do nothing");
    }
}

- (void) handleTouchEnd:(NSSet*)touches
{
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:_imageView];
    if(_effectiveTouch){
        CGPoint np = [self normalize:pt size:_imageView.bounds.size];
        CGPoint delta = CGPointMake(np.x - _touchBegin.x, np.y - _touchBegin.y);
        _selectRegion.frame = [self calcFrame:_touchBegin delta:delta];
        cv::Rect maskRect = [self toImageRect:_selectRegion.frame size:_imageView.frame.size imageSize:_imageView.image.size];
        EZDEBUG(@"ratio Rect %i, %i, %i, %i", maskRect.x, maskRect.y, maskRect.width, maskRect.height);
        grabHandler->setMaskRect(maskRect);
        EZDEBUG(@"before call next iteration");
        [[EZThreadUtility getInstance] executeBlockInQueue:
         ^(){
             int itCount = grabHandler->nextIter();
             dispatch_main(^(){
                 Mat res;
                 grabHandler->showImage(NO, res);
                 UIImage* converted = [EZImageConverter matToImage:res];
                 _imageView.image = converted;
             });
         } isConcurrent:NO];
        //EZDEBUG(@"before converted");
        
        //EZDEBUG(@"converted is done");
        //EZDEBUG(@"itCount is:%i, converted size:%@", itCount, NSStringFromCGSize(converted.size));
        _selectStatus = kSelectRough;
        _selectRegion.hidden = YES;
        
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
