//
//  EZAlbumTablePage.m
//  Feather
//
//  Created by xietian on 13-11-13.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZAlbumTablePage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "EZPhotoCell.h"
#import "EZDisplayPhoto.h"
#import "EZThreadUtility.h"
#import "EZMessageCenter.h"
#import "EZFileUtil.h"
#import "EZClickView.h"
#import "EZTestSuites.h"
#import "EZUIUtility.h"
#import "DLCImagePickerController.h"
#import "EZDataUtil.h"
#import "SlideAnimation.h"
#import "EZNetworkUtility.h"
#import "UIImageView+AFNetworking.h"
#import "EZExtender.h"
#import "EZChatRegion.h"
#import "EZAnimationUtil.h"
#import "EZRotateAnimation.h"
#import "EZScrollController.h"
#import "EZShapeCover.h"
#import "EZSimpleClick.h"
#import "EZCenterButton.h"
#import "EZContactTablePage.h"
#import "EZShapeButton.h"
#import "EZAnimationUtil.h"
#import "EZBlurAnimator.h"
static int photoCount = 1;
@interface EZAlbumTablePage ()

@end

@implementation EZAlbumTablePage

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    EZPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    EZDisplayPhoto* cp = [_combinedPhotos objectAtIndex:indexPath.row];
    cell.backgroundColor = VinesGray;
    
    //This is for later update purpose. great, let's get whole thing up and run.
    cell.currentPos = indexPath.row;
    //EZCombinedPhoto* curPhoto = [cp.combinedPhotos objectAtIndex:cp.selectedCombinePhoto];
    EZPhoto* myPhoto = cp.photo;
    EZPhoto* switchPhoto = [cp.photo.photoRelations objectAtIndex:0];
    
    EZPerson* frontPerson = pid2person(myPhoto.personID);
    EZPerson* backPerson = pid2person(switchPhoto.personID);
    EZDEBUG(@"myPhoto image size:%@, screenURL:%@, isFront:%i,upload status:%i", NSStringFromCGSize(myPhoto.size), myPhoto.screenURL, cp.isFront, cp.photo.uploadStatus);
    // Configure the cell...
    //[cell displayImage:[myPhoto getLocalImage]];
    [[cell viewWithTag:animateCoverViewTag] removeFromSuperview];
    EZDEBUG(@"Will display front image");
    if(cp.isFront){
        [self loadFrontImage:cell photo:myPhoto file:myPhoto.assetURL];
        preloadimage(switchPhoto.screenURL);
    }else{
        [self loadImage:cell url:switchPhoto.screenURL];
    }
    
    
    EZDEBUG(@"upload status is:%i, photo relation count:%i, object Pointer:%i", myPhoto.uploadStatus, myPhoto.photoRelations.count, (int)myPhoto);
    if(myPhoto.uploadStatus == kUploadInit){
        EZDEBUG(@"Will register upload success");
        myPhoto.uploadSuccess = ^(id obj){
            EZDEBUG(@"upload success, photoRelation:%i", );
            
            
        };
        
    }
    __weak EZAlbumTablePage* weakSelf = self;
    __weak EZPhotoCell* weakCell = cell;
    //__block NSString* staticFile = nil;
    cell.frontImage.tappedBlock = ^(id obj){
        //NSArray* stored = [[EZDataUtil getInstance] readStoredPhotos];
        //EZDEBUG(@"Stored photo is:%i", stored.count);
        //for(EZPhoto* pt in stored){
        //    EZDEBUG(@"id:%@, url:%@, created:%@", pt.photoID, pt.screenURL, pt.createdTime);
        //}
        
        //EZPhoto* myPhoto = [[EZPhoto alloc] init];
        //myPhoto.photoID = @"any";
        //myPhoto.createdTime = [NSDate date];
        //myPhoto.screenURL = @"cool";
        //[[EZDataUtil getInstance] storeAllPhotos:@[myPhoto]];
        //if(switchPhoto){
        EZPhoto* swPhoto = [myPhoto.photoRelations objectAtIndex:0];
        if(swPhoto){
            [weakSelf switchImage:weakCell displayPhoto:cp front:myPhoto back:swPhoto animate:YES];
        }
        //}
    };
    
    __block BOOL longPressed = false;
    cell.frontImage.longPressed = ^(id obj){
        if(longPressed){
            EZDEBUG(@"Quit for pressed");
            return;
        }
        longPressed = TRUE;
        EZClickImage* fullView = [[EZClickImage alloc] initWithFrame:[UIScreen mainScreen].bounds];
        fullView.contentMode = UIViewContentModeScaleAspectFill;
        fullView.image = weakCell.frontImage.image;
        fullView.enableTouchEffects = NO;
        EZDEBUG(@"Long press called %@", NSStringFromCGRect(fullView.bounds));
        //EZScrollController* sc = [[EZScrollController alloc] initWithDetail:fullView];
        //sc.transitioningDelegate = self.detailAnimation;
        //[self.navigationController presentViewController:sc animated:YES completion:nil];
        //fullView.pressedBlock = ^(id obj){
        //    EZDEBUG(@"presssed");
        //    [sc dismissViewControllerAnimated:YES completion:nil];
        //};
        fullView.alpha = 0;
        macroHideStatusBar(YES);
        [TopView addSubview:fullView];
        [UIView animateWithDuration:0.3 animations:^(){
            fullView.alpha = 1.0;
        }];
        __weak EZClickImage* weakFull = fullView;
        fullView.releasedBlock = ^(UIView* obj){
            EZDEBUG(@"dismiss current view");
            longPressed = false;
            //[obj dismissViewControllerAnimated:YES completion:nil];
            [UIView animateWithDuration:0.3 animations:^(){
                weakFull.alpha = 0;
            } completion:^(BOOL completed){
                EZDEBUG(@"remove fullView:%i",(int)weakFull);
                [weakFull removeFromSuperview];
                macroHideStatusBar(YES);
                CGFloat offsetY = indexPath.row * CurrentScreenHeight;
                //CGPoint offset = weakSelf.tableView.contentOffset;
                weakSelf.tableView.contentOffset = CGPointMake(0, offsetY);
            }];
            //[EZDataUtil getInstance].centerButton.alpha = 1.0;
            
        };
        //[EZDataUtil getInstance].centerButton.alpha = 0.0;
        
        
    };
    EZPerson* person = nil;
    if(cp.isFront){
        person = pid2person(cp.photo.personID);
        EZDEBUG(@"I will display front image: person id:%@, name:%@", cp.photo.personID, person.name);
        [self setChatInfo:cell displayPhoto:cp.photo person:person];
    }else{
        EZPhoto* otherSide = nil;
        if(cp.photo.photoRelations.count){
            otherSide = [cp.photo.photoRelations objectAtIndex:0];
        }
        person = [[EZDataUtil getInstance] getPersonByID:otherSide.personID success:nil];
        [self setChatInfo:cell displayPhoto:otherSide person:person];
    }
    
    cell.moreButton.releasedBlock = ^(id obj){
        //NSString* someText = self.textView.text;
        EZDEBUG(@"more clicked");
        NSArray* dataToShare = @[@"我爱老哈哈"];  // ...or whatever pieces of data you want to share.
        UIActivityViewController* activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                          applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:^{
            EZDEBUG(@"Completed sharing");
        }];
    };
    cell.authorName.text = frontPerson.name;
    cell.otherName.text = backPerson.name;
    [cell.headIcon setImageWithURL:str2url(frontPerson.avatar)];
    [cell.otherIcon setImageWithURL:str2url(backPerson.avatar)];
    //dispatch_later(0.3, ^(){
    //    if(indexPath.row == 0){
    //        CGFloat offsetY = indexPath.row * CurrentScreenHeight;
    //CGPoint offset = weakSelf.tableView.contentOffset;
    //       weakSelf.tableView.contentOffset = CGPointMake(0, offsetY);
    //   }
    //});
    return cell;
}



