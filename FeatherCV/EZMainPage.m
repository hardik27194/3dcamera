//
//  EZMainPage.m
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZMainPage.h"
#import "EZProfileHeader.h"
#import "EZDetailHeader.h"
#import "EZScrollerView.h"
#import "EZMainCell.h"
#import "EZMenuItem.h"
#import "EZFileUtil.h"
#import "EZDataUtil.h"
#import "EZMainCell.h"
#import "EZProfile.h"
#import "EZRecordTypeDesc.h"
#import "UIImageView+AFNetworking.h"
#import "EZTrackRecord.h"
#import "EZRecordMain.h"
#import "EZMessageCenter.h"
#import "EZMainPhotoCell.h"
#import "EZShotTask.h"
#import "EZStoredPhoto.h"
#import "EZCaptureCameraController.h"
#import "EZMessageCenter.h"
#import "EZPreviewView.h"
#import "EZDetailPage.h"
#import "RAViewController.h"
#import "EZPhotoEditPage.h"
#import "EZMainLayout.h"

#define CELL_ID @"CELL_ID"

@interface EZMainPage ()

@end

@implementation EZMainPage

- (BOOL)calendar:(CKCalendarView *)calendar willSelectDate:(NSDate *)date
{
    if([date compareByDay:[NSDate date]] == NSOrderedDescending){
        return false;
    }
    return true;
}
- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date
{
    EZDEBUG(@"will show the right date:%@", date);
    _dateLabel.text = [[EZDataUtil getInstance].titleFormatter stringFromDate:date];
    [calendar dismiss:YES delay:0.3];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (EZMainPage*) initPage:(NSArray*)arr
{
    EZMainLayout* grid = [[EZMainLayout alloc] init];
    grid.itemSize = CGSizeMake(CurrentScreenWidth/2.0 - 1, (CurrentScreenWidth * 2.0)/3.0 - 1);
    //grid.sectionInset = UIEdgeInsetsMake(1, 1, 0, 0);
    grid.minimumInteritemSpacing = 0;
    grid.minimumLineSpacing = 1;
    //_layout = grid;
    _date = [NSDate date];
    _uploadedPhotos = [[NSMutableArray alloc] initWithArray:arr];
    return [self initWithCollectionViewLayout:grid];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.collectionView.frame = CGRectMake(0, 44, self.view.bounds.size.width,_currentPos==0?(self.view.bounds.size.height-88):(self.view.bounds.size.height-44));
    _bottomBar.y = self.view.bounds.size.height - 44;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"button index:%i", buttonIndex);
    //NSInteger shotBase = 12;
    if(buttonIndex == 4){
        return;
    }
    NSInteger total = 12 + buttonIndex * 6;
    
    EZCaptureCameraController *cam = [[EZCaptureCameraController alloc] init];
    cam.proposedNumber = total;
    cam.shotType = kNormalShotTask;
    cam.confirmClicked = ^(EZShotTask* task){
        EZDEBUG(@"Confirmed clicked, will add the progress screen later");
        //[[EZMessageCenter getInstance] postEvent:EZShotPhotos attached:task];
        task.uploading = true;
        [_uploadedPhotos insertObject:task atIndex:0];
        [_collectionView reloadData];
        __block int count = 0;
        [[EZDataUtil getInstance] updateTask:task success:^(EZShotTask* tk){
            //task.taskID = taskID;
            NSString* taskID = task.taskID;
            for(EZStoredPhoto* sp in task.photos){
                sp.taskID = taskID;
                [[EZDataUtil getInstance] uploadStoredPhoto:sp success:^(EZStoredPhoto* uploaded){
                    EZDEBUG(@"successfully updated:%@, remoteURL:%@", sp.photoID, sp.remoteURL);
                    ++count;
                    if(count == task.photos.count){
                        task.uploading = false;
                        task.newlyUpload = true;
                        int pos = [_uploadedPhotos indexOfObject:task];
                        [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:pos inSection:0]]];
                    }
                } failure:nil];
            }
        } failure:^(id obj){
            EZDEBUG(@"failed to get taskID:%@", obj);
            task.uploading = false;
            int pos = [_uploadedPhotos indexOfObject:task];
            [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:pos inSection:0]]];
        }];
    };
    [self.navigationController pushViewController:cam animated:YES];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void) addClicked:(id)obj
{
    //[self raiseCamera:nil personID:nil];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择拍摄数量" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"12",@"18",@"24",@"32", nil];
    
    [actionSheet showInView:self.view];
}

- (void) shareClicked:(EZShotTask*)shotTask
{
    
    NSString* url = [NSString stringWithFormat:@"%@p3d/show3d?taskID=%@", baseServiceURL, shotTask.taskID];
    NSArray *activityItems = @[@"P3D", str2url(url)];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
    
    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed)
     {
         NSLog(@"Activity = %@",activityType);
         NSLog(@"Completed Status = %d",completed);
         
    }];
}

