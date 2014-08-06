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
    grid.itemSize = CGSizeMake(106.0, 114.0);
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

- (void) addClicked:(id)obj
{
    //[self raiseCamera:nil personID:nil];
    SCCaptureCameraController *cam = [[SCCaptureCameraController alloc] init];
    [self.navigationController pushViewController:cam animated:YES];
    
}

- (void)takePicture:(DLCImagePickerController*)picker imageInfo:(NSDictionary*)info
{
    EZDEBUG(@"Take picture:%@",info);
}
- (void)imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    EZDEBUG(@"Take photo:%@",info);
    //[self raiseCamera:nil personID:nil];
}

- (void) raiseCamera:(NSString *)photo personID:(NSString*)personID
{

        
    DLCImagePickerController* camera = [[DLCImagePickerController alloc] initWithFront:false];
    camera.delegate = self;
    camera.personID = personID;
    [self.navigationController pushViewController:camera animated:YES];
}


- (void) viewDidLoad
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClicked:)];
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
}


-(id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    if (self = [super init])
    {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self.collectionView registerClass:[EZMainPhotoCell class] forCellWithReuseIdentifier:CELL_ID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        //_collectionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_collectionView];
    }
    return self;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EZMainPhotoCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    EZDEBUG(@"load cell:%i", indexPath.row);
    //NSDate* curDate = _date;
    EZShotTask* shotTask = [_uploadedPhotos objectAtIndex:indexPath.row];
    //EZTrackRecord* record = [_recorders objectAtIndex:indexPath.row];
    //[cell.name setTitle:desc.name forState:UIControlStateNormal];
    cell.name.text = shotTask.name;
    cell.updateDate.text = [[EZDataUtil getInstance].titleFormatter stringFromDate:shotTask.shotDate];
    EZStoredPhoto* storePhoto = [shotTask.photos objectAtIndex:0];
    [cell.photo setImageWithURL:str2url(storePhoto.remoteURL)];
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
