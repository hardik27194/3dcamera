//
//  EZImageAdder.m
//  BabyCare
//
//  Created by xietian on 14-10-9.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZImageAdder.h"

@implementation EZImageAdder

- (id) initWithFrame:(CGRect)frame padding:(CGSize)padding markSize:(CGSize)markSize limit:(CGSize)limit controller:(UIViewController *)controller
{
    
    self = [super initWithFrame:frame];
    _uploadImages = [[NSMutableArray alloc] init];
    _imageBtns = [[NSMutableArray alloc] init];
    _padding = padding;
    _markSize = markSize;
    _limit = limit;
    
    if(_padding.width == -1){
        CGFloat gap = frame.size.width - markSize.width * limit.width;
        _padding.width = gap/(limit.width + 1);
    }
    
    _addImageMark = [[UIButton alloc] initWithFrame:CGRectMake(_padding.width, 0, _markSize.width, _markSize.height)];
    [_addImageMark addTarget:self action:@selector(addImage:) forControlEvents:UIControlEventTouchUpInside];
    _addImageMark.layer.borderColor = RGBCOLOR(103, 103, 103).CGColor;
    _addImageMark.layer.borderWidth = 1;
    UIView* horizon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 2)];
    horizon.layer.cornerRadius = 1;
    horizon.backgroundColor = RGBCOLOR(203, 203, 203);
    UIView* vertical = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 20)];
    vertical.layer.cornerRadius = 1;
    vertical.backgroundColor = RGBCOLOR(203, 203, 203);
    horizon.center = CGPointMake(_markSize.width/2.0, _markSize.height/2.0);
    vertical.center = CGPointMake(_markSize.width/2.0, _markSize.height/2.0);
    [_addImageMark addSubview:horizon];
    [_addImageMark addSubview:vertical];
    [self addSubview:_addImageMark];
    
    _controller = controller;
    //[self. addSubview:_textView];
    //[self.view addSubview:_imageRegion];
    
    return self;
}


- (void) addImage:(id)obj
{
    EZDEBUG(@"Add image clicked");
    //[_textView resignFirstResponder];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"相册", nil];
    [actionSheet showInView:TopView];
}

- (void) removePhoto:(UIButton*)obj
{
    NSInteger removePos = [_imageBtns indexOfObject:obj];
    EZDEBUG(@"Will remove:%i", removePos);
    [_imageBtns removeObjectAtIndex:removePos];
    [_uploadImages removeObjectAtIndex:removePos];
    [UIView animateWithDuration:0.3 animations:^(){
        obj.alpha = 0;
        [self readjustImages];
    } completion:^(BOOL completed){
        [obj removeFromSuperview];
    }];
}

- (void) readjustImages
{
    for(int i = 0; i < _imageBtns.count; i ++){
        UIButton* imgButton = [_imageBtns objectAtIndex:i];
        [imgButton setPosition:CGPointMake(_padding.width + (_markSize.width + _padding.width) * (i % (int)_limit.width), (_markSize.height + _padding.height) * (i/(int)_limit.width))];
        EZDEBUG(@"readjust image:%@", NSStringFromCGRect(imgButton.frame));
    }
    [self adjustMark:nil];
}

- (void) addSelectedImage:(UIImage*)img
{
    [_uploadImages addObject:img];
    
    UIButton* imgView = [[UIButton alloc] initWithFrame:_addImageMark.frame];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    //imgView.image = img;
    [imgView setImage:img forState:UIControlStateNormal];
    [imgView addTarget:self action:@selector(removePhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:imgView];
    [_imageBtns addObject:imgView];
    [self adjustMark:imgView];
}

- (void) adjustMark:(UIView*)imgView
{
    imgView.alpha = 0;
    CGFloat nextPos = _padding.width + (_markSize.width + _padding.width) * (_uploadImages.count % (int)_limit.width);
    CGFloat nextY = (_markSize.height + _padding.height) * (_uploadImages.count / (int)_limit.width);
    [UIView animateWithDuration:0.3 animations:^(){
        imgView.alpha = 1.0;
        [_addImageMark setPosition:CGPointMake(nextPos, nextY)];
    }];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex < 2){
        [[EZUIUtility sharedEZUIUtility] raiseCamera:buttonIndex controller:_controller completed:^(UIImage* image){
            [self addSelectedImage:image];
        } allowEditing:NO];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
