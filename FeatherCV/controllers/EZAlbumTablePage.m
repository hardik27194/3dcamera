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


static int photoCount = 1;
@interface EZAlbumTablePage ()

@end

@implementation EZAlbumTablePage


-(id)initWithQueryBlock:(EZQueryBlock)queryBlock
{
    self = [super initWithStyle:UITableViewStylePlain];
    self.title = @"羽毛";
    _queryBlock = queryBlock;
    [self createMoreButton];
    [self.tableView registerClass:[EZPhotoCell class] forCellReuseIdentifier:@"PhotoCell"];
    return self;
}


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
    //_moreButton.alpha = 0.0;
    //[self.navigationController.navigationBar addSubview:_moreButton];
    //[UIView animateWithDuration:0.3 animations:^(){
    //    _moreButton.alpha = 1.0;
    //}];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_moreButton removeFromSuperview];
    _menuView.height = 0;
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


- (void) showMenu:(id)sender
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
    for(int i = 0; i < _newlyCreated; i++){
        NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:path];
        if(!cell){
            continue;
        }
        EZDisplayPhoto* cp = [_combinedPhotos objectAtIndex:i];
        if(!cp.isFront){
            EZDEBUG(@"flipped manually");
            continue;
        }
        EZPhoto* switchPhoto = [cp.photo.photoRelations objectAtIndex:0];
        cp.isFront = !cp.isFront;
        EZDEBUG(@"prefetchDone:%i", switchPhoto.prefetchDone);
        if(switchPhoto.prefetchDone){
            [self switchAnimation:cp photoCell:cell indexPath:path tableView:self.tableView photo:cp.isFront?cp.photo:switchPhoto];
        }else{
            dispatch_later(1.0,
                           ^(){
                               EZDEBUG(@"after dispatch prefetch done:%i", switchPhoto.prefetchDone);
                                [self switchAnimation:cp photoCell:cell indexPath:path tableView:self.tableView photo:cp.isFront?cp.photo:switchPhoto];
                           }
                           );
        }
        
        
    }
}

