//
//  EZPhotoEditPage.m
//  3DCamera
//
//  Created by xietian on 14-8-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZPhotoEditPage.h"
#import "UIImageView+AFNetworking.h"
#import "EZDataUtil.h"
#import "EZShotTask.h"
#import "EZStoredPhoto.h"
#import "EZMessageCenter.h"
#import "SCCaptureCameraController.h"
#import "RAViewController.h"

@interface EZPhotoEditPage ()

@end

@implementation EZPhotoEditPage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithTask:(EZShotTask*)task pos:(NSInteger)pos
{
    self = [super initWithNibName:nil bundle:nil];
    //_task = task;
    self.title = @"编辑";
    _task = task;
    _photos = task.photos;
    _currentPos = pos;
    return self;
}


- (void) panned:(UIPanGestureRecognizer*)panGesturer
{
    CGPoint tranlation = [panGesturer translationInView:self.view];
    CGPoint velocity = [panGesturer velocityInView:self.view];
   
    
    if(_photos.count < 2){
        return;
    }
    
    CGFloat pixelPerImage = self.imageView.bounds.size.width/2.0/_photos.count;
    int imageMovePos = (tranlation.x - _prevX)/pixelPerImage;
    if(ABS(imageMovePos) > 0){
        _prevX = tranlation.x;
    }else{
        return;
    }
    //imageMovePos = imageMovePos % _photos.count;
    _currentPos += imageMovePos;
    _currentPos = _currentPos % _photos.count;
    if(_currentPos < 0){
        _currentPos = _currentPos + _photos.count;
    }
    
    EZDEBUG(@"translation:%@, velocity:%@, prevX:%f, _currentPos:%i", NSStringFromCGPoint(tranlation), NSStringFromCGPoint(velocity), _prevX, _currentPos);
    //EZDEBUG(@"translation:%@, velocity:%@, imagePos:%i, currentPos:%i", NSStringFromCGPoint(tranlation), NSStringFromCGPoint(velocity), imageMovePos, _currentPos);
    [self loadImage];
    //[self reloadImage];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"button index:%i", buttonIndex);
    if(buttonIndex == 1){
        if(_photos.count>0){
            EZStoredPhoto* storedPhoto = [_photos objectAtIndex:_currentPos];
            [[EZDataUtil getInstance] deleteStoredPhoto:storedPhoto success:^(id obj){
                [_photos removeObject:storedPhoto];
                [[EZMessageCenter getInstance] postEvent:EZShotTaskChanged attached:storedPhoto];
                //[self.navigationController popViewControllerAnimated:YES];
                if(_currentPos > _photos.count - 1){
                    _currentPos = _photos.count - 1;
                }
                [self loadImage];
            } failed:^(id err){
                EZDEBUG(@"error to delete:%@", err);
            }];
            
        }
    }

}
- (void) delete:(id)sender
{
    //url2fullpath()
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"确认删除" message:@"删除照片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    
    [alertView show];
}

- (void) addPhoto:(id)sender
{
    EZStoredPhoto* storedPhoto = [_photos objectAtIndex:_currentPos];
    SCCaptureCameraController* sc = [[SCCaptureCameraController alloc] init];
    sc.shotType = kShotSingle;
    //sc.photo = storedPhoto;
    
    sc.confirmClicked = ^(NSString* localURL){
        EZDEBUG(@"replace confirmed:%@", localURL);
        if(!localURL){
            return;
        }
        EZStoredPhoto* addedPhoto = [[EZStoredPhoto alloc] init];
        addedPhoto.taskID = storedPhoto.taskID;
        
        //[[EZDataUtil getInstance] deleteLocalFile:storedPhoto];
        //storedPhoto.localFileURL = localURL;
        addedPhoto.localFileURL = localURL;
        addedPhoto.createdTime = [NSDate date];
        addedPhoto.sequence = _photos.count;
        
        [[EZDataUtil getInstance] uploadStoredPhoto:storedPhoto success:^(id obj){
            EZDEBUG(@"obj:%@", obj);
            [_photos addObject:addedPhoto];
            [_imageView setImageWithURL:str2url(localURL)];
            [[EZMessageCenter getInstance] postEvent:EZShotTaskChanged attached:addedPhoto];
        } failure:^(id err){
            EZDEBUG(@"error:%@", err);
        }];
        
    };
    
    [self.navigationController pushViewController:sc animated:YES];
}

- (void) replace:(id)sender
{
    EZStoredPhoto* storedPhoto = [_photos objectAtIndex:_currentPos];
    SCCaptureCameraController* sc = [[SCCaptureCameraController alloc] init];
    sc.shotType = kShotSingle;
    sc.photo = storedPhoto;
    
    sc.confirmClicked = ^(NSString* localURL){
        EZDEBUG(@"replace confirmed:%@", localURL);
        if(!localURL){
            return;
        }
        [[EZDataUtil getInstance] deleteLocalFile:storedPhoto];
        storedPhoto.localFileURL = localURL;
        [[EZDataUtil getInstance] uploadStoredPhoto:storedPhoto success:^(id obj){
            EZDEBUG(@"obj:%@", obj);
            [_imageView setImageWithURL:str2url(localURL)];
            [[EZMessageCenter getInstance] postEvent:EZShotTaskChanged attached:storedPhoto];
        } failure:^(id err){
            EZDEBUG(@"error:%@", err);
        }];
        
    };
    
    [self.navigationController pushViewController:sc animated:YES];
}

