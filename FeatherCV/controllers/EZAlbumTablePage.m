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
    EZDEBUG(@"Store image get called");
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    UIImage* img = [info objectForKey:@"image"];
    NSDictionary* orgdata = [info objectForKey:@"metadata"];
    NSMutableDictionary* metadata =[[NSMutableDictionary alloc] init];
    if(metadata){
        [metadata setDictionary:orgdata];
    }
    EZDEBUG(@"Recived metadata:%@, actual orientation:%i", metadata, img.imageOrientation);
    [metadata setValue:@(img.imageOrientation) forKey:@"Orientation"];
    [library writeImageToSavedPhotosAlbum:img.CGImage metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error2)
     {
         //             report_memory(@"After writing to library");
         if (error2) {
             EZDEBUG(@"ERROR: the image failed to be written");
         }
         else {
             EZDEBUG(@"Stored image to album assetURL: %@", assetURL);
             [[EZDataUtil getInstance] assetURLToAsset:assetURL success:^(ALAsset* result){
                 EZDEBUG(@"Transfer the image to EZDisplayPhoto successfully");
                 EZDisplayPhoto* ed = [[EZDisplayPhoto alloc] init];
                 ed.isFront = true;
                 EZPhoto* ep = [[EZPhoto alloc] init];
                 ed.pid = ++[EZDataUtil getInstance].photoCount;
                 ep.asset = result;
                 ep.isLocal = true;
                 ed.photo = ep;
                 ed.photo.owner = [[EZPerson alloc] init];
                 ed.photo.owner.name = @"天哥";
                 ed.photo.owner.avatar = [EZFileUtil fileToURL:@"tian_2.jpeg"].absoluteString;
                 //EZDEBUG(@"Before size");
                 ep.size = [result defaultRepresentation].dimensions;
                 [[EZMessageCenter getInstance]postEvent:EZTakePicture attached:ed];
                 EZDEBUG(@"after size:%f, %f", ep.size.width, ep.size.height);
             }];
         }
     }];
    
}

- (void)imagePickerControllerDidCancel:(DLCImagePickerController *)picker
{
    
}


- (void) raiseCamera
{
    if([EZUIUtility sharedEZUIUtility].cameraRaised || [EZUIUtility sharedEZUIUtility].stopRotationRaise){
        return;
    }
    
    if(_picker == nil){
        _picker = [[DLCImagePickerController alloc] init];
    }
    //controller.prefersStatusBarHidden = TRUE;
    _picker.transitioningDelegate = _cameraAnimation;
    _picker.delegate = self;
    if(_picker.isFrontCamera){
        [_picker switchCamera];
    }
    [self presentViewController:_picker animated:TRUE completion:^(){
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
    UIActionSheet* photoSheet = [[UIActionSheet alloc] initWithTitle:@"拍摄类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"自拍", @"拍摄", nil];
    [photoSheet showInView:self.view];
    _picker = [[DLCImagePickerController alloc] init];
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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pickPhotoType:)];
    /**
    CGRect bound = [UIScreen mainScreen].bounds;
    CGFloat diameter = 70.0;

    EZClickView* clickButton = [[EZClickView alloc] initWithFrame:CGRectMake((320 - diameter)/2, bound.size.height - diameter - 20, diameter, diameter)];
    [clickButton enableRoundImage];
    [self.view addSubview:clickButton];
    clickButton.backgroundColor = RGBACOLOR(255, 255, 255, 128);
    _cameraClicked = ^(id sender){
        [weakSelf raiseCamera];
    };
    EZUIUtility.sharedEZUIUtility.cameraClickButton = clickButton;
    dispatch_main(^(){
        EZDEBUG(@"The mainWindow:%i, topView:%i", (int)EZUIUtility.sharedEZUIUtility.mainWindow,(int)TopView);
        [TopView addSubview:clickButton];
    });
     **/
}


- (void) viewDidAppear:(BOOL)animated
{
    EZDEBUG(@"View did show");
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
    EZUIUtility.sharedEZUIUtility.cameraClickButton.pressedBlock = _cameraClicked;
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
        CGSize imgSize = [UIImage imageNamed:cp.randImage].size;
        imageHeight =  floorf((imgSize.height/imgSize.width) * ContainerWidth);
        //EZDEBUG(@"Column count is:%f, width:%f, %f", imageHeight, cp.photo.size.width, cp.photo.size.height);
    }
    }
    if(cp.turningAnimation){
        //EZDEBUG(@"calculate the height, is front:%i, turning height:%f", cp.isFront, imageHeight);
    }
    //EZDEBUG(@"image width:%f, height:%f, final height:%f", cp.myPhoto.size.width, cp.myPhoto.size.height, imageHeight);
    //Tool bar height is 20, added it back.
    return imageHeight + 20 + 40;
    // 400;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _combinedPhotos.count;
    //return 0;
}

