//
//  EZScrollViewer.m
//  FeatherCV
//
//  Created by xietian on 14-4-13.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZScrollViewer.h"
#import "UIImageView+AFNetworking.h"

@interface EZScrollViewer ()

@end

@implementation EZScrollViewer

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.maximumZoomScale = 1.0;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.zoomScale = 1.0;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _imageViews = [[NSMutableArray alloc] init];
    
    
    CGFloat startPos = -100;
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(10, CurrentScreenHeight - 220 - startPos, 24, 10)];
    //_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    //[_scrollView addSubview:_imageView];
    // Initialization code
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    self.userInteractionEnabled = TRUE;
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:longPress];
    [self addSubview:_scrollView];
    [self addSubview:_pageControl];
    return self;
}

- (void) longPress:(id)obj
{
    if(_longPressed){
        _longPressed(obj);
    }
}

- (void) tap:(id)obj
{
    if(_tappedBlock){
        _tappedBlock(obj);
    }
}


- (void) setCurrentPos:(NSInteger)pos
{
    _currentPos = pos;
    _pageControl.currentPage = pos;
    _scrollView.contentOffset = CGPointMake(pos * CurrentScreenWidth, 0);
}

- (void) setImage:(UIImage*)image
{
    _imageView.image = image;
    _image = image;
}


- (void) setImageWithURL:(NSURL*)url
{
    //[_imageView setImageWithURL:url];
}

- (UIImageView*) createImageView:(CGRect)frame
{
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.backgroundColor = ClickedColor;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    return imgView;
}

- (void) setPhotos:(NSArray*)photos position:(int)pos
{
    EZDEBUG(@"begin set photos");
    _currentPos = pos;
    NSInteger count = 1;
    if(photos.count){
        count = photos.count;
    }
    _pageControl.currentPage = pos;
    _pageControl.numberOfPages = photos.count;
    int addCount = photos.count - 2;
    if(addCount > 0){
        _pageControl.width = 24 + 16 * addCount;
    }else{
        _pageControl.width = 24;
    }
    _photos = photos;
    for(UIImageView* imgView in _imageViews){
        [imgView removeFromSuperview];
    }
    
    [_imageViews removeAllObjects];
    _scrollView.contentSize = CGSizeMake(CurrentScreenWidth*count, CurrentScreenHeight);
    _scrollView.contentOffset = CGPointMake(CurrentScreenWidth * pos, 0);
    for(int i = 0; i < count; i++){
        UIImageView* imgView = [self createImageView:CGRectMake(CurrentScreenWidth * i, 0, CurrentScreenWidth, CurrentScreenHeight)];
        [_scrollView addSubview:imgView];
        [_imageViews addObject:imgView];
    }
    _imageView = [_imageViews objectAtIndex:pos];
    EZDEBUG(@"end set photoss");
}

//Will clean all of them.
- (void) cleanAllPhotos
{
    _scrollView.contentSize = CGSizeMake(CurrentScreenWidth, CurrentScreenHeight);
    _scrollView.contentOffset = CGPointMake(0, 0);
    for(UIImageView* imgView in _imageViews){
        [imgView removeFromSuperview];
    }
    _imageView = nil;
    //if(!_imageView)
    //_imageView = [self createImageView:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    //else
    //_imageView.image = nil;
    //[_scrollView addSubview:_imageView];
    //_imageViews = @[_scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger pos = _scrollView.contentOffset.x / CurrentScreenWidth;
    EZDEBUG(@"Current Position:%i", pos);
    _currentPos = pos;
    _pageControl.currentPage = pos;
    _imageView = [_imageViews objectAtIndex:pos];
    if(_scrollBlock){
        _scrollBlock(@(pos));
    }
}

- (void) setFront:(BOOL)front
{
    _isFront = front;
    if(front){
        _scrollView.contentOffset = CGPointMake(0, 0);
        _scrollView.contentSize = CGSizeMake(CurrentScreenWidth, CurrentScreenHeight);
        _imageView = [_imageViews objectAtIndex:0];
        //_pageControl.hidden = YES;
    }else{
        _scrollView.contentSize = CGSizeMake(CurrentScreenWidth * (_photos.count?_photos.count:1), CurrentScreenHeight);
        _scrollView.contentOffset = CGPointMake(CurrentScreenWidth * _currentPos, 0);
        _imageView = [_imageViews objectAtIndex:_currentPos];
        //_pageControl.hidden = NO;
    }
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