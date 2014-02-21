//
//  EZScrollController.m
//  FeatherCV
//
//  Created by xietian on 14-2-21.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZScrollController.h"

@interface EZScrollController ()

@end

@implementation EZScrollController


- (void) loadView
{
    UIScrollView* scrollView = [[UIScrollView alloc] init];
    scrollView.maximumZoomScale = 4.0;
    scrollView.minimumZoomScale = 0.5;
    scrollView.delegate = self;
    scrollView.zoomScale = 1.0;
    self.view = scrollView;
}

- (id) initWithDetail:(UIImageView *)detail
{
    self = [super init];
    [self.view addSubview:detail];
    UIScrollView* scrollView = (UIScrollView*)self.view;
    scrollView.contentSize = CGSizeMake(detail.bounds.size.width, detail.bounds.size.height);
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView = scrollView;
    _detail = detail;
    return self;
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _detail;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) tapped:(id)sender
{
    EZDEBUG(@"Tapped");
    if(_tappedBlock){
        _tappedBlock(self);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer* recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:recog];
	// Do any additional setup after loading the view.
}

- (void)layoutScrollView
{
    if (!_detail.image) return;
    UIImage* image = _detail.image;
    
    CGFloat heightScale = _scrollView.frame.size.height / image.size.height;
    CGFloat widthScale = _scrollView.frame.size.width / image.size.width;
    CGFloat scale = MIN(widthScale, heightScale);
    self.scrollView.minimumZoomScale = scale;
    self.scrollView.maximumZoomScale = MAX(1.0f ,scale * 2.0f);
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
    [self centerImage];
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    [self centerImage];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerImage];
}

- (void)centerImage
{
    if (!self.detail.image) return;
    UIImage* image = _detail.image;
    CGFloat imageScaleWidth = image.size.width * _scrollView.zoomScale;
    CGFloat imageScaleHeight = image.size.height * _scrollView.zoomScale;
    
    CGFloat hOffset = (_scrollView.frame.size.width - imageScaleWidth) * 0.5f;
    CGFloat vOffset = (_scrollView.frame.size.height - imageScaleHeight) * 0.5f;
    
    if (hOffset < 0) hOffset = 0;
    if (vOffset < 0) vOffset = 0;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(vOffset, hOffset, 0, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