- (void) testBackendCommunication
{
    //NSString* storedFile = [EZFileUtil saveImageToCache:[myPhoto getScreenImage]];
    
    
    [EZNetworkUtility postParameterAsJson:@"query/contacts" parameters:@[@{@"name":@"coolguy"}, @{@"name":@"hot girl"}] complete:^(id result){
        EZDEBUG(@"result:%@", result);
    } failblk:^(NSError* err){
        EZDEBUG(@"Error:%@", err);
    }];
    /**
    [[EZDataUtil getInstance] registerUser:@{@"email":@"coolguy@gmail.com",
                                             @"password":@"hahahehe",
                                             @"mobile":@"15216727142"
                                             }
                                   success:^(EZPerson* person){
                                       EZDEBUG(@"person name:%@", person.name);
                                   } error:^(NSError* err){
                                       EZDEBUG(@"err:%@", err);
                                   }];
    
    [[EZDataUtil getInstance] loginUser:@{@"email":@"coolguy@gmail.com",
                                          @"password":@"hahahehe",
                                          @"mobile":@"15216727142"
                                          }
                                success:^(EZPerson* person){
                                    EZDEBUG(@"post person name:%@", person.name);
                                } error:^(NSError* err){
                                    EZDEBUG(@"post err:%@", err);
                                }];
     **/
    /**
     [[EZNetworkUtility getInstance] upload:baseUploadURL file:storedFile uploadField:@"myfile" headers:nil parameters:@{@"personid":@"coolguy"} complete:^(id obj){
     EZDEBUG(@"Upload successfully");
     } error:^(id obj){
     EZDEBUG(@"Upload failed");
     } method:nil];
     **/
    
    /**
     [[EZNetworkUtility getInstance] upload:baseUploadURL parameters:@{@"personid":@"coolguy"} file:storedFile complete:^(id obj){
     EZDEBUG(@"Complete call back:%@, is main:%i",obj,[NSThread isMainThread]);
     } error:^(id err){
     EZDEBUG(@"Upload error:%@,  is main:%i", err, [NSThread isMainThread]);
     } progress:^(CGFloat percent){
     EZDEBUG(@"The upload progress is:%f", percent);
     }];
     **/
    /**
     [EZNetworkUtility getJson:@"static/handpa.txt" complete:^(id dict){
     EZDEBUG(@"get upload:%@", dict);
     } failblk:^(NSError* err){
     EZDEBUG(@"get upload:%@", err);
     }];
     EZDEBUG(@"upload asynchronized");
     
     [EZNetworkUtility postJson:@"feather" parameters:@{@"coolguy":@"yaya"} complete:^(id json){
     EZDEBUG(@"Post response:%@", json);
     } failblk:^(NSError* err){
     EZDEBUG(@"Error:%@", err);
     }];
     **/

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    EZPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell || cell.isTurning){
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
    if(cp.isFront){
        EZDEBUG(@"Will display front image");
        [cell displayImage:[myPhoto getScreenImage]];
        [cell adjustCellSize:myPhoto.size];
    }else{//Display the back
        UIImage* img = [UIImage imageNamed:cp.randImage];
        
        [cell displayImage:img];
        [cell adjustCellSize:img.size];
        EZDEBUG(@"Will display random image:%@, front image:%@, rotateContainer:%@, container:%@", NSStringFromCGSize(img.size), NSStringFromCGSize(cell.frontImage.frame.size),NSStringFromCGRect(cell.rotateContainer.frame), NSStringFromCGRect(cell.container.frame));
    }
    }
    __weak EZPhotoCell* weakCell = cell;
    __weak EZAlbumTablePage* weakSelf = self;
    cell.container.releasedBlock = ^(id obj){
        if(cp.combineStatus == kEZStartStatus){
            cp.combineStatus = kEZSendSharedRequest;
            EZDEBUG(@"Will start upload the image");
            [self testBackendCommunication];
        }else{
            [weakSelf switchAnimation:cp photoCell:weakCell indexPath:indexPath tableView:tableView];
        }
    };

    return cell;
}

- (void) switchAnimation:(EZDisplayPhoto*)cp photoCell:(EZPhotoCell*)weakCell indexPath:(NSIndexPath*)indexPath tableView:(UITableView*)tableView
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
    cp.isFront = !cp.isFront;
    EZEventBlock complete = ^(id sender){
        EZDEBUG(@"Complete get called");
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    if(cp.isFront){
        //[weakCell displayImage:[myPhoto getLocalImage]];
        [weakCell switchImage:[cp.photo getScreenImage] photo:cp complete:complete tableView:tableView index:indexPath];
    }else{
        EZDEBUG(@"The container size:%f, %f", weakCell.container.frame.size.width, weakCell.container.frame.size.height);
        if(!cp.randImage){
            int imagePos = rand()%17;
            ++imagePos;
            NSString* randFile = [NSString stringWithFormat:@"santa_%i.jpg", imagePos];
            EZDEBUG(@"Random File name:%@", randFile);
            cp.randImage = randFile;
        }
        [weakCell switchImage:[UIImage imageNamed:cp.randImage] photo:cp complete:complete tableView:tableView index:indexPath];
    }

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
