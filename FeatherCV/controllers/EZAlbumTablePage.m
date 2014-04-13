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
#import "EZNote.h"
#import "EZCoreAccessor.h"
#import "EZPersonDetail.h"
#import "EZTrianglerView.h"
#import "UIScrollView+ScrollIndicator.h"





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
    cell.headIcon.image = nil;
    cell.otherIcon.image = nil;
    cell.authorName.text = nil;
    cell.otherName.text = nil;
    cell.otherName.hidden = NO;
    cell.otherIcon.hidden = NO;
    cell.andSymbol.hidden = NO;
    cell.otherTalk.hidden = NO;
    cell.authorName.hidden = NO;
    cell.headIcon.hidden = NO;
    cell.ownTalk.hidden = NO;
    cell.frontImage.image = nil;
    cell.frontImage.backgroundColor = ClickedColor;
    cell.activityView.hidden = YES;
    //cell.frontImage.backgroundColor = VinesGray;
    cell.cameraView.hidden = YES;
    cell.waitingInfo.hidden = YES;
    cell.shotPhoto.hidden = YES;
    _rightCycleButton.hidden = NO;
    //This is for later update purpose. great, let's get whole thing up and run.
    cell.currentPos = indexPath.row;
    //EZCombinedPhoto* curPhoto = [cp.combinedPhotos objectAtIndex:cp.selectedCombinePhoto];
    EZPhoto* myPhoto = cp.photo;
    EZPhoto* switchPhoto = [cp.photo.photoRelations objectAtIndex:0];
    cell.photoDate.text = formatRelativeTime(myPhoto.createdTime);
    // Configure the cell...
    //[cell displayImage:[myPhoto getLocalImage]];
    [[cell viewWithTag:animateCoverViewTag] removeFromSuperview];
    
    __weak EZAlbumTablePage* weakSelf = self;
    __weak EZPhotoCell* weakCell = cell;
 
    if(cp.isFirstTime){
       
        cp.isFirstTime = NO;
        //cell.firstTimeView.hidden = NO;
        EZPerson* person = pid2person(switchPhoto.personID);
        EZDEBUG(@"name:%@, pendingCount:%i, photoID:%@", person.name, person.pendingEventCount, cp.photo.photoID);
        //person.pendingEventCount -= 1;
        [person adjustPendingEventCount:-1];
        //[person save];
        [[EZMessageCenter getInstance] postEvent:EZNoteCountChange attached:@(-1)];
    }else{
        cell.firstTimeView.hidden = YES;
    }
    EZDEBUG(@"Will display front image type:%i", myPhoto.typeUI);
    if(cp.isFront){
        [cell setFrontFormat:true];
        //cell.authorName.textColor = [UIColor whiteColor];
        //cell.otherName.textColor = RGBCOLOR(240, 240, 240);
        if(myPhoto.typeUI == kPhotoRequest){
            //EZClickView* takePhoto = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            //takePhoto.center =
            //cell.frontImage.image = nil
            //cell.frontImage.backgroundColor = ClickedColor;
            cell.cameraView.hidden = NO;
            EZPerson* otherPerson = pid2person(switchPhoto.personID);
            weakCell.requestFixInfo.text = @"拍摄后翻看";
            weakCell.requestInfo.text =[NSString stringWithFormat:@"\"%@\"发来的照片", otherPerson.name?otherPerson.name:@"朋友"];
            weakSelf.rightCycleButton.hidden = YES;
            cell.shotPhoto.hidden = NO;
            cell.frontImage.backgroundColor = ClickedColor;
            cell.otherIcon.hidden = YES;
            cell.otherName.hidden = YES;
            cell.otherTalk.hidden = YES;
            cell.andSymbol.hidden = YES;
            cell.authorName.hidden = YES;
            cell.headIcon.hidden = YES;
            
            cell.shotPhoto.releasedBlock = ^(id obj){
                EZDEBUG(@"cameraView clicked");
                [self raiseCamera:cp indexPath:indexPath];
            };
        }else{
            [self loadFrontImage:cell photo:myPhoto file:myPhoto.assetURL path:indexPath];
        }
        preloadimage(switchPhoto.screenURL);
        
    }else{
        //cell.authorName.textColor = RGBCOLOR(240, 240, 240);
        //cell.otherName.textColor = [UIColor whiteColor];
        [cell setFrontFormat:false];
        [self setWaitingInfo:cell displayPhoto:cp back:switchPhoto];
        if(switchPhoto.type == kPhotoRequest || ([cp.photo.exchangePersonID isNotEmpty] && switchPhoto == nil)){
            
        }else if(switchPhoto == nil){
            //weakCell.frontImage.image = nil;
            [[EZUIUtility sharedEZUIUtility] showErrorInfo:macroControlInfo(@"Network not available") delay:1.0 view:self.view];
        }
        else{
            //cell.waitingInfo.hidden = YES;
            [self loadImage:cell url:switchPhoto.screenURL retry:0 path:indexPath];
        }
    }

   
    EZDEBUG(@"upload status is:%i, photo relation count:%i, object Pointer:%i", myPhoto.updateStatus, myPhoto.photoRelations.count, (int)myPhoto);
    _progressBar.hidden = YES;
    
    //Simplfy the condition
    //As long as I have no matched photo
    //I will monitoring the event.
    EZEventBlock otherBlock = ^(EZPerson*  person){
        if(cell.currentPos == indexPath.row){
            cell.otherName.text = person.name;
            //[cell.otherIcon setImageWithURL:str2url(person.avatar)];
            [cell.otherIcon loadImageURL:person.avatar haveThumb:NO loading:NO];
        }
    };
    if(!myPhoto.photoRelations.count && !(myPhoto.type == 1)){
        EZDEBUG(@"Will register upload success");
        myPhoto.progress = ^(NSNumber* number){
            if(cell.currentPos == indexPath.row){
                if(number){
                    [_progressBar setProgress:0.2 + number.floatValue*0.8 animated:YES];
                }else{
                    EZDEBUG(@"upload failed");
                }
            }
        };
        
        myPhoto.uploadSuccess = ^(EZPhoto* returned){
            EZDEBUG(@"upload success, photoRelation:%i", returned.photoRelations.count);
            
            if(cell.currentPos == indexPath.row){
                //[_progressBar setProgress:1.0 animated:YES];
                EZDEBUG(@"Will rotate the photo");
                //_progressBar.hidden = YES;
                EZPhoto* swPhoto = [returned.photoRelations objectAtIndex:0];
                
                pid2personCall(swPhoto.personID, otherBlock);
                if(swPhoto){
                    [weakSelf switchImage:weakCell displayPhoto:cp front:returned back:swPhoto animate:YES path:indexPath];
                }

            }
        };
        
    }
    
    //EZDEBUG(@"likedUser:%@, otherID:%@", myPhoto.liked)
    //cell.otherLike.backgroundColor = [UIColor clearColor];
    cell.likeButton.backgroundColor = [UIColor clearColor];
    if([switchPhoto.likedUsers containsObject:currentLoginID]){
        cell.likeButton.backgroundColor = RGBA(255, 0, 0, 64);
    }
    //switchPhoto.likedUsers
    cell.otherLike.backgroundColor = [UIColor clearColor];
    EZDEBUG(@"myself likedUsers:%@, liked other:%@", myPhoto.likedUsers, switchPhoto.likedUsers);
    if([myPhoto.likedUsers containsObject:switchPhoto.personID]){
        cell.otherLike.backgroundColor = RGBA(0, 255, 0, 64);
    }
    
    
    cell.likeButton.releasedBlock = ^(EZClickView* obj){
        EZDEBUG(@"Liked clicked");
        if(switchPhoto){
            BOOL liked = [switchPhoto.likedUsers containsObject:currentLoginID];
            EZDEBUG(@"photoID:%@, liked:%i, personID:%@", switchPhoto.photoID, liked, switchPhoto.personID);
            liked = !liked;
            UIColor* oldColor = obj.backgroundColor;
            obj.backgroundColor = RGBA(0, 0, 0, 60);
            obj.userInteractionEnabled = NO;
            [[EZDataUtil getInstance] likedPhoto:switchPhoto.photoID ownPhotoID:myPhoto.photoID like:liked success:^(id success){
                EZDEBUG(@"Liked successfully");
                obj.userInteractionEnabled = YES;
                if(liked){
                    switchPhoto.likedUsers = @[currentLoginID];
                    weakCell.likeButton.backgroundColor = RGBA(255, 0, 0, 64);
                }else{
                    switchPhoto.likedUsers = nil;
                    weakCell.likeButton.backgroundColor = [UIColor clearColor];
                        
                }
                [[EZDataUtil getInstance] storeAllPhotos:@[myPhoto]];
            } failure:^(id err){
                obj.userInteractionEnabled = YES;
                obj.backgroundColor = oldColor;
                EZDEBUG(@"Encounter like errors:%@", err);
            }];
        }
    };
    [self displayChat:cell ownerPhoto:myPhoto otherPhoto:switchPhoto];

    //__block NSString* staticFile = nil;
    cell.frontImage.tappedBlock = ^(id obj){
        //EZDEBUG(@"Send a message out");
        //[[EZMessageCenter getInstance] postEvent:EZNoteCountChange attached:@(2)];
        if(myPhoto.typeUI != kPhotoRequest){
            EZPhoto* swPhoto = [myPhoto.photoRelations objectAtIndex:0];
            //swPhoto.screenURL = @"http://192.168.1.102:8080/broken/49497";
            EZDEBUG(@"my photoID:%@, otherID:%@, otherPerson:%@, other photo upload:%i, other screenURL:%@", myPhoto.photoID,swPhoto.photoID, swPhoto.personID, swPhoto.uploaded, swPhoto.screenURL);
            //NSString* localURL = [[EZDataUtil getInstance] lo]
            //if(swPhoto){
            [weakSelf switchImage:weakCell displayPhoto:cp front:myPhoto back:swPhoto animate:YES path:indexPath];
            //}
        }else{
            EZDEBUG(@"photo request clicked: %@", myPhoto.photoID);
            //[self raiseCamera:cp indexPath:indexPath];
            dispatch_later(0.15, ^(){
            CATransform3D trans = CATransform3DRotate(CATransform3DIdentity, M_PI/6.0, 0.0, 1.0, 0.0);
            trans.m34 = 1/3000.0;
            
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
                weakCell.container.layer.transform = trans;
            } completion:^(BOOL complete){
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(){
                    weakCell.container.layer.transform = CATransform3DIdentity;
                } completion:nil];
            }];
            });
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
                macroHideStatusBar(NO);
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
        //[self setChatInfo:cell displayPhoto:cp.photo person:person];
    }else{
        EZPhoto* otherSide = nil;
        if(cp.photo.photoRelations.count){
            otherSide = [cp.photo.photoRelations objectAtIndex:0];
        }
        person = pid2person(otherSide.personID);
        //[self setChatInfo:cell displayPhoto:otherSide person:person];
    }
    
    
    cell.moreButton.releasedBlock = ^(id obj){
        //NSString* someText = self.textView.text;
        EZDEBUG(@"more clicked");
        //NSArray* dataToShare = @[@"我爱老哈哈"];  // ...or whatever pieces of data you want to share.
        //NSString *textToShare = self.navigationItem.title;
        //NSArray *itemsToShare = @[@"", [imagesArray objectAtIndex:afImgViewer.currentImage]];
        /**
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[weakCell.frontImage.image] applicationActivities:nil];
        //activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll   UIActivityTypeAssignToContact]; //or whichever you don't need
        [self presentViewController:activityVC animated:YES completion:nil];
        **/
        
         //UIActivityViewController* activityViewController =
        //[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
        //[self presentViewController:activityViewController animated:YES completion:^{
        //    EZDEBUG(@"Completed sharing");
        //}];
        
        
    };

    EZEventBlock curBlock = ^(EZPerson*  person){
        if(cell.currentPos == indexPath.row){
            cell.authorName.text = person.name;
            [cell.headIcon loadImageURL:person.avatar haveThumb:NO loading:NO];
        }
    };
    
    EZPerson* backPerson = pid2personCall(switchPhoto.personID, otherBlock);
    //if(backPerson){
    //    otherBlock(backPerson);
    //}
    EZPerson* frontPerson = pid2personCall(myPhoto.personID, curBlock);
    //if(frontPerson){
    //    curBlock(frontPerson);
    //}
    cell.otherIcon.releasedBlock = ^(id obj){
        /**
        EZPersonDetail* pd = [[EZPersonDetail alloc] initWithPerson:backPerson];
        //pd.modalPresentationStyle = UIModalPresentationPageSheet;
        //pd.transitioningDelegate = weakSelf;
        //pd.modalPresentationStyle = UIModalPresentationCustom;
        _isPushCamera = false;
        //pd.modalTransitionStyle
        //self.transitioningDelegate
        _leftCyleButton.hidden = YES;
        _rightCycleButton.hidden = YES;
        //[self presentViewController:pd animated:YES completion:^(){
        //}];
        [self.navigationController pushViewController:pd animated:YES];
         **/
        UIView* coverView = [weakCell snapshotViewAfterScreenUpdates:NO];
        [self.view addSubview:coverView];
        [self setCurrentUser:backPerson readyBlock:^(id obj){
            for(int i = 0; i < weakSelf.combinedPhotos.count; i++){
                EZDisplayPhoto* backDP = [weakSelf.combinedPhotos objectAtIndex:i];
                EZPhoto* backPhoto = [backDP.photo.photoRelations objectAtIndex:0];
                if([cp.photo.photoID isEqualToString:backDP.photo.photoID] && (!backPhoto || [backPhoto.photoID isEqualToString:switchPhoto.photoID])){
                    [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    break;
                }
            }
            [coverView removeFromSuperview];
        }];
    };
    
    
    cell.headIcon.releasedBlock = ^(id obj){
        //EZPersonDetail* pd = [[EZPersonDetail alloc] initWithPerson:frontPerson];
        //pd.transitioningDelegate = weakSelf;
        //pd.modalPresentationStyle = UIModalPresentationCustom;
        //_isPushCamera = false;
        //_leftCyleButton.hidden = YES;
        //_rightCycleButton.hidden = YES;
        //[self presentViewController:pd animated:YES completion:^(){
        //}];
        //[self.navigationController pushViewController:pd animated:YES];
        UIView* coverView = [weakCell snapshotViewAfterScreenUpdates:NO];
        [self.view addSubview:coverView];
        [self setCurrentUser:currentLoginUser readyBlock:^(id obj){
            for(int i = 0; i < weakSelf.combinedPhotos.count; i++){
                EZDisplayPhoto* backDP = [weakSelf.combinedPhotos objectAtIndex:i];
                EZPhoto* backPhoto = [backDP.photo.photoRelations objectAtIndex:0];
                if([cp.photo.photoID isEqualToString:backDP.photo.photoID] && (!backPhoto || [backPhoto.photoID isEqualToString:switchPhoto.photoID])){
                    [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    break;
                }
            }
            [coverView removeFromSuperview];
        }];
    };
    return cell;
}


- (void) refreshVisibleCell
{
    //self.tableView.visibleCells
    NSArray* visibleRows = self.tableView.indexPathsForVisibleRows;
    if(visibleRows.count){
        [self.tableView reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];
    }
}


-(id)initWithQueryBlock:(EZQueryBlock)queryBlock
{
    self = [super init]; //[super initWithStyle:UITableViewStylePlain];
    self.title = @"";//originalTitle;
    _queryBlock = queryBlock;
    //self.edgesForExtendedLayout=UIRectEdgeNone;
    [self createMoreButton];
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
    self = [super init];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (int) getPendingCount
{
    NSArray* persons = [EZDataUtil getInstance].currentQueryUsers.allValues;
    int totalPending = 0;
    for(EZPerson* person in persons){
        totalPending += person.pendingEventCount;
    }
    return totalPending;
}

- (void) setNoteCount
{
    int pendingCount = 0;
    if(_currentUser){
        pendingCount = _currentUser.pendingEventCount;
    }else{
        pendingCount = [self getPendingCount];
    }
    if(pendingCount){
        _numberLabel.alpha = 1;
        _numberLabel.text = int2str(pendingCount);
    }else{
        _numberLabel.alpha = 0;
    }
}

- (void) setCurrentUser:(EZPerson *)currentUser readyBlock:(EZEventBlock)readyBlock
{
    EZDEBUG(@"Will change the user from:%@ to %@", _currentUser, currentUser);
    
    if([currentUser.personID isEqualToString:currentLoginID]){
        if(_currentUser){
            _currentUser = nil;
            self.title = @"";
            //[[EZMessageCenter getInstance] postEvent:EZNoteCountSet attached:@([self getPendingCount])];
             [self setNoteCount];
            [_rightCycleButton setButtonStyle:kShotForAll];
            [_leftCyleButton setTitle:EZOriginalTitle forState:UIControlStateNormal];
            _leftCyleButton.titleLabel.font = EZTitleSlimFont;
            
            CGSize fitSize = [_leftCyleButton.titleLabel sizeThatFits:CGSizeMake(230, 40)];
            CGFloat width = fitSize.width > 230?230:fitSize.width;
            EZDEBUG(@"fit size width:%f", width);
            //[_leftText setWidth:fitSize.width];
            [_signRegion setX:width + 10];
            [_leftCyleButton setWidth:width + 2];
            [_combinedPhotos removeAllObjects];
            [_nonsplitted removeAllObjects];
            //
            if([EZDataUtil getInstance].mainPhotos.count){
                [_combinedPhotos addObjectsFromArray:[EZDataUtil getInstance].mainPhotos];
                [_nonsplitted addObjectsFromArray:[EZDataUtil getInstance].mainNonSplits];
            }else{
                NSArray* orgPhoto = [[EZDataUtil getInstance] getStoredPhotos];
                NSArray* splitted = [self splitPhotos:orgPhoto];
                [_combinedPhotos addObjectsFromArray:[self wrapPhotos:splitted]];
                [_nonsplitted addObjectsFromArray:orgPhoto];
            }
            
            EZDEBUG(@"The combined photo size:%i", _combinedPhotos.count);
            [self.tableView reloadData];
            if(readyBlock){
                readyBlock(nil);
            }else{
                [self scrollToBottom:NO];
            }
            
        }else{
            if(readyBlock){
                readyBlock(nil);
            }
            return;
        }
    }else if(![currentUser.personID isEqualToString:_currentUser.personID]){
        [_rightCycleButton setButtonStyle:kShotForOne];
        self.title = @""; //currentUser.name;
        if(!_currentUser && ![EZDataUtil getInstance].mainPhotos.count){
            
            [[EZDataUtil getInstance].mainPhotos addObjectsFromArray:_combinedPhotos];
            [[EZDataUtil getInstance].mainNonSplits addObjectsFromArray:_nonsplitted];
        }
        _currentUser = currentUser;
         [self setNoteCount];
        //_leftText.text = currentUser.name;
        //_leftText.font = smallFont;//[UIFont systemFontOfSize:20];
        //_leftText.font = EZLargeFont;//titleFontCN;
        [_leftCyleButton setTitle:currentUser.name forState:UIControlStateNormal];
        _leftCyleButton.titleLabel.font= EZLargeFont;
        CGSize fitSize = [_leftCyleButton.titleLabel sizeThatFits:CGSizeMake(230, 40)];
        CGFloat width = fitSize.width > 230?230:fitSize.width;
        EZDEBUG(@"fit size for string:%@, size:%f, width:%f", currentUser.name, fitSize.width, width);
        //[_leftText setWidth:fitSize.width];
        [_leftCyleButton setWidth:width + 2];
        [_signRegion setX:width + 10];
        [_combinedPhotos removeAllObjects];
        [_nonsplitted removeAllObjects];
        NSArray* storedPhoto = nil;
        
        if([EZDataUtil getInstance].mainPhotos.count){
            //[_combinedPhotos addObjectsFromArray:[EZDataUtil getInstance].mainPhotos];
            storedPhoto  = [EZDataUtil getInstance].mainPhotos;
            //[_nonsplitted addObjectsFromArray:[EZDataUtil getInstance].mainNonSplits];
        }else{
            storedPhoto = [[EZDataUtil getInstance] getStoredPhotos];
            //NSArray* splitted = [self splitPhotos:orgPhoto];
            //[_combinedPhotos addObjectsFromArray:[self wrapPhotos:splitted]];
            
            //[_nonsplitted addObjectsFromArray:orgPhoto];
        }
        EZDEBUG(@"Person All stored photos:%i, non splitted:%i", storedPhoto.count, _nonsplitted.count);
        for(EZDisplayPhoto* dp in storedPhoto){
            EZPhoto* ph = nil;
            for(int i = 0; i < dp.photo.photoRelations.count; i++){
                ph = [dp.photo.photoRelations objectAtIndex:i];
                if([ph.personID isEqualToString:currentUser.personID]){
                    if(dp.photo.photoRelations.count > 0){
                        if(dp.photo.type != kPhotoRequest){
                            dp.isFront = NO;
                        }
                    }
                    [_combinedPhotos addObject:dp];
                    [_nonsplitted addObject:dp.photo];
                }
            }
        }
        //[_nonsplitted addObjectsFromArray:_combinedPhotos];
        EZDEBUG(@"After search out:%i", _combinedPhotos.count);
        [self.tableView reloadData];
        if(readyBlock){
            readyBlock(nil);
        }else{
            [self scrollToBottom:NO];
        }
        //dispatch_later(0.2, ^(){
        //    self.tableView.contentOffset = CGPointMake(0, 0);
        //});
        [self loadMorePhoto:^(id obj){
            //if(!_combinedPhotos.count){
            //    [self.tableView reloadData];
            //}
            if(!readyBlock){
                [self scrollToBottom:NO];
            }
        } reload:YES pageSize:5];

    }else{
        if(readyBlock){
            readyBlock(nil);
        }
        return;
    }
    
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

- (void) loadMorePhoto:(EZEventBlock)completed reload:(BOOL)reload pageSize:(int)pageSize
{
    
    int pageStart = _nonsplitted.count/pageSize;
    EZDEBUG(@"Will load from %i", pageStart);
    [[EZDataUtil getInstance] queryPhotos:pageStart pageSize:pageSize otherID:_currentUser.personID success:^(EZResult* res){
        
        //EZDEBUG(@"Reloaded about %i rows of data, inset:%@", arr.count, NSStringFromUIEdgeInsets(self.tableView.contentInset));
        _totalCount = res.totalCount;
        //Assumption is that already have photo filled.
        [self reloadRows:res.result reload:reload];
        if(completed){
            completed(@(res.result.count));
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
    
    NSArray* visiblepaths = [self.tableView indexPathsForVisibleRows];
    EZDEBUG(@"visiblePaths:%i", visiblepaths.count);
    if(visiblepaths.count){
        NSIndexPath* path = [visiblepaths objectAtIndex:0];
        EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:path.row];
        if(dp.photo.typeUI == kPhotoRequest){
            _rightCycleButton.hidden = YES;
        }else{
            _rightCycleButton.hidden = NO;
        }
    }else{
        _rightCycleButton.hidden = NO;
    }
    _leftCyleButton.hidden = NO;
    [self.tableView refreshCustomScrollIndicatorsWithAlpha:0.0];
    //.hidden = NO;
    //[[UINavigationBar appearance] setBackgroundImage:ClearBarImage forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.view addSubview:[EZDataUtil getInstance].naviBarBlur];
    EZDEBUG(@"initial content inset:%@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[TopView addSubview:_progressBar];
    _progressBar.hidden = YES;
    _leftCyleButton.hidden = YES;
    _rightCycleButton.hidden = YES;
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
        
        if(cp.photo.photoRelations.count){
            EZPhoto* switchPhoto = [cp.photo.photoRelations objectAtIndex:0];
            //cp.isFront = !cp.isFront;
            EZDEBUG(@"prefetchDone:%i", switchPhoto.prefetchDone);
        
            [[EZDataUtil getInstance] prefetchImage:switchPhoto.screenURL success:^(UIImage* img){
                //[self switchAnimation:cp photoCell:cell indexPath:path tableView:self.tableView];
                [self switchImage:cell displayPhoto:cp front:cp.photo back:switchPhoto animate:NO path:path];
            } failure:nil];
        }
    }
    EZDEBUG(@"animFlip is done");
}

- (void) scrollToBottom:(BOOL)animated
{
    EZDEBUG(@"Scroll to bottom");
    if(!_combinedPhotos.count){
        return;
    }
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_combinedPhotos.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    
    self.tableView.contentOffset = CGPointMake(0, (_combinedPhotos.count - 1) * CurrentScreenHeight);
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


- (void) raiseCamera:(EZDisplayPhoto *)photo indexPath:(NSIndexPath *)indexPath
{
    [self raiseCamera:photo indexPath:indexPath personID:_currentUser.personID];
}

- (void) raiseCamera:(EZDisplayPhoto*)disPhoto indexPath:(NSIndexPath*)indexPath personID:(NSString*)personID
{
    
    //if(camera.isFrontCamera){
    //    [camera switchCamera];
    //}
    _isPushCamera = YES;
    _newlyCreated = 0;
    EZDEBUG(@"before present");
    if([EZUIUtility sharedEZUIUtility].cameraRaised || [EZUIUtility sharedEZUIUtility].stopRotationRaise){
        return;
    }

    
    //if(_picker == nil){
    DLCImagePickerController* camera = [[DLCImagePickerController alloc] init];
    //}
    //controller.prefersStatusBarHidden = TRUE;
    //camera.transitioningDelegate = _cameraAnimation;
    camera.delegate = self;
    //if(photo)
    //if(pers)
    camera.personID = personID;
    if(disPhoto){
        camera.personID = nil;
        camera.shotPhoto = disPhoto.photo;
        camera.disPhoto = disPhoto;
        camera.isPhotoRequest = true;
        camera.refreshTable = ^(id obj){
            //EZDEBUG("Refresh type:%i", photo.typeUI);
            disPhoto.photo.typeUI = kNormalPhoto;
            [[EZMessageCenter getInstance] postEvent:EZNoteCountChange attached:@(-1)];
            EZDEBUG("after Refresh type:%i, row:%i", disPhoto.photo.typeUI, indexPath.row);
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        };
    }

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
        [self raiseCamera:nil indexPath:nil];
    }else if(buttonIndex == 1){
        _picker.frontFacing = false;
        //_picker = [[DLCImagePickerController alloc] initWithFront:NO];
        [self raiseCamera:nil indexPath:nil];
    }
    _picker = nil;
}

- (void) pickPhotoType:(id)sender
{
    //UIActionSheet* photoSheet = [[UIActionSheet alloc] initWithTitle:@"拍摄类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"自拍", @"拍摄", nil];
    //[photoSheet showInView:self.view];
    //_picker = [[DLCImagePickerController alloc] init];
    [self raiseCamera:nil indexPath:nil];
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

-(void) refreshInvoked:(id)sender{
    // Refresh table here...
    //[_allEntries removeAllObjects];
    //[self.tableView reloadData];
    //[self refresh];
    EZDEBUG(@"refresh content inset:%@", NSStringFromUIEdgeInsets(self.tableView.contentInset));
    [self loadMorePhoto:^(NSNumber* obj){
        //[self endRefresh:obj.intValue];
        [self.refreshControl endRefreshing];
    }reload:NO pageSize:5];
     
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

/**
-(void) refreshView:(UIRefreshControl *)refresh
{
    //refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"更新数据中..."];
    
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"MMM d, h:mm a"];
    //NSString *lastUpdated = [NSString stringWithFormat:@"上次更新日期 %@",
                             [formatter stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [self initData];
    [_dataTableView reloadData];
    [refresh endRefreshing];
}
 **/

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.tableView refreshCustomScrollIndicatorsWithAlpha:0.0];
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    _combinedPhotos = [[NSMutableArray alloc] init];
    
    _nonsplitted = [[NSMutableArray alloc] init];
    //self.refreshControl = [[UIRefreshControl alloc] init];
    //[self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:)forControlEvents:UIControlEventValueChanged];
    //self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    //self.tableView.y = - 20;
    self.view.backgroundColor = VinesGray;
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.tableView enableCustomScrollIndicatorsWithScrollIndicatorType:JMOScrollIndicatorTypeClassic positions:JMOVerticalScrollIndicatorPositionRight color:[UIColor whiteColor]];
    [self.tableView registerClass:[EZPhotoCell class] forCellReuseIdentifier:@"PhotoCell"];
    [self.view addSubview:self.tableView];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self
                        action:@selector(refreshInvoked:)
              forControlEvents:UIControlEventValueChanged];
    //[_refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"松手更新数据"]];
    [self.tableView addSubview:_refreshControl];
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
        [_nonsplitted addObject:dp.photo];
        
        [[EZDataUtil getInstance].mainPhotos addObject:dp];
        [[EZDataUtil getInstance].mainNonSplits addObject:dp.photo];
        _totalCount++;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        //[self.tableView a]
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZRaisePersonDetail block:^(EZPerson* ps){
        EZPersonDetail* pd = [[EZPersonDetail alloc] initWithPerson:ps];
        //pd.modalPresentationStyle = UIModalPresentationPageSheet;
        //pd.transitioningDelegate = weakSelf;
        //pd.modalPresentationStyle = UIModalPresentationCustom;
        _isPushCamera = false;
        //pd.modalTransitionStyle
        //self.transitioningDelegate
        _leftCyleButton.hidden = YES;
        _rightCycleButton.hidden = YES;
        [self.navigationController pushViewController:pd animated:YES];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZAlbumImageReaded block:^(EZDisplayPhoto* dp){
        EZDEBUG(@"Recieved a image from album");
        [_combinedPhotos addObject:dp];
        [_nonsplitted addObject:dp];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZSetAlbumUser block:^(EZPerson* person){
        [self setCurrentUser:person readyBlock:nil];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZUserEditted block:^(EZPerson* person){
        [self refreshVisibleCell];
        [[EZDataUtil getInstance] storeAllPersons:@[person]];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZTriggerCamera block:^(id obj){
        //[weakSelf raiseCamera];
        [weakSelf raiseCamera:nil indexPath:nil personID:obj];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZNoteCountChange block:^(NSNumber* num){
        EZDEBUG(@"change notes:%i", num.intValue);
        [self setNoteCount];
    }];
    
    
    
    [[EZMessageCenter getInstance] registerEvent:EZNoteCountSet block:^(NSNumber* num){
        EZDEBUG(@"set notes count:%i", num.intValue);
        [self setNoteCount];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZRecievedNotes block:^(EZNote* note){
        EZDEBUG(@"Recieved notes:%@, notes:%@, pointer:%i", note.type, note.noteID, (int)note);
        if([@"match" isEqualToString:note.type]){
            //EZPhoto* matchedPhoto = note.matchedPhoto;
            //self.title = @"用户合照片";
            
            [self insertMatch:note];
        }else if([@"like" isEqualToString:note.type]){
            [self addLike:note];
        }else if([@"upload" isEqualToString:note.type]){
            [self insertUpload:note];
        }else if([EZNoteJoined isEqualToString:note.type]){
            EZPerson* ps = note.person;
            //[EZDataUtil getInstance].currentQueryUsers
            EZDEBUG(@"adjust the activity for person:%@", ps.personID);
            //[[EZDataUtil getInstance] adjustActivity:ps.personID];
            _leftMessageCount.hidden = NO;
        }else if([EZNoteFriendAdd isEqualToString:note.type]){
            
        }else if([EZNoteFriendKick isEqualToString:note.type]){
            
        }
    }];
    
    EZDEBUG(@"The login personID:%@, getID:%@", [EZDataUtil getInstance].currentPersonID, [[EZDataUtil getInstance] getCurrentPersonID]);
    
    EZEventBlock queryPhotoBlock = ^(EZPerson* user){
        EZDEBUG(@"newly login user:%@, id:%@", user.name, user.personID);
        if(user){
            //Mean new user are login.
            //[EZCoreAccessor cleanClientDB];
            //[[EZDataUtil getInstance] cleanDBPhotos];
            _numberLabel.alpha = 0;
            [_combinedPhotos removeAllObjects];
            [_nonsplitted removeAllObjects];
            [weakSelf.tableView reloadData];
            
        }
        NSArray* storedPhotos = [[EZDataUtil getInstance] getStoredPhotos];
        for(EZPhoto* photo in storedPhotos){
            [self updatePendingCount:photo];
        }
        NSArray* splitted = [self splitPhotos:storedPhotos];
        EZDEBUG(@"Total stored:%i, splitted:%i", storedPhotos.count, splitted.count);
        [_combinedPhotos addObjectsFromArray:[self wrapPhotos:splitted]];
        [_nonsplitted addObjectsFromArray:storedPhotos];
        [[EZDataUtil getInstance].mainPhotos addObjectsFromArray:_combinedPhotos];
        [[EZDataUtil getInstance].mainNonSplits addObjectsFromArray:_nonsplitted];
        EZDEBUG(@"The stored photo is %i", _combinedPhotos.count);
        [[EZDataUtil getInstance] queryPhotos:_nonsplitted.count pageSize:photoPageSize otherID:_currentUser.personID success:^(EZResult* res){
            _totalCount = res.totalCount;
            _currentUser.photoCount = _totalCount;
            if(!_currentUser){
                currentLoginUser.photoCount = _totalCount;
            }
            NSArray* arr = res.result;
            EZDEBUG(@"returned length:%i, total photo:%i", arr.count, _totalCount);
            //[_combinedPhotos addObjectsFromArray:arr];
            [self reloadFirst:arr totalCount:_totalCount];
            dispatch_later(0.1,
            ^(){
                [self scrollToBottom:NO];
                [self setNoteCount];
                //[self updatePendingCount:nil];
            });
        } failure:^(NSError* err){
            EZDEBUG(@"Error detail:%@", err);
        }];
    };
    if(currentLoginID){
        queryPhotoBlock(nil);
    }
    [[EZMessageCenter getInstance] registerEvent:EZUserAuthenticated block:queryPhotoBlock];

    _progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 20, 300, 10)];
    _progressBar.transform = CGAffineTransformMakeScale(1.0, 0.5);
    _progressBar.progressViewStyle = UIProgressViewStyleDefault;
    _progressBar.progressTintColor = [UIColor whiteColor];
    _progressBar.trackTintColor = [UIColor clearColor];
    _progressBar.hidden = YES;
    
    _networkStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CurrentScreenWidth, 20)];
    _networkStatus.textAlignment = NSTextAlignmentCenter;
    _networkStatus.textColor = [UIColor whiteColor];
    _networkStatus.font = [UIFont systemFontOfSize:12];
    [_networkStatus enableShadow:[UIColor blackColor]];
    [self.view addSubview:_networkStatus];
    _networkStatus.hidden = YES;
    
    dispatch_later(0.3, ^(){
        [self scrollToBottom:NO];
    });
    EZClickImage* bigClickButton = [[EZUIUtility sharedEZUIUtility] createBackShotButton];
    bigClickButton.center = CGPointMake(CurrentScreenWidth/2.0, CurrentScreenHeight - bigClickButton.frame.size.height/2.0 - 20);
    
    [self.view insertSubview:bigClickButton belowSubview:self.tableView];
    bigClickButton.releasedBlock = ^(id obj){
        [weakSelf raiseCamera:nil indexPath:nil];
    };
}

- (int) findPhoto:(NSString*)photoID matchID:(NSString*)matchID  photos:(NSArray*)photos
{
    for(int i = 0; i < photos.count; i ++){
        EZDisplayPhoto* dp = [photos objectAtIndex:i];
        if(dp.photo.photoRelations.count){
            EZPhoto* matchPhoto = [dp.photo.photoRelations objectAtIndex:0];
            if([photoID isEqualToString:dp.photo.photoID] && [matchPhoto.photoID isEqualToString:matchID]){
                return i;
            }
        }
    }
    return -1;
}

- (int) findMainPhoto:(NSString*)photoID matchID:(NSString*)matchID  photos:(NSArray*)photos
{
    for(int i = 0; i < photos.count; i ++){
        EZPhoto* photo = [photos objectAtIndex:i];
        if(photo.photoRelations.count){
            EZPhoto* matchPhoto = [photo.photoRelations objectAtIndex:0];
            if([photoID isEqualToString:photo.photoID] && [matchPhoto.photoID isEqualToString:matchID]){
                return i;
            }
        }
    }
    return -1;
}

- (void) insertUpload:(EZNote*)note
{
    
    int pos = [self findPhoto:note.srcID matchID:note.matchedID photos:_combinedPhotos];
    EZDEBUG(@"upload srcPhotoID:%@, uploaded:%i, matchedID:%@, uploaded:%i, position:%i, match type:%i", note.srcPhoto.photoID, note.srcPhoto.uploaded, note.matchedID, note.matchedPhoto.uploaded, pos, note.matchedPhoto.type);
    if(pos <  0){
        EZDEBUG(@"Quit for not find the id:%@, let's find in total photos:%i", note.srcID, [EZDataUtil getInstance].mainNonSplits.count);
        pos = [self findPhoto:note.srcID matchID:note.matchedID photos:[EZDataUtil getInstance].mainPhotos];
        EZDisplayPhoto* disPhoto = [[EZDataUtil getInstance].mainPhotos objectAtIndex:pos];
        disPhoto.isFront = NO;
        disPhoto.photo.photoRelations = @[note.matchedPhoto];
        disPhoto.isFirstTime = YES;
        [[EZDataUtil getInstance] storeAllPhotos:@[disPhoto.photo]];
        return;
    }
    
    EZDisplayPhoto* disPhoto = [_combinedPhotos objectAtIndex:pos];
    disPhoto.isFront = NO;
    disPhoto.photo.photoRelations = @[note.matchedPhoto];
    disPhoto.isFirstTime = YES;
    //[[EZMessageCenter getInstance] postEvent:EZNoteCountChange attached:@(1)];
    //EZPerson* otherPerson = pid2person(note.matchedPhoto.personID);
    //otherPerson.pendingEventCount += 1;
    [[EZDataUtil getInstance] storeAllPhotos:@[disPhoto.photo]];
    EZDEBUG(@"matchedPhoto converstion:%@, url:%@, disPhotoID:%@", note.matchedPhoto.conversations, note.matchedPhoto.screenURL, disPhoto.photo.photoID);
    //disPhoto.photo = note.srcPhoto;
    //[_combinedPhotos addObject:disPhoto];
    //preloadimage(note.matchedPhoto.screenURL);
    //[[EZDataUtil getInstance] preloadImage:note.matchedPhoto.screenURL success:^(id sender) {
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:pos  inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    //} failed:^(id obj){}];
    return;
    //}
}

- (void) changeButtonColor:(BOOL)normal
{
    
}

- (void) insertMatch:(EZNote*)note
{
    
    //This is a photo request
    //Let's simply insert the photo to the beginning and see what's going on.
    EZPhoto* matched = note.matchedPhoto;
    if(!note.matchedPhoto){
        return;
    }
    //if(note.srcPhoto.photoRelations.count > 0){
        //matched = [note.srcPhoto.photoRelations objectAtIndex:0];
       
    //}
    EZDEBUG(@"srcPhotoID:%@,matchID:%@ uploaded:%i, matched:%@, type:%i", note.srcPhoto.photoID,note.matchedID, note.srcPhoto.uploaded, matched.photoID, note.srcPhoto.type);
    
    /**
    if(note.srcPhoto && !note.srcPhoto.uploaded){
        EZDisplayPhoto* disPhoto = [[EZDisplayPhoto alloc] init];
        disPhoto.isFront = YES;
        disPhoto.photo = note.srcPhoto;
        note.srcPhoto.photoRelations = @[note.matchedPhoto];
        [_combinedPhotos addObject:disPhoto];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count - 1  inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        return;
    }
     **/
    
    //if(note.senderPerson){
    //    EZDEBUG(@"match Sender person is:%@", note.senderPerson);
    //}
    
    if(note.srcPhoto.type){
        EZDEBUG(@"This is a photoRequest srcID:%@, UI type:%i, matchID:%@,relations:%i, dataMainPhoto:%i, dataNonSplit:%i, currentID:%@", note.srcPhoto.photoID,note.srcPhoto.typeUI, note.matchedPhoto.photoID, note.srcPhoto.photoRelations.count, [EZDataUtil getInstance].mainPhotos.count, [EZDataUtil getInstance].mainNonSplits.count, _currentUser.name);
        EZDisplayPhoto* disPhoto = [[EZDisplayPhoto alloc] init];
        disPhoto.isFront = YES;
        disPhoto.photo = note.srcPhoto;
        note.srcPhoto.photoRelations = @[note.matchedPhoto];
        note.srcPhoto.createdTime = [NSDate date];
        [[EZDataUtil getInstance] storeAllPhotos:@[note.srcPhoto]];
        
        //if(_currentUser){
        [[EZDataUtil getInstance].mainPhotos addObject:disPhoto];
        [[EZDataUtil getInstance].mainNonSplits addObject:note.srcPhoto];
        //}
        if(_currentUser && ![note.matchedPhoto.personID isEqualToString:_currentUser.personID]){
            EZDEBUG(@"Quit for not displayable");
            return;
        }
        //disPhoto.isFirstTime = NO;
        EZPerson* ps =  [[EZDataUtil getInstance]updatePerson:note.senderPerson];
        //ps.pendingEventCount += 1;
        [ps adjustPendingEventCount:1];
        //[ps save];
        //[[EZDataUtil getInstance]storeAllPersons:@[ps]];
        //[_combinedPhotos insertObject:disPhoto atIndex:_combinedPhotos.count];
        [_combinedPhotos addObject:disPhoto];
        [[EZMessageCenter getInstance] postEvent:EZNoteCountChange attached:@(1)];
        [_nonsplitted addObject:note.srcPhoto];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        return;
        
    }
    
    NSArray* matchedArrs = nil;
    //if(_currentUser == nil && [_currentUser.personID isEqualToString:note.otherID]){
    //    matchedArrs = [[NSArray alloc] initWithArray:_combinedPhotos];
    //}else{
    matchedArrs = [[NSArray alloc] initWithArray:[EZDataUtil getInstance].mainNonSplits];
    //}
    //NSMutableArray* matchedPhotos = [[NSMutableArray alloc] init];
    int pos = -1;
    BOOL alreadyIn = false;
    for (int i = 0; i < matchedArrs.count; i++) {
        EZPhoto* ph = [matchedArrs objectAtIndex:i];
        if([ph.photoID isEqualToString:note.srcID]){
            //[matchedPhotos addObject:ph];
            if(pos < 0){
                pos = i;
            }
            if(ph.photoRelations.count){
                EZPhoto* match = [ph.photoRelations objectAtIndex:0];
                if([match.photoID isEqualToString:note.matchedID]){
                    EZDEBUG(@"Already matched");
                    alreadyIn = true;
                    break;
                }
            }
        }
    }
    
     EZDEBUG(@"Will insert the newly matched at pos:%i, _combined length:%i, aleadyIn:%i", pos, _combinedPhotos.count, alreadyIn);
    if(alreadyIn){
        return;
    }
    if(pos < 0){
        EZDEBUG(@"Quit for not find, mean don't load this photo so far");
        return;
    }
   
    EZPhoto* orgin = [matchedArrs objectAtIndex:pos];
    NSMutableArray* ma = [[NSMutableArray alloc] initWithArray:orgin.photoRelations];
    [ma addObject:note.matchedPhoto];
    orgin.photoRelations = ma;
    [[EZDataUtil getInstance] storeAllPhotos:@[orgin]];
    
    EZPhoto* cloned = orgin.copy;
    cloned.photoRelations = @[note.matchedPhoto];
    EZDisplayPhoto* disPhoto = [[EZDisplayPhoto alloc] init];
    disPhoto.isFront = NO;
    disPhoto.photo = cloned;
    disPhoto.isFirstTime = YES;
    EZPerson* ps = [[EZDataUtil getInstance] updatePerson:note.senderPerson];
    //ps.pendingEventCount += 1;
    [ps adjustPendingEventCount:1];
    //[ps save];
    //[[EZDataUtil getInstance]storeAllPersons:@[ps]];
    [[EZMessageCenter getInstance] postEvent:EZNoteCountChange attached:@(1)];
    //if(_currentUser){
        //[[EZDataUtil getInstance].mainPhotos addObject:disPhoto];
    NSArray* photos = [NSArray arrayWithArray:[EZDataUtil getInstance].mainPhotos];
    for(int i = 0; i < photos.count; i++){
            EZDisplayPhoto* dp = [photos objectAtIndex:i];
            if([dp.photo.photoID isEqualToString:disPhoto.photo.photoID]){
                [[EZDataUtil getInstance].mainPhotos insertObject:disPhoto atIndex:i];
                break;
            }
    }
    //}
    if(_currentUser && ![note.matchedPhoto.personID isEqualToString:_currentUser.personID]){
        EZDEBUG(@"Quit for not displayable");
        return;
    }
    EZDEBUG(@"Recieved match event from:%@, totalCount:%i,otherID:%@, photoID:%@", ps.name, ps.pendingEventCount, note.otherID, note.srcPhoto.photoID);
    for(int i = 0; i < _combinedPhotos.count; i++){
        EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:i];
        if([dp.photo.photoID isEqualToString:disPhoto.photo.photoID]){
            [_combinedPhotos insertObject:disPhoto atIndex:i];
            //[self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            break;
            //[self.tableView endUpdates];
        }
    }
    
}

//I alway search from the non-split
- (void) saveMatchedPhoto:(EZNote*)note
{
    
}


- (NSMutableArray*) splitPhotos:(NSArray*)photos
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    for(EZPhoto* pt in photos){
        //EZDEBUG(@"photo comments:%@", pt.conversations);
        for(EZPhoto* subPt in pt.photoRelations){
            EZPhoto* orgCopy = pt.copy;//[pt copyWithZone:nil];
            //EZDEBUG(@"copy comments:%@", orgCopy.conversations);
            orgCopy.photoRelations = @[subPt];
            [res addObject:orgCopy];
        }
    }
    return res;
}

- (void) addLike:(EZNote*)note
{
    NSArray* matchedArrs = [[NSArray alloc] initWithArray:_combinedPhotos];
    for (int i = 0; i < matchedArrs.count; i++) {
        EZPhoto* ph = ((EZDisplayPhoto*)[matchedArrs objectAtIndex:i]).photo;
        if([ph.photoID isEqualToString:note.photoID]){
            EZDEBUG(@"like operation:%@, like:%i", note.photoID, note.like);
                  if(note.like){
                        if(![ph.likedUsers containsObject:note.otherID]){
                            [ph.likedUsers addObject:note.otherID];
                        }
                    }else{
                        //if([ph.likedUsers containsObject:note.otherID]){
                        [ph.likedUsers removeObject:note.otherID];
                        //}
                    }
                    [[EZDataUtil getInstance] storeAllPhotos:@[ph]];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    break;
                //}
            //}
        }
    }

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

- (EZPhoto*) existed:(NSString*)pid
{
    NSArray* totalNonSplit = [EZDataUtil getInstance].mainNonSplits;
    for(int i = 0; i < totalNonSplit.count; i ++){
        EZPhoto* photo = [totalNonSplit objectAtIndex:i];
        if([photo.photoID isEqualToString:pid]){
            return photo;
        }
    }
    return nil;
}

- (EZDisplayPhoto*) wrapPhoto:(EZPhoto*)photo
{
    EZDisplayPhoto* ed = [[EZDisplayPhoto alloc] init];
    if(photo.type)
        ed.isFront = TRUE;
    else
        ed.isFront = false;

    ed.photo = photo;
    photo.isLocal = true;
    return ed;
}

//The purpose of this method
//Is to load all the photos into the
//Reload the photo from the images
- (void) reloadFirst:(NSArray*)photos totalCount:(int)totalCount
{
    int count = 0;
    NSMutableArray* stored = [[NSMutableArray alloc] init];
    for(EZPhoto* pt in photos){
        EZPhoto* finded = [self existed:pt.photoID];
        if(!finded){
            [self updatePendingCount:pt];
            //EZDEBUG(@"Transfer the image to EZDisplayPhoto successfully, personID:%@",pt.personID);
            NSArray* splitted = [self splitPhotos:@[pt]];
            for(EZPhoto* sp in splitted){
                EZDisplayPhoto* dp = [self wrapPhoto:sp];
                [_combinedPhotos insertObject:dp atIndex:0];
                [[EZDataUtil getInstance].mainPhotos addObject:dp];
                
                count ++;
            }
            [[EZDataUtil getInstance].mainNonSplits addObject:pt];
            [_nonsplitted insertObject:pt atIndex:0];
            [stored addObject:pt];
        }
    }
    _fillCount = totalCount - _nonsplitted.count;
    EZDEBUG(@"total count:%i, _combinedPhoto:%i, non-splitCount:%i, fillCount:%i", totalCount, _combinedPhotos.count, _nonsplitted.count, _fillCount);
    
    //for(int i = 0; i < _fillCount; i ++){
    //    EZDisplayPhoto* dp = [[EZDisplayPhoto alloc] init];
    //    dp.isPlaceHolder = true;
    //    [_combinedPhotos insertObject:dp atIndex:0];
    //}
    [[EZDataUtil getInstance] storeAllPhotos:stored];
    [self.tableView reloadData];
}

- (int) findPlaceHolder
{
    //int res = -1;
    for(int i = 0; i < _combinedPhotos.count; i++){
        EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:i];
        if(dp.isPlaceHolder){
            return i;
        }
    }
    return -1;
}


//Return true if it is update
//Return false if it is add
- (BOOL) fillCombinePhotos:(EZPhoto*)photo
{
    //int placePos = [self findPlaceHolder];
    //if(placePos >= 0){
    //    EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:placePos];
    //    dp.photo = photo;
    //    dp.isPlaceHolder = false;
    //    dp.isFront = NO;
    //    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:placePos inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    //    return true;
    //}else{
    //if(placePos >= 0){
    EZDisplayPhoto* dp = [self wrapPhoto:photo];
    [_combinedPhotos insertObject:dp atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    return false;
     //}
    //}
}

//What's the purpose of this function?
//To find out the person and add the pendingCount to it.
- (void) updatePendingCount:(EZPhoto*)photo
{
    EZPhoto* matched = [photo.photoRelations objectAtIndex:0];
    EZPerson* ps = pid2person(matched.personID);
    EZDEBUG(@"stored person id:%@, other id:%@", photo.personID, matched.personID);
    if(photo.type == kPhotoRequest){
        [ps adjustPendingEventCount:1];
    }else{
        if(matched.type == kPhotoRequest){
            [ps adjustPendingEventCount:1];
        }
    }
}

- (void) reloadRows:(NSArray*)photos reload:(BOOL)reload
{
    int count = 0;
    NSMutableArray* stored = [[NSMutableArray alloc] init];
    for(EZPhoto* pt in photos){
        EZPhoto* finded = [self existed:pt.photoID];
        if(!finded){
            [self updatePendingCount:pt];
            EZDEBUG(@"reload successfully, personID:%@",pt.personID);
            NSArray* splitted = [self splitPhotos:@[pt]];
            for(EZPhoto* sp in splitted){
                //EZDisplayPhoto* dp = [self wrapPhoto:sp];
                //[_combinedPhotos insertObject:dp atIndex:0];
                [self fillCombinePhotos:sp];
                
                count ++;
            }
            [_nonsplitted insertObject:pt atIndex:0];
            [stored addObject:pt];
        }else{
            
        }
        
    }
    [[EZDataUtil getInstance] storeAllPhotos:stored];
    EZDEBUG(@"newly loaded count:%i", count);
    //if(photos.count && reload){
    //    [self.tableView reloadData];
    //}
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
    //[UIView animateWithDuration:0.25 animations:^{
    //}];
    [EZDataUtil getInstance].centerButton.hidden = NO;
    //if(!_progressBar.superview){
    //    [TopView addSubview:_progressBar];
    //}
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
    //[self.refreshControl setPosition:CGPointMake(230, 64)];
    self.refreshControl.y = 64;
    self.refreshControl.alpha = 0;
    self.navigationItem.titleView = [[UIView alloc] init];
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    /**
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
     **/
    EZHairButton* clickView = [[EZUIUtility sharedEZUIUtility] createShotButton];
    clickView.releasedBlock = ^(id obj){
        [weakSelf raiseCamera:nil indexPath:nil];
    };
    //clickView.center = CGPointMake(160, bounds.size.height - (30 + 5));
    [TopView addSubview:clickView];
    //EZDEBUG(@"View will Appear:%@", NSStringFromCGRect(TopView.frame));
    UIView* statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBarBackground.backgroundColor = EZStatusBarBackgroundColor;
    //[TopView addSubview:statusBarBackground];
    [EZDataUtil getInstance].barBackground = statusBarBackground;
    //[EZDataUtil getInstance].centerButton = clickView;
    _rightCycleButton = clickView;
    
    [[EZMessageCenter getInstance] registerEvent:EZShowShotButton block:^(EZEventBlock blk){
        EZDEBUG(@"Show the shot button");
        clickView.releasedBlock = blk;
        clickView.hidden = NO;
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZRecoverShotButton block:^(id obj){
        clickView.releasedBlock = ^(id obj){
            [weakSelf raiseCamera:nil indexPath:nil];
        };
    }];
    
    //_leftContainer = [[UIView alloc] initWithFrame:CGRectMake(12,30, 120, 46)];
    //_leftContainer.backgroundColor = [UIColor clearColor];
    
    _leftCyleButton = [[UIButton alloc] initWithFrame:CGRectMake(10,25, 120, 46)];
    _leftCyleButton.titleLabel.font = EZTitleSlimFont;
    [_leftCyleButton setTitleColor:ClickedColor forState:UIControlStateHighlighted];
    [_leftCyleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _leftCyleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_leftCyleButton setTitle:@"feather" forState:UIControlStateNormal];
    //_leftCyleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    //_leftCyleButton.layer.borderWidth = 2;
    //_leftText = [[UILabel alloc] initWithFrame:CGRectMake(0, -5, 120, 46)];
    //_leftText.font = EZTitleSlimFont;
    //_leftText.textAlignment = NSTextAlignmentLeft;
    //_leftText.text = @"feather";
    //_leftText.textColor = [UIColor whiteColor];
    //[_leftCyleButton addSubview:_leftText];
    
    CGSize reginSize = [_leftCyleButton.titleLabel sizeThatFits:CGSizeMake(999, 40)];
    
    _signRegion = [[UIView alloc] initWithFrame:CGRectMake(reginSize.width + 10,  0, 20, 46)];
    
    _numberLabel = [[EZUIUtility sharedEZUIUtility] createNumberLabel];
    _numberLabel.alpha = 0;
    
    _triangler = [[EZTrianglerView alloc] initWithFrame:CGRectMake(0,  21, 7, 4)];
    [_signRegion addSubview:_triangler];
    [_signRegion addSubview:_numberLabel];
    
    [_leftCyleButton addSubview:_signRegion];
    //_leftCyleButton.enableTouchEffects = FALSE;
    //[_triangler enableShadow:[UIColor whiteColor]];
    
    //[_leftCyleButton enableRoundImage];
    
    _leftMessageCount = [[UIView alloc] initWithFrame:CGRectMake(4, 0, 12, 12)];
    _leftMessageCount.layer.borderColor = [UIColor whiteColor].CGColor;
    _leftMessageCount.layer.borderWidth = 1;
    _leftMessageCount.backgroundColor = RGBCOLOR(255, 30, 10);
    [_leftMessageCount enableRoundImage];
    _leftMessageCount.hidden = YES;
    //[_leftContainer addSubview:_leftCyleButton];
    //[_leftContainer addSubview:_leftMessageCount];
    
    [TopView addSubview:_leftCyleButton];
    
    [_leftCyleButton addTarget:self action:@selector(titleClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) titleClicked:(id)obj
{
    _leftMessageCount.hidden = YES;
    
    //dispatch_later(0.3, ^(){
    //[weakSelf.leftText setTextColor:[UIColor whiteColor]];
    //});
    [self showMenu:nil];

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


/**
- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, 20)];
    sectionView.backgroundColor = RGBCOLOR(200, 100, 0);
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, 20)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    label.backgroundColor = [UIColor clearColor];
    [sectionView addSubview:label];
    label.text = [NSString stringWithFormat:@"section:%i", section];
    EZDEBUG(@"return section view:%i", (int)sectionView);
    return sectionView;
}
**/

/**
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
**/

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


- (void) loadFrontImage:(EZPhotoCell*)weakCell photo:(EZPhoto*)photo file:(NSString*)assetURL path:(NSIndexPath*)path
{
  
    if([EZFileUtil isFileExist:assetURL isURL:NO]){
        EZDEBUG("File exist");
        [weakCell.frontImage setImage:[photo getScreenImage]];
    }else{
        EZDEBUG(@"file not exist load from url:%@", photo.screenURL);
        [self loadImage:weakCell url:photo.screenURL retry:2 path:path];
    }
}

- (void) loadImage:(EZPhotoCell*)weakCell  url:(NSString*)secondURL retry:(int)count path:(NSIndexPath*)path
{
    //NSString* secondURL = @"http://192.168.1.102:8080/static/5666df6256e9504dd8b5f6a4b21edbac.jpg";
    UIActivityIndicatorView* ai = weakCell.activityView;
    [ai stopAnimating];
    ai.hidden = YES;
    __block BOOL loaded = false;
    __weak EZAlbumTablePage* weakSelf = self;
    //weakCell.frontImage.image = nil;
    //weakCell.frontImage.backgroundColor = ClickedColor;
    
    int rotateCount = weakCell.rotateCount;
    //EZDEBUG(@"image loading start");
    [[EZDataUtil getInstance] serialLoad:secondURL fullOk:^(NSString* localURL){
        //EZDEBUG(@"image loaded full:%i, url:%@", loaded, localURL);
        if(weakCell.currentPos != path.row || rotateCount != weakCell.rotateCount){
            return;
        }
        [ai stopAnimating];
        //[ai removeFromSuperview];
        ai.hidden = YES;
        if(!loaded){
            loaded = true;
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
        if(weakCell.currentPos != path.row || rotateCount != weakCell.rotateCount){
            return;
        }
        if(!loaded){
            loaded = true;
            if(!ai.isAnimating){
                [ai startAnimating];
            }
            UIImage* blurred = [fileurl2image(localURL) createBlurImage:15.0];
            weakCell.frontImage.image = blurred;
        }
    } pending:^(id obj){
        //[weakCell.frontImage addSubview:ai];
        ai.hidden = NO;
        [ai startAnimating];
    } failure:^(id err){
        EZDEBUG(@"failure get called: retry:%i", count);
        //EZDEBUG(@"err:%@", err);
        //[[EZUIUtility sharedEZUIUtility] showErrorInfo:macroControlInfo(@"Network not available") delay:1.0 view:self.view];
        if(weakCell.currentPos != path.row || weakCell.rotateCount != rotateCount){
            return;
        }
        //if(count < 3){
        //    [weakSelf loadImage:weakCell url:secondURL retry:count + 1 path:path];
        //}
        //[ai stopAnimating];
        //[ai removeFromSuperview];
    }];
}


- (void) displayChat:(EZPhotoCell*)cell ownerPhoto:(EZPhoto*)ownp otherPhoto:(EZPhoto*)otherp
{
    
    EZDEBUG(@"own Conversation count:%i, other count:%i", ownp.conversations.count, otherp.conversations.count);
    if(ownp.conversations.count){
        NSDictionary* conversation = [ownp.conversations objectAtIndex:0];
        cell.ownTalk.text = [conversation objectForKey:@"text"];
    }else{
        cell.ownTalk.text = @"";
    }
    
    if(otherp.conversations.count){
        NSDictionary* conversation = [otherp.conversations objectAtIndex:0];
        cell.otherTalk.text = [conversation objectForKey:@"text"];
    }else{
        cell.otherTalk.text = @"";
    }
}

/**
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

**/
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


- (void) setWaitingInfo:(EZPhotoCell*)cell displayPhoto:(EZDisplayPhoto*)cp back:(EZPhoto*)back
{
    EZDEBUG(@"setWaitingInfo get called:%i, %i", back.typeUI, back
            .type);
    EZPerson* otherPerson = pid2person(back.personID);
    if(back.type == kPhotoRequest || ([cp.photo.exchangePersonID isNotEmpty] && back==nil)){
        cell.frontImage.image = nil;
        cell.frontImage.backgroundColor = ClickedColor;
        cell.waitingInfo.text =[NSString stringWithFormat:@"等待\"%@\"的照片", otherPerson.name?otherPerson.name:@"朋友"];
        cell.waitingInfo.hidden = NO;
        cell.otherIcon.hidden = YES;
        cell.otherName.hidden = YES;
        cell.andSymbol.hidden = YES;
        cell.ownTalk.hidden = YES;
        cell.authorName.hidden = YES;
        cell.headIcon.hidden = YES;
    }else{
        cell.waitingInfo.hidden = YES;
    }
}

- (void) switchImage:(EZPhotoCell*)weakCell displayPhoto:(EZDisplayPhoto*)cp front:(EZPhoto*)front back:(EZPhoto*)back animate:(BOOL)animate path:(NSIndexPath*)path
{
    
    EZPhoto* photo = nil;
    NSString* localFull = checkimageload(back.screenURL);
    EZDEBUG(@"try to local url:%@, local:%@, back is:%i, back type:%i", back.screenURL, localFull, (int)back, back.type);
    //if(!localFull && !back.type){
    //    return;
    //}
    weakCell.rotateCount += 1;
    if(animate){
        UIView* snapShot = [weakCell.frontImage snapshotViewAfterScreenUpdates:YES];
        snapShot.frame = weakCell.frontImage.frame;
        [weakCell.rotateContainer addSubview:snapShot];
        
        weakCell.frontImage.image = nil;
        if(cp.isFront){
            photo = back;
            [weakCell setFrontFormat:false];
            [self setWaitingInfo:weakCell displayPhoto:cp back:back];
            if(back.type == kPhotoRequest || ([cp.photo.exchangePersonID isNotEmpty] && back == nil)){
                //weakCell.frontImage.image = [UIImage imageNamed:@"background.png"];
                EZDEBUG(@"waiting for response");
            }else if(photo == nil){
                //weakCell.frontImage.image = nil;
                [[EZUIUtility sharedEZUIUtility] showErrorInfo:macroControlInfo(@"Network not available") delay:1.0 view:self.view];
            }
            else
            {
                [self loadImage:weakCell url:photo.screenURL retry:0 path:path];
            }
        }else{
            photo = front;
            [weakCell setFrontFormat:true];
            weakCell.waitingInfo.hidden = YES;
            //[weakCell.frontImage setImage:[front getScreenImage]];
            [self loadFrontImage:weakCell photo:front file:front.assetURL path:path];
        }
        
        
    
        dispatch_later(0.15, ^(){
        [UIView flipTransition:snapShot dest:weakCell.frontImage container:weakCell.rotateContainer isLeft:YES duration:EZRotateAnimDuration complete:^(id obj){
            [snapShot removeFromSuperview];
            EZPerson* person = pid2person(photo.personID);
            EZDEBUG(@"person id:%@, name:%@", photo.personID, person.name);
            //[self setChatInfo:weakCell displayPhoto:photo person:person];
            //[weakCell.headIcon setImageWithURL:str2url(person.avatar)];
            //weakCell.authorName.text = person.name;
            //EZDEBUG(@"rotation completed:%i", (int)[snapShot superview]);
        }];}
       );
    }else{
        weakCell.frontImage.image = nil;
        if(cp.isFront){
            photo = back;
            [self setWaitingInfo:weakCell displayPhoto:cp back:back];
            if(back.type == kPhotoRequest){
                //weakCell.frontImage.image = [UIImage imageNamed:@"background.png"];
                
            }
            else if(photo == nil){
                [[EZUIUtility sharedEZUIUtility] showErrorInfo:macroControlInfo(@"Network not available") delay:1.0 view:self.view];
            }

            else{
                weakCell.waitingInfo.hidden = YES;
                [self loadImage:weakCell url:photo.screenURL retry:0 path:path];
            }
        }else{
            photo = front;
            //[weakCell.frontImage setImage:[front getScreenImage]];
            [self loadFrontImage:weakCell photo:front file:front.assetURL path:path];
        }
        //EZPerson* person = pid2person(photo.personID);
        //[self setChatInfo:weakCell displayPhoto:photo person:pid2person(photo.personID)];
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
            [self raiseCamera:nil indexPath:nil];
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
    
    EZDEBUG(@"_raiseAnimated");
    _raiseAnimation.type = AnimationTypePresent;
    return _raiseAnimation;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    EZDEBUG(@"_dismissAnimation");
    _raiseAnimation.type = AnimationTypeDismiss;
    //dispatch_later(0.3, ^(){
    //_leftContainer.hidden = NO;
    //_rightCycleButton.hidden = NO;
    //});
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