-(id)initWithQueryBlock:(EZQueryBlock)queryBlock
{
    self = [super initWithStyle:UITableViewStylePlain];
    self.title = @"羽毛";
    _queryBlock = queryBlock;
    //self.edgesForExtendedLayout=UIRectEdgeNone;
    [self createMoreButton];
    [self.tableView registerClass:[EZPhotoCell class] forCellReuseIdentifier:@"PhotoCell"];
    return self;
}

/**
- (UIStatusBarStyle)preferredStatusBarStyle
{
    EZDEBUG(@"preferred style");
    return UIStatusBarStyleLightContent;
}
**/

- (void) addPhoto:(EZDisplayPhoto*)photo
{
    [_combinedPhotos insertObject:photo atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]withRowAnimation:UITableViewRowAnimationFade];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void) setCurrentUser:(EZPerson *)currentUser
{
    EZDEBUG(@"Will change the user from:%@ to %@", _currentUser, currentUser);
    
    if([currentUser.personID isEqualToString:currentLoginID]){
        if(_currentUser){
            _currentUser = nil;
            self.title = @"羽毛";
            [_combinedPhotos removeAllObjects];
        }else{
            return;
        }
    }else if(![currentUser.personID isEqualToString:_currentUser.personID]){
        self.title = currentUser.name;
        _currentUser = currentUser;
        [_combinedPhotos removeAllObjects];
    }else{
        return;
    }
    [self loadMorePhoto:^(id obj){
        if(!_combinedPhotos.count){
            [self.tableView reloadData];
        }
    } reload:YES];

}


- (void) downloadCache
{
    NSString* imageURL = @"http://www.enjoyxue.com:8080/static/531c871521ae7a4796b65b39/bf354b7d788345b2794985b576fcea5b.jpg";
    NSString* url = [[EZDataUtil getInstance] preloadImage:imageURL success:^(id success){
        EZDEBUG(@"successfully downloaded:%@", success);
        NSString* secURL = [[EZDataUtil getInstance] preloadImage:imageURL success:nil failed:nil];
        EZDEBUG(@"Should return immediately:%@", secURL);
        
        dispatch_later(0.5, ^(){
            UIImageView* imageShow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 100, 100)];
            imageShow.backgroundColor = [UIColor redColor];
            //[imageShow setImageURL:str2url(secURL)];
            [imageShow setImageWithURL:str2url(secURL)];
            [TopView addSubview:imageShow];
        });
    } failed:^(NSError* err){
        EZDEBUG(@"failed to download:%@", err);
    }];
    
    url = [[EZDataUtil getInstance] preloadImage:imageURL success:^(id success){
        EZDEBUG(@"second successfully downloaded:%@", success);
    } failed:^(NSError* err){
        EZDEBUG(@"second failed to download:%@", err);
    }];
    
    EZDEBUG(@"Immdiatedly returned image:%@", url);
}

- (void) storeCurrent
{
    if(_currentUser == nil){
        EZDEBUG(@"Will store current user");
        NSMutableArray* res = [[NSMutableArray alloc] init];
        for(EZDisplayPhoto* dp in _combinedPhotos){
            [res addObject:dp.photo];
        }
        [[EZDataUtil getInstance] storeAllPhotos:res];
    }
}

- (void) loadMorePhoto:(EZEventBlock)completed reload:(BOOL)reload
{
    int pageStart = _combinedPhotos.count/photoPageSize;
    EZDEBUG(@"Will load from %i", pageStart);
    [[EZDataUtil getInstance] queryPhotos:pageStart pageSize:photoPageSize otherID:_currentUser.personID success:^(NSArray* arr){
        //EZDEBUG(@"Reloaded about %i rows of data, inset:%@", arr.count, NSStringFromUIEdgeInsets(self.tableView.contentInset));
        [self reloadRows:arr reload:reload];
        if(completed){
            completed(@(arr.count));
        }
        //[self.refreshControl endRefreshing];
    } failure:^(id err){
        //animBlock();
        EZDEBUG(@"Error query photo from:%i", pageStart);
        //[self.refreshControl endRefreshing];
        if(completed){
            completed(nil);
        }
    }];

}

- (UIView*) createSeperate:(CGRect)orgBound
{
    UIView* seperate = [[UIView alloc] initWithFrame:CGRectMake(orgBound.origin.x, orgBound.size.height - 2, orgBound.size.width, 2)];
    seperate.backgroundColor = [UIColor whiteColor];
    UIView* darker = [[UIView alloc] initWithFrame:CGRectMake(0, 1, orgBound.size.width, 1)];
    darker.backgroundColor = RGBCOLOR(227, 227, 227);
    [seperate addSubview:darker];
    return  seperate;
}

