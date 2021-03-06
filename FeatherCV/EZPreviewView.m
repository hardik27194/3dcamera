//
//  EZPreviewView.m
//  3DCamera
//
//  Created by xietian on 14-8-11.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZPreviewView.h"
#import "UIImageView+AFNetworking.h"
#import "EZStoredPhoto.h"

@implementation EZPreviewView

- (id) initWithFrame:(CGRect)frame images:(NSArray*)images
{
    self = [super initWithFrame:frame];
    if(self){
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        if(images){
            _images = [[NSMutableArray alloc] initWithArray:images];
            EZStoredPhoto* storePhoto = [images objectAtIndex:_currentPos];
            _currentPos = 0;
            [_imageView setImageWithURL:str2url(storePhoto.remoteURL)];
            
        }else{
            _images = [[NSMutableArray alloc] init];
        }
               [self addSubview:_imageView];
        UIPanGestureRecognizer* panGesturer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        UITapGestureRecognizer* tapGesturer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:panGesturer];
        [self addGestureRecognizer:tapGesturer];
    }
    return self;
}

- (void) tapped:(UITapGestureRecognizer*) tapGes{
    EZDEBUG(@"Tapped get called");
    [self dismiss];
}
//增加，删除，替换，分享
- (UIView*) createToolBar
{
    UIView* toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, CurrentScreenHeight - 44, CurrentScreenWidth, 44)];
    toolbar.backgroundColor = [UIColor clearColor];
    UIButton* addPhoto = [UIButton createButton:CGRectMake(0, 0, CurrentScreenWidth/4, 44) font:[UIFont systemFontOfSize:16] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
    [addPhoto setTitle:@"添加" forState:UIControlStateNormal];
    [toolbar addSubview:addPhoto];
    
    UIButton* delButton = [UIButton createButton:CGRectMake(addPhoto.right, 0, CurrentScreenWidth/4, 44) font:[UIFont systemFontOfSize:16] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
    [addPhoto setTitle:@"删除" forState:UIControlStateNormal];
    [toolbar addSubview:delButton];
    
    UIButton* changeSequence = [UIButton createButton:CGRectMake(delButton.right, 0, CurrentScreenWidth/4, 44) font:[UIFont systemFontOfSize:16] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
    [changeSequence setTitle:@"改顺序" forState:UIControlStateNormal];
    [toolbar addSubview:changeSequence];
    
    UIButton* replace = [UIButton createButton:CGRectMake(changeSequence.right, 0, CurrentScreenWidth/4, 44) font:[UIFont systemFontOfSize:16] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
    [replace setTitle:@"更换" forState:UIControlStateNormal];
    [toolbar addSubview:replace];
    return toolbar;
}

+ (void) showPreview:(NSArray*)images inCtrl:(UIViewController*)controller complete:(EZEventBlock)complete edit:(EZEventBlock)edit
{
    UIView* view = controller.view;
    EZPreviewView* preView = [[EZPreviewView alloc] initWithFrame:view.bounds images:images];
    UIView* overLay = [[UIView alloc] initWithFrame:view.bounds];
    overLay.backgroundColor = RGBACOLOR(0, 0, 0, 0.8);
    [view addSubview:overLay];
    preView.overLay = overLay;
    EZDEBUG(@"The view rect:%@, overlay bound:%@", NSStringFromCGRect(view.bounds), NSStringFromCGRect(overLay.frame));
    //CGRect initRect = CGRectMake(view.bounds.size.width/2.0 - 1 , view.bounds.size.height/2.0 - 1, 2, 2);
    preView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [view addSubview:preView];
    [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:1.4 initialSpringVelocity:1.4 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
        preView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL completed){
    }];
    
}

- (void) dismiss
{
    [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:1.4 initialSpringVelocity:1.4 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL completed){
        [self removeFromSuperview];
        [_overLay removeFromSuperview];
        if(self.completeBlock){
            self.completeBlock(self);
        }
    }];
}

- (void) panned:(UIPanGestureRecognizer*)panGesturer
{
    CGPoint tranlation = [panGesturer translationInView:self];
    CGPoint velocity = [panGesturer velocityInView:self];
    EZDEBUG(@"translation:%@, velocity:%@", NSStringFromCGPoint(tranlation), NSStringFromCGPoint(velocity));
    
    if(_images.count < 2){
        return;
    }
    
    CGFloat pixelPerImage = self.bounds.size.width/2.0/_images.count;
    int imageMovePos = tranlation.x/pixelPerImage;
    imageMovePos = imageMovePos % _images.count;
    if(imageMovePos < 0){
        imageMovePos = imageMovePos + _images.count;
    }
    if(imageMovePos == _currentPos){
        return;
    }

    EZDEBUG(@"translation:%@, velocity:%@, imagePos:%i, currentPos:%i", NSStringFromCGPoint(tranlation), NSStringFromCGPoint(velocity), imageMovePos, _currentPos);
    _currentPos = imageMovePos;
    [self reloadImage];
}

- (void) reloadImage
{
    EZStoredPhoto* photo = [_images objectAtIndex:_currentPos];
    [_imageView setImageWithURL:str2url(photo.remoteURL)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame images:nil];
    return self;
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
