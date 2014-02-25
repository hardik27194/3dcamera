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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    EZDEBUG(@"preferred style");
    return UIStatusBarStyleLightContent;
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
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
   
    if(![EZDataUtil getInstance].barBackground.superview)
        [TopView addSubview:[EZDataUtil getInstance].barBackground];
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
    [[EZDataUtil getInstance].barBackground removeFromSuperview];
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
            [self switchImage:cell displayPhoto:cp front:cp.photo back:switchPhoto];
        } failure:nil];
    }
}

- (void)imagePickerControllerDidCancel:(DLCImagePickerController *)picker imageCount:(int)imageCount
{
    EZDEBUG(@"cancel get called:%i", _newlyCreated);
    if(imageCount){
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

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    // Refresh table here...
    //[_allEntries removeAllObjects];
    //[self.tableView reloadData];
    //[self refresh];
    EZDEBUG(@"Refreshed get called:%i", state);
    dispatch_later(1.0, ^(){
        [self.refreshControl endRefreshing];
    });
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   //self.navigationItem.rightBarButtonItem = [[UINavigationItem alloc] initWithTitle:@""];
    
    //self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
    _combinedPhotos = [[NSMutableArray alloc] init];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:)forControlEvents:UIControlEventValueChanged];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
    //self.tableView.backgroundColor = RGBCOLOR(230, 231, 226);
    self.tableView.backgroundColor = VinesGray;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    __weak EZAlbumTablePage* weakSelf = self;
    //[self.tableView addSubview:[EZTestSuites testResizeMasks]];
    _slideAnimation = [[SlideAnimation alloc] init];
    _raiseAnimation = [[EZRaiseAnimation alloc] init];
    _cameraAnimation = [[EZModalRaiseAnimation alloc] init];
    
    _detailAnimation = [[EZModalDissolveAnimation alloc] init];
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
    [[EZDataUtil getInstance] queryPhotos:0 pageSize:photoPageSize success:^(NSArray* arr){
        EZDEBUG(@"returned length:%i", arr.count);
        //[_combinedPhotos addObjectsFromArray:arr];
        [self reloadRows:arr];
        //[self.tableView reloadData];
    } failure:^(NSError* err){
        EZDEBUG(@"Error detail:%@", err);
    }];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pickPhotoType:)];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    CGFloat radius = 60.0;
    
    //dispatch_later(0.1, ^(){
        
    //});
    dispatch_later(0.1, ^(){
    
        EZClickView* clickView = [[EZClickView alloc] initWithFrame:CGRectMake((320.0 - radius)/2.0, bounds.size.height - radius - 20.0, radius, radius)];
    //[clickView digHole:50 color:[UIColor whiteColor] opacity:1.0];
    //clickView.userInteractionEnabled = YES;
    
        
    //UIView* borderView = [[UIView alloc] initWithFrame:CGRectMake(0, bounds.size.height - radius, radius, radius)];
    //borderView.backgroundColor = [UIColor clearColor];
        clickView.layer.borderColor = [UIColor whiteColor].CGColor;
        clickView.layer.borderWidth = 4.0;
        //[borderView enableRoundImage];
        //[TopView addSubview:borderView];
    //clickView.backgroundColor = [UIColor clearColor];
    //clickView.layer.borderColor = [UIColor whiteColor].CGColor;
    //clickView.layer.borderWidth = 4.0;
    [clickView enableRoundImage];
    clickView.releasedBlock = ^(id obj){
        [weakSelf raiseCamera];
    };
    [TopView addSubview:clickView];
        
    UIView* statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBarBackground.backgroundColor = RGBCOLOR(0, 197, 213);
    [TopView addSubview:statusBarBackground];
    [EZDataUtil getInstance].barBackground = statusBarBackground;
    [EZDataUtil getInstance].centerButton = clickView;
    });
    
    
    //_observedTarget = [[EZPhoto alloc] init];
    //observeTarget.uploaded
    //EZClickView* clickView = [[EZClickView alloc] initWithFrame:CGRectMake(0, 200, 100, 100)];
    //clickView.backgroundColor = RGBCOLOR(128, 128, 255);
    //[self.view addSubview:clickView];
    
    //clickView.pressedBlock = ^(id obj){
     //   EZDEBUG(@"clicked");
     //   _observedTarget.uploaded = !_observedTarget.uploaded;
    //};
    
    //[_observedTarget addObserver:self forKeyPath:@"uploaded" options:NSKeyValueObservingOptionNew context:nil];
    

}

- (void) testHomeMadeRotation
{
    
    EZClickImage* clickView = [[EZClickImage alloc] initWithFrame:CGRectMake(0, 100, 200, 200)];
    static int type = 0;
    clickView.image = [UIImage imageNamed:@"header_1"];
    clickView.backgroundColor = RGBCOLOR(255, 128, 128);
    [self.tableView addSubview:clickView];
    //clickView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    clickView.releasedBlock = ^(id obj){
        EZRotateAnimation* rotateAnim = [[EZRotateAnimation alloc] init:clickView interval:3.0 rad:1.0 repeat:type];
        //_holder = rotateAnim;
        //[[EZAnimationUtil sharedEZAnimationUtil] addAnimation:rotateAnim];
        [UIView animateWithDuration:0.3 animations:^(){
            
            
        }];
        EZDEBUG(@"start animate:%i", type);
        ++type;
    };
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

