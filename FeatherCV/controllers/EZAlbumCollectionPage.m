//
//  EZAlbumCollectionPage.m
//  Feather
//
//  Created by xietian on 13-10-11.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZAlbumCollectionPage.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "EZCollectionPhotoCell.h"
#import "EZTransitionLayout.h"
#import "EZCombinedPhoto.h"
#import "EZClickView.h"
#import "EZPhoto.h"
#import "EZUIUtility.h"
#import "EZContactsPage.h"
#import "EZExtender.h"
#import "AFNetworking.h"
#import "EZClickImage.h"
#import "EZDataUtil.h"
#import "EZMessageCenter.h"
#import "EZContactsPage.h"
#import "EZDisplayPhoto.h"
#import "EZCrossHair.h"

#define CELL_ID @"PhotoCell"
#define MAX_COUNT 100

@interface EZAlbumCollectionPage ()

@end

@implementation EZAlbumCollectionPage

+ (EZAlbumCollectionPage*) createGridAlbumPage:(BOOL)isLarge ownID:(int)ownID queryBlock:(EZQueryBlock)queryBlock
{
    // We could have multiple section stacks and find the right one,
    UICollectionViewFlowLayout* grid = [[UICollectionViewFlowLayout alloc] init];
    if(isLarge){
        grid.itemSize = CGSizeMake(320, 433);
        grid.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }else{
        grid.itemSize = CGSizeMake(45.0, 45.0);
        grid.sectionInset = UIEdgeInsetsMake(0, 3, 0, 2);
    }
    
    grid.minimumInteritemSpacing = 0;
    grid.minimumLineSpacing = 0;
   
    EZAlbumCollectionPage* nextCollectionViewController = [[EZAlbumCollectionPage alloc] initWithCollectionViewLayout:grid queryBlock:queryBlock queryLimit:isLarge?20:140];
    nextCollectionViewController.isLarge = isLarge;
    if(isLarge){
        UIPinchGestureRecognizer* pincher = [[UIPinchGestureRecognizer alloc] initWithTarget:nextCollectionViewController action:@selector(zoomOut:)];
        [nextCollectionViewController.collectionView addGestureRecognizer:pincher];
        //nextCollectionViewController.queryLimit = 20;
    }else{
        UIPinchGestureRecognizer* pincher = [[UIPinchGestureRecognizer alloc] initWithTarget:nextCollectionViewController action:@selector(zoomIn:)];
        [nextCollectionViewController.collectionView addGestureRecognizer:pincher];
        //Leave some room for the query buffer
        //nextCollectionViewController.queryLimit = 140;
        
    }
    //nextCollectionViewController.queryBlock = queryBlock;
    //nextCollectionViewController.useLayoutToLayoutNavigationTransitions = YES;
    nextCollectionViewController.ownerID = ownID;
    nextCollectionViewController.title = @"照片";
    return nextCollectionViewController;
    
}

//Mean I will call the query a lot
- (void) viewDidLoad
{
    if(_queryBlock){
        EZDEBUG(@"will query from:%i, limit:%i", _currentBegin+_combinedPhotos.count, _queryLimit);
        _queryBlock(_currentBegin+_combinedPhotos.count, _queryLimit, ^(NSArray* ar){
            //EZDEBUG(@"result total:%i, current batch:%i", ar.totalPhoto, ar.photos.count);
            _totalLength = ar.count;
            [_combinedPhotos addObjectsFromArray:ar];
            [self.collectionView reloadData];
        }, ^(id error){
            EZDEBUG(@"Query error:%@", error);
        });
    }
}

- (void) zoomOut:(UIPinchGestureRecognizer*)outGesturer
{
    EZDEBUG(@"Zoom out ratio:%f", outGesturer.scale);
    if(outGesturer.scale < 0.5){
        EZAlbumCollectionPage* page = [EZAlbumCollectionPage createGridAlbumPage:NO ownID:_ownerID queryBlock:_queryBlock];
        [self.collectionView removeGestureRecognizer:outGesturer];
        [self.navigationController pushViewController:page animated:YES];
    }
}

- (void) zoomIn:(UIPinchGestureRecognizer*)insideGesturer
{
    EZDEBUG(@"Zoom in ratio:%f", insideGesturer.scale);
    if(insideGesturer.scale > 2){
        //EZAlbumCollectionPage* page = [EZAlbumCollectionPage createGridAlbumPage:YE ownID:_ownerID];
        //[self.navigationController pushViewController:page animated:YES];
        [self.collectionView removeGestureRecognizer:insideGesturer];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) swipped:(UISwipeGestureRecognizer*) gesture
{
    EZDEBUG(@"Direction is:%i", gesture.direction);
    EZContactsPage* personPage = [[EZContactsPage alloc] initPage];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:personPage];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void) setOwnerID:(int)ownerID
{
    _ownerID = ownerID;
    __weak EZAlbumCollectionPage* weakSelf = self;
    /**
    [[EZDataUtil getInstance] getCombinedPhoto:ownerID start:0 limit:20 success:^(NSArray* photos){
        [weakSelf.combinedPhotos addObjectsFromArray:photos];
        [weakSelf.collectionView reloadData];
    } failure:nil];
    **/
    //Mean I am the current user.
    if(_ownerID == [EZDataUtil getInstance].getCurrentPersonID){
        EZDEBUG(@"Will register for current user:%i", _ownerID);
        _uploadProcess = ^(EZDisplayPhoto* cp){
            //EZDisplayPhoto* dp = [[EZDisplayPhoto alloc] init];
            //dp.combinedPhotos = @[cp];
            [weakSelf.combinedPhotos insertObject:cp atIndex:0];
            [weakSelf.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
        };
    [   [EZMessageCenter getInstance] registerEvent:EZPhotoUploadSuccess block:_uploadProcess];
    }
}

//- (void) viewWillAppear:(BOOL)animated


-(id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout queryBlock:(EZQueryBlock)queryBlock queryLimit:(int)queryLimit;
{

    if (self = [super initWithCollectionViewLayout:layout])
    {
        _queryBlock = queryBlock;
        _combinedPhotos = [[NSMutableArray alloc] init];
        _queryLimit = queryLimit;
        [self.collectionView registerClass:[EZCollectionPhotoCell class] forCellWithReuseIdentifier:CELL_ID];
    }
    self.collectionView.alwaysBounceVertical = true;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self createHiddenButton];
    UISwipeGestureRecognizer* swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipped:)];
    [self.collectionView addGestureRecognizer:swiper];
    return self;
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"selected %i",buttonIndex);
    if(buttonIndex == 0){
        [self takePhoto:YES];
    }else if(buttonIndex == 1){
        [self takePhoto:NO];
    }
}

- (void) takePhoto:(bool)isAlbum
{
    [[EZUIUtility sharedEZUIUtility] raiseCamera:isAlbum controller:self.navigationController completed:^(UIImage* image){
        
        [[EZDataUtil getInstance] uploadPhoto:image success:^(EZDisplayPhoto* cp){
            EZDEBUG(@"Upload photo success");
            [[EZMessageCenter getInstance] postEvent:EZPhotoUploadSuccess attached:cp];
        } failure:^(id error){
            EZDEBUG("Upload photo failed");
        }];
        
        EZDEBUG(@"Get photo image");
    }];
}


- (void) createHiddenButton
{
    __weak UIViewController* weakSelf = self;
    _container = [[UIView alloc] initWithFrame:CGRectMake(0, -208, 320, 208)];
    EZClickView* addFriend = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
    //addFriend.backgroundColor = [UIColor greenColor];
    UIImageView* friendImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_friend"]];
    [friendImage setPosition:CGPointMake((160 - 38)/2, (160 - 38)/2)];
    [addFriend addSubview:friendImage];
    addFriend.releasedBlock = ^(id obj){
        EZDEBUG(@"Add friend get clicked");
        //EZAlbumCollectionPage* allPage = [EZAlbumCollectionPage createGridAlbumPage:YES];
        //[self.navigationController pushViewController:allPage animated:YES];
        EZContactsPage* contactPage = [[EZContactsPage alloc] initPage];
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:contactPage];
        [weakSelf presentViewController:nav animated:YES completion:nil];
    };
    UIView* splitter = [[UIView alloc] initWithFrame:CGRectMake(159, 20, 1, 120)];
    splitter.backgroundColor = RGBCOLOR(220, 220, 224);
    [addFriend addSubview:splitter];
    __weak UIView* cv = self.view;
    EZClickView* shootPhoto = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    shootPhoto.backgroundColor = [UIColor clearColor];
    
    EZCrossHair* crossHair = [[EZCrossHair alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    //shootPhoto.backgroundColor = [UIColor yellowColor];
    //UIImageView* shootImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"take_photo"]];
    //[shootImage setPosition:CGPointMake((160 - 38)/2, (160 - 38)/2)];
    //[shootPhoto addSubview:shootImage];
    shootPhoto.releasedBlock = ^(id obj){
        //EZDEBUG(@"Shoot photo get clicked");
        UIActionSheet* ah = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册",@"拍照", nil];
        [ah showInView:cv];
    };
    
    //[_container addSubview:addFriend];
    [_container addSubview:crossHair];
    [_container addSubview:shootPhoto];
    
    //UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(0, 202, 320, 1)];
    //sep.backgroundColor = RGBCOLOR(220, 220, 224);
    //[_container addSubview:sep];
    _totalEntries = [[UILabel alloc] initWithFrame:CGRectMake(25, 160, 60, 18)];
    _totalEntries.font = [UIFont systemFontOfSize:17];
    _totalEntries.textColor = RGBCOLOR(127, 127, 127);
    _totalEntries.text = @"0";
    UILabel* entryTitle = [[UILabel alloc] initWithFrame:CGRectMake(25, 177, 80, 18)];
    entryTitle.font = [UIFont systemFontOfSize:17];
    entryTitle.textColor = RGBCOLOR(220, 220, 224);
    entryTitle.text = @"ENTRIES";
    [_container addSubview:_totalEntries];
    [_container addSubview:entryTitle];
    
    
    _monthCount = [[UILabel alloc] initWithFrame:CGRectMake(105, 160, 50, 18)];
    _monthCount.font = [UIFont systemFontOfSize:17];
    _monthCount.textColor = RGBCOLOR(127, 127, 127);
    _monthCount.text = @"0";
    entryTitle = [[UILabel alloc] initWithFrame:CGRectMake(105, 177, 80, 18)];
    entryTitle.font = [UIFont systemFontOfSize:16];
    entryTitle.textColor = RGBCOLOR(220, 220, 224);
    entryTitle.text = @"DAYS";
    [_container addSubview:_monthCount];
    [_container addSubview:entryTitle];
    
    _weekCount = [[UILabel alloc] initWithFrame:CGRectMake(170, 160, 50, 18)];
    _weekCount.font = [UIFont systemFontOfSize:17];
    _weekCount.textColor = RGBCOLOR(127, 127, 127);
    _weekCount.text = @"0";
    entryTitle = [[UILabel alloc] initWithFrame:CGRectMake(170, 177, 80, 18)];
    entryTitle.font = [UIFont systemFontOfSize:16];
    entryTitle.textColor = RGBCOLOR(220, 220, 224);
    entryTitle.text = @"WEEK";
    [_container addSubview:_weekCount];
    [_container addSubview:entryTitle];
    
    
    _dailyCount = [[UILabel alloc] initWithFrame:CGRectMake(235, 160, 50, 18)];
    _dailyCount.font = [UIFont systemFontOfSize:17];
    _dailyCount.textColor = RGBCOLOR(127, 127, 127);
    _dailyCount.text = @"0";
    entryTitle = [[UILabel alloc] initWithFrame:CGRectMake(235, 177, 80, 18)];
    entryTitle.font = [UIFont systemFontOfSize:16];
    entryTitle.textColor = RGBCOLOR(220, 220, 224);
    entryTitle.text = @"TODAY";
    [_container addSubview:_dailyCount];
    [_container addSubview:entryTitle];
    
    [self.collectionView addSubview:_container];
}


- (void) setLikeButton:(EZCollectionPhotoCell*)cell combinedPhoto:(EZCombinedPhoto*)cp
{
    cell.likeButton.releasedBlock = nil;
    if(cp.likedByMe && cp.likedByOthers){
        [cell.likeButton setImage:[UIImage imageNamed:@"whole_love"]];
    }else if(cp.likedByMe){
        [cell.likeButton setImage:[UIImage imageNamed:@"half_love_right"]];
    }else{
        if(cp.likedByOthers){
            [cell.likeButton setImage:[UIImage imageNamed:@"half_love_left"]];
        }else{
            [cell.likeButton setImage:[UIImage imageNamed:@"not_love"]];
        }
    }
    
    if(!cp.likedByMe && cp.selfPhoto.ownerID == _ownerID){
        __weak EZCollectionPhotoCell* weakCell = cell;
        cell.likeButton.enableTouchEffects = true;
        cell.likeButton.releasedBlock = ^(id obj){
            [[EZDataUtil getInstance]likedPhoto:cp.combinedID success:^(id obj){
                cp.likedByMe = true;
                if(cp.likedByOthers){
                    [weakCell.likeButton setImage:[UIImage imageNamed:@"whole_love"]];
                }else{
                    [weakCell.likeButton setImage:[UIImage imageNamed:@"half_love_right"]];
                }
            } failure:nil];
        };

    }else if(!cp.likedByOthers && cp.otherPhoto.ownerID == _ownerID){
        __weak EZCollectionPhotoCell* weakCell = cell;
        cell.likeButton.enableTouchEffects = true;
        cell.likeButton.releasedBlock = ^(id obj){
            [[EZDataUtil getInstance]likedPhoto:cp.combinedID success:^(id obj){
                cp.likedByOthers = true;
                if(cp.likedByMe){
                    [weakCell.likeButton setImage:[UIImage imageNamed:@"whole_love"]];
                }else{
                    [weakCell.likeButton setImage:[UIImage imageNamed:@"half_love_left"]];
                }
            } failure:nil];
        };

    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EZCollectionPhotoCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    

    //static NSString *CellIdentifier = @"PhotoCell";
    EZDisplayPhoto* cp = [_combinedPhotos objectAtIndex:indexPath.row];
    cell.currentID = cp.pid;
    //EZCombinedPhoto* curPhoto = [cp.combinedPhotos objectAtIndex:cp.selectedCombinePhoto];
    EZPhoto* myPhoto = cp.photo;
    
    __weak EZCollectionPhotoCell* weakCell = cell;
    cell.container.releasedBlock = ^(id sender){
        if(cp.isFront){
            //[weakCell switchImageTo:curPhoto.otherPhoto.url];
        }else{
            //[weakCell switchImageTo:curPhoto.selfPhoto.url];
        }
        cp.isFront = !cp.isFront;
    };
    [self setLikeButton:cell combinedPhoto:curPhoto];
    if(cp.isFront){
        if(myPhoto.isLocal){
            EZDEBUG(@"Encounter local");
            [cell displayPhotoImage:[myPhoto getThumbnail]];
            [myPhoto getAsyncImage:^(UIImage* img){
                if(cell.currentID == cp.pid){
                    [cell displayPhotoImage:img];
                }else{
                    EZDEBUG(@"No more the same cell");
                }
            }];
            //[cell displayPhotoImage:[myPhoto getLocalImage]];
            
        }else{
            [cell displayPhoto:myPhoto.url];
        }
        //cell.name.text = @"我自己";
        EZPerson* owner = [[EZDataUtil getInstance] getPerson:_ownerID];
        [cell.headIcon setImageWithURL:str2url(owner.avatar) placeholderImage:PlaceHolderSmall];
    }else{
        [cell displayPhoto:myPhoto.url];
        //EZPerson* other = [[EZDataUtil getInstance] getPerson:curPhoto.otherPhoto.ownerID];
        //[cell.headIcon setImageWithURL:str2url(other.avatar) placeholderImage:PlaceHolderSmall];
    }
    cell.shareButton.releasedBlock = ^(id obj){
        EZDEBUG(@"Raise the buildin share sheet");
        NSArray *activityItems = @[[NSURL URLWithString:@"http://127.0.0.1"]];
        // Build a collection of custom activities (if you have any)
        NSMutableArray *customActivities = [[NSMutableArray alloc] init];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:customActivities];
        
        [self presentViewController:activityController animated:YES completion:nil];
    };
    cell.lastestWord.text = @"";
    [[EZDataUtil getInstance] getConversation:curPhoto.combinedID success:^(NSArray* arr){
        EZDEBUG(@"Get conversation");
        if(arr.count){
            EZConversation* convs = [arr objectAtIndex:0];
            weakCell.lastestWord.text = convs.content;
        }
        
    } failure:nil];
    cell.flippedCompleted = ^(id obj){
        EZDEBUG(@"Flip completed get called");
        if(cp.isFront){
            [weakCell displayPhoto:curPhoto.selfPhoto.url];
            //cell.name.text = @"我自己";
            EZPerson* owner = [[EZDataUtil getInstance] getPerson:_ownerID];
            [weakCell.headIcon setImageWithURL:str2url(owner.avatar) placeholderImage:PlaceHolderSmall];
        }else{
            [weakCell displayPhoto:curPhoto.otherPhoto.url];
            EZPerson* other = [[EZDataUtil getInstance] getPerson:curPhoto.otherPhoto.ownerID];
            [weakCell.headIcon setImageWithURL:str2url(other.avatar) placeholderImage:PlaceHolderSmall];
        }
    };
    
    [self setCellCorner:cell indexPath:indexPath];
    return cell;
}

- (void) setCellCorner:(EZCollectionPhotoCell*)cell indexPath:(NSIndexPath*)indexPath
{
    int rowCount =((_combinedPhotos.count%3)?1:0) + _combinedPhotos.count/3;
    int actCount = (((indexPath.row + 1)%3)?1:0) + (indexPath.row+1)/3;
    int column = (indexPath.row + 1) % 3;
    EZCornerType cornerType = kHiddenAll;
    /**
    if(indexPath.row == 0){
        cornerType = (cornerType | kLeftUp);
    }
    if(indexPath.row == 2){
        cornerType = cornerType | kRightUp;
    }
    
    if(rowCount == actCount && column==1){
        cornerType = cornerType | kLeftBottom;
    }
    
    if((indexPath.row + 1) == _combinedPhotos.count && ((indexPath.row+1) % 3)== 0){
        cornerType = cornerType | kRightBottom;
    }
     **/
    EZDEBUG(@"rowCount:%i, actCount:%i, combinedPhoto:%i, index:%i, type:%i", rowCount, actCount, _combinedPhotos.count, indexPath.row,cornerType);
    
    [cell showCorner:cornerType]; 
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(velocity.y < -1.5 && targetContentOffset->y == -64){
        //targetContentOffset->y = -224;
        //self.collectionView.contentInsect = [UI]
        [UIView animateWithDuration:0.2 animations:^(){
            self.collectionView.contentInset = UIEdgeInsetsMake(64+_container.frame.size.height, 0, 0, 0);
        }];
    }else{
        //targetContentOffset->y = -64;
        [UIView animateWithDuration:0.2 animations:^(){
            self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        }];
    }
    
    EZDEBUG(@"Velocity x: %f, y:%f, target offset: x:%f, y:%f, top size:%f", velocity.x, velocity.y, targetContentOffset->x, targetContentOffset->y, self.collectionView.contentInset.top);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    EZDEBUG(@"didScroll get called");
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _combinedPhotos.count;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    EZDEBUG(@"Should rotate to :%i", interfaceOrientation);
    return true;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//I will get view now.
//I guess, I could start load the view now


- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    EZTransitionLayout *myCustomTransitionLayout = [[EZTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    return myCustomTransitionLayout;
}


@end
