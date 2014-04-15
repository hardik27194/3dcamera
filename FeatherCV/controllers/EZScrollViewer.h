//
//  EZScrollViewer.h
//  FeatherCV
//
//  Created by xietian on 14-4-13.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZScrollViewer : UIView<UIScrollViewDelegate>

@property (nonatomic,strong) NSArray* photos;

@property (nonatomic, strong) UIScrollView* scrollView;

@property (nonatomic, strong) UIPageControl* pageControl;

@property (nonatomic, strong) EZEventBlock tappedBlock;

@property (nonatomic, strong) EZEventBlock longPressed;

@property (nonatomic, strong) UIImageView* imageView;

@property (nonatomic, strong) UIImage* image;

@property (nonatomic, strong) NSMutableArray* imageViews;

@property (nonatomic, strong) EZEventBlock scrollBlock;

@property (nonatomic, assign) BOOL isFront;

//@property (nonatomic, assign) BOOL isSingle;

@property (nonatomic, assign) NSInteger currentPos;

- (void) setCurrentPos:(NSInteger)pos;

- (void) setImage:(UIImage*)image;

//- (void) setImage:(UIImage *)image pos:(int)position;

- (void) setImageWithURL:(NSURL*)url;

- (void) setPhotos:(NSArray*)photos position:(int)pos;

- (void) cleanAllPhotos;

- (void) setFront:(BOOL)front;


@end