- (IBAction) moreClicked:(id)sender
{
    EZDEBUG(@"More button clicked");
    
}

- (void) createMoreButton
{
    _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 0, 100, 44)];
    _moreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    //_moreButton.titleLabel.textColor = RGBCOLOR(48, 48, 48);
    [_moreButton setTitle:@"更多" forState:UIControlStateNormal];
    _moreButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_moreButton setTitleColor:RGBCOLOR(48, 48, 48) forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    
}

//This method may not get called
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[[UINavigationBar appearance] setBackgroundImage:ClearBarImage forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.view addSubview:[EZDataUtil getInstance].naviBarBlur];
    EZDEBUG(@"initial content inset:%@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    //[_moreButton removeFromSuperview];
    //[[EZDataUtil getInstance].barBackground removeFromSuperview];
    //_menuView.height = 0;
}

- (void) viewDidDisappear:(BOOL)animated
{
    //[EZDataUtil getInstance].centerButton.hidden = YES;
}




- (UIView*) createMenuView:(NSArray*)menuNames
{
    CGFloat itemHight = 40;
    LFGlassView* res = [[LFGlassView alloc] initWithFrame:CGRectMake(10, 60, 100, itemHight * menuNames.count)];
    res.userInteractionEnabled = true;
    //res.backgroundColor = RGBA(230, 230, 230, 100);
    res.backgroundColor = BlurBackground;
    res.clipsToBounds = YES;
    res.layer.cornerRadius = 5;
    res.backgroundColor = [UIColor whiteColor];//RGBA(255, 100, 100, 128);
    for(int i = 0; i < menuNames.count; i ++){
        NSDictionary* menuItem = [menuNames objectAtIndex:i];
        EZClickView* clickView = [[EZClickView alloc] initWithFrame:CGRectMake(0, 40*i, 100, 40)];
        clickView.backgroundColor = [UIColor clearColor];
        [clickView addSubview:[self createSeperate:clickView.frame]];
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 38)];
        title.text = [menuItem objectForKey:@"text"];
        title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        title.textAlignment = NSTextAlignmentCenter;
        [clickView addSubview:title];
        EZEventBlock clickedBlock = [menuItem objectForKey:@"block"];
        clickView.releasedBlock = clickedBlock;
        [res addSubview:clickView];
    }
    return res;
}


- (void) mockMenu
{
    int tag = 20140129;
    if(!_menuView){
        _menuView = [self createMenuView:EZUIUtility.sharedEZUIUtility.showMenuItems];
        //_menuView.clipsToBounds = true;
        _menuHeight = _menuView.frame.size.height;
        [TopView addSubview:_menuView];
        _menuView.height = 0;
        
    }
    
    
    if(_menuView.height > 10){
        [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
            _menuView.height = 0;
            
        } completion:nil];
    }else{
        [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
            _menuView.height = _menuHeight;
        } completion:nil];
        
    }
}

- (void) showMenu:(id)sender
{
    //if(_menuClicked){
    //    _menuClicked(Nil);
    //}
    _isPushCamera = false;
    EZContactTablePage* contactPage = [[EZContactTablePage alloc] init];
    [self.navigationController pushViewController:contactPage animated:YES];
}

- (void)imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    EZDEBUG(@"Store image get called:%i", _newlyCreated);
    ++_newlyCreated;
}

//Will animate the newly create image to flip to another side
- (void) animateFlip
{
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    EZDEBUG(@"I will start flip the image:%i", _newlyCreated);
    for(int i = _combinedPhotos.count - 1; i >= _combinedPhotos.count - _newlyCreated; i--){
        NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:0];
        EZPhotoCell* cell = (EZPhotoCell*)[self.tableView cellForRowAtIndexPath:path];
        if(!cell){
            continue;
        }
        EZDisplayPhoto* cp = [_combinedPhotos objectAtIndex:i];
        if(cell.currentPos != path.row){
            EZDEBUG(@"Turn while cell no more this row:%i, %i", cell.currentPos, path.row);
            return;
        }
        if(!cp.isFront){
            EZDEBUG(@"flipped manually");
            continue;
        }
        EZPhoto* switchPhoto = [cp.photo.photoRelations objectAtIndex:0];
        //cp.isFront = !cp.isFront;
        EZDEBUG(@"prefetchDone:%i", switchPhoto.prefetchDone);
        
        [[EZDataUtil getInstance] prefetchImage:switchPhoto.screenURL success:^(UIImage* img){
            //[self switchAnimation:cp photoCell:cell indexPath:path tableView:self.tableView];
            [self switchImage:cell displayPhoto:cp front:cp.photo back:switchPhoto animate:NO];
        } failure:nil];
    }
    EZDEBUG(@"animFlip is done");
}