- (void) topClicked:(UIButton*)btn
{
    if(btn != _currentTopBtn){
        //_currentTopBtn
        int pos = [_topBtns indexOfObject:btn];
        CGFloat stepLen = CurrentScreenWidth/_topBtns.count;
        CGFloat nextPos = pos * stepLen + (stepLen - _bottomLine.width)/2.0;
        
        [UIView animateWithDuration:0.3 animations:^(){
            _bottomLine.left = nextPos;
        } completion:^(BOOL completed){
            [btn setTitleColor:ClickedColor forState:UIControlStateNormal];
            [_currentTopBtn setTitleColor:WhiteTitleColor forState:UIControlStateNormal];
            _currentTopBtn = btn;
            
        }];
        if(pos == 0){
             _bottomBar.hidden = NO;
             self.collectionView.frame = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-88);
            [UIView animateWithDuration:0.3 animations:^(){
                _bottomBar.alpha = 1.0;
               
            } completion:^(BOOL completed){
                //[self.collectionView layoutSubviews];
            }];
        }else{
            self.collectionView.frame = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44);
            [UIView animateWithDuration:0.3 animations:^(){
                _bottomBar.alpha = 0.0;
                
                //[self.collectionView layoutSubviews];
            } completion:^(BOOL completed){
                _bottomBar.hidden = YES;
                //[self.collectionView layoutSubviews];
            }];
        }
        [self btnClicked:pos];
    }
}

- (void) btnClicked:(NSInteger)pos
{
    EZDEBUG(@"Botton clicked:%i", pos);
    _currentPos = pos;
    if(pos == 0 || pos == 1){
        NSString* pid = pos?nil:currentLoginID;
        _loadingActivity.hidden = NO;
        [_loadingActivity startAnimating];
        [[EZDataUtil getInstance] queryTaskByPersonID:pid success:^(NSArray* tasks){
            _uploadedPhotos = [[NSMutableArray alloc] initWithArray:tasks];
            [_collectionView reloadData];
            [_loadingActivity stopAnimating];
            _loadingActivity.hidden = YES;
        } failed:^(id err){
            [_loadingActivity stopAnimating];
            _loadingActivity.hidden = YES;
        }];
    }else{
    }
}

