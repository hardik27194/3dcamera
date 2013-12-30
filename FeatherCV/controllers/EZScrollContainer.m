//
//  PagingScrollViewController.m
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
#import <AssetsLibrary/AssetsLibrary.h>
#import "EZScrollContainer.h"
#import "EZClickView.h"
#import "EZUIUtility.h"
#import "EZDataUtil.h"
#import "EZDisplayPhoto.h"
#import "EZPhoto.h"
#import "EZFileUtil.h"
#import "EZMessageCenter.h"

//#import "PageViewController.h"
//#import "DataSource.h"

@implementation EZScrollContainer


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _children = [[NSMutableArray alloc] init];
    return self;
}
//
- (void)applyNewIndex:(NSInteger)newIndex pageController:(UIViewController *)pageController
{
	NSInteger pageCount = _children.count;
	BOOL outOfBounds = newIndex >= pageCount || newIndex < 0;

	if (!outOfBounds)
	{
		CGRect pageFrame = pageController.view.frame;
		pageFrame.origin.y = 0;
		pageFrame.origin.x = _scrollView.frame.size.width * newIndex;
		pageController.view.frame = pageFrame;
	}
	else
	{
		CGRect pageFrame = pageController.view.frame;
		pageFrame.origin.y = _scrollView.frame.size.height;
		pageController.view.frame = pageFrame;
	}

	//pageController.pageIndex = newIndex;
}

- (void) loadView
{
    CGRect bound = [[UIScreen mainScreen] bounds];
    _scrollView = [[UIScrollView alloc] initWithFrame:bound];
    _scrollView.backgroundColor = [UIColor grayColor];
    self.view = _scrollView;
    _cameraContainer = [[UIView alloc] initWithFrame:CGRectMake(bound.size.width*2, 0, bound.size.width, bound.size.height)];
    [_scrollView addSubview:_cameraContainer];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    
}

- (void) setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width*currentIndex, 0);
}

- (void) addChildren:(NSArray *)children
{
    [_children addObjectsFromArray:children];
    [self alignViews];
}

//This will be called when something happened like the rotation.
- (void) setIndex:(int)idx animated:(BOOL)animated slide:(BOOL)slide
{
    _currentIndex = idx;
    [self createController:idx slide:slide];
    CGRect bound = [UIScreen mainScreen].bounds;
    bound.origin.x = idx * bound.size.width;
    EZDEBUG(@"before scroll contentOffset:%f", _scrollView.contentOffset.x);
    [_scrollView scrollRectToVisible:bound animated:animated];
    EZDEBUG(@"after scroll contentOffset:%f", _scrollView.contentOffset.x);
}


- (void) alignViews
{
    int pos = 0;
     CGRect bound = [[UIScreen mainScreen] bounds];
    for(UIViewController* ctrl in _children){
        CGRect frame = bound;
        frame.origin = CGPointMake(frame.size.width*pos, 0);
        ctrl.view.frame = frame;
        [self.view addSubview:ctrl.view];
        /**
        EZClickView* click = [[EZClickView alloc] initWithFrame:CGRectMake(40, 40, 100, 100)];
        click.backgroundColor = [UIColor whiteColor];
        click.releasedBlock = ^(id sender){
            EZDEBUG(@"Release block get called");
            [self setIndex:2 animated:YES];
        };
        [ctrl.view addSubview:click];
         **/
        pos++;
    }
    _scrollView.contentSize = CGSizeMake(bound.size.width*_children.count, bound.size.height);
}

- (void)orientationChanged:(NSNotification *)notification
{
    EZDEBUG(@"Orientation changed:%i, currentIndex is:%i", [UIDevice currentDevice].orientation, _currentIndex);
    //[self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    if(([UIDevice currentDevice].orientation ==  UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)){
        if(_currentIndex != 2){
            //EZDEBUG(@"")
            _usingBackCamera = true;
            [self setIndex:2 animated:TRUE slide:FALSE];
            
        }
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
	//currentPage = [[PageViewController alloc] initWithNibName:@"PageView" bundle:nil];
	//nextPage = [[PageViewController alloc] initWithNibName:@"PageView" bundle:nil];
	//[scrollView addSubview:currentPage.view];
	//[scrollView addSubview:nextPage.view];
    [self setNeedsStatusBarAppearanceUpdate];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:[UIDevice currentDevice]];
    EZDEBUG(@"Current childSize:%i", _children.count);
    _scrollView.contentSize =
		CGSizeMake(
			_scrollView.frame.size.width * _children.count,
			_scrollView.frame.size.height);
	_scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);
    [self removeUnusedView];
	//pageControl.numberOfPages = [[DataSource sharedDataSource] numDataPages];
	//pageControl.currentPage = 0;

}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    float fractionalPage = _scrollView.contentOffset.x / pageWidth;
	
	NSInteger lowerNumber = floor(fractionalPage);
	NSInteger upperNumber = lowerNumber + 1;
	
	EZDEBUG(@"fractionalPage:%f,small number, big number:%i, %i", fractionalPage, lowerNumber, upperNumber);
    [self createController:lowerNumber slide:YES];
    [self createController:upperNumber slide:YES];
}