- (void) scrollToBottom:(BOOL)animated
{
    EZDEBUG(@"Scroll to bottom");
    if(!_combinedPhotos.count){
        return;
    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_combinedPhotos.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)imagePickerControllerDidCancel:(DLCImagePickerController *)picker imageCount:(int)imageCount
{
    EZDEBUG(@"cancel get called:%i", _newlyCreated);
    if(imageCount){
        dispatch_later(0.1, ^(){
            [self scrollToBottom:NO];
            //dispatch_later(0.1, ^(){
            //[self animateFlip];
            //});

        });
    }
}

- (void) raiseCamera
{
    if([EZUIUtility sharedEZUIUtility].cameraRaised || [EZUIUtility sharedEZUIUtility].stopRotationRaise){
        return;
    }
    _newlyCreated = 0;
    
    //if(_picker == nil){
    DLCImagePickerController* camera = [[DLCImagePickerController alloc] init];
    //}
    //controller.prefersStatusBarHidden = TRUE;
    //camera.transitioningDelegate = _cameraAnimation;
    camera.delegate = self;
    camera.personID = _currentUser.personID;
    //if(camera.isFrontCamera){
    //    [camera switchCamera];
    //}
    _isPushCamera = YES;
    EZDEBUG(@"before present");
    //[self presentViewController:camera animated:TRUE completion:^(){
    //    EZDEBUG(@"Presentation completed");
    //}];
    [self.navigationController pushViewController:camera animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"button clicked:%i", buttonIndex);
    if(buttonIndex == 0){
        //_picker = [[DLCImagePickerController alloc] initWithFront:YES];
        _picker.frontFacing = true;
        _picker.shotMode = kSelfShotMode;
        [self raiseCamera];
    }else if(buttonIndex == 1){
        _picker.frontFacing = false;
        //_picker = [[DLCImagePickerController alloc] initWithFront:NO];
        [self raiseCamera];
    }
    _picker = nil;
}

- (void) pickPhotoType:(id)sender
{
    //UIActionSheet* photoSheet = [[UIActionSheet alloc] initWithTitle:@"拍摄类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"自拍", @"拍摄", nil];
    //[photoSheet showInView:self.view];
    //_picker = [[DLCImagePickerController alloc] init];
    [self raiseCamera];
}

- (void) endRefresh:(int)count
{
    EZDEBUG(@"End refresh get called: %f", self.tableView.contentOffset.y);
    --count;
    if(count < 0){
        count = 0;
    }
    [UIView animateWithDuration:0.3 animations:^(){
        //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        //if(self.tableView.contentOffset.y == -64){
        self.tableView.contentOffset = CGPointMake(0, count * CurrentScreenHeight);
        //}
    } completion:^(BOOL finished) {
        [self.refreshControl endRefreshing];
        //[self.refreshControl endRefreshing];
        //dispatch_later(0.3, ^(){
        //    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        //});
    }];
    
    
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    // Refresh table here...
    //[_allEntries removeAllObjects];
    //[self.tableView reloadData];
    //[self refresh];
    EZDEBUG(@"refresh content inset:%@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
    [self loadMorePhoto:^(NSNumber* obj){
        [self endRefresh:obj.intValue];
    }reload:NO];
    //[self.refreshControl endRefreshing];

}



- (void) testTextInput
{
    EZChatRegion* chatRegion = [[EZChatRegion alloc] initWithFrame:CGRectMake(0, 200, 300, 200)];
    chatRegion.ownerID = @"2231";
    EZPerson* otherPerson = [[EZPerson alloc] init];
    EZPerson* currentPs = [[EZPerson alloc] init];
    currentPs.personID = @"2231";
    otherPerson.personID = @"1123";
    chatRegion.conversations = @[
                                 @{
                                     @"text":@"这是一段从来没有人经历过的旅程，很多时候我们都认为自己是神经病，其实我们是网络节点",
                                     @"person":otherPerson
                                     
                                     },
                                 @{
                                     @"text":@"这是一段从来没有人经历过的旅程",
                                     @"person":currentPs
                                     
                                     },
                                 @{
                                     @"text":@"这是一段从来没有人经历过的旅程",
                                     @"person":currentPs
                                     
                                     }
                                 
                                 ];
    chatRegion.otherClicked = ^(id obj){
        EZDEBUG(@"Other clicked");
    };
    chatRegion.ownerClicked = ^(id obj){
        EZDEBUG(@"Owner clicked");
    };
    chatRegion.chatCompleted = ^(NSString* text){
        EZDEBUG(@"Chat text:%@", text);
        [chatRegion insertChat:@{
                                 @"text":text,
                                 @"person":otherPerson
                                 }];
        
    };
    chatRegion.backgroundColor = RGBCOLOR(220, 220, 220);
    [chatRegion render];
    [self.tableView addSubview:chatRegion];
}

- (NSArray*) wrapPhotos:(NSArray*)photos
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(EZPhoto* pt in photos){
        [res insertObject:[self wrapPhoto:pt] atIndex:0];
    }
    return res;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _combinedPhotos = [[NSMutableArray alloc] init];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:)forControlEvents:UIControlEventValueChanged];
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    //self.tableView.y = - 20;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.pagingEnabled = YES;
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    //self.tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    EZDEBUG(@"Before change:%i", self.edgesForExtendedLayout);
    //self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.backgroundColor = VinesGray;
    //self.tableView.backgroundColor = VinesGray; //[UIColor blackColor];
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"featherPage"]];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    __weak EZAlbumTablePage* weakSelf = self;
    //[self.tableView addSubview:[EZTestSuites testResizeMasks]];
    _slideAnimation = [[SlideAnimation alloc] init];
    _raiseAnimation = [[EZRaiseAnimation alloc] init];
    _cameraAnimation = [[EZModalRaiseAnimation alloc] init];
    
    _detailAnimation = [[EZModalDissolveAnimation alloc] init];
    _cameraNaviAnim = [[EZCameraNaviAnimation alloc] init];
    EZDEBUG(@"Query block is:%i",(int)_queryBlock);

    [[EZMessageCenter getInstance] registerEvent:EZTakePicture block:^(EZDisplayPhoto* dp){
        EZDEBUG(@"A photo get generated");
        [_combinedPhotos addObject:dp];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        //[self.tableView a]
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZAlbumImageReaded block:^(EZDisplayPhoto* dp){
        EZDEBUG(@"Recieved a image from album");
        [_combinedPhotos addObject:dp];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZSetAlbumUser block:^(EZPerson* person){
        [self setCurrentUser:person];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZTriggerCamera block:^(id obj){
        //[weakSelf raiseCamera];
    }];
    
    
    EZDEBUG(@"The login personID:%@, getID:%@", [EZDataUtil getInstance].currentPersonID, [[EZDataUtil getInstance] getCurrentPersonID]);
    
    [_combinedPhotos addObjectsFromArray:[self wrapPhotos:[[EZDataUtil getInstance] getStoredPhotos]]];
    EZDEBUG(@"The stored photo is %i", _combinedPhotos.count);
    [[EZDataUtil getInstance] queryPhotos:_combinedPhotos.count pageSize:photoPageSize otherID:_currentUser.personID success:^(NSArray* arr){
        EZDEBUG(@"returned length:%i", arr.count);
        //[_combinedPhotos addObjectsFromArray:arr];
        [self reloadRows:arr reload:NO];
        dispatch_later(0.1,
         ^(){
             [self scrollToBottom:YES];
        });
    } failure:^(NSError* err){
        EZDEBUG(@"Error detail:%@", err);
    }];
    
    
    dispatch_later(0.3, ^(){
        [self scrollToBottom:YES];
    });
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"通讯录" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
    _progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 64, 300, 10)];
    _progressBar.progressViewStyle = UIProgressViewStyleDefault;
    _progressBar.progressTintColor = [UIColor whiteColor];
    _progressBar.trackTintColor = [UIColor clearColor];
    
    //UIBarButtonItem* barItem = [[UIBarButtonItem alloc] initWithTitle:@"通讯录" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
    
    //UIButton* commButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 120, 44)];
    //[commButton setTitle:@"通讯录" forState:UIControlStateNormal];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pickPhotoType:)];
    //dispatch_later(0.2, ^(){
        //[self raiseRegister];
        
   
    //});
    
    [EZDataUtil getInstance].timerBlock = ^(id obj){
        [self storeCurrent];
    };

}

