//
//  EZScrollerView.m
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZScrollerView.h"
#import "EZSeperator.h"

@implementation EZScrollerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_scrollView];
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceVertical = false;
        _scrollView.showsHorizontalScrollIndicator = false;
        [self addSubview:_scrollView];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 10, CurrentScreenWidth, 10)];
        [self addSubview:_pageControl];
        
        _seperator = [[EZSeperator alloc] initWithFrame:CGRectMake(0, frame.size.height - 5, CurrentScreenWidth, 1)];
        [self addSubview:_seperator];
        _seperator.color = RGBA(255, 255, 255, 80);
        _seperator.gap = 50;
        _scrollView.delegate = self;
    }
    return self;
}



- (void) setHidePageControl:(BOOL)hidePageControl
{
    _pageControl.hidden = hidePageControl;
    _hidePageControl = hidePageControl;
    if(hidePageControl){
        [_seperator setY:self.frame.size.height - 1];
        [_seperator setGap:0];
    }else{
        [_seperator setGap:50];
        [_seperator setY:self.frame.size.height - 5];
    }
    
}

- (void) setCurrentPos:(NSInteger)pos
{
    _currentPos = pos;
    _pageControl.currentPage = pos;
    _scrollView.contentOffset = CGPointMake(pos * CurrentScreenWidth, 0);
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    int pos = scrollView.contentOffset.x / CurrentScreenWidth;
    _pageControl.currentPage = pos;
    
    EZDEBUG(@"srollViewEndDecelerating called, %i,prev:%i", pos, _currentPos);
    if(_currentPos == pos){
        return;
    }
    if(_scrolledTo){
        _scrolledTo(@{@"prev":@(_currentPos), @"curr":@(pos)});
    }
    _currentPos = pos;
}

- (void) setViews:(NSMutableArray *)views
{
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = views.count;
    _currentPos = 0;
    _views = views;
    _scrollView.contentSize = CGSizeMake(_views.count * CurrentScreenWidth, _scrollView.bounds.size.height);
    _scrollView.contentOffset = CGPointMake(0, 0);
    for(int i = 0; i < _views.count; i ++){
        UIView* view = [_views objectAtIndex:i];
        [view setX:CurrentScreenWidth * i];
        [_scrollView addSubview:view];
    }
    
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