- (void)imagePickerControllerDidCancel:(DLCImagePickerController *)picker
{
    EZDEBUG(@"cancel get called:%i", _newlyCreated);
    if(_newlyCreated){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        dispatch_later(1.5, ^(){
            [self animateFlip];
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
    camera.transitioningDelegate = _cameraAnimation;
    camera.delegate = self;
    if(camera.isFrontCamera){
        [camera switchCamera];
    }
    [self presentViewController:camera animated:TRUE completion:^(){
        EZDEBUG(@"Presentation completed");
    }];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.navigationItem.rightBarButtonItem = [[UINavigationItem alloc] initWithTitle:@""];
    
    //self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
    _combinedPhotos = [[NSMutableArray alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.tableView.backgroundColor = RGBCOLOR(230, 231, 226);
    self.tableView.backgroundColor = VinesGray;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    __weak EZAlbumTablePage* weakSelf = self;
    //[self.tableView addSubview:[EZTestSuites testResizeMasks]];
    _slideAnimation = [[SlideAnimation alloc] init];
    _raiseAnimation = [[EZRaiseAnimation alloc] init];
    _cameraAnimation = [[EZModalRaiseAnimation alloc] init];
    EZDEBUG(@"Query block is:%i",(int)_queryBlock);

    [[EZMessageCenter getInstance] registerEvent:EZTakePicture block:^(EZDisplayPhoto* dp){
        EZDEBUG(@"A photo get generated");
        [_combinedPhotos insertObject:dp atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZAlbumImageReaded block:^(EZDisplayPhoto* dp){
        EZDEBUG(@"Recieved a image from album");
        [_combinedPhotos insertObject:dp atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZTriggerCamera block:^(id obj){
        [weakSelf raiseCamera];
    }];
    
    
    EZDEBUG(@"The login personID:%@, getID:%@", [EZDataUtil getInstance].currentPersonID, [[EZDataUtil getInstance] getCurrentPersonID]);
    [[EZDataUtil getInstance] queryPhotos:0 pageSize:10 success:^(NSArray* arr){
        EZDEBUG(@"returned length:%i", arr.count);
        //[_combinedPhotos addObjectsFromArray:arr];
        [self reloadRows:arr];
        //[self.tableView reloadData];
    } failure:^(NSError* err){
        EZDEBUG(@"Error detail:%@", err);
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pickPhotoType:)];

}
- (void) reloadRows:(NSArray*)photos
{
    for(EZPhoto* pt in photos){
        [[EZDataUtil getInstance] assetURLToAsset:str2url(pt.assetURL) success:^(ALAsset* result){
            EZDEBUG(@"Transfer the image to EZDisplayPhoto successfully");
            EZDisplayPhoto* ed = [[EZDisplayPhoto alloc] init];
            ed.isFront = true;
            ed.photo = pt;
            //EZPhoto* ep = [[EZPhoto alloc] init];
            //ed.pid = ++[EZDataUtil getInstance].photoCount;
            //ep.photoID = _matchedPhoto.srcPhotoID;
            //ep.photoRelations = @[_matchedPhoto];
            pt.asset = result;
            //ep.assetURL = assetURL.absoluteString;
            pt.isLocal = true;
            //ed.photo = ep;
            ed.photo.owner = [EZDataUtil getInstance].currentLoginPerson;
            //EZDEBUG(@"Before size");
            //ep.size = [result defaultRepresentation].dimensions;
            
            //[self preMatchPhoto];
            //[[EZMessageCenter getInstance]postEvent:EZTakePicture attached:ed];
            //EZDEBUG(@"after size:%f, %f", ep.size.width, ep.size.height);
            //success(ed);
            [_combinedPhotos addObject:ed];
            //[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView reloadData];
        }];
        
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    EZDEBUG(@"View did show");
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
    EZUIUtility.sharedEZUIUtility.cameraClickButton.pressedBlock = _cameraClicked;
    /**
    [UIImageView preloadImageURL:str2url(@"http://192.168.1.102:8080/static/79661d8d26c00668ac4c215373fdf12e.jpg") success:^(UIImage* image){
        EZDEBUG(@"view loaded");
        EZClickImage* view = [[EZClickImage alloc] initWithFrame:CGRectMake(0, 200, 100, 100)];
        view.image = image;
        [UIImageView preloadImageURL:str2url(@"http://192.168.1.102:8080/static/79661d8d26c00668ac4c215373fdf12e.jpg") success:^(UIImage* img){
            EZDEBUG(@"success immediately");
        } failed:^(NSError* err){
        
        }];
        //[self.view addSubview:view];
        view.releasedBlock = ^(id obj){
            [[EZDataUtil getInstance] queryPhotos:0 pageSize:5 success:^(NSArray* photos){
                EZDEBUG(@"fetch back count:%i", photos.count);
                EZPhoto* first = [photos objectAtIndex:0];
                EZDEBUG(@"PhotoID:%@, relationsSize:%i", first.photoID, first.photoRelations.count);
                EZPhoto* matchedPhoto = [first.photoRelations objectAtIndex:0];
                EZDEBUG(@"Matched photo:%@, screenURL:%@", matchedPhoto.photoID, matchedPhoto.screenURL);
            } failure:^(id err){
                EZDEBUG(@"query photo error:%@", err);
            }];
        };
    } failed:^(id err){
        EZDEBUG(@"encounter error:%@", err);
    }];
    **/
    
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
    
    return imageHeight + 20 + ToolRegionHeight;
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

- (void) changePhotoStatus:(EZPhoto*)photo success:(EZEventBlock)success failed:(EZEventBlock)failed
{
    
}

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
    [[EZDataUtil getInstance] exchangePhoto:photo success:^(EZPhoto* pt){
        block(pt);
    } failure:failed];

}

- (void) testBackendCommunication:(EZPhoto*)photo exchanged:(EZEventBlock)block
{
    static int sequence = 0;
    //if((sequence % 2) == 0){
    //NSString* storedFile = [EZFileUtil saveImageToCache:[myPhoto getScreenImage]];
    EZDEBUG(@"Uploaded for photoID:%@, uploaded:%i", photo.photoID, photo.uploaded);
    if(!photo.uploaded){
        [[EZDataUtil getInstance] uploadPhoto:photo success:^(EZPhoto* obj){
                EZDEBUG(@"Uploaded photoID success:%@", obj.photoID);
        } failure:^(id err){
                EZDEBUG(@"upload photo error:%@", err);
        }];
    }
    [[EZDataUtil getInstance] exchangePhoto:photo success:^(EZPhoto* pt){
        block(pt);
    } failure:^(id err){
        EZDEBUG(@"Photo exchange failure:%@", err);
    }];
    //}else{
    
    //}
    ++sequence;
    
}

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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    EZPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell.isTurning){
        EZDEBUG(@"Recieved a rotating cell.");
        cell = [[EZPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //[cell backToOriginSize];
    
    cell.isLarge = false;
    EZDisplayPhoto* cp = [_combinedPhotos objectAtIndex:indexPath.row];
    
    //This is for later update purpose. great, let's get whole thing up and run.
    cell.currentPos = indexPath.row;
    //EZCombinedPhoto* curPhoto = [cp.combinedPhotos objectAtIndex:cp.selectedCombinePhoto];
    EZPhoto* myPhoto = cp.photo;
    EZPhoto* switchPhoto = [cp.photo.photoRelations objectAtIndex:0];
    if(!cp.isFront){
        EZPhoto* tmpPhoto = myPhoto;
        myPhoto = switchPhoto;
        switchPhoto = tmpPhoto;
    }
    EZDEBUG(@"myPhoto image size:%@, screenURL:%@, isFront:%i", NSStringFromCGSize(myPhoto.size), myPhoto.screenURL, cp.isFront);
    // Configure the cell...
    //[cell displayImage:[myPhoto getLocalImage]];
    [[cell viewWithTag:animateCoverViewTag] removeFromSuperview];
    if(cell.rotateContainer.superview == nil){
        EZDEBUG(@"encounter nil rotateContainer");
        [cell.container addSubview:cell.rotateContainer];
    }
    if(cp.turningAnimation){
        EZDEBUG(@"Turning animation get called");
        //[cell adjustCellSize:cp.turningImageSize];
        //[cell displayImage:cp.oldTurnedImage];
        [cell.container addSubview:cp.oldTurnedImage];
        EZEventBlock animBlock = cp.turningAnimation;
        cp.turningAnimation = nil;
        animBlock(cell);
        //cp.oldTurnedImage = nil;
    }else{
        EZDEBUG(@"Will display front image");
        if(cp.isFront){
            [cell.frontImage setImage:[myPhoto getScreenImage]];
        }else{
            [cell.frontImage setImageWithURL:str2url(myPhoto.screenURL)];
        }
        [cell adjustCellSize:myPhoto.size];
    }
    __weak EZPhotoCell* weakCell = cell;
    __weak EZAlbumTablePage* weakSelf = self;
    if(cp.combineStatus == kEZStartStatus){
        [cell.toolRegion.unlockButton setTitle:@"私人" forState:UIControlStateNormal];
    }else{
        [cell.toolRegion.unlockButton setTitle:@"公开" forState:UIControlStateNormal];
    }
    cell.toolRegion.buttonClicked = ^(UIButton* button){
        /**
        if(cp.combineStatus == kEZStartStatus){
            //UIActionSheet* asheet = [[UIActionSheet alloc] initWithTitle:@"公开照片" delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"公开", nil];
            //[asheet showInView:weakSelf.view];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"公开照片"  message:@"照片公开后可以被你的朋友和羽毛用户发现" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"所有人",@"只限朋友", nil];
            [alertView show];
            weakSelf.alertClicked = ^(NSNumber* num){
                //EZDEBUG(@"number pass to me is:%i", num.intValue);
                //[[EZDataUtil getInstance]
            };
        }else{
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"取消公开" message:@"取消公开后你的朋友和羽毛好友将不再能看见这张照片" delegate:self cancelButtonTitle:nil  otherButtonTitles:@"确认", nil];
            [alertView show];
            weakSelf.alertClicked = ^(NSNumber* num){
                EZDEBUG(@"number pass to me is:%i", num.intValue);
            };
        }
         **/
    };
    
    
    cell.container.releasedBlock = ^(id obj){
        /**
        [UIView animateWithDuration:0.6 animations:^(){
            CATransform3D transform = CATransform3DRotate(weakCell.rotateContainer.layer.transform, M_PI, 0.0, 1.0,0.0);
        //[UIView setAnimationRepeatCount:100];
            weakCell.rotateContainer.layer.transform = transform;
        }];
        **/
        
        /**
        UIView* destView = [[UIView alloc] initWithFrame:weakCell.rotateContainer.frame];
        destView.backgroundColor = [UIColor grayColor];
        [weakCell.container addSubview:destView];
        [self customeFlip:3.0 srcView:weakCell.rotateContainer destView:destView completed:^(){
            EZDEBUG(@"Completed");
            weakCell.rotateContainer.layer.transform = CATransform3DIdentity;
            [destView removeFromSuperview];
        }];
         **/
        
        /**
        if(cp.combineStatus == kEZStartStatus){
            cp.combineStatus = kEZSendSharedRequest;
            EZDEBUG(@"Will start upload the image");
            [self testBackendCommunication:myPhoto exchanged:^(EZPhoto* ep){
                cp.photo.photoRelations = @[ep];
                EZDEBUG(@"Returned screen image URL:%@", ep.screenURL);
                //[weakCell.frontImage setImageWithURL:str2url(ep.screenURL)];
                cp.isFront = false;
                [weakSelf switchAnimation:cp photoCell:weakCell indexPath:indexPath tableView:tableView photo:ep];
            }];
        }else{
         **/
            //If the photo not returned, then why bothering to flip it?
        if(switchPhoto){
            cp.isFront = !cp.isFront;
            [weakSelf switchAnimation:cp photoCell:weakCell indexPath:indexPath tableView:tableView photo:cp.isFront?cp.photo:switchPhoto];
        }
        //}
    };

    return cell;
}

- (void) switchAnimation:(EZDisplayPhoto*)cp photoCell:(EZPhotoCell*)weakCell indexPath:(NSIndexPath*)indexPath tableView:(UITableView*)tableView photo:(EZPhoto*)photo
{
    if(cp.isTurning){
        EZDEBUG(@"Return while turning");
        return;
    }
    if(weakCell.currentPos != indexPath.row){
        EZDEBUG(@"Turn while cell no more this row:%i, %i", weakCell.currentPos, indexPath.row);
        return;
    }
    EZDEBUG(@"rotateContainer,FrontImage rect:%@, %@, rotatateContainer parent:%i, %i",NSStringFromCGRect(weakCell.rotateContainer.frame), NSStringFromCGRect(weakCell.frontImage.frame), (int)weakCell.rotateContainer.superview, (int)weakCell.container);
    cp.isTurning = true;
    EZEventBlock complete = ^(id sender){
        EZDEBUG(@"Complete get called");
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
     [weakCell switchImage:photo photo:cp complete:complete tableView:tableView index:indexPath];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    EZDEBUG(@"Begin dragging");
    _isScrolling = true;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    EZDEBUG(@"End dragging:%i", decelerate);
    if (!decelerate) {
        _isScrolling = false;
        [self replaceLargeImage];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    EZDEBUG(@"End Decelerating");
    _isScrolling = false;
    [self replaceLargeImage];
}

- (void) replaceLargeImage
{
    /**
    NSArray* cells = [self.tableView visibleCells];
    EZDEBUG(@"Scroll stopped:%i", cells.count);
    
    for(EZPhotoCell* pcell in cells){
        EZDisplayPhoto* cp = [_combinedPhotos objectAtIndex:pcell.currentPos];
        
        if(cp.isFront && !pcell.isLarge){
            pcell.isLarge = true;
            //[[EZThreadUtility getInstance] executeBlockInQueue:^(){
            //[pcell displayEffectImage:[cp.photo getLocalImage]];
            [pcell displayImage:[cp.photo getLocalImage]];
            //}];
        }
    }
    **/
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
            _raiseAnimation.type = AnimationTypePresent;
            return  _raiseAnimation;
        case UINavigationControllerOperationPop:
            _raiseAnimation.type = AnimationTypeDismiss;
            return _raiseAnimation;
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