- (void) switchFriend:(EZPerson*)person
{
    self.title = person.name;
    EZDEBUG(@"Suppose to switch friend:%@", person.name);
    if([currentLoginUser.mobile isEqualToString:null2Empty(person.mobile)]){
        
    }
    //NSString* personID = currentLoginID;
    //if([person.personID isEqualToString:currentLoginID]){
        
    //}
}

- (void) raiseRegister
{
    EZDEBUG(@"trigger register");
    [[EZDataUtil getInstance] triggerLogin:^(EZPerson* ps){
        EZDEBUG(@"person id:%@, name:%@", ps.personID, ps.name);
    } failure:^(NSError* err){
        EZDEBUG(@"error:%@", err);
    } reason:@"试一试" isLogin:false];
}


- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    EZDEBUG(@"Key path get called %@, object type:%@", keyPath, object);
    if ([keyPath isEqual:@"uploaded"]) {
        NSNumber* changedName = [change objectForKey:NSKeyValueChangeNewKey];
        EZDEBUG(@"changed value:%i", changedName.intValue);
        //do something with the changedName - call a method or update the UI here
        //self.nameLabel.text = changedName;
    }
}

- (BOOL) existed:(NSString*)pid
{
    for(int i = 0; i < _combinedPhotos.count; i ++){
        EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:i];
        if([dp.photo.photoID isEqualToString:pid]){
            return true;
        }
    }
    return false;
}

- (EZDisplayPhoto*) wrapPhoto:(EZPhoto*)photo
{
    EZDisplayPhoto* ed = [[EZDisplayPhoto alloc] init];
    ed.isFront = true;
    ed.photo = photo;
    photo.isLocal = true;
    return ed;
}

