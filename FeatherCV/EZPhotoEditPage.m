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
#import "EZCaptureCameraController.h"
#import "RAViewController.h"
#import "EZInfoDotView.h"
#import "EZPhotoInfo.h"
#import "EZPopupInput.h"
#import "EZInputItem.h"
#import "EZBackgroundEraser.h"
#import "LocalTasks.h"

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

- (id) initWithShot:(NSArray*)photos pos:(NSInteger)pos deletedBlock:(EZEventBlock)deletedBlock
{
    self = [super initWithNibName:nil bundle:nil];
    //_task = task;
    self.title = @"编辑";
    //_task = task;
    _photos = [[NSMutableArray alloc] initWithArray:photos];
    _currentPos = pos;
    _showShot = YES;
    _deletedClicked = deletedBlock;
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

- (void) deleteConfirmed:(id)sender
{
    EZDEBUG(@"delete confirm get called:%@", _task.taskID);
    if([_task.taskID isNotEmpty]){
    [[EZDataUtil getInstance] deletePhotoTask:_task.taskID success:^(id obj){
        [_task deleteLocal];
        [[EZMessageCenter getInstance] postEvent:@"EZDeletePhotoTask" attached:_task];
        [self.navigationController popViewControllerAnimated:YES];
    } failed:^(id err){
        EZDEBUG(@"failed to delete");
    }];
    }else{
        [_task deleteLocal];
        [[EZMessageCenter getInstance] postEvent:@"EZDeletePhotoTask" attached:_task];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"button index:%i", buttonIndex);
    if(alertView == _deleteAlert){
        if(buttonIndex == 1){
            [self deleteConfirmed:nil];
        }
        return;
    }
    
    if(buttonIndex == 1){
        if(_photos.count>0){
            EZStoredPhoto* storedPhoto = [_photos objectAtIndex:_currentPos];
            int deletePos = _currentPos;
            if(_showShot){
                [_photos removeObject:storedPhoto];
                if(_currentPos > _photos.count - 1){
                    _currentPos = _photos.count - 1;
                }
                [self loadImage];
                if(_deletedClicked){
                    _deletedClicked(@(deletePos));
                }
            }else{
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
    EZCaptureCameraController* sc = [[EZCaptureCameraController alloc] init];
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
    EZCaptureCameraController* sc = [[EZCaptureCameraController alloc] init];
    sc.shotType = kShotSingle;
    sc.photo = storedPhoto;
    
    sc.confirmClicked = ^(NSString* localURL){
        EZDEBUG(@"replace confirmed:%@", localURL);
        if(!localURL){
            return;
        }
        [[EZDataUtil getInstance] deleteLocalFile:storedPhoto];
        storedPhoto.localFileURL = localURL;
        
        if([storedPhoto.photoID isNotEmpty]){
        [[EZDataUtil getInstance] uploadStoredPhoto:storedPhoto success:^(id obj){
            EZDEBUG(@"obj:%@", obj);
            [_imageView setImageWithURL:str2url(localURL)];
            [[EZMessageCenter getInstance] postEvent:EZShotTaskChanged attached:storedPhoto];
        } failure:^(id err){
            EZDEBUG(@"error:%@", err);
        }];
        }else{
            [_imageView setImageWithURL:str2url(localURL)];
        }
        
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
    
    __weak EZPhotoEditPage* weakSelf = self;
    for (UIView* infoView in _dotViews) {
        [infoView removeFromSuperview];
    }
    [_dotViews removeAllObjects];
    if(_photos.count > 0){
        EZStoredPhoto* sp = [_photos objectAtIndex:_currentPos];
        [_imageView setImageWithURL:str2url(sp.localFileURL?sp.localFileURL:sp.remoteURL)];
        _posText.text = [NSString stringWithFormat:@"第%i张", _currentPos + 1];
        
        NSArray* photoInfos = sp.infos;
        for(EZPhotoInfo* info in photoInfos){
            EZInfoDotView* dotView = [EZInfoDotView create:CGPointMake(info.x/100 * _imageView.width, info.y/100 * _imageView.height)];
            dotView.clicked = ^(id obj){
                [weakSelf raiseDailog:info];
            };
            dotView.moveCompleted = ^(EZInfoDotView* idotView){
                EZDEBUG(@"moved to :%@", NSStringFromCGPoint(idotView.finalPosition));
                info.x = idotView.finalPosition.x;
                info.y = idotView.finalPosition.y;
                [[EZDataUtil getInstance] updatePhotoInfo:info success:^(id obj){
                    EZDEBUG(@"update success");
                } failed:nil];
            };
            [self.imageView addSubview:dotView];
            [_dotViews addObject:dotView];
        }
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
    _dotViews = [[NSMutableArray alloc] init];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, MIN(CurrentScreenWidth, CurrentScreenHeight))];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.userInteractionEnabled = YES;
     //UIPanGestureRecognizer* panGesturer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    //[_imageView addGestureRecognizer:panGesturer];
    //panGesturer.delegate = self;
    
    
    UIView* grayView = [[UIView alloc] initWithFrame:_imageView.frame];
    grayView.backgroundColor = RGBACOLOR(0, 0, 0, 90);
    grayView.userInteractionEnabled = false;
    
    _posText = [UILabel createLabel:CGRectMake(20, 0, CurrentScreenWidth - 2*20, 20) font:[UIFont boldSystemFontOfSize:18] color:[UIColor whiteColor]];
    _posText.textAlignment = NSTextAlignmentCenter;
    
    
    _toolBar = [[UIView alloc] initWithFrame:CGRectZero];
    _toolBar.userInteractionEnabled = true;
    _toolBar.backgroundColor = [UIColor clearColor];
    
    
    _replaceBtn = [UIButton createButton:CGRectMake(0, 0, CurrentScreenWidth/3.0, 44) font:[UIFont boldSystemFontOfSize:18] color:RGBCOLOR(70, 70, 70) align:NSTextAlignmentCenter];
    [_replaceBtn setTitle:@"更换" forState:UIControlStateNormal];
    [_replaceBtn addTarget:self action:@selector(replace:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _deleteBtn = [UIButton createButton:CGRectMake(CurrentScreenWidth/4.0, 0, CurrentScreenWidth/3.0, 44) font:[UIFont boldSystemFontOfSize:18] color:RGBCOLOR(70, 70, 70) align:NSTextAlignmentCenter];
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _adjustSequence = [UIButton createButton:CGRectMake( CurrentScreenWidth/3.0, 0, CurrentScreenWidth/3.0, 44)  font:[UIFont boldSystemFontOfSize:18] color:RGBCOLOR(70, 70, 70) align:NSTextAlignmentCenter];
    [_adjustSequence setTitle:@"调整顺序" forState:UIControlStateNormal];
    [_adjustSequence addTarget:self action:@selector(sequence:) forControlEvents:UIControlEventTouchUpInside];
    
    _addButton = [UIButton createButton:CGRectMake(2 * CurrentScreenWidth/3.0, 0, CurrentScreenWidth/3.0, 44)  font:[UIFont boldSystemFontOfSize:18] color:RGBCOLOR(70, 70, 70) align:NSTextAlignmentCenter];
    [_addButton setTitle:@"增加" forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];

    
    if(_showShot){
        _deleteBtn.frame = CGRectMake(0, 0, CurrentScreenWidth/2.0, 44);
        [_toolBar addSubview:_deleteBtn];
        
        _replaceBtn.frame = CGRectMake(CurrentScreenWidth/2.0, 0, CurrentScreenWidth/2.0, 44);
        [_toolBar addSubview:_replaceBtn];
    }else{
        [_toolBar addSubview:_replaceBtn];
        //[_toolBar addSubview:_deleteBtn];
        [_toolBar addSubview:_adjustSequence];
        [_toolBar addSubview:_addButton];
    }
    [self.view addSubview:_imageView];
    [self.view addSubview:grayView];
    [self.view addSubview:_posText];
    [self.view addSubview:_toolBar];
    
    [[EZMessageCenter getInstance] registerEvent:EZShotTaskChanged block:^(id obj){
        EZDEBUG(@"shot photo changed");
    }];
    [self loadImage];
    
    UIButton* btn = [UIButton createButton:CGRectMake(0, 0, 200, 44) font:[UIFont boldSystemFontOfSize:17] color:ClickedColor align:NSTextAlignmentCenter];
    [btn setTitle:@"修改名称" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(raiseTitleChange) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = btn;
    _titleButton = btn;
    if([_task.name isNotEmpty]){
        [_titleButton setTitle:_task.name forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteTask)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"去背景" style:UIBarButtonItemStylePlain target:self action:@selector(eraseBg:)];
    // Do any additional setup after loading the view.
}

- (void) deleteTask
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"删除%@", ([_task.name isNotEmpty]?_task.name:@"未命名")] message:[NSString  stringWithFormat:@"共有%i张照片，确认删除吗？", _task.photos.count] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertView show];
    _deleteAlert = alertView;
}



- (void) raiseTitleChange
{
    EZDEBUG(@"click get called");
    EZInputItem* item1 = [[EZInputItem alloc] initWithName:@"名称" type:kStringValue defaultValue:_task.name?_task.name:@""];
    
    EZPopupInput* input = [[EZPopupInput alloc] initWithTitle:@"图片名称" inputItems:@[item1] haveDelete:NO saveBlock:^(EZPopupInput* popInput){
        //info.title = item1.changedValue;
        //info.comment = item2.changedValue;
        _task.name = item1.changedValue;
        [_titleButton setTitle:item1.changedValue forState:UIControlStateNormal];
        [[EZDataUtil getInstance] updateTask:_task success:^(id obj){
            EZDEBUG(@"update name success");
            //[[EZMessageCenter getInstance] postEvent:EZPhotoUploadSuccess attached:]
            [[EZMessageCenter getInstance] postEvent:EZShotTaskChanged attached:nil];
        } failure:^(id err){
            EZDEBUG(@"failed to update name %@", err);
        }];
    } deleteBlock:nil];
    
    [input showInView:self.view animated:YES];
    
    
}

- (void) eraseBg:(id)obj
{
    EZBackgroundEraser* backEraser = [[EZBackgroundEraser alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenWidth) image:_imageView.image];
    [self.view addSubview:backEraser];
    EZDEBUG(@"Background eraser started");
}

- (void) addInfoPoint:(id)obj
{
    
    CGRect imageRegion = self.imageView.frame;//[self.view convertRect:self.imageView.frame fromView:self.view];
    UIView* topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 20, CurrentScreenWidth, 44)];
    topBar.backgroundColor = RGBCOLOR(200, 200, 200);
    UIButton* cancelBtn = [UIButton createButton:CGRectMake(0, 0, 60, 44) font:[UIFont systemFontOfSize:17]  color:RGBCOLOR(255, 68, 69) align:NSTextAlignmentCenter];
    topBar.tag = 2046;
    topBar.alpha = 0.0;
    [TopView addSubview:topBar];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelPoint:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:cancelBtn];
    
    UIButton* confirmBtn = [UIButton createButton:CGRectMake(CurrentScreenWidth - 60, 0, 60, 44) font:[UIFont systemFontOfSize:17] color:ClickedColor align:NSTextAlignmentCenter];
    [confirmBtn addTarget:self action:@selector(confirmPoint:) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [topBar addSubview:confirmBtn];
    
    UIView* grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    grayView.backgroundColor = RGBACOLOR(0, 0, 0, 60);
    grayView.alpha = 0.0;
    UIView* moveView = [[UIView alloc] initWithFrame:imageRegion];
    moveView.backgroundColor = [UIColor clearColor];
    //[grayView addSubview:topBar];
    [grayView addSubview:moveView];
    [self.view addSubview:grayView];
    _pointCover = grayView;
    _photoInfo = [[EZPhotoInfo alloc] init];
    EZInfoDotView* dotView = [[EZInfoDotView alloc] initWithFrame:CGRectMake(130, 200, 60, 60) dotDiameter:15 color:RGBCOLOR(64, 64, 255)];
    _dotView = dotView;
    [moveView addSubview:dotView];
    _dotView.moveCompleted = ^(EZInfoDotView* dotView){
        EZDEBUG(@"moved to :%@", NSStringFromCGPoint(dotView.finalPosition));
        _photoInfo.x = dotView.finalPosition.x;
        _photoInfo.y = dotView.finalPosition.y;
    };
    _dotView.clicked = ^(EZInfoDotView* dotView){
        [self raiseDailog:_photoInfo];
    };
    //UIView* grayCover = [[UIView alloc] initWithFrame:];
    [UIView animateWithDuration:0.3 animations:^(){
        topBar.alpha = 1.0;
        _pointCover.alpha = 1.0;
    }];
}

- (void) raiseDailog:(EZPhotoInfo*)info
{
    EZDEBUG(@"click get called");
    EZInputItem* item1 = [[EZInputItem alloc] initWithName:@"Title" type:kStringValue defaultValue:info.title?info.title:@""];
    EZInputItem* item2 = [[EZInputItem alloc] initWithName:@"Comment" type:kStringValue defaultValue:info.comment?info.comment:@""];
    EZPopupInput* input = [[EZPopupInput alloc] initWithTitle:@"图片信息点" inputItems:@[item1, item2] haveDelete:NO saveBlock:^(EZPopupInput* popInput){
        info.title = item1.changedValue;
        info.comment = item2.changedValue;
        if([info.infoID isNotEmpty]){
            [[EZDataUtil getInstance] updatePhotoInfo:info success:^(id obj){
                EZDEBUG(@"update success");
            } failed:nil];
        }
    } deleteBlock:nil];
    
    [input showInView:self.view animated:YES];
}

- (void) cancelPoint:(id)obj
{
    EZDEBUG(@"cancel get called");
    [UIView animateWithDuration:0.3 animations:^(){
        _pointCover.alpha = 0.0;
        [TopView viewWithTag:2046].alpha = 0.0;
    } completion:^(BOOL finished) {
        [_pointCover removeFromSuperview];
        [[TopView viewWithTag:2046] removeFromSuperview];
        _pointCover = nil;
        _photoInfo = nil;
    }];
}

- (void) confirmPoint:(id)obj
{
    EZDEBUG(@"confirm get called");
    EZStoredPhoto* sp = [_photos objectAtIndex:_currentPos];
    _photoInfo.photoID = sp.photoID;
    [[EZDataUtil getInstance] createPhotoInfo:_photoInfo success:^(EZPhotoInfo* info){
        [sp.infos addObject:info];
        [self loadImage];
    } failed:^(id err){
        EZDEBUG(@"failed to update the info:%@", err);
    }];
    [self cancelPoint:obj];
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