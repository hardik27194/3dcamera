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
#import "SCCaptureCameraController.h"
#import "EZMessageCenter.h"
#import "EZPreviewView.h"
#import "EZDetailPage.h"
#import "RAViewController.h"
#import "EZPhotoEditPage.h"

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
    UICollectionViewFlowLayout* grid = [[UICollectionViewFlowLayout alloc] init];
    grid.itemSize = CGSizeMake(CurrentScreenWidth/2.0 - 1, (CurrentScreenWidth * 2.0)/3.0 - 1);
    //grid.sectionInset = UIEdgeInsetsMake(1, 1, 0, 0);
    grid.minimumInteritemSpacing = 0;
    grid.minimumLineSpacing = 1;
    _date = [NSDate date];
    _uploadedPhotos = [[NSMutableArray alloc] initWithArray:arr];
    return [self initWithCollectionViewLayout:grid];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"button index:%i", buttonIndex);
    //NSInteger shotBase = 12;
    if(buttonIndex == 4){
        return;
    }
    NSInteger total = 12 + buttonIndex * 6;
    
    SCCaptureCameraController *cam = [[SCCaptureCameraController alloc] init];
    cam.proposedNumber = total;
    cam.shotType = kNormalShotTask;
    cam.confirmClicked = ^(EZShotTask* task){
        [[EZMessageCenter getInstance] postEvent:EZShotPhotos attached:task];
        [[EZDataUtil getInstance] createTaskID:^(NSString* taskID){
            task.taskID = taskID;
            for(EZStoredPhoto* sp in task.photos){
                sp.taskID = taskID;
                [[EZDataUtil getInstance] uploadStoredPhoto:sp success:^(EZStoredPhoto* uploaded){
                    EZDEBUG(@"successfully updated:%@, remoteURL:%@", sp.photoID, sp.remoteURL);
                } failure:nil];
            }
        } failure:^(id obj){
            EZDEBUG(@"failed to get taskID:%@", obj);
        }];
    };
    [self.navigationController pushViewController:cam animated:YES];
    
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


- (void) viewDidLoad
{
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [self.collectionView registerClass:[EZMainPhotoCell class] forCellWithReuseIdentifier:CELL_ID];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    //_collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_collectionView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClicked:)];
    self.title = @"P3D";
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
    
    UIButton* shotBtn = [UIButton createButton:CGRectMake((CurrentScreenWidth - iconImage.size.width)/2, CurrentScreenHeight - iconImage.size.height - 5, iconImage.size.width, iconImage.size.height) font:[UIFont systemFontOfSize:10] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
    
    [shotBtn setImage:iconImage forState:UIControlStateNormal];
    [shotBtn addTarget:self action:@selector(addClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shotBtn];
    [[EZMessageCenter getInstance] registerEvent:EZLoginSuccess block:^(EZPerson* ps){
        [[EZDataUtil getInstance] queryTaskByPersonID:currentLoginID success:^(NSArray* tasks){
            _uploadedPhotos = [[NSMutableArray alloc] initWithArray:tasks];
            [_collectionView reloadData];
        } failed:^(id err){}];
    }];
    EZDEBUG(@"loginID:%@", currentLoginID);
    
    if(currentLoginID){
        [[EZDataUtil getInstance] queryTaskByPersonID:currentLoginID success:^(NSArray* tasks){
            _uploadedPhotos = [[NSMutableArray alloc] initWithArray:tasks];
            [_collectionView reloadData];
        } failed:^(id err){}];
    }
    
    
    [[EZMessageCenter getInstance] registerEvent:EZShotTaskChanged block:^(EZShotTask* task){
        [_collectionView reloadData];
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    //[self.navigationController]
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //EZRecordTypeDesc* rd = [_descs objectAtIndex:indexPath.row];
    EZDEBUG(@"Selected: %i",indexPath.row);
    
    EZShotTask* task = [_uploadedPhotos objectAtIndex:indexPath.row];
    EZDetailPage* dp = [[EZDetailPage alloc] initWithTask:task];
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
    cell.name.text = shotTask.name;
    cell.updateDate.text = [[EZDataUtil getInstance].titleFormatter stringFromDate:shotTask.shotDate];
    cell.photoCount.text = [NSString stringWithFormat:@"共%i张", shotTask.photos.count];
    EZStoredPhoto* storePhoto = [shotTask.photos objectAtIndex:0];
    [cell.photo setImageWithURL:str2url(storePhoto.remoteURL)];
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