- (void) reloadRows:(NSArray*)photos reload:(BOOL)reload
{
    int count = 0;
    for(EZPhoto* pt in photos){
        if(! [self existed:pt.photoID]){
            count ++;
             EZDEBUG(@"Transfer the image to EZDisplayPhoto successfully, personID:%@",pt.personID);
            [_combinedPhotos insertObject:[self wrapPhoto:pt] atIndex:0];
        }
    }
    if(count && !reload){
        NSMutableArray* updatePaths = [[NSMutableArray alloc] init];
        for(int i = 0; i < count; i++){
            [updatePaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
           
        }
        [self.tableView insertRowsAtIndexPaths:updatePaths withRowAnimation:UITableViewRowAnimationTop];
        //if(updatePaths.count){
        //    [self.tableView insertRowsAtIndexPaths:updatePaths withRowAnimation:UITableViewRowAnimationTop];
        //}
    }else if(photos.count && reload){
        [self.tableView reloadData];
    }
}

//Pull and refresh will help to check if we have more photo to match.
//This really make sense
//Refresh to get more

/**
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!_isFirstCompleted){
        _isFirstCompleted = TRUE;
        return;
    }
        
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height + 40)
    {
        EZDEBUG(@"Will raise camera");
        //[self raiseCamera];
    }
}
**/
- (void) loadingView
{
    EZDEBUG(@"I will load more data");
    _isLoadingMoreData = true;
    UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //[activity startAnimating];
    [activity setPosition:CGPointMake((320.0 - activity.width)/2.0, self.tableView.contentSize.height)];
    [self.tableView addSubview:activity];
    [activity startAnimating];
    //UIEdgeInsets oldInset = self.tableView.contentInset;
    [UIView animateWithDuration:0.2 animations:^(){
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    }];
    EZOperationBlock animBlock = ^(){
        [UIView animateWithDuration:0.3 animations:^(){
            self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        } completion:^(BOOL completed){
            [activity removeFromSuperview];
        }];
        _isLoadingMoreData = false;
    };
    animBlock();
    // proceed with the loading of more data
}

- (void) viewDidAppear:(BOOL)animated
{
    EZDEBUG(@"View did show");
    [super viewDidAppear:animated];
    [EZDataUtil getInstance].centerButton.hidden = NO;
    if(_notFirstTime){
        return;
    }
    _notFirstTime = true;
    [self setupUI];

}

/**
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int pos = self.tableView.contentOffset.y / CurrentScreenHeight;
    if(pos < _combinedPhotos.count){
        EZPhoto* photo = [_combinedPhotos objectAtIndex:pos];
        EZDEBUG(@"Photo status:%i", photo.uploadStatus);
    }
}
**/
- (void) setupUI
{
    self.navigationController.delegate = self;
    EZUIUtility.sharedEZUIUtility.cameraClickButton.pressedBlock = _cameraClicked;
    __weak EZAlbumTablePage* weakSelf = self;
    if(_alreadyExecuted){
        return;
    }
    _alreadyExecuted = true;
    [self.refreshControl setPosition:CGPointMake(230, 25)];
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    EZCenterButton* clickView = [[EZCenterButton alloc] initWithFrame:CGRectMake((CurrentScreenWidth - EZCenterSmallRadius)/2.0, bounds.size.height - EZCenterSmallRadius - 6.0, EZCenterSmallRadius, EZCenterSmallRadius) cycleRadius:EZOuterCycleRadius lineWidth:3];
    
    clickView.enableTouchEffects = false;
    clickView.releasedBlock = ^(EZCenterButton* obj){
        [obj animateButton:0.5 lineWidth:13 completed:^(id obj){
            //EZDEBUG(@"Before raise camera, %i", (int)self);
            [self raiseCamera];
            //EZDEBUG(@"The button clicked");
        }];
    };
    clickView.longPressBlock = ^(EZCenterButton* obj){
        EZDEBUG(@"Long press clicked");
        [[EZDataUtil getInstance] jumpCycleAnimation:^(id obj){
            EZContactTablePage* contactPage = [[EZContactTablePage alloc] init];
            //contactPage.transitioningDelegate =
            _isPushCamera = false;
            [self.navigationController pushViewController:contactPage animated:YES];
            contactPage.completedBlock = ^(id obj){
                [weakSelf switchFriend:obj];
            };
        }];
    };
    clickView.center = CGPointMake(160, bounds.size.height - (30 + 5));
    [TopView addSubview:clickView];
    //EZDEBUG(@"View will Appear:%@", NSStringFromCGRect(TopView.frame));
    UIView* statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBarBackground.backgroundColor = EZStatusBarBackgroundColor;
    //[TopView addSubview:statusBarBackground];
    [EZDataUtil getInstance].barBackground = statusBarBackground;
    [EZDataUtil getInstance].centerButton = clickView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /**
    EZDisplayPhoto* cp = [_combinedPhotos objectAtIndex:indexPath.row];
    CGFloat imageHeight;
    if(cp.turningAnimation){
        imageHeight = cp.turningImageSize.height;
    }else{
    
    if(cp.isFront){
        imageHeight = floorf((cp.photo.size.height/cp.photo.size.width) * ContainerWidth);
        //EZDEBUG(@"The row height is:%f, width:%f, %f", imageHeight, cp.photo.size.width, cp.photo.size.height);
    }else{
        EZPhoto* matchPhoto = [cp.photo.photoRelations objectAtIndex:0];
        CGSize imgSize = matchPhoto.size;
        imageHeight =  floorf((imgSize.height/imgSize.width) * ContainerWidth);
        //EZDEBUG(@"Column count is:%f, width:%f, %f", imageHeight, cp.photo.size.width, cp.photo.size.height);
    }
    }
    **/
    
    return CurrentScreenHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _combinedPhotos.count;
    //return 0;
}

- (void) testRegister:(EZPhoto*)photo
{
    [[EZDataUtil getInstance] registerUser:@{
                                             @"name":@"cool",
                                             @"email":@"unix@gmail.com",
                                             @"mobile":@"15216727142",
                                             @"password":@"i love you"
                                             } success:^(EZPerson* person){
                                                 EZDEBUG(@"successfully registred:%@, sessionID:%@", person.personID, [EZDataUtil getInstance].currentPersonID);
                                                 [[EZDataUtil getInstance] uploadPhoto:photo success:^(EZPhoto* obj){
                                                     EZDEBUG(@"Uploaded photoID success:%@", obj.photoID);
                                                 } failure:^(id err){
                                                     EZDEBUG(@"upload photo error:%@", err);
                                                 }];
                                             } error:^(NSError* err){
                                                 EZDEBUG(@"Register error:%@", err);
                                             }];

}


- (void) uploadAllContacts
{
    [[EZDataUtil getInstance] uploadContacts:[EZDataUtil getInstance].contacts success:^(NSArray* filled){
        EZDEBUG(@"Success uploaded the contacts:%i", filled.count);
        for(int i = 0; i < filled.count; i++){
            NSDictionary* dict = [filled objectAtIndex:i];
            EZPerson* ep = [[EZDataUtil getInstance].contacts objectAtIndex:i];
            EZDEBUG(@"mobile:%@, returned:%@, id:%@", [dict objectForKey:@"mobile"], ep.mobile, [dict objectForKey:@"personID"]);
            
            [ep fromJson:dict];
        }
    } failure:^(NSError* err){
        EZDEBUG(@"Error:%@", err);
    }];

}


/**
- (void) uploadAndExchange:(EZPhoto*)photo sucess:(EZEventBlock)block failed:(EZEventBlock)failed
{
    EZDEBUG(@"Uploaded for photoID:%@, uploaded:%i", photo.photoID, photo.uploaded);
    if(!photo.uploaded){
        [[EZDataUtil getInstance] uploadPhoto:photo success:^(EZPhoto* obj){
            EZDEBUG(@"Uploaded photoID success:%@", obj.photoID);
        } failure:^(id failed){
            EZDEBUG(@"Photo upload failed, will try it again later");
        }];
    }
    [[EZDataUtil getInstance] exchangeWithperson:nil success:^(EZPhoto* pt){
        block(pt);
    } failure:failed];

}
**/

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
        EZDEBUG(@"indexPath no more visible:%i", indexPath.row);
        EZPhotoCell* pc  = (EZPhotoCell*)[tableView cellForRowAtIndexPath:indexPath];
        EZDEBUG(@"before release image size:%@", NSStringFromCGSize(pc.frontImage.image.size));
        pc.frontImage.image = nil;
        
    }
}

- (void) customeFlip:(CGFloat)duration srcView:(UIView*)srcView destView:(UIView*)destView completed:(EZOperationBlock)completed
{
    CGFloat halfTime = duration/2.0;
    CATransform3D rotationAndPerspective = CATransform3DIdentity;
    rotationAndPerspective.m34 = 1.0 / 3000.0;
    CATransform3D trans = CATransform3DRotate(rotationAndPerspective, -M_PI/2.0, 0.0, 1.0, 0.0);
    CATransform3D halfTrans = CATransform3DRotate(rotationAndPerspective, M_PI/2.0, 0.0, 1.0, 0.0);
    CATransform3D identity = CATransform3DIdentity;
    destView.layer.transform = trans;
    [UIView animateWithDuration:halfTime animations:^(){
        srcView.layer.transform = halfTrans;
    } completion:^(BOOL compl){
        [UIView animateWithDuration:halfTime delay:0.0 options:UIViewAnimationOptionCurveEaseOut  animations:^(){
            destView.layer.transform = identity;
        } completion:^(BOOL compl){
            completed();
        }];
    }];
}

