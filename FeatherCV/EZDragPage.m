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
#import "EZPopupInput.h"
#import "EZInputItem.h"
#import "EZDataUtil.h"
#import "EZCompleteSetting.h"
#import "EZConfigure.h"
#import "EZCaptureCameraController.h"


@interface EZDragPage ()

//@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//@property (nonatomic, strong) NSMutableArray *photosArray;

@end

@implementation EZDragPage

- (id) initWithTask:(EZShotTask*)task mode:(BOOL)isEditMode;
{
    self = [super init];
    _isEditMode = isEditMode;
    _task = task;
    _storedPhotos = _task.photos;//[[NSMutableArray alloc] initWithArray:_task.photos];
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:YES];
}

- (void) raiseNormal
{
    [self raiseTitleChange:nil];
}

- (void) raiseCompleteView
{
    EZCompleteSetting* completeSetting = [[EZCompleteSetting alloc] initWithFrame:CGRectMake(15, 80, CurrentScreenWidth - 30, 220)];
    __weak EZDragPage* weakSelf = self;
    //completeSetting.confirmed =
    [completeSetting showInView:self.view aniamted:YES confirmed:^(NSArray* values){
        weakSelf.task.name = [values objectAtIndex:0];
        weakSelf.task.isPrivate = [EZConfigure sharedEZConfigure].isPrivate;
        if(weakSelf.confirmClicked){
            weakSelf.confirmClicked(@(YES));
        }
    }];
    
}

- (void) raiseTitleChange:(EZEventBlock)inputSuccess;
{
    EZDEBUG(@"click get called");
    EZInputItem* item1 = [[EZInputItem alloc] initWithName:@"名称" type:kStringValue defaultValue:_task.name?_task.name:@""];

    EZPopupInput* input = [[EZPopupInput alloc] initWithTitle:@"图片名称" inputItems:@[item1] haveDelete:NO saveBlock:^(EZPopupInput* popInput){
        //info.title = item1.changedValue;
        //info.comment = item2.changedValue;
        EZDEBUG(@"Changed value:%@", item1.changedValue);
        _task.name = item1.changedValue;
        [_titleChangeBtn setTitle:item1.changedValue forState:UIControlStateNormal];
        if([_task.name isNotEmpty] && inputSuccess){
            inputSuccess(nil);
        }
        
    } deleteBlock:nil];
    
    [input showInView:self.view animated:YES];
    [item1.textField becomeFirstResponder];
}

- (void) addPhoto:(id)sender
{
    //EZStoredPhoto* storedPhoto = [_photos objectAtIndex:_currentPos];
    EZCaptureCameraController* sc = [[EZCaptureCameraController alloc] init];
    sc.shotType = kShotSingle;
    //sc.photo = storedPhoto;
    
    sc.confirmClicked = ^(NSString* localURL){
        EZDEBUG(@"replace confirmed:%@", localURL);
        if(!localURL){
            return;
        }
        EZStoredPhoto* addedPhoto = [[EZStoredPhoto alloc] init];
        //addedPhoto.taskID = storedPhoto.taskID;
        
        //[[EZDataUtil getInstance] deleteLocalFile:storedPhoto];
        //storedPhoto.localFileURL = localURL;
        addedPhoto.localFileURL = localURL;
        addedPhoto.remoteURL = localURL;
        addedPhoto.createdTime = [NSDate date];
        addedPhoto.sequence = _storedPhotos.count;
        addedPhoto.isOriginal = true;
        [_storedPhotos addObject:addedPhoto];
        [[EZMessageCenter getInstance] postEvent:EZShotPhotoAdded attached:addedPhoto];
        /**
        [[EZDataUtil getInstance] addUploadPhoto:addedPhoto success:^(id obj){
            EZDEBUG(@"obj:%@", obj);
            //[_imageView setImageWithURL:str2url(localURL)];
            [[EZMessageCenter getInstance] postEvent:EZShotTaskChanged attached:addedPhoto];
        } failure:^(id err){
            EZDEBUG(@"error:%@", err);
        }];
        **/
    };
    
    [self.navigationController pushViewController:sc animated:YES];
}