- (void) scrollEnded
{
    EZDEBUG(@"scrollEnded get called, using backCamera:%i", _usingBackCamera);
    if(_currentIndex == 0){
        [[EZMessageCenter getInstance] postEvent:EZScreenSlide attached:@(0)];
    }
    if(_currentIndex != 2){
        //[_picker viewDidDisappear:YES];
        [_dlcPicker becomeInvisible];
    }else{
        //I will show the from.
        if(_usingBackCamera){
            [_dlcPicker becomeVisible:FALSE];
            _usingBackCamera = false;
        }else{
            [_dlcPicker becomeVisible:TRUE];
        }
    }

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)newScrollView
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    float fractionalPage = _scrollView.contentOffset.x / pageWidth;
	
	NSInteger lowerNumber = floor(fractionalPage);
	//NSInteger upperNumber = lowerNumber + 1;
    
    NSLog(@"endScrollAnimation, currentPage:%i, updatedPage:%i", _currentIndex, lowerNumber);
    _currentIndex = lowerNumber;
    [self scrollEnded];
    //[self removeUnusedView];
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)newScrollView
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    float fractionalPage = _scrollView.contentOffset.x / pageWidth;
	
	NSInteger lowerNumber = floor(fractionalPage);
	//NSInteger upperNumber = lowerNumber + 1;
    
    NSLog(@"endDecelerating, currentPage:%i, updatedPage:%i", _currentIndex, lowerNumber);
    _currentIndex = lowerNumber;
    [self scrollEnded];
    //[self removeUnusedView];
}


//I will put this image to another place.
- (void)takePicture:(DLCImagePickerController*)picker imageInfo:(NSDictionary*)info
{

}


- (void)imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    EZDEBUG(@"Store image get called");
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    UIImage* img = [info objectForKey:@"image"];
    NSDictionary* orgdata = [info objectForKey:@"metadata"];
    NSMutableDictionary* metadata =[[NSMutableDictionary alloc] init];
    if(metadata){
        [metadata setDictionary:orgdata];
    }
    EZDEBUG(@"Recived metadata:%@, actual orientation:%i", metadata, img.imageOrientation);
    [metadata setValue:@(img.imageOrientation) forKey:@"Orientation"];
    [library writeImageToSavedPhotosAlbum:img.CGImage metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error2)
     {
         //             report_memory(@"After writing to library");
         if (error2) {
             EZDEBUG(@"ERROR: the image failed to be written");
         }
         else {
             EZDEBUG(@"Stored image to album assetURL: %@", assetURL);
             [[EZDataUtil getInstance] assetURLToAsset:assetURL success:^(ALAsset* result){
                 EZDEBUG(@"Transfer the image to EZDisplayPhoto successfully");
                 EZDisplayPhoto* ed = [[EZDisplayPhoto alloc] init];
                 ed.isFront = true;
                 EZPhoto* ep = [[EZPhoto alloc] init];
                 ed.pid = ++[EZDataUtil getInstance].photoCount;
                 ep.asset = result;
                 ep.isLocal = true;
                 ed.photo = ep;
                 ed.photo.owner = [[EZPerson alloc] init];
                 ed.photo.owner.name = @"天哥";
                 ed.photo.owner.avatar = [EZFileUtil fileToURL:@"tian_2.jpeg"].absoluteString;
                 //EZDEBUG(@"Before size");
                 ep.size = [result defaultRepresentation].dimensions;
                 [[EZMessageCenter getInstance]postEvent:EZTakePicture attached:ed];
                 EZDEBUG(@"after size:%f, %f", ep.size.width, ep.size.height);
             }];
         }
     }];
    
}

- (void)imagePickerControllerDidCancel:(DLCImagePickerController *)picker
{
    
}

//I will use the new ImagePicker to complete my job
- (UIViewController*) createController:(int)pos slide:(BOOL)slide
{
    EZDEBUG(@"Create Controller:%i", pos);
    if(pos != 2){
        return nil;
    }
    //return nil;
    if(_dlcPicker){
        return _dlcPicker;
    }
    
    _dlcPicker = [[DLCImagePickerController alloc] init];
    _dlcPicker.delegate = self;
    CGRect bound = [UIScreen mainScreen].bounds;
    _dlcPicker.view.frame = bound;
    [_cameraContainer addSubview:_dlcPicker.view];
    UIViewController* uc = [_children objectAtIndex:2];
    uc.view.alpha = 1;
    //CGRect frame = self.view.frame;
    //frame.origin.x = self.view.frame.size.width * pos;
    //_picker.view.alpha = 0.5;
    return _dlcPicker;
    
}

//When will this get called?
//Mean If I found here I will not get it from the array
- (UIViewController*) createControllerOldPicker:(int)pos slide:(BOOL)slide
{
    EZDEBUG(@"Create Controller:%i", pos);
    if(pos != 2){
        return nil;
    }
    if(_picker){
        return _picker;
    }
    
    
    _picker = [[EZUIUtility sharedEZUIUtility] getCamera:NO slide:slide completed:^(UIImage* img){
        EZDEBUG(@"images ready");
    }];
    EZDEBUG(@"Will try to initialize the image picker, alpha:%f", _picker.view.alpha);
    
    UIViewController* uc = [_children objectAtIndex:2];
    uc.view.alpha = 1;
    //CGRect frame = self.view.frame;
    //frame.origin.x = self.view.frame.size.width * pos;
    CGRect bound = [UIScreen mainScreen].bounds;
    _picker.view.frame = bound;
    [_cameraContainer addSubview:_picker.view];
    //_picker.view.alpha = 0.5;
    return _picker;
}

- (void) removeUnusedView
{
    EZDEBUG(@"remove unused:%li", (long)_currentIndex);

    if(_currentIndex != 2){
        EZDEBUG(@"remove picker");
        if(_picker){
            [_picker.view removeFromSuperview];
            _picker = nil;
        }
    }else{
        
    }
}



@end