//Make sure to understand the different index.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"Altert clicked:%i", buttonIndex);
    if(_alertClicked){
        _alertClicked(@(buttonIndex));
    }
    _alertClicked = nil;
}


- (void) loadFrontImage:(EZPhotoCell*)weakCell photo:(EZPhoto*)photo file:(NSString*)assetURL
{
    if([EZFileUtil isFileExist:assetURL isURL:NO]){
        EZDEBUG("File exist");
        [weakCell.frontImage setImage:[photo getScreenImage]];
    }else{
        EZDEBUG(@"file not exist load from url:%@", photo.screenURL);
        [self loadImage:weakCell url:photo.screenURL];
    }
}

- (void) loadImage:(EZPhotoCell*)weakCell  url:(NSString*)secondURL
{
    //NSString* secondURL = @"http://192.168.1.102:8080/static/5666df6256e9504dd8b5f6a4b21edbac.jpg";
    UIActivityIndicatorView* ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    ai.center = weakCell.frontImage.center;
    __block BOOL loaded = false;
    
    [[EZDataUtil getInstance] serialLoad:secondURL fullOk:^(NSString* localURL){
        EZDEBUG(@"image loaded full:%i, url:%@", loaded, localURL);
        if(!loaded){
            loaded = true;
            [ai stopAnimating];
            [ai removeFromSuperview];
            //[weakCell.frontImage setImageWithURL:str2url(fullURL)];
            weakCell.frontImage.image = fileurl2image(localURL);
        }else{
            UIView* snapShot = [weakCell.frontImage snapshotViewAfterScreenUpdates:NO];
            [weakCell.frontImage addSubview:snapShot];
            //[weakCell setImageWithURL:str2url(localURL)];
            weakCell.frontImage.image = fileurl2image(localURL);
            [UIView animateWithDuration:0.3 animations:^(){
                snapShot.alpha = 0;
            } completion:^(BOOL completed){
                [snapShot removeFromSuperview];
            }];
        }
    } thumbOk:^(NSString* localURL){
        EZDEBUG(@"image loaded blur:%i, url:%@", loaded, localURL);
        if(!loaded){
            loaded = true;
            [ai stopAnimating];
            [ai removeFromSuperview];
            UIImage* blurred = [fileurl2image(localURL) createBlurImage:70.0];
            weakCell.frontImage.image = blurred;
        }
    } pending:^(id obj){
        [weakCell.frontImage addSubview:ai];
        [ai startAnimating];
    } failure:^(id err){
        EZDEBUG(@"failure get called");
        EZDEBUG(@"err:%@", err);
        [ai stopAnimating];
        [ai removeFromSuperview];
    }];
}


- (void) setChatInfo:(EZPhotoCell*)cell displayPhoto:(EZPhoto*)photo person:(EZPerson*)person
{
    if(photo.conversations.count == 0){
        cell.chatUnit.hidden = YES;
    }else{
        cell.chatUnit.hidden = NO;
    }
    
    [cell.chatUnit.authorIcon setImageWithURL:str2url(person.avatar)];
    cell.chatUnit.authorIcon.releasedBlock = ^(id obj){
        EZDEBUG(@"The author id is:%@", person.personID);
    };
    if(photo.conversations.count > 0){
        NSDictionary* conversation = [photo.conversations objectAtIndex:0];
        NSDate* dt =(NSDate*) [conversation objectForKey:@"date"];
        NSString* comment = [conversation objectForKey:@"text"];
        EZDEBUG(@"converation %@:%@", dt, comment);
        //cell.chatUnit.textDate = [conversation objectForKey:@"date"];
        [cell.chatUnit setTimeStr:formatRelativeTime(dt)];
        [cell.chatUnit setChatStr:comment name:person.name];
    }else{
        [cell.chatUnit setTimeStr:@""];
        [cell.chatUnit setChatStr:@"" name:person.name];
    }
}


- (void) presentNaiveView:(EZPhotoCell*)weakCell
{
    EZClickImage* fullView = [[EZClickImage alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    fullView.contentMode = UIViewContentModeScaleAspectFill;
    fullView.image = weakCell.frontImage.image;
    fullView.backgroundColor = [UIColor blackColor];
    [TopView insertSubview:fullView belowSubview:self.view];
    [UIView transitionFromView:self.navigationController.view toView:fullView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL completed){
        EZDEBUG(@"Complelted presentation");
        [TopView bringSubviewToFront:fullView];
    }];
    __weak UIView* weakView = fullView;
    fullView.pressedBlock = ^(id obj){
        EZDEBUG(@"Pressed block");
        [UIView transitionFromView:weakView  toView:self.navigationController.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL completed){
            EZDEBUG(@"Complelted presentation");
            [weakView removeFromSuperview];
        }];
    };

}
- (void) switchImage:(EZPhotoCell*)weakCell displayPhoto:(EZDisplayPhoto*)cp front:(EZPhoto*)front back:(EZPhoto*)back animate:(BOOL)animate
{
    
    EZPhoto* photo = nil;

    if(animate){
        UIView* snapShot = [weakCell.frontImage snapshotViewAfterScreenUpdates:YES];
        snapShot.frame = weakCell.frontImage.frame;
        [weakCell.rotateContainer addSubview:snapShot];
        
        if(cp.isFront){
            photo = back;
            [self loadImage:weakCell url:photo.screenURL];
        }else{
            photo = front;
            //[weakCell.frontImage setImage:[front getScreenImage]];
            [self loadFrontImage:weakCell photo:front file:front.assetURL];
        }
    
        dispatch_later(0.15, ^(){
        [UIView flipTransition:snapShot dest:weakCell.frontImage container:weakCell.rotateContainer isLeft:YES duration:EZRotateAnimDuration complete:^(id obj){
            [snapShot removeFromSuperview];
            EZPerson* person = pid2person(photo.personID);
            EZDEBUG(@"person id:%@, name:%@", photo.personID, person.name);
            [self setChatInfo:weakCell displayPhoto:photo person:person];
            //[weakCell.headIcon setImageWithURL:str2url(person.avatar)];
            //weakCell.authorName.text = person.name;
            //EZDEBUG(@"rotation completed:%i", (int)[snapShot superview]);
        }];}
       );
    }else{
        if(cp.isFront){
            photo = back;
            [self loadImage:weakCell url:photo.screenURL];
        }else{
            photo = front;
            //[weakCell.frontImage setImage:[front getScreenImage]];
            [self loadFrontImage:weakCell photo:front file:front.assetURL];
        }
        //EZPerson* person = pid2person(photo.personID);
        [self setChatInfo:weakCell displayPhoto:photo person:pid2person(photo.personID)];
        //[weakCell.headIcon setImageWithURL:str2url(person.avatar)];
        //weakCell.authorName.text = person.name;

    }
    cp.isFront = !cp.isFront;

}