- (void) viewDidLoad
{
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [self.collectionView registerClass:[EZMainPhotoCell class] forCellWithReuseIdentifier:CELL_ID];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    //_collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_collectionView];
    _loadingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:_loadingActivity];
    _loadingActivity.hidden = YES;
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClicked:)];
    
    //self.title = @"P3D";
    NSArray* texts = @[@"我的", @"广场", @"好友"];
    NSMutableArray* btns = [[NSMutableArray alloc] init];
    _topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 20, CurrentScreenWidth, 44)];
    _topBar.backgroundColor = MainBackgroundColor;
    CGFloat stepLen = CurrentScreenWidth/texts.count;
    
    for(int i = 0; i < texts.count; i ++){
        CGFloat startX = stepLen * i;
        NSString* title = [texts objectAtIndex:i];
        UIButton* btn = [UIButton createButton:CGRectMake(startX, 0, stepLen, 44) font:[UIFont boldSystemFontOfSize:20] color:WhiteTitleColor align:NSTextAlignmentCenter];
        [btn setTitle:title forState:UIControlStateNormal];
        [btns addObject:btn];
        [btn addTarget:self action:@selector(topClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_topBar addSubview:btn];
    }
    _topBtns = btns;
    _bottomLine = [[UIView alloc] initWithFrame:CGRectMake((stepLen - 55)/2.0, 41, 55, 2)];
    _bottomLine.backgroundColor = ClickedColor;
    _currentTopBtn = [btns objectAtIndex:0];
    [_currentTopBtn setTitleColor:ClickedColor forState:UIControlStateNormal];
    [_topBar addSubview:_bottomLine];

    [self.view addSubview:_topBar];
    
    [[EZMessageCenter getInstance] registerEvent:EZDeletePhotoTask block:^(EZShotTask* task){
        int pos = [_uploadedPhotos indexOfObject:task];
        [_uploadedPhotos removeObject:task];
        [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:pos inSection:0]]];
    }];
    [[EZMessageCenter getInstance] registerEvent:EZShotPhotos block:^(EZShotTask* task){
        EZDEBUG(@"I receieved photo");
        if(!task){
            return;
        }
        [_uploadedPhotos addObject:task];
        //if(_uploadedPhotos.count){
        //    [self.collectionView insertItemsAtIndexPaths:@[[[NSIndexPath alloc] initWithIndex:_uploadedPhotos.count-1]]];
        //}else{
        [_collectionView reloadData];
        //}
        
    }];
    

    UIImage* iconImage = [UIImage imageNamed:@"camera_btn"];
    
    
    _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, 44)];
    _bottomBar.backgroundColor = MainBackgroundColor;
    
    [self.view addSubview:_bottomBar];
    CGFloat imageWidth = 44 * iconImage.size.width/iconImage.size.height;
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake((80-imageWidth)/2.0, 0, imageWidth, 44)];
  
    image.image = iconImage;
    UIButton* shotBtn = [UIButton createButton:CGRectMake((CurrentScreenWidth - 80)/2, 0, 80, 44) font:[UIFont systemFontOfSize:10] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
    shotBtn.backgroundColor = ClickedColor;
    [shotBtn addSubview:image];
    //[shotBtn setImage:iconImage forState:UIControlStateNormal];
    [shotBtn addTarget:self action:@selector(addClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBar addSubview:shotBtn];
    
    [[EZMessageCenter getInstance] registerEvent:EZLoginSuccess block:^(EZPerson* ps){
        /**
        [[EZDataUtil getInstance] queryTaskByPersonID:currentLoginID success:^(NSArray* tasks){
            _uploadedPhotos = [[NSMutableArray alloc] initWithArray:tasks];
            [_collectionView reloadData];
        } failed:^(id err){}];
         **/
        [self btnClicked:_currentPos];
    }];
    EZDEBUG(@"loginID:%@", currentLoginID);
    
    if(currentLoginID){
        /**
        [[EZDataUtil getInstance] queryTaskByPersonID:currentLoginID success:^(NSArray* tasks){
            _uploadedPhotos = [[NSMutableArray alloc] initWithArray:tasks];
            [_collectionView reloadData];
        } failed:^(id err){}];
         **/
        [self btnClicked:_currentPos];
    }
    
    
    [[EZMessageCenter getInstance] registerEvent:EZShotTaskChanged block:^(EZShotTask* task){
        [_collectionView reloadData];
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    //[self.navigationController]
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //EZRecordTypeDesc* rd = [_descs objectAtIndex:indexPath.row];
    EZDEBUG(@"Selected: %i",indexPath.row);
    
    EZShotTask* task = [_uploadedPhotos objectAtIndex:indexPath.row];
    EZDetailPage* dp = [[EZDetailPage alloc] initWithTask:task];
    if(task.newlyUpload){
        task.newlyUpload = false;
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    [self.navigationController pushViewController:dp animated:YES];
}


-(id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    if (self = [super init])
    {
        _layout = layout;
    }
    return self;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EZMainPhotoCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
        //NSDate* curDate = _date;
    EZShotTask* shotTask = [_uploadedPhotos objectAtIndex:indexPath.row];
    //EZTrackRecord* record = [_recorders objectAtIndex:indexPath.row];
    //[cell.name setTitle:desc.name forState:UIControlStateNormal];
    cell.name.text = [shotTask.name isNotEmpty]?shotTask.name:@"未命名";
    cell.updateDate.text = [[EZDataUtil getInstance].titleFormatter stringFromDate:shotTask.shotDate];
    cell.photoCount.text = [NSString stringWithFormat:@"共%i张", shotTask.photos.count];
    EZStoredPhoto* storePhoto = nil;
    if(shotTask.photos.count){
        EZStoredPhoto* storePhoto = [shotTask.photos objectAtIndex:0];
        [cell.photo setImageWithURL:str2url(storePhoto.remoteURL) loading:YES];
    }else{
        [cell.photo setImage:nil];
    }
    if(shotTask.newlyUpload){
        cell.clickInfo.hidden = NO;
    }else{
        cell.clickInfo.hidden = YES;
    }
    __weak EZMainPage* weakSelf = self;
    
    cell.editClicked = ^(id obj){
        //NSMutableArray* photoURLs = [[NSMutableArray alloc] init];
        //for(EZStoredPhoto* sp in shotTask.photos){
        //    [photoURLs addObject:sp.localFileName];
        //}
        //[EZPreviewView showPreview:shotTask.photos inCtrl:weakSelf.navigationController complete:nil edit:nil];
        EZPhotoEditPage* ep = [[EZPhotoEditPage alloc] initWithTask:shotTask pos:0];
        [self.navigationController pushViewController:ep animated:YES];
        
        };
    EZDEBUG(@"load cell:%i, remoteURL:%@, localFile:%@", indexPath.item, storePhoto.remoteURL, storePhoto.localFileURL);

    cell.shareClicked = ^(id obj){
        [weakSelf shareClicked:shotTask];
    };
    [cell setUploading:shotTask.uploading];
    //cell.editBtn
    return cell;
}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _uploadedPhotos.count;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