- (void) sequence:(id)obj
{
    
    RAViewController* editorView = [[RAViewController alloc] initWithTask:_task];
    [self.navigationController pushViewController:editorView animated:YES];
    editorView.confirmClicked = ^(RAViewController* raView){
        EZDEBUG(@"editor confirm get called");
        _task.photos = raView.storedPhotos;
        [[EZDataUtil getInstance] updateTaskSequence:_task success:^(id info){
            EZDEBUG(@"successfully change sequence");
            //[weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            [self loadImage];
        } failure:^(id err){
            EZDEBUG(@"failed to update the sequence");
        }];
    };
 
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewWillLayoutSubviews
{
    //_imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, MIN(self.view.bounds.size.width, self.view.bounds.size.height));
    _toolBar.frame = CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
}

- (void) loadImage
{
    if(_photos.count > 0){
        EZStoredPhoto* sp = [_photos objectAtIndex:_currentPos];
        [_imageView setImageWithURL:str2url(sp.localFileURL?sp.localFileURL:sp.remoteURL)];
        _posText.text = [NSString stringWithFormat:@"第%i张", _currentPos];
    }else{
        _posText.text = @"";
        [_imageView setImage:nil];
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    _touchBegin = [touch locationInView:_imageView];
    _prevX = _touchBegin.x;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint curPoint = [touch locationInView:_imageView];
    if(_photos.count < 2){
        return;
    }
    
    CGFloat pixelPerImage = self.imageView.bounds.size.width/2.0/_photos.count;
    int imageMovePos = (curPoint.x - _prevX)/pixelPerImage;
    EZDEBUG(@"imageMovePos:%i", imageMovePos);
    if(ABS(imageMovePos) > 0){
        _prevX = curPoint.x;
    }else{
        return;
    }
    //imageMovePos = imageMovePos % _photos.count;
    _currentPos += imageMovePos;
    //_currentPos = _currentPos % _photos.count;
    EZDEBUG(@"currPos:%i", _currentPos);
    if(_currentPos < 0){
        _currentPos = _currentPos + _photos.count;
    }
    _currentPos = _currentPos % _photos.count;
    
    EZDEBUG(@"point:%@, prevX:%f, _currentPos:%i", NSStringFromCGPoint(curPoint), _prevX, _currentPos);
    //EZDEBUG(@"translation:%@, velocity:%@, imagePos:%i, currentPos:%i", NSStringFromCGPoint(tranlation), NSStringFromCGPoint(velocity), imageMovePos, _currentPos);
    [self loadImage];

}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    EZDEBUG(@"touch cancelled");
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    EZDEBUG(@"touch ended");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, MIN(CurrentScreenWidth, CurrentScreenHeight))];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.userInteractionEnabled = YES;
     //UIPanGestureRecognizer* panGesturer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    //[_imageView addGestureRecognizer:panGesturer];
    //panGesturer.delegate = self;
    [self loadImage];
    
    _posText = [UILabel createLabel:CGRectMake(20, 0, CurrentScreenWidth - 2*20, 20) font:[UIFont boldSystemFontOfSize:18] color:[UIColor whiteColor]];
    _posText.textAlignment = NSTextAlignmentCenter;
    
    
    _toolBar = [[UIView alloc] initWithFrame:CGRectZero];
    _toolBar.userInteractionEnabled = true;
    _toolBar.backgroundColor = [UIColor clearColor];
    
    
    _replaceBtn = [UIButton createButton:CGRectMake(0, 0, CurrentScreenWidth/4.0, 44) font:[UIFont boldSystemFontOfSize:18] color:RGBCOLOR(70, 70, 70) align:NSTextAlignmentCenter];
    [_replaceBtn setTitle:@"更换" forState:UIControlStateNormal];
    [_replaceBtn addTarget:self action:@selector(replace:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _deleteBtn = [UIButton createButton:CGRectMake(CurrentScreenWidth/4.0, 0, CurrentScreenWidth/4.0, 44) font:[UIFont boldSystemFontOfSize:18] color:RGBCOLOR(70, 70, 70) align:NSTextAlignmentCenter];
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _adjustSequence = [UIButton createButton:CGRectMake(2 * CurrentScreenWidth/4.0, 0, CurrentScreenWidth/4.0, 44)  font:[UIFont boldSystemFontOfSize:18] color:RGBCOLOR(70, 70, 70) align:NSTextAlignmentCenter];
    [_adjustSequence setTitle:@"调整顺序" forState:UIControlStateNormal];
    [_adjustSequence addTarget:self action:@selector(sequence:) forControlEvents:UIControlEventTouchUpInside];
    
    _addButton = [UIButton createButton:CGRectMake(3 * CurrentScreenWidth/4.0, 0, CurrentScreenWidth/4.0, 44)  font:[UIFont boldSystemFontOfSize:18] color:RGBCOLOR(70, 70, 70) align:NSTextAlignmentCenter];
    [_addButton setTitle:@"增加" forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];

    
    
    [_toolBar addSubview:_replaceBtn];
    [_toolBar addSubview:_deleteBtn];
    [_toolBar addSubview:_adjustSequence];
    [_toolBar addSubview:_addButton];
    [self.view addSubview:_imageView];
    [self.view addSubview:_posText];
    [self.view addSubview:_toolBar];
    
    [[EZMessageCenter getInstance] registerEvent:EZShotTaskChanged block:^(id obj){
        EZDEBUG(@"shot photo changed");
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhoto:)];
    // Do any additional setup after loading the view.
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