- (void) scrollViewDidScrollOld:(UIScrollView *)scrollView
{
      //EZDEBUG(@"ViewDidScroll dragging point:%@, size:%@, %f _isScrolling:%i, showShapeCover:%i, animateStarted:%i", NSStringFromCGPoint(scrollView.contentOffset), NSStringFromCGSize(scrollView.contentSize),scrollView.frame.size.height, _isScrolling, _showShapeCover, _animStarted);
    
    if(_isScrolling){
        CGFloat minius = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height;
        
        if(!_showShapeCover && minius > 40 && scrollView.contentSize.height > scrollView.frame.size.height){
            _showShapeCover = TRUE;
            //if(!_shapeCover){
            //    _shapeCover = [[EZUIUtility sharedEZUIUtility] createHoleView];
                //_shapeCover.backgroundColor = [UIColor blackColor];
            //    [scrollView addSubview:_shapeCover];
            //}
            //_shapeCover.hidden = NO;
            //_shapeCover.y = scrollView.contentSize.height + 40;
            //EZDEBUG(@"_shapaCover size:%@", NSStringFromCGRect(_shapeCover.frame));
            //[scrollView addSubview:_shapeCover];
        }else if(_showShapeCover && minius > 100){
            //_prevInsets = scrollView.contentInset;
            //_animStarted = TRUE;
            //_showShapeCover = FALSE;
            //EZDEBUG(@"Will start animation");
            [self raiseCamera];
            /**
            dispatch_later(0.1, ^(){
                
                [scrollView scrollRectToVisible:_shapeCover.frame animated:YES];
            //[UIView  animateWithDuration:0.5 animations:^(){
                //scrollView.contentInset = UIEdgeInsetsMake(_prevInsets.top, 0, CurrentScreenHeight + 40, 0);
                //scrollView.contentOffset = CGPointMake(0, scrollView.contentSize.height + _shapeCover.height + 40);
                
                
            //}
            //completion:^(BOOL complete){
            //    EZDEBUG(@"Completed scroll animation");
                //scrollView.contentInset = _prevInsets;
            //    _animStarted = false;
            //}
                
             //];
            
            });
             **/
             
        }
        
    }
}


- (void)scrollViewWillBeginDraggingOld:(UIScrollView *)scrollView
{
    EZDEBUG(@"Begin dragging point:%@, size:%@", NSStringFromCGPoint(scrollView.contentOffset), NSStringFromCGSize(scrollView.contentSize));
    _isScrolling = true;
}

- (void)scrollViewDidEndDraggingOld:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    EZDEBUG(@"End dragging point:%@, size:%@, refreshing:%i", NSStringFromCGPoint(scrollView.contentOffset), NSStringFromCGSize(scrollView.contentSize), self.refreshControl.refreshing);
    _isScrolling = false;
    /**
    if(!self.refreshControl.refreshing && scrollView.contentOffset.y < 0){
        [UIView animateWithDuration:0.3 animations:^(){
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL completed){
            self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        }];
    }
     **/
    //if(decelerate) return;
    //[self scrollViewDidEndDecelerating:scrollView];
}
- (void)scrollViewDidEndDeceleratingOld:(UIScrollView *)scrollView
{
    EZDEBUG(@"DidEndDecelerating point:%@, size:%@, refreshing:%i", NSStringFromCGPoint(scrollView.contentOffset), NSStringFromCGSize(scrollView.contentSize), self.refreshControl.refreshing);
    //_isScrolling = false;
    if(_showShapeCover){
        _shapeCover.hidden = TRUE;
        _showShapeCover = NO;
        _animStarted = false;
    }
    if(scrollView.contentOffset.y == -64){
        [UIView animateWithDuration:0.3 animations:^(){
            //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            scrollView.contentOffset = CGPointMake(0, 0);
        } completion:^(BOOL completed){
            //self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        }];
    }
    //UITableView* tableView = (UITableView*)scrollView;
    //[tableView scrollToRowAtIndexPath:[tableView indexPathForRowAtPoint: CGPointMake(tableView.contentOffset.x, tableView.contentOffset.y+tableView.rowHeight/2)] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark - Transitioning Delegate (Modal)
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    //_modalAnimationController.type = AnimationTypePresent;
    _raiseAnimation.type = AnimationTypePresent;
    return _raiseAnimation;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _raiseAnimation.type = AnimationTypeDismiss;
    return _raiseAnimation;
}

#pragma mark - Navigation Controller Delegate

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    EZDEBUG(@"Exactly before transition");
    
    switch (operation) {
        case UINavigationControllerOperationPush:
            if(_isPushCamera){
                _cameraNaviAnim.type = AnimationTypePresent;
                return _cameraNaviAnim;
            }else{
                _raiseAnimation.type = AnimationTypePresent;
                return  _raiseAnimation;
            }
        case UINavigationControllerOperationPop:
            if(_isPushCamera){
                _cameraNaviAnim.type = AnimationTypeDismiss;
                return _cameraNaviAnim;
            }else{
                _raiseAnimation.type = AnimationTypeDismiss;
                return _raiseAnimation;
            }
        default: return nil;
    }
    
}

-(id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    
    EZDEBUG(@"Somebody ask if I am interactive transition or not");
    /**
    if ([animationController isKindOfClass:[ScaleAnimation class]]) {
        ScaleAnimation *controller = (ScaleAnimation *)animationController;
        if (controller.isInteractive) return controller;
        else return nil;
    } else return nil;
     **/
    return nil;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */



@end
