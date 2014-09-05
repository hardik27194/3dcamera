//
//  EZDragPage.m
//  3DCamera
//
//  Created by xietian on 14-8-30.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZDragPage.h"
#import "RACollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "EZShotTask.h"
#import "EZStoredPhoto.h"
#import "EZMessageCenter.h"
#import "EZPhotoEditPage.h"



@interface EZDragPage ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//@property (nonatomic, strong) NSMutableArray *photosArray;

@end

@implementation EZDragPage

- (id) initWithTask:(EZShotTask*)task
{
    self = [super init];
    _task = task;
    _storedPhotos = _task.photos;//[[NSMutableArray alloc] initWithArray:_task.photos];
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:YES];
}

- (void) confirmed:(id)obj
{
    EZDEBUG(@"Drag confirmed");
    if(_confirmClicked){
        _confirmClicked(@(YES));
    }
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void) cancel:(id)obj
{
    EZDEBUG(@"Drag cancelled");
    if(_confirmClicked){
        _confirmClicked(@(NO));
    }
}

- (void) viewWillLayoutSubviews
{
    EZDEBUG(@"view bounds is:%@", NSStringFromCGRect(self.view.bounds));
    self.collectionView.frame = self.view.bounds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(confirmed:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    UICollectionView* collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[RACollectionViewReorderableTripletLayout alloc] init]];
    [collectionView registerClass:[RACollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView = collectionView;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    //[self setupPhotosArray];
    
    [[EZMessageCenter getInstance] registerEvent:EZShotTaskChanged block:^(EZStoredPhoto* pt){
        //[_collectionView reloadData];
        [self refresh:nil];
    }];
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //if (section == 0) {
    //    return 1;
    //}
    EZDEBUG(@"storedPhotos count:%i",_storedPhotos.count);
    return _storedPhotos.count;
}

- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 1.f;
}

- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 1.f;
}

- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 1.f;
}

- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(1, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForLargeItemsInSection:(NSInteger)section
{
    //if (section == 0) {
    //    return CGSizeMake(320, 200);
    //}
    /**
     else{
     return CGSizeMake(100, 100);
     }
     **/
    return RACollectionViewTripletLayoutStyleSquare; //same as default !
}

- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(50.f, 0, 50.f, 0); //Sorry, horizontal scroll is not supported now.
}

- (UIEdgeInsets)autoScrollTrigerPadding:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(64.f, 0, 0, 0);
}

- (CGFloat)reorderingItemAlpha:(UICollectionView *)collectionview
{
    return .3f;
}


- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    EZDEBUG(@"end dragging get called:%i, row:%i", indexPath.item, indexPath.row);
    //RACollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    EZStoredPhoto* fromSp = [_storedPhotos objectAtIndex:fromIndexPath.item];
    //EZStoredPhoto* toSp = [_storedPhotos objectAtIndex:toIndexPath.item];
    [_storedPhotos removeObjectAtIndex:fromIndexPath.item];
    [_storedPhotos insertObject:fromSp atIndex:toIndexPath.item];
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    //if (toIndexPath.section == 0) {
    //    return NO;
    //}
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    // if (indexPath.section == 0) {
    //     return NO;
    // }
    return YES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID = @"cellID";
    RACollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    //[cell.imageView removeFromSuperview];
    //cell.imageView.frame = cell.bounds;
    //cell.imageView.image = _photosArray[indexPath.item];
    //cell.imageView.frame = cell.bounds;
    //[cell.contentView addSubview:cell.imageView];
    EZStoredPhoto* sp = [_storedPhotos objectAtIndex:indexPath.item];
    if(sp.localFileURL){
        [cell.imageView setImageWithURL:str2url(sp.localFileURL)];
    }else{
        [cell.imageView setImageWithURL:str2url(sp.remoteURL)];
        
    }
    EZDEBUG(@"item:%i cell bounds:%@, localURL:%@, remoteURL:%@",indexPath.item, NSStringFromCGRect(cell.frame), sp.localFileURL, sp.remoteURL);
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //if (_storedPhotos.count == 1) {
    //    return;
    //}
    /**
     [self.collectionView performBatchUpdates:^{
     //[_photosArray removeObjectAtIndex:indexPath.item];
     [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
     } completion:^(BOOL finished) {
     [self.collectionView reloadData];
     }];
     **/
    //UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    //EZDEBUG(@"Did select indexPath:%i, frame:%@", indexPath.item, NSStringFromCGRect(cell.frame));
    //EZStoredPhoto* stored
    EZPhotoEditPage* ep = [[EZPhotoEditPage alloc] initWithShot:_storedPhotos pos:indexPath.item deletedBlock:^(NSNumber* pos){
        EZDEBUG(@"deleted get called:%i", pos.intValue);
        //int pos = [_storedPhotos indexOfObject:storedPht];
        [_storedPhotos removeObjectAtIndex:pos.intValue];
        //[self refresh:nil];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:pos.intValue inSection:0]]];
        
    }]; //[[EZPhotoEditPage alloc] initWithPhotos:_storedPhotos pos:indexPath.item];
    
    [self.navigationController pushViewController:ep animated:YES];
}

- (IBAction)refresh:(UIBarButtonItem *)sender
{
    //[self setupPhotosArray];
    [_collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}

@end