- (void) confirmed:(id)obj
{
    EZDEBUG(@"Drag confirmed");
    [self raiseCompleteView];
    
    /**
    if([_task.name isNotEmpty]){
        if(_confirmClicked){
            _confirmClicked(@(YES));
        }
    }else{
        [self raiseTitleChange:^(id obj){
            if(_confirmClicked){
                _confirmClicked(@(YES));
            }
        }];
    }
     **/
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

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self raiseTitleChange];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    EZDEBUG(@"EZDragPage view did load:%i", _task.photos.count);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(confirmed:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    _cellLayout = [[RACollectionViewReorderableTripletLayout alloc] init];
    UICollectionView* collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_cellLayout];
    
    [collectionView registerClass:[RACollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
    //self.view.backgroundColor = MainBackgroundColor;
    self.collectionView = collectionView;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    self.collectionView.backgroundColor = MainBackgroundColor;////[UIColor whiteColor];
    
    /**
    UIButton* btn = [UIButton createButton:CGRectMake(0, 0, 200, 44) font:[UIFont boldSystemFontOfSize:17] color:ClickedColor align:NSTextAlignmentCenter];
    [btn setTitle:@"修改名称" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(raiseNormal) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = btn;
    _titleChangeBtn = btn;
    **/
    self.title = @"编辑照片";
    //[self setupPhotosArray];
    __weak EZDragPage* dragPage = self;
    [[EZMessageCenter getInstance] registerEvent:EZShotPhotoAdded block:^(id obj){
        dragPage.cellLayout.needsUpdateLayout = YES;
        [dragPage.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:dragPage.storedPhotos.count - 1 inSection:0]]];
    }];
    /**
    [[EZMessageCenter getInstance] registerEvent:EZShotTaskChanged block:^(EZStoredPhoto* pt){
        //[_collectionView reloadData];
        [dragPage refresh:nil];
    }];
     **/
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
    return _storedPhotos.count + 1;
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
    //[self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    _isDragMode = true;
    NSArray* visibleCell = [collectionView visibleCells];
    for(RACollectionViewCell* cell in visibleCell){
        [cell showDelete:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    if(fromIndexPath.item < _storedPhotos.count && toIndexPath.item < _storedPhotos.count){
        EZStoredPhoto* fromSp = [_storedPhotos objectAtIndex:fromIndexPath.item];
        //EZStoredPhoto* toSp = [_storedPhotos objectAtIndex:toIndexPath.item];
        [_storedPhotos removeObjectAtIndex:fromIndexPath.item];
        [_storedPhotos insertObject:fromSp atIndex:toIndexPath.item];
        if([_task.taskID isNotEmpty]){
            [[EZDataUtil getInstance] updateTaskSequence:_task success:^(id obj){
                EZDEBUG(@"update sequence success");
                [[EZMessageCenter getInstance] postEvent:EZShotTaskChanged attached:nil];
            } failure:^(id err){
                EZDEBUG(@"error:%@", err);
            }];
        }
    }
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    //if (toIndexPath.section == 0) {
    //    return NO;
    //}
    if(toIndexPath.item < _storedPhotos.count){
        return YES;
    }
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    // if (indexPath.section == 0) {
    //     return NO;
    // }
    if(indexPath.item < _task.photos.count){
        return YES;
    }
    return NO;
}

/**
 *
 **/
- (void) deletePhoto:(EZStoredPhoto*)sp indexPath:(NSIndexPath*)outPath
{
    NSInteger realPos = [_storedPhotos indexOfObject:sp];
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:realPos inSection:0];
    
    if(indexPath.item >= _storedPhotos.count){
        EZDEBUG(@"quit for non-exist photo:%i, %i", indexPath.item, _storedPhotos.count);
        return;
    }
    [_storedPhotos removeObject:sp];
    EZDEBUG(@"Before delete item");
    _cellLayout.needsUpdateLayout = YES;
    [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    //[_collectionView reloadData];
    EZDEBUG(@"After delete item");
    [[EZMessageCenter getInstance] postEvent:EZShotTaskChanged attached:nil];
    if([sp.photoID isNotEmpty]){
        [[EZDataUtil getInstance] deleteStoredPhoto:sp success:^(id obj){
            EZDEBUG(@"delete photo successfully");
        } failed:^(id err){
            EZDEBUG(@"delete error detail:%@", err);
        }];
    }else{
        sp.removed = true;
        //[_storedPhotos removeObject:sp];
        //[_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID = @"cellID";
    //EZDEBUG(@"current index:%i", indexPath.item);
    __weak EZDragPage* weakSelf = self;
    RACollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    //[cell.imageView removeFromSuperview];
    //cell.imageView.frame = cell.bounds;
    //cell.imageView.image = _photosArray[indexPath.item];
    //cell.imageView.frame = cell.bounds;
    //[cell.contentView addSubview:cell.imageView];
    [cell showImage:_isDragMode];
    if(indexPath.item < _storedPhotos.count){
        EZStoredPhoto* sp = [_storedPhotos objectAtIndex:indexPath.item];
    //if(sp.localFileURL){
    //    [cell.imageView setImageWithURL:str2url(sp.localFileURL)];
    //}else{
        [cell.imageView setImageWithURL:str2url(sp.remoteURL) loading:NO];
    //}
        //EZDEBUG(@"item:%i cell bounds:%@, localURL:%@, remoteURL:%@",indexPath.item, NSStringFromCGRect(cell.frame), sp.localFileURL, sp.remoteURL);
        cell.deleteClicked = ^(id obj){
            [weakSelf deletePhoto:sp indexPath:indexPath];
        };
    }else{
        [cell showAdd];
        if(_isEditMode){
            cell.addClicked = _addClicked;
        }else{
            cell.addClicked = ^(id obj){
                [weakSelf addPhoto:nil];
            };
        }
        //EZDEBUG(@"Will show add button");
    }
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EZDEBUG(@"did select at path:%i", indexPath.item);
    if(_isDragMode){
        _isDragMode = false;
        //[self setDragMode:_isDragMode];
        _cellLayout.dragStatus = false;
        [self.collectionView reloadData];
    }
}

/**
- (void) setDragMode:(BOOL)dragMode
{
    
}
**/
- (IBAction)refresh:(UIBarButtonItem *)sender
{
    //[self setupPhotosArray];
    [_collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}

@end