- (void) reloadRows:(NSArray*)photos
{
    for(EZPhoto* pt in photos){
        if(! [self existed:pt.photoID]){
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
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            //[self.tableView reloadData];
        }];
        }
    }
}

//Pull and refresh will help to check if we have more photo to match.
//This really make sense
//Refresh to get more
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!_isFirstCompleted){
        _isFirstCompleted = TRUE;
        return;
    }
        
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height + 30)
    {
        if (!_isLoadingMoreData)
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
            int pageStart = _combinedPhotos.count/photoPageSize;
            EZDEBUG(@"Will load from %i", pageStart);
            [[EZDataUtil getInstance] queryPhotos:pageStart pageSize:photoPageSize success:^(NSArray* arr){
                EZDEBUG(@"Reloaded about %i rows of data", arr.count);
                [self reloadRows:arr];
                animBlock();
            } failure:^(id err){
                animBlock();
            }];
            // proceed with the loading of more data
        }
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
    
    return 320 + 40;
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    EZDisplayPhoto* cp = [_combinedPhotos objectAtIndex:indexPath.row];
    cell.backgroundColor = VinesGray;
    //This is for later update purpose. great, let's get whole thing up and run.
    cell.currentPos = indexPath.row;
    //EZCombinedPhoto* curPhoto = [cp.combinedPhotos objectAtIndex:cp.selectedCombinePhoto];
    EZPhoto* myPhoto = cp.photo;
    EZPhoto* switchPhoto = [cp.photo.photoRelations objectAtIndex:0];
    
    EZDEBUG(@"myPhoto image size:%@, screenURL:%@, isFront:%i", NSStringFromCGSize(myPhoto.size), myPhoto.screenURL, cp.isFront);
    // Configure the cell...
    //[cell displayImage:[myPhoto getLocalImage]];
    [[cell viewWithTag:animateCoverViewTag] removeFromSuperview];
    EZDEBUG(@"Will display front image");
    if(cp.isFront){
        [cell.frontImage setImage:[myPhoto getScreenImage]];
    }else{
        [cell.frontImage setImageWithURL:str2url(switchPhoto.screenURL)];
    }
    __weak EZPhotoCell* weakCell = cell;
    cell.frontImage.tappedBlock = ^(id obj){
        EZDEBUG(@"Cell Released clicked");
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:@"测试" info:@"好好测"];
        if(switchPhoto){
            [self switchImage:weakCell displayPhoto:cp front:myPhoto back:switchPhoto];
        }
    };
    
    cell.frontImage.longPressed = ^(id obj){
        UIImageView* fullView = [[UIImageView alloc] initWithImage:weakCell.frontImage.image];
        fullView.contentMode = UIViewContentModeScaleToFill;
        EZDEBUG(@"Long press called %@", NSStringFromCGRect(fullView.bounds));
        EZScrollController* sc = [[EZScrollController alloc] initWithDetail:fullView];
        sc.transitioningDelegate = self.detailAnimation;
        [self.navigationController presentViewController:sc animated:YES completion:nil];
        //fullView.pressedBlock = ^(id obj){
        //    EZDEBUG(@"presssed");
        //    [sc dismissViewControllerAnimated:YES completion:nil];
        //};
        sc.tappedBlock = ^(UIViewController* obj){
            EZDEBUG(@"dismiss current view");
            [obj dismissViewControllerAnimated:YES completion:nil];
            [EZDataUtil getInstance].centerButton.alpha = 1.0;
        };
        [EZDataUtil getInstance].centerButton.alpha = 0.0;
        
    };
    return cell;
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
- (void) switchImage:(EZPhotoCell*)weakCell displayPhoto:(EZDisplayPhoto*)cp front:(EZPhoto*)front back:(EZPhoto*)back
{
    UIView* snapShot = [weakCell.frontImage snapshotViewAfterScreenUpdates:YES];
    snapShot.frame = weakCell.frontImage.frame;
    [weakCell.rotateContainer addSubview:snapShot];
    if(cp.isFront){
        [weakCell.frontImage setImageWithURL:str2url(back.screenURL)];
    }else{
        [weakCell.frontImage setImage:[front getScreenImage]];
    }
    
    
    [UIView flipTransition:snapShot dest:weakCell.frontImage container:weakCell.rotateContainer isLeft:YES duration:2 complete:^(id obj){
        [snapShot removeFromSuperview];
        //EZDEBUG(@"rotation completed:%i", (int)[snapShot superview]);
    }];
    cp.isFront = !cp.isFront;

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
