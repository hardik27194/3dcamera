//
//  PagingScrollViewController.h
//  PagingScrollView
//
//  Created by Matt Gallagher on 24/01/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#import "EZAppConstants.h"
#import "DLCImagePickerController.h"
//@class PageViewController;

@interface EZScrollContainer : UIViewController<UIScrollViewDelegate, DLCImagePickerDelegate>
{
	//IBOutlet UIScrollView *scrollView;
	//IBOutlet UIPageControl *pageControl;
	
	//PageViewController *currentPage;
	//PageViewController *nextPage;
}

@property (nonatomic, strong) NSMutableArray* children;
@property (nonatomic, strong) UIScrollView* scrollView;

@property (nonatomic, strong) UIImagePickerController* picker;

@property (nonatomic, strong) DLCImagePickerController* dlcPicker;
//I will adde the camera into this container
@property (nonatomic, strong) UIView* cameraContainer;


//This mean which index are displayed in the middle
@property (nonatomic, assign) NSInteger currentIndex;

//Use to differentiate the front.
@property (nonatomic, assign) BOOL usingBackCamera;

- (void) addChildren:(NSArray *)children;

- (void) setIndex:(int)idx animated:(BOOL)animated slide:(BOOL)slide;

@end
