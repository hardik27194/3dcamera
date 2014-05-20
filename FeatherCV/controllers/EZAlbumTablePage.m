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
#import "EZScrollViewer.h"
#import "EZEnlargedView.h"
#import "EZMotionImage.h"
#import "EZMotionRecord.h"





static int photoCount = 1;
@interface EZAlbumTablePage ()

@property (nonatomic, strong) EZMotionImage* mi;

@end

@implementation EZAlbumTablePage


- (void) setEmptyInfo:(EZPhotoCell*)cell isEmpty:(BOOL)isEmpty
{
    __weak EZAlbumTablePage* weakSelf = self;
    //if(back.type == kPhotoRequest || ([cp.photo.exchangePersonID isNotEmpty] && back==nil)){
    if(isEmpty){
        cell.frontImage.image = nil;
        cell.frontImage.backgroundColor = ClickedColor;
        cell.requestFixInfo.text = @"";
        //cell.waitingInfo.text =@"我拍故我在";//[NSString stringWithFormat:@"等待\"%@\"的照片", otherPerson.name?otherPerson.name:@"朋友"];
        cell.waitingInfo.hidden = YES;
        cell.otherIcon.hidden = YES;
        cell.otherName.hidden = YES;
        cell.andSymbol.hidden = YES;
        cell.ownTalk.hidden = YES;
        cell.authorName.hidden = YES;
        cell.headIcon.hidden = YES;
        cell.cameraView.hidden = NO;
        cell.otherTalk.hidden = YES;
        cell.shotPhoto.hidden = NO;
        cell.shotPhoto.releasedBlock = ^(id obj){
            [weakSelf raiseCamera:nil indexPath:nil personID:_currentUser.personID];
        };
        
        cell.frontImage.tappedBlock = nil;
    }else{
        cell.requestFixInfo.text = @"拍摄后翻看";
        
    }

}

- (int) findPhotoByID:(NSString*)photoID photos:(NSArray*)photos
{
    for(int i = 0 ; i < photos.count; i ++){
        EZDisplayPhoto* dp = [photos objectAtIndex:i];
        if([dp.photo.photoID isEqualToString:photoID]){
            return i;
        }
    }
    return -1;
}

- (void) setHeart:(EZPhoto*)forward back:(EZPhoto*)back cell:(EZPhotoCell*)cell
{
    if([back.likedUsers containsObject:currentLoginID] && [forward.likedUsers containsObject:back.personID]){
        //cell.likeButton.backgroundColor = RGBA(255, 0, 0, 64);
        //likedByMe = true;
        //[cell.likeButton setImage:FullHeartImage forState:UIControlStateNormal];
        //[cell.likeButton setTitleColor:EZAllLikeColor forState:UIControlStateNormal];
        cell.leftHalf.hidden = NO;
        cell.rightHalf.hidden = NO;
        //[cell.likeButton setImage:LeftHeartImage forState:UIControlStateNormal];
    }else if([back.likedUsers containsObject:currentLoginID]){
        //[cell.likeButton setImage:LeftHeartImage forState:UIControlStateNormal];
        //[cell.likeButton setTitleColor:EZOwnColor forState:UIControlStateNormal];
        cell.leftHalf.hidden = NO;
        cell.rightHalf.hidden = YES;
        
    }else if([forward.likedUsers containsObject:back.personID]){
        
        //[cell.likeButton setImage:RightHeartImage forState:UIControlStateNormal];
        //[cell.likeButton setTitleColor:EZOtherColor forState:UIControlStateNormal];
        cell.leftHalf.hidden = YES;
        cell.rightHalf.hidden = NO;
    }else{
        //[cell.likeButton setImage:EmptyHeartImage forState:UIControlStateNormal];
        //[cell.likeButton setTitleColor:EZEmptyColor forState:UIControlStateNormal];
        cell.leftHalf.hidden = YES;
        cell.rightHalf.hidden = YES;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EZDEBUG(@"cellForRow Called:%i", indexPath.row);
    
    /**
     if(_combinedPhotos.count <= indexPath.row){
     UITableViewCell* bottomCell = [tableView dequeueReusableCellWithIdentifier:@"BottomCell"];
     [bottomCell addSubview:_bottomView];
     return bottomCell;
     }
     **/
    static NSString *CellIdentifier = @"PhotoCell";
    EZPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [[cell.rotateContainer viewWithTag:2012] removeFromSuperview];
    EZDisplayPhoto* cp = nil;
    if(_combinedPhotos.count){
        cp = [_combinedPhotos objectAtIndex:indexPath.row];
    }else{
        cp = [[EZDisplayPhoto alloc] init];
        cp.isPlaceHolder = TRUE;
    }
    
    //return cell;
    
    [cell setupCell:cp];
    //return cell;
    //[cell.frontImage cleanAllPhotos];
    //[cell.frontImage setPhotos:cp.photo.photoRelations currentPos:cp.photoPos];
    if([self isVisibleController]){
        _rightCycleButton.hidden = NO;
    }
    //This is for later update purpose. great, let's get whole thing up and run.
    cell.currentPos = indexPath.row;
    
    //EZCombinedPhoto* curPhoto = [cp.combinedPhotos objectAtIndex:cp.selectedCombinePhoto];
    EZPhoto* myPhoto = cp.photo;
    EZDEBUG(@"pos2 switchPhoto:%i", cp.photo.photoRelations.count);
    if(!cp.photo.photoRelations.count)
        cp.photo.photoRelations = nil;
    EZPhoto* switchPhoto = [cp.photo.photoRelations objectAtIndex:cp.photoPos];
    //EZDEBUG(@"pos2");
    //cell.photoDate.text = formatRelativeTime(myPhoto.createdTime);
    // Configure the cell...
    //[cell displayImage:[myPhoto getLocalImage]];
    //[[cell viewWithTag:animateCoverViewTag] removeFromSuperview];
    
    __weak EZAlbumTablePage* weakSelf = self;
    __weak EZPhotoCell* weakCell = cell;
    
    cell.likeButton.userInteractionEnabled = YES;
    if(cp.isPlaceHolder){
        EZDEBUG(@"Encounter empty");
        [self setEmptyInfo:cell isEmpty:YES];
        return cell;
    }
    EZEventBlock otherBlock = ^(EZPerson*  person){
        if(weakCell.currentPos == indexPath.row){
            weakCell.otherName.text = person.name;
            //[cell.otherIcon setImageWithURL:str2url(person.avatar)];
            if([person.avatar isNotEmpty]){
                [weakCell.otherIcon.clickImage loadImageURL:person.avatar haveThumb:NO loading:NO];
            }else{
                weakCell.otherIcon.clickImage.image = nil;
            }
        }
    };
    
    
    cell.frontImage.scrollBlock = ^(NSNumber* posNum){
        //EZDEBUG(@"scroll position:%i", posNum.intValue);
        cp.photoPos = posNum.integerValue;
        EZPhoto* backPt = [cp.photo.photoRelations objectAtIndex:cp.photoPos];
        weakCell.rotateCount ++;
        [weakSelf loadImage:weakCell url:backPt.screenURL retry:0 path:indexPath position:cp.photoPos];
        //UIImageView* imageView = [weakCell.frontImage.imageViews objectAtIndex:cp.photoPos];
        //[imageView loadImageURL:backPt.screenURL haveThumb:YES loading:NO];
        weakCell.frontImage.pageControl.currentPage = posNum.intValue;
        weakCell.otherTalk.text = [backPt getConversation];
        if(![weakCell.otherTalk.text isNotEmpty]){
            weakCell.otherTalk.text =formatRelativeTime(backPt.createdTime);
        }
        pid2personCall(backPt.personID, otherBlock);
        [weakCell setFrontFormat:false];
        [self setHeart:myPhoto back:backPt cell:weakCell];
    };
    
    cell.frontImage.scrollBeginBlock = ^(NSNumber* posNum){
        if(cp.isFront){
            return;
        }
        EZDEBUG(@"scroll begin:%i", posNum.integerValue);
        int minus = posNum.integerValue - 1;
        int plus = posNum.integerValue + 1;
        weakCell.rotateCount ++;
        if(minus >= 0){
            EZPhoto* backPt = [cp.photo.photoRelations objectAtIndex:minus];
            //[weakSelf loadImage:weakCell url:backPt.screenURL retry:0 path:indexPath position:minus];
            UIImageView* imageView = [weakCell.frontImage.imageViews objectAtIndex:minus];
            [imageView loadImageURL:backPt.screenURL haveThumb:YES loading:NO];
        }
        
        if(plus < cp.photo.photoRelations.count){
            EZPhoto* backPt = [cp.photo.photoRelations objectAtIndex:plus];
            //[weakSelf loadImage:weakCell url:backPt.screenURL retry:0 path:indexPath position:plus];
             UIImageView* imageView = [weakCell.frontImage.imageViews objectAtIndex:plus];
            [imageView loadImageURL:backPt.screenURL haveThumb:YES loading:NO];
        }
    };
    //return cell;
    EZDEBUG(@"Will display front image type:%i", myPhoto.typeUI);
    [self displayChat:cell ownerPhoto:myPhoto otherPhoto:switchPhoto];
    //return cell;
    
    
    if(cp.isFront){
        [cell setFrontFormat:true];
        //cell.authorName.textColor = [UIColor whiteColor];
        //cell.otherName.textColor = RGBCOLOR(240, 240, 240);
        if(myPhoto.typeUI == kPhotoRequest){
            //EZClickView* takePhoto = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            //takePhoto.center =
            //cell.frontImage.image = nil
            //cell.frontImage.backgroundColor = ClickedColor;
            
            EZEventBlock personGet = ^(EZPerson* ps){
                weakCell.requestInfo.hidden = NO;
                weakCell.requestInfo.text =[NSString stringWithFormat:macroControlInfo(@"%@发来的照片"), ps.name];
            };
            EZPerson* otherPerson = pid2personCall(switchPhoto.personID, personGet);
            weakCell.requestFixInfo.text = macroControlInfo(@"拍摄后翻看");
            if(!otherPerson)
                weakCell.requestInfo.text = @"";
            
            cell.cameraView.hidden = NO;
            cell.gradientView.hidden = YES;
            weakSelf.rightCycleButton.hidden = YES;
            cell.shotPhoto.hidden = NO;
            //cell.frontImage.backgroundColor = ClickedColor;
            cell.otherIcon.hidden = NO;
            cell.otherName.hidden = NO;
            cell.otherTalk.hidden = NO;
            cell.andSymbol.hidden = YES;
            cell.authorName.hidden = YES;
            cell.headIcon.hidden = YES;
            cell.ownTalk.hidden = YES;
            
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
            //[[EZUIUtility sharedEZUIUtility] showErrorInfo:macroControlInfo(@"Network not available") delay:1.0 view:self.view];
        }
        else{
            //cell.waitingInfo.hidden = YES;
            //
            //[cell.frontImage setPhotos:cp.photo.photoRelations currentPos:cp.photoPos];
            EZPhoto* backPt = [cp.photo.photoRelations objectAtIndex:cp.photoPos];
            [self loadImage:cell url:backPt.screenURL retry:0 path:indexPath position:cp.photoPos];
            
        }
    }
    
    
    EZDEBUG(@"upload status is:%i, photo relation count:%i, object Pointer:%i", myPhoto.updateStatus, myPhoto.photoRelations.count, (int)myPhoto);
    _progressBar.hidden = YES;
    if(!myPhoto.photoRelations.count && !(myPhoto.type == 1)){
        //EZDEBUG(@"Will register upload success");
        myPhoto.progress = ^(NSNumber* number){
            if(weakCell.currentPos == indexPath.row){
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
                    [weakSelf switchImage:weakCell displayPhoto:cp front:returned back:swPhoto animate:YES path:indexPath position:0];
                }
                
            }
        };
        
    }

    [self setHeart:myPhoto back:switchPhoto cell:cell];
    
    cell.buttonClicked = ^(EZClickView* obj){
        EZDEBUG(@"Liked clicked");
        if(!myPhoto.photoRelations.count || myPhoto.typeUI == kPhotoRequest || switchPhoto.typeUI == kPhotoRequest){
            return;
        }
        if(cp.photoPos > myPhoto.photoRelations.count){
            return;
        }
        EZPhoto* otherPhoto = [myPhoto.photoRelations objectAtIndex:cp.photoPos];
        if(otherPhoto){
            BOOL liked = [otherPhoto.likedUsers containsObject:currentLoginID];
            EZDEBUG(@"photoID:%@, liked:%i, personID:%@", otherPhoto.photoID, liked, otherPhoto.personID);
            liked = !liked;
            //UIColor* oldColor = obj.backgroundColor;
            //obj.backgroundColor = RGBA(0, 0, 0, 60);
            weakCell.likeButton.userInteractionEnabled = NO;
            EZDEBUG(@"start like");
            if(liked){
                otherPhoto.likedUsers = @[currentLoginID];
            }else{
                otherPhoto.likedUsers = nil;
            }
            [self setHeart:myPhoto back:otherPhoto cell:weakCell];

            [[EZDataUtil getInstance] likedPhoto:otherPhoto.photoID ownPhotoID:myPhoto.photoID like:liked success:^(id success){
                EZDEBUG(@"Liked successfully");
                [[EZDataUtil getInstance] storeAllPhotos:@[myPhoto]];
                weakCell.likeButton.userInteractionEnabled = YES;
            } failure:^(id err){
                weakCell.likeButton.userInteractionEnabled = YES;
                //obj.backgroundColor = oldColor;
                //EZDEBUG(@"Encounter like errors:%@", err);
                otherPhoto.likedUsers = nil;
                [self setHeart:myPhoto back:otherPhoto cell:weakCell];
                
            }];
        }
    };
    
    
    //__block NSString* staticFile = nil;
    cell.frontImage.tappedBlock = ^(id obj){
        //[[EZDataUtil getInstance] fetchLastImage:^(ALAsset* image){
        //EZDEBUG(@"Get image from album");
        //weakCell.frontImage.image = image;
        //CGImageRef cgImage = [[image defaultRepresentation] fullScreenImage];
        //NSString* assetURL = [[image valueForProperty:ALAssetPropertyAssetURL] absoluteString];
        //weakSelf.assetImage =[UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
        //[weakSelf raiseCamera:assetURL personID:nil];
        //}];
        //EZDEBUG(@"Send a message out");
        //[[EZMessageCenter getInstance] postEvent:EZNoteCountChange attached:@(2)];
        if(myPhoto.typeUI != kPhotoRequest){
            EZPhoto* swPhoto = [myPhoto.photoRelations objectAtIndex:cp.photoPos];
            //swPhoto.screenURL = @"http://192.168.1.102:8080/broken/49497";
            EZDEBUG(@"my photoID:%@, otherID:%@, otherPerson:%@, other photo upload:%i, other screenURL:%@, status content:%i, match:%i, update:%i, createTime:%@", myPhoto.photoID,swPhoto.photoID, swPhoto.personID, swPhoto.uploaded, swPhoto.screenURL, myPhoto.contentStatus, myPhoto.exchangeStatus, myPhoto.updateStatus, swPhoto.createdTime);
            //NSString* localURL = [[EZDataUtil getInstance] lo]
            //if(swPhoto){
            [weakSelf switchImage:weakCell displayPhoto:cp front:myPhoto back:swPhoto animate:YES path:indexPath position:cp.photoPos];
            //}
        }else{
            EZDEBUG(@"photo request clicked: %@, type:%i, otherEnd:%@", myPhoto.photoID, myPhoto.type, switchPhoto.photoID);
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
        if(weakSelf.scrollBlock){
            weakSelf.scrollBlock(@(false));
        }
        
        EZClickImage* fullView = [[EZClickImage alloc] initWithFrame:[UIScreen mainScreen].bounds];
        //fullView.contentMode = UIViewContentModeScaleAspectFill;
        //fullView.image = weakCell.frontImage.image;
        UIView* snapShot = [weakCell.frontImage snapshotViewAfterScreenUpdates:NO];
        [fullView addSubview:snapShot];
        fullView.enableTouchEffects = NO;
        EZDEBUG(@"Long press called %@", NSStringFromCGRect(fullView.bounds));
        fullView.tag = 6565;
        fullView.alpha = 0;
        macroHideStatusBar(YES);
        [weakCell addSubview:fullView];
        [UIView animateWithDuration:0.3 animations:^(){
            fullView.alpha = 1.0;
            weakSelf.leftCyleButton.alpha = 0;
            weakSelf.rightCycleButton.alpha = 0;
        }];
        __weak EZClickImage* weakFull = fullView;
        EZEventBlock clickBlock = ^(NSNumber* showCycle){
            EZDEBUG(@"dismiss current view");
            weakSelf.scrollBlock = nil;
            longPressed = false;
            //[obj dismissViewControllerAnimated:YES completion:nil];
            [UIView animateWithDuration:0.3 animations:^(){
                weakFull.alpha = 0;
                if(showCycle.boolValue){
                    weakSelf.leftCyleButton.alpha = 1.0;
                    weakSelf.rightCycleButton.alpha = 1.0;
                }
            } completion:^(BOOL completed){
                EZDEBUG(@"remove fullView:%i",(int)weakFull);
                [weakFull removeFromSuperview];
                if(showCycle.boolValue){
                    macroHideStatusBar(NO);
                }
                //CGFloat offsetY = indexPath.row * CurrentScreenHeight;
                //CGPoint offset = weakSelf.tableView.contentOffset;
                //weakSelf.tableView.contentOffset = CGPointMake(0, offsetY);
            }];
            //[EZDataUtil getInstance].centerButton.alpha = 1.0;
        };
        fullView.releasedBlock = ^(EZClickImage* obj){
            clickBlock(@(YES));
        };
        
        weakSelf.scrollBlock = clickBlock;
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
        
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:macroControlInfo(@"删除照片") delegate:self cancelButtonTitle:macroControlInfo(@"取消") destructiveButtonTitle:macroControlInfo(@"确认删除") otherButtonTitles:nil];
        [actionSheet showInView:self.view];
        _actionBlock = ^(NSNumber* btnIndex){
            //if(btnIndex.integerValue == 0)
            EZDEBUG(@"btn index:%i", btnIndex.integerValue);
            if(btnIndex.integerValue != 0){
                return;
            }
            weakCell.activityView.hidden = NO;
            [weakCell.activityView startAnimating];
            [[EZDataUtil getInstance] deletePhoto:cp.photo success:^(id obj){
                [weakCell.activityView stopAnimating];
                weakCell.activityView.hidden = YES;
                if(weakCell.currentPos == indexPath.row && weakSelf.combinedPhotos.count > indexPath.row){
                    //[weakSelf.combinedPhotos removeObjectAtIndex:indexPath.row];
                    int pos = [weakSelf findPhotoByID:cp.photo.photoID photos:weakSelf.combinedPhotos];
                    if(pos != indexPath.row){
                        return;
                    }
                    [[EZDataUtil getInstance] deleteImageFile:cp.photo];
                    [[EZDataUtil getInstance] deleteImageFiles:cp.photo.photoRelations];
                    [weakSelf.combinedPhotos removeObjectAtIndex:pos];
                    [[EZDataUtil getInstance] removeLocalPhoto:cp.photo.photoID];
                    if(weakSelf.combinedPhotos.count){
                        [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }else{
                        [weakSelf.tableView reloadData];
                    }
                    [[EZMessageCenter getInstance] postEvent:EZNoteCountChange attached:nil];
                }
            } failure:^(id err){
                [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"删除失败") info:macroControlInfo(@"请稍后重试")];
                [weakCell.activityView stopAnimating];
                weakCell.activityView.hidden = YES;
            }];
        };
        
    };
    
    EZEventBlock curBlock = ^(EZPerson*  person){
        if(cell.currentPos == indexPath.row){
            cell.authorName.text = person.name;
            [cell.headIcon.clickImage loadImageURL:person.avatar haveThumb:NO loading:NO];
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
        EZPhoto* bp = [cp.photo.photoRelations objectAtIndex:cp.photoPos];
        EZPerson* ps = pid2person(bp.personID);
        
        EZPersonDetail* pd = [[EZPersonDetail alloc] initWithPerson:ps];
        //pd.modalPresentationStyle = UIModalPresentationPageSheet;
        //pd.transitioningDelegate = weakSelf;
        //pd.modalPresentationStyle = UIModalPresentationCustom;
        weakSelf.isPushCamera = false;
        //pd.modalTransitionStyle
        //self.transitioningDelegate
        weakSelf.leftCyleButton.hidden = YES;
        weakSelf.rightCycleButton.hidden = YES;
        //[self presentViewController:pd animated:YES completion:^(){
        //}];
        [weakSelf.navigationController pushViewController:pd animated:YES];
        
    };
    
    
    cell.headIcon.releasedBlock = ^(id obj){
        EZPersonDetail* pd = [[EZPersonDetail alloc] initWithPerson:frontPerson];
        //pd.transitioningDelegate = weakSelf;
        //pd.modalPresentationStyle = UIModalPresentationCustom;
        weakSelf.isPushCamera = false;
        weakSelf.leftCyleButton.hidden = YES;
        weakSelf.rightCycleButton.hidden = YES;
        //[self presentViewController:pd animated:YES completion:^(){
        //}];
        [weakSelf.navigationController pushViewController:pd animated:YES];
    };
    return cell;
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    /**
    NSArray* paths = self.tableView.indexPathsForVisibleRows;
    if(_combinedPhotos.count){
    for(NSIndexPath* path in paths){
        EZPhotoCell* cell = (EZPhotoCell*)[self.tableView cellForRowAtIndexPath:path];
        EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:path.row];
        if(dp.photo.typeUI != kPhotoRequest && dp.isFront){
            EZDEBUG(@"Will revert back to the old position");
            EZPhoto* backPhoto = nil;
            if(dp.photo.photoRelations.count > dp.photoPos){
                backPhoto = [dp.photo.photoRelations objectAtIndex:dp.photoPos];
            }
            [self switchImage:cell displayPhoto:dp front:dp.photo back:backPhoto animate:YES path:path position:dp.photoPos];
        }
    }
    }
    **/
    EZDEBUG(@"Will decelerate:%i", decelerate);
    _previousGap = fabsf(_scrollBeginPos - self.tableView.contentOffset.y);
    
    dispatch_later(0.05, ^(){
    if(_rotateCell){
        CGFloat curentGap = fabsf(_scrollBeginPos - self.tableView.contentOffset.y);
        CGFloat delta = curentGap/CurrentScreenHeight;
        EZDEBUG(@"end dragging delta:%f, prevGap:%f, currentGap:%f", delta, _previousGap, curentGap);
        EZPhotoCell* pcell = _rotateCell;
        if(delta > 0.5){
            [UIView animateWithDuration:0.3 animations:^(){
                //CGFloat delta = fabsf(_scrollBeginPos - self.tableView.contentOffset.y)/CurrentScreenHeight;
                //CATransform3D trans = CATransform3DRotate(CATransform3DIdentity, M_PI, 0.0, 1.0, 0.0);
                //trans.m34 = 1/3000.0;
                pcell.frontImage.layer.transform = CATransform3DIdentity;
            } completion:^(BOOL completion){
                [[pcell.rotateContainer viewWithTag:2012] removeFromSuperview];
                //[[pcell.rotateContainer viewWithTag:2012] removeFromSuperview];
            }];
        }else if(curentGap > _previousGap){
            [UIView animateWithDuration:0.15 animations:^(){
                //CGFloat delta = fabsf(_scrollBeginPos - self.tableView.contentOffset.y)/CurrentScreenHeight;
                CATransform3D trans = CATransform3DRotate(CATransform3DIdentity, M_PI/2.0, 0.0, 1.0, 0.0);
                trans.m34 = 1/3000.0;
                //_rotateCell.frontImage.layer.transform = CATransform3DIdentity;
                [pcell.rotateContainer viewWithTag:2012].layer.transform = trans;
            } completion:^(BOOL completion){
                [[pcell.rotateContainer viewWithTag:2012] removeFromSuperview];
                //[[pcell.rotateContainer viewWithTag:2012] removeFromSuperview];
                [UIView animateWithDuration:0.15 animations:^(){
                    pcell.frontImage.layer.transform = CATransform3DIdentity;
                } completion:^(BOOL completion){
                }];
            }];
        }
        else{
            EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:_rotateIndex.row];
            
            EZPhoto* backPhoto = nil;
            if(dp.photoPos < dp.photo.photoRelations.count){
                backPhoto = [dp.photo.photoRelations objectAtIndex:dp.photoPos];
            }
            dp.isFront = false;
            [self switchImage:pcell displayPhoto:dp front:dp.photo back:backPhoto animate:NO path:_rotateIndex position:dp.photoPos];
            
            [UIView animateWithDuration:0.3 animations:^(){
                [pcell.rotateContainer viewWithTag:2012].layer.transform = CATransform3DIdentity;
            } completion:^(BOOL finished) {
                pcell.frontImage.layer.transform = CATransform3DIdentity;
                [[pcell.rotateContainer viewWithTag:2012] removeFromSuperview];
            }];
        }
        _rotateCell = nil;
    }});

}



- (void) setupLongPress:(EZPhotoCell*)weakCell
{
    __weak EZAlbumTablePage* weakSelf = self;
    EZClickImage* fullView = [[EZClickImage alloc] initWithFrame:[UIScreen mainScreen].bounds];
    fullView.contentMode = UIViewContentModeScaleAspectFill;
    //fullView.image = weakCell.frontImage.image;
    [fullView addSubview:[weakCell.frontImage snapshotViewAfterScreenUpdates:NO]];
    fullView.enableTouchEffects = NO;
    EZDEBUG(@"Long press called %@", NSStringFromCGRect(fullView.bounds));
    fullView.tag = 6565;
    fullView.alpha = 0;
    macroHideStatusBar(YES);
    [weakCell addSubview:fullView];
    [UIView animateWithDuration:0.3 animations:^(){
        fullView.alpha = 1.0;
        weakSelf.leftCyleButton.alpha = 0;
        weakSelf.rightCycleButton.alpha = 0;
    }];
    __weak EZClickImage* weakFull = fullView;
    EZEventBlock clickBlock = ^(NSNumber* showCycle){
        EZDEBUG(@"dismiss current view");
        weakSelf.scrollBlock = nil;
        //[obj dismissViewControllerAnimated:YES completion:nil];
        [UIView animateWithDuration:0.3 animations:^(){
            weakFull.alpha = 0;
            if(showCycle.boolValue){
                weakSelf.leftCyleButton.alpha = 1.0;
                weakSelf.rightCycleButton.alpha = 1.0;
            }
        } completion:^(BOOL completed){
            EZDEBUG(@"remove fullView:%i",(int)weakFull);
            [weakFull removeFromSuperview];
            if(showCycle.boolValue){
                macroHideStatusBar(NO);
            }
            //CGFloat offsetY = indexPath.row * CurrentScreenHeight;
            //CGPoint offset = weakSelf.tableView.contentOffset;
            //weakSelf.tableView.contentOffset = CGPointMake(0, offsetY);
        }];
        //[EZDataUtil getInstance].centerButton.alpha = 1.0;
    };
    fullView.releasedBlock = ^(EZClickImage* obj){
        clickBlock(@(YES));
    };
    
    weakSelf.scrollBlock = clickBlock;
}

- (DLCImagePickerController*) embedCamera:(NSString*)photo personID:(NSString*)personID
{
    _newlyCreated = 0;
    EZDEBUG(@"before present");
    if([EZUIUtility sharedEZUIUtility].cameraRaised || [EZUIUtility sharedEZUIUtility].stopRotationRaise){
        return nil;
    }

    DLCImagePickerController* camera = [[DLCImagePickerController alloc] initWithAsset:photo image:_assetImage];
    //}
    //controller.prefersStatusBarHidden = TRUE;
    //camera.transitioningDelegate = _cameraAnimation;
    camera.delegate = self;
    //if(photo)
    //if(pers)
    camera.personID = personID;

    //camera.view.frame = self.view.bounds;
    return camera;
}

- (void) raiseCamera:(NSString *)photo personID:(NSString*)personID
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
    
    DLCImagePickerController* camera = [[DLCImagePickerController alloc] initWithAsset:photo image:_assetImage];
    //}
    //controller.prefersStatusBarHidden = TRUE;
    //camera.transitioningDelegate = _cameraAnimation;
    camera.delegate = self;
    //if(photo)
    //if(pers)
    camera.personID = personID;

    //[self presentViewController:camera animated:TRUE completion:^(){
    //    EZDEBUG(@"Presentation completed");
    //}];
    [self.navigationController pushViewController:camera animated:YES];
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
    
    for(EZDisplayPhoto* dp in [EZDataUtil getInstance].mainPhotos){
        if(dp.isFirstTime){
            totalPending += 1;
        }
    }
    return totalPending;
}

- (void) setNoteCount
{
    int pendingCount = 0;
    if(_currentUser){
        pendingCount = [[EZDataUtil getInstance] getPendingForPerson:_currentUser.personID filterType:_currentUser.filterType];
    }else{
        pendingCount = [[EZDataUtil getInstance] getPendingForPerson:nil filterType:0];
    }
    if(pendingCount){
        _numberLabel.alpha = 1;
        _numberLabel.text = int2str(pendingCount);
    }else{
        _numberLabel.alpha = 0;
    }
}





- (NSArray*) getAllWaitRequests
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    
    NSArray* srcArr = [EZDataUtil getInstance].mainPhotos;
    EZDEBUG(@"Read from main:%i", srcArr.count);
    
    if(!srcArr.count){
         srcArr = [[EZDataUtil getInstance] getStoredPhotos];
    }
    EZDEBUG(@"Read from stored:%i", srcArr.count);
    
    

        //[EZDataUtil getInstance].mainPhotos];
        //[_nonsplitted addObjectsFromArray:[EZDataUtil getInstance].mainNonSplits];
        for(EZDisplayPhoto* dp in srcArr){
            EZPhoto* otherSide = dp.photo.photoRelations.count?[dp.photo.photoRelations objectAtIndex:0]:nil;
            if(dp.photo.type == kPhotoRequest){
                [res addObject:dp];
            }else if(otherSide.type  == kPhotoRequest){
                [res addObject:dp];
            }
        }
    return res;
}

- (NSArray*) getHeartType:(EZFilterType)filterType
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    
    NSArray* storedPhoto = [EZDataUtil getInstance].mainPhotos;
    
    EZDEBUG(@"Person All stored photos:%i", storedPhoto.count);
    for(EZDisplayPhoto* dp in storedPhoto){
        //EZPhoto* ph = nil;
        EZDisplayPhoto* newDP = nil;
        for(int i = 0; i < dp.photo.photoRelations.count; i++){
            EZPhoto* ph = [dp.photo.photoRelations objectAtIndex:i];
            
            BOOL otherLike = [dp.photo.likedUsers containsObject:ph.personID];
            BOOL ownLike = [ph.likedUsers containsObject:currentLoginID];
            if(otherLike || ownLike){
                //if(dp.photo.photoRelations.count > 0){
                if(!newDP){
                    newDP = [self wrapPhoto:ph];
                    newDP.photoPos = 0;
                    newDP.photo = dp.photo.copy;
                    newDP.photo.photoRelations = [[NSMutableArray alloc] init];
                }
                
                if(filterType == kPhotoOwnLike){
                    if(!otherLike && ownLike){
                        [newDP.photo.photoRelations addObject:ph];
                    }
                }else if(filterType == kPhotoOtherLike){
                    if(otherLike && !ownLike){
                        [newDP.photo.photoRelations addObject:ph];
                    }
                }else if(filterType == kPhotoAllLike){
                    if(otherLike && ownLike){
                        [newDP.photo.photoRelations addObject:ph];
                    }
                }
            }
        }
        if(newDP.photo.photoRelations.count){
            [res addObject:newDP];
        }
    }
    return res;
}

- (void) setTitleFormat:(EZPerson*)currentUser isHeartSelector:(BOOL)heartSelector
{
    _currentUser = currentUser;
    self.title = @"";///currentUser.name;
    if(heartSelector){
        _numberLabel.alpha = 0;
    }else{
        [self setNoteCount];
    }
    [_leftCyleButton setTitle:currentUser.name forState:UIControlStateNormal];
    _iconButton.hidden = YES;
    _leftCyleButton.titleLabel.font= EZLargeFont;
    CGSize fitSize = [_leftCyleButton.titleLabel sizeThatFits:CGSizeMake(230, 40)];
    CGFloat width = fitSize.width > 230?230:fitSize.width;
    EZDEBUG(@"like fit size for string:%@, size:%f, width:%f", currentUser.name, fitSize.width, width);
    [_leftCyleButton setWidth:width + 2];
    [_signRegion setX:width + 10];
}

- (void) setCurrentUser:(EZPerson *)currentUser readyBlock:(EZEventBlock)readyBlock
{
    EZDEBUG(@"Will change the user from:%@ to %@", _currentUser, currentUser);
    if(currentUser.filterType){
        _assetView.hidden = YES;
    }else{
        _assetView.hidden = NO;
    }
    
    if(currentUser.filterType == kPhotoAllLike || currentUser.filterType == kPhotoOwnLike || currentUser.filterType == kPhotoOtherLike){
        
        [self setTitleFormat:currentUser isHeartSelector:YES];
        [_combinedPhotos removeAllObjects];
        [_combinedPhotos addObjectsFromArray:[self getHeartType:currentUser.filterType]];
        EZDEBUG(@"filter type:%i, photoCount:%i", currentUser.filterType, _combinedPhotos.count);
        [_tableView reloadData];
        [self scrollToBottom:NO];
        
    }else if(currentUser.filterType == kPhotoNewFilter){
        [self setTitleFormat:currentUser isHeartSelector:NO];
        [_combinedPhotos removeAllObjects];
        [_combinedPhotos addObjectsFromArray:[[EZDataUtil getInstance] getFirstTimeArray]];
        [_tableView reloadData];
        [self scrollToBottom:NO];
        
    }else
    if(currentUser.filterType == kPhotoWaitFilter){
        NSArray* requests = [self getAllWaitRequests];
        [self setTitleFormat:currentUser isHeartSelector:NO];
        [_combinedPhotos removeAllObjects];
        [_combinedPhotos addObjectsFromArray:requests];
        [_tableView reloadData];
        [self scrollToBottom:NO];
    }
    else
    if([currentUser.personID isEqualToString:currentLoginID]){
        if(_currentUser){
            _currentUser = nil;
            self.title = @"";
            //[[EZMessageCenter getInstance] postEvent:EZNoteCountSet attached:@([self getPendingCount])];
             [self setNoteCount];
            _iconButton.hidden = NO;
            [(EZHairButton*)_rightCycleButton.innerView setButtonStyle:kShotForAll];
            [_leftCyleButton setTitle:DefaultEmptyString forState:UIControlStateNormal];
            _leftCyleButton.titleLabel.font = EZTitleSlimFont;
            
            CGSize fitSize = [_leftCyleButton.titleLabel sizeThatFits:CGSizeMake(230, 40)];
            CGFloat width = fitSize.width > 230?230:fitSize.width;
            EZDEBUG(@"fit size width:%f", width);
            //[_leftText setWidth:fitSize.width];
            [_signRegion setX:width + 10];
            [_leftCyleButton setWidth:width + 2];
            [_combinedPhotos removeAllObjects];
            //[_nonsplitted removeAllObjects];
            //
            if([EZDataUtil getInstance].mainPhotos.count){
                [_combinedPhotos addObjectsFromArray:[EZDataUtil getInstance].mainPhotos];
                //[_nonsplitted addObjectsFromArray:[EZDataUtil getInstance].mainNonSplits];
            }else{
                NSArray* orgPhoto = [[EZDataUtil getInstance] getStoredPhotos];
                //NSArray* splitted = [self splitPhotos:orgPhoto];
                [_combinedPhotos addObjectsFromArray:[self wrapPhotos:orgPhoto]];
                //[_nonsplitted addObjectsFromArray:orgPhoto];
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
        [(EZHairButton*)_rightCycleButton.innerView setButtonStyle:kShotForOne];
        self.title = @""; //currentUser.name;
        _currentUser = currentUser;
        [self setNoteCount];
        _iconButton.hidden = YES;
        [_leftCyleButton setTitle:currentUser.name forState:UIControlStateNormal];
        _leftCyleButton.titleLabel.font= EZLargeFont;
        CGSize fitSize = [_leftCyleButton.titleLabel sizeThatFits:CGSizeMake(230, 40)];
        CGFloat width = fitSize.width > 230?230:fitSize.width;
        EZDEBUG(@"fit size for string:%@, size:%f, width:%f", currentUser.name, fitSize.width, width);
        //[_leftText setWidth:fitSize.width];
        [_leftCyleButton setWidth:width + 2];
        [_signRegion setX:width + 10];
        [_combinedPhotos removeAllObjects];
        //[_nonsplitted removeAllObjects];
        NSArray* storedPhoto = nil;
        
        if([EZDataUtil getInstance].mainPhotos.count){
            //[_combinedPhotos addObjectsFromArray:[EZDataUtil getInstance].mainPhotos];
            storedPhoto  = [EZDataUtil getInstance].mainPhotos;
            //[_nonsplitted addObjectsFromArray:[EZDataUtil getInstance].mainNonSplits];
        }else{
            storedPhoto = [[EZDataUtil getInstance] getStoredPhotos];
        }
        EZDEBUG(@"Person All stored photos:%i", storedPhoto.count);
        for(EZDisplayPhoto* dp in storedPhoto){
            EZPhoto* ph = nil;
            for(int i = 0; i < dp.photo.photoRelations.count; i++){
                ph = [dp.photo.photoRelations objectAtIndex:i];
                if([ph.personID isEqualToString:currentUser.personID]){
                    //if(dp.photo.photoRelations.count > 0){
                    EZDisplayPhoto* newDP = [self wrapPhoto:ph];
                    newDP.photoPos = 0;
                    newDP.photo = dp.photo.copy;
                    newDP.photo.photoRelations = @[ph];
                    //newDP.isSingle = YES;
                    if(dp.photo.type != kPhotoRequest){
                        newDP.isFront = NO;
                    }else{
                        newDP.isFront = YES;
                    }
                    [_combinedPhotos addObject:newDP];
                    break;
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

        [self loadMorePhoto:^(id obj){
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
    
    int pageStart = _combinedPhotos.count/pageSize;
    if(_currentUser){
        completed(nil);
        return;
    }
    EZDEBUG(@"Will load from %i", pageStart);
    [[EZDataUtil getInstance] queryPhotos:pageStart pageSize:pageSize otherID:_currentUser.personID success:^(EZResult* res){
        
        //EZDEBUG(@"Reloaded about %i rows of data, inset:%@", arr.count, NSStringFromUIEdgeInsets(self.tableView.contentInset));
        _totalCount = res.totalCount;
        //Assumption is that already have photo filled.
        //EZDEBUG(@"before reload");
        [self reloadRows:res.result reload:reload];
        //EZDEBUG(@"after reload");
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
    
    if(_combinedPhotos.count){
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
    }else{
        _leftCyleButton.hidden = NO;
        _rightCycleButton.hidden = NO;
    }
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
                [self switchImage:cell displayPhoto:cp front:cp.photo back:switchPhoto animate:NO path:path position:0];
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
    
    if(self.navigationController.visibleViewController != self){
        EZDEBUG(@"Quit for navigation not ready");
        return;
    }
    //if(camera.isFrontCamera){
    //    [camera switchCamera];
    //}
    __weak EZAlbumTablePage* weakSelf = self;
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
            
            //[[EZMessageCenter getInstance] postEvent:EZNoteCountChange attached:@(-1)];
            
            NSInteger pos = [weakSelf.combinedPhotos indexOfObject:disPhoto];
            EZDEBUG("after Refresh type:%i, row:%i, updated row:%i", disPhoto.photo.typeUI, indexPath.row, pos);
            if(pos != NSNotFound){
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:pos inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
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
    //EZDEBUG(@"button clicked:%i", buttonIndex);
   
    if(_actionBlock){
        _actionBlock(@(buttonIndex));
    }
    /**
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
     **/
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
        //NSMutableArray* arr = [[NSMutableArray alloc] init];
        //[arr addObjectsFromArray:pt.photoRelations];
        //[arr addObjectsFromArray:pt.photoRelations];
        //pt.photoRelations = arr;
    }
    return res;
}



- (void) triggerFallAnim
{
    EZDEBUG(@"will fall it");
    //[UIView animate]
    self.pushBehavior.pushDirection = CGVectorMake(0.0f, -80.0f);
    // active is set to NO once the instantaneous force is applied. All we need to do is reactivate it on each button press.
    self.pushBehavior.active = YES;
}

- (void) test3DPlay
{
    UIImageView* centralImage = [[UIImageView alloc]initWithFrame:CGRectMake(30, 30, 160, 284)];
    centralImage.contentMode = UIViewContentModeScaleAspectFill;
    [TopView addSubview:centralImage];
    
    _mi = [[EZMotionImage alloc] init];
    EZMotionRecord* mrO = [[EZMotionRecord alloc] init];
    mrO.image = [UIImage imageNamed:@"hou_1.JPG"];
    mrO.deltaY = 0.0;
    
    EZMotionRecord* mrOne = [[EZMotionRecord alloc] init];
    mrOne.image = [UIImage imageNamed:@"yue_1.JPG"];
    mrOne.deltaY = -0.3;
    
    EZMotionRecord* mr2 = [[EZMotionRecord alloc] init];
    mr2.image = [UIImage imageNamed:@"tian_1.JPG"];
    mr2.deltaY = 0.3;
    
    _mi.motionImages = @[mrO, mrOne, mrO, mr2];
    _mi.container = centralImage;
    [_mi play];

}

- (void) setupAlbumImage
{
    if(!_assetView){
        _assetView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        //UIView* upperCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight/2.0)];
        //upperCover.backgroundColor = ClickedColor;
        //[_assetView addSubview:upperCover];
        _assetView.contentMode = UIViewContentModeScaleAspectFill;
        _assetView.clipsToBounds = TRUE;
        //[self.view insertSubview:weakSelf.assetView belowSubview:_albumContainer];
        CGFloat height = _tableView.contentSize.height;
        if(self.tableView.contentSize.height < CurrentScreenHeight){
            height = CurrentScreenHeight;
        }
        [_tableView addSubview:_assetView];
        _assetView.hidden = YES;
        _outerImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _outerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _outerImageView.clipsToBounds = TRUE;
        [_outerImageView setY:CurrentScreenHeight];
        [_albumContainer addSubview:_outerImageView];
    }
    _assetView.image = _assetImage;
    _outerImageView.image = _assetImage;
    NSString* oldPhotoURL = [[NSUserDefaults standardUserDefaults] stringForKey:EZOldPhotoAssetURL];
    if(![oldPhotoURL isEqualToString:_asset]){
        [[NSUserDefaults standardUserDefaults]  setObject:_asset forKey:EZOldPhotoAssetURL];
        [self triggerFallAnim];
        dispatch_later(1.5, ^(){
            [self triggerFallAnim];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _combinedPhotos = [[NSMutableArray alloc] init];
    self.view.backgroundColor = ClickedColor;//VinesGray;
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    
    _albumContainer = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _albumContainer.backgroundColor = [UIColor clearColor];
    [_albumContainer addSubview:_tableView];
    
    [self.tableView enableCustomScrollIndicatorsWithScrollIndicatorType:JMOScrollIndicatorTypeClassic positions:JMOVerticalScrollIndicatorPositionRight color:[UIColor whiteColor]];
    [self.tableView registerClass:[EZPhotoCell class] forCellReuseIdentifier:@"PhotoCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"BottomCell"];
    [self.view addSubview:_albumContainer];
    
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
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
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
        //[_nonsplitted addObject:dp.photo];
        
        [[EZDataUtil getInstance].mainPhotos addObject:dp];
        //[[EZDataUtil getInstance].mainNonSplits addObject:dp.photo];
        _totalCount++;
        if(_currentUser.filterType){
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            //[self scrollToBottomLater:0.1 animated:NO];
        }else
        if(_combinedPhotos.count == 1){
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }else{
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
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
    [[EZMessageCenter getInstance] registerEvent:EZAlbumImageClean block:^(id obj){
        _assetView.image = nil;
        _asset = nil;
        _assetImage = nil;
        _outerImageView.image = nil;
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZDeleteOtherPhoto block:^(NSDictionary* dict){
        NSString* srcID = [dict objectForKey:@"srcID"];
        NSString* deletedID = [dict objectForKey:@"deletedID"];
        int pos = [self findPhotoByID:srcID photos:_combinedPhotos];
        [[EZDataUtil getInstance] removeOtherPhoto:deletedID array:[EZDataUtil getInstance].mainPhotos store:YES];
        if(pos > 0){
            EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:pos];
            [self deleteMatchPhoto:dp deletedID:deletedID pos:pos];
        }
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZAlbumImageUpdate block:^(id obj){
        //Turn off the Album update
        //return;
        [[EZDataUtil getInstance] fetchLastImage:^(ALAsset* image){
            ALAssetRepresentation* ap = [image defaultRepresentation];
            NSDate* date = [image valueForProperty:ALAssetPropertyDate];
            CLLocation *location = [image valueForProperty:ALAssetPropertyLocation];
            UIImageOrientation orientation = [[image valueForProperty:ALAssetPropertyOrientation] integerValue];
            
            if(!location){
                EZDEBUG(@"quit for have no location");
                return;
            }
            if(orientation == UIImageOrientationLeft || orientation == UIImageOrientationRight){
                orientation = UIImageOrientationUp;
            }else{
                orientation = UIImageOrientationLeft;
            }
            EZDEBUG(@"dimension is:%@, date is:%@, %@, %i", NSStringFromCGSize(ap.dimensions), date, location, orientation);
            //weakCell.frontImage.image = image;
            CGImageRef cgImage = [[image defaultRepresentation] fullScreenImage];
            NSString* assetURL = [[image valueForProperty:ALAssetPropertyAssetURL] absoluteString];
            weakSelf.assetImage =[UIImage imageWithCGImage:cgImage scale:1.0 orientation:orientation];
            EZDEBUG(@"Get image from album, size:%@", NSStringFromCGSize(weakSelf.assetImage.size));
            weakSelf.asset = assetURL;
            //[self setupAlbumImage];
            //[weakSelf raiseCamera:assetURL personID:nil];
        } failure:^(id err){
            EZDEBUG(@"failed to get album:%@", err);
            _assetView.image = nil;
            _outerImageView.image = nil;
            _asset = nil;
            _assetImage = nil;
        }];

    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZAlbumImageReaded block:^(EZDisplayPhoto* dp){
        EZDEBUG(@"Recieved a image from album");
        [_combinedPhotos addObject:dp];
        //[_nonsplitted addObject:dp];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZExpiredPhotos block:^(NSArray* arr){
        EZDEBUG(@"deleted count:%i", arr.count);
        NSMutableArray* deletedPath = [[NSMutableArray alloc] init];
        for(EZPhoto* pt in arr){
            //int j = 0;
            for(int i = 0, j = 0; i < _combinedPhotos.count; i++, j++){
                EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:i];
                if([dp.photo.photoID isEqualToString:pt.photoID]){
                    [_combinedPhotos removeObjectAtIndex:i];
                    --i;
                    [deletedPath addObject:[NSIndexPath indexPathForRow:j inSection:0]];
                }
            }
        }
        if(deletedPath.count > 0){
            //[self.tableView deleteRowsAtIndexPaths:deletedPath withRowAnimation:UITableViewRowAnimationFade];
            if(deletedPath.count == 1){
                NSArray* visible = [self.tableView indexPathsForVisibleRows];
                NSIndexPath* targetIdx = [deletedPath objectAtIndex:0];
                if(visible.count){
                    NSIndexPath* idxPath = [visible objectAtIndex:0];
                    if(idxPath.row == targetIdx.row || idxPath.row < targetIdx.row){
                        if(_combinedPhotos.count > 0){
                            [weakSelf.tableView deleteRowsAtIndexPaths:deletedPath withRowAnimation:UITableViewRowAnimationFade];
                        }else{
                            [weakSelf.tableView reloadData];
                        }
                    }else{
                        EZDEBUG(@"Will delete the view now:%i, %i", idxPath.row, targetIdx.row);
                        //EZPhotoCell* pc = (EZPhotoCell*)[weakSelf.tableView cellForRowAtIndexPath:idxPath];
                        UIView* snapView = [TopView snapshotViewAfterScreenUpdates:NO];//[[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];//[pc snapshotViewAfterScreenUpdates:NO];
                        //snapView.backgroundColor = [UIColor redColor];
                        [TopView addSubview:snapView];
                        [weakSelf.tableView deleteRowsAtIndexPaths:deletedPath withRowAnimation:NO];
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idxPath.row - 1 inSection:0]] withRowAnimation:NO];
                        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:idxPath.row - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        dispatch_later(0.5, ^(){
                            [snapView removeFromSuperview];
                        });
                    }
                }
                
            }else{
                [self.tableView reloadData];
            }
        }
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZSetAlbumUser block:^(EZPerson* person){
        [self setCurrentUser:person readyBlock:nil];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZUserEditted block:^(EZPerson* person){
        [self refreshVisibleCell];
        [[EZDataUtil getInstance] storeAllPersons:@[person]];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZPositionHold block:^(NSNumber* num){
        if(num.integerValue == UIDeviceOrientationPortrait){
            if(weakSelf.scrollBlock){
                weakSelf.scrollBlock(@(true));
                weakSelf.scrollBlock = nil;
            }
        }else if(num.integerValue == UIDeviceOrientationLandscapeLeft || num.integerValue == UIDeviceOrientationLandscapeRight){
            [weakSelf presentCurrentCell];
        }
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZTriggerCamera block:^(id obj){
        //[weakSelf raiseCamera];
        [weakSelf raiseCamera:nil indexPath:nil personID:obj];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZNoteCountChange block:^(NSNumber* num){
        //EZDEBUG(@"change notes:%i", num.intValue);
        //if(_currentUser.filterType == kPhotoWaitFilter){
        //    _currentUser.pendingEventCount += num.integerValue;
        //}
        //[self setNoteCount];
        [self setNoteCount];
        EZDEBUG(@"change notes The currentUser:%@, type:%i, %@", _currentUser.name, _currentUser.filterType, _numberLabel.text);
        
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZNetworkStatus block:^(NSNumber* num){
        EZDEBUG(@"network change :%i", [EZDataUtil getInstance].networkAvailable);
        if(![EZDataUtil getInstance].networkAvailable){
            _networkStatus.hidden = NO;
            _networkStatus.text = macroControlInfo(@"Network not available");
        }else{
            //_networkStatus.text = @"";
            _networkStatus.hidden = YES;
        }
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZNoteCountSet block:^(NSNumber* num){
        EZDEBUG(@"set notes count:%i", num.intValue);
        [self setNoteCount];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZRecievedNotes block:^(EZNote* note){
        
        BOOL triggerByNotes = [[EZDataUtil getInstance].pushNotes objectForKey:note.noteID] != nil;
        NSString* trigger = [NSString stringWithFormat:@"%@,%i", note.type, triggerByNotes];
        [MobClick event:EZALRecievedNotes label:trigger];
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
            //_leftMessageCount.hidden = NO;
            BOOL triggerByNote = [[EZDataUtil getInstance].pushNotes objectForKey:note.noteID] != nil;
            if(triggerByNote){
                EZPersonDetail* pd = [[EZPersonDetail alloc] initWithPerson:ps];
                _isPushCamera = false;
                _leftCyleButton.hidden = YES;
                _rightCycleButton.hidden = YES;
                [self.navigationController pushViewController:pd animated:YES];
            }
        }else if([@"deleted" isEqualToString:note.type]){
            [self processDeleteNote:note];
        }
        else if([EZNoteFriendAdd isEqualToString:note.type]){
            
        }else if([EZNoteFriendKick isEqualToString:note.type]){
            
        }
    }];
    
    EZDEBUG(@"The login personID:%@, getID:%@", [EZDataUtil getInstance].currentPersonID, [[EZDataUtil getInstance] getCurrentPersonID]);
    
    //[[EZMessageCenter getInstance] postEvent:EZAlbumImageUpdate attached:nil];
    
    EZEventBlock queryPhotoBlock = ^(EZPerson* user){
        EZDEBUG(@"newly login user:%@, id:%@", user.name, user.personID);
        if(user){
            //Mean new user are login.
            //[EZCoreAccessor cleanClientDB];
            //[[EZDataUtil getInstance] cleanDBPhotos];
            _numberLabel.alpha = 0;
            [_combinedPhotos removeAllObjects];
            //[_nonsplitted removeAllObjects];
            [weakSelf.tableView reloadData];
        }
        NSArray* storedPhotos = [[EZDataUtil getInstance] getStoredPhotos];
        for(EZPhoto* photo in storedPhotos){
            [self updatePendingCount:photo];
        }
        //NSArray* splitted = [self splitPhotos:storedPhotos];
        EZDEBUG(@"Total stored:%i", storedPhotos.count);
        [_combinedPhotos addObjectsFromArray:[self wrapPhotos:storedPhotos]];
        //[_nonsplitted addObjectsFromArray:storedPhotos];
        [[EZDataUtil getInstance].mainPhotos addObjectsFromArray:_combinedPhotos];
        //[[EZDataUtil getInstance].mainNonSplits addObjectsFromArray:_nonsplitted];
        EZDEBUG(@"The stored photo is %i", _combinedPhotos.count);
        [[EZDataUtil getInstance] queryPhotos:_combinedPhotos.count pageSize:photoPageSize otherID:_currentUser.personID success:^(EZResult* res){
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
    
    _networkStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, CurrentScreenWidth, 20)];
    _networkStatus.textAlignment = NSTextAlignmentCenter;
    _networkStatus.textColor = [UIColor whiteColor];
    _networkStatus.font = [UIFont systemFontOfSize:12];
    //[_networkStatus enableShadow:[UIColor blackColor]];
    [self.view addSubview:_networkStatus];
    _networkStatus.hidden = YES;
    
    dispatch_later(0.3, (^(){
        [self scrollToBottom:NO];
    }));
    
    /**
    EZClickImage* bigClickButton = [[EZUIUtility sharedEZUIUtility] createBackShotButton];
    bigClickButton.center = CGPointMake(CurrentScreenWidth/2.0, CurrentScreenHeight - bigClickButton.frame.size.height/2.0 - 20);
    
    [self.view insertSubview:bigClickButton belowSubview:self.tableView];
    bigClickButton.releasedBlock = ^(id obj){
        [weakSelf raiseCamera:nil indexPath:nil];
    };
     **/
}


- (void) processDeleteNote:(EZNote*)note
{
    NSString* deletedID = note.deletedID;
    int prevPos = [[EZDataUtil getInstance] removeOtherPhoto:deletedID array:[EZDataUtil getInstance].mainPhotos store:YES];
    
    NSString* srcID = note.sourcePid;
    
    
    int pos = [self findPhotoByID:srcID photos:_combinedPhotos];
    EZDEBUG(@"deleted notes:%@, %@, pos:%i, pos now:%i", srcID, deletedID, prevPos, pos);
    if(pos >= 0){
        EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:pos];
        if(dp.photo.type == kPhotoRequest){
            [_combinedPhotos removeObjectAtIndex:pos];
            if(_combinedPhotos.count){
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:pos inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }else{
                [self.tableView reloadData];
            }
        }else{
            [self deleteMatchPhoto:dp deletedID:deletedID pos:pos];
        }
        
    }
}

- (void) deleteMatchPhoto:(EZDisplayPhoto*)dp deletedID:(NSString*)deletedID pos:(NSInteger)pos
{
    EZDEBUG(@"found dp:%@, relation count:%i", dp.photo.photoID, dp.photo.photoRelations.count);
    for(int i = 0; i < dp.photo.photoRelations.count; i++){
        EZPhoto* photo = [dp.photo.photoRelations objectAtIndex:i];
        if([photo.photoID isEqualToString:deletedID]){
            dp.photo.photoRelations = [[NSMutableArray alloc] initWithArray:dp.photo.photoRelations];
            [(NSMutableArray*)dp.photo.photoRelations removeObjectAtIndex:i];
        }
    }
    dp.photoPos = 0;
    
    EZDEBUG(@"Will reload photo");
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:pos inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}
//Make sure current view is the topMost.
- (BOOL) isVisibleController
{
    if(EZUIUtility.topMostController == self.navigationController && self.navigationController.visibleViewController == self){
        return true;
    }
    return false;
}

- (void) presentCurrentCell
{
    BOOL isVisible = [self isVisibleController];
    EZDEBUG(@"Visible status:%i", isVisible);
    if(isVisible){
        if(_scrollBlock){
            _scrollBlock(@(false));
        }
        NSArray* indexPaths = [self.tableView indexPathsForVisibleRows];
        EZDEBUG(@"visible index:%i", indexPaths.count);
        if(indexPaths.count){
            NSIndexPath* path = [indexPaths objectAtIndex:0];
            EZPhotoCell* cell = (EZPhotoCell*)[self.tableView cellForRowAtIndexPath:path];
            [self setupLongPress:cell];
        }
        
    }
    
    //NSArray* cells = [self.tableView visibleCells];
}

-(void)setupContentViewControllerAnimatorProperties {
    NSAssert(self.animator == nil, @"Animator is not nil – setupContentViewControllerAnimatorProperties likely called twice.");
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[_albumContainer]];
    // Need to create a boundary that lies to the left off of the right edge of the screen.
    //collisionBehaviour.translatesReferenceBoundsIntoBoundary = YES;
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-300, 0, 0, 0)];
    //collisionBehaviour.collisionDelegate = self;
    [self.animator addBehavior:collisionBehaviour];
    
    self.gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[_albumContainer]];
    //self.gravityBehaviour.gravityDirection = CGVectorMake(0, 1);
    [self.animator addBehavior:self.gravityBehaviour];
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[_albumContainer] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.magnitude = 0.0f;
    self.pushBehavior.angle = 0.0f;
    [self.animator addBehavior:self.pushBehavior];
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[_albumContainer]];
    itemBehaviour.elasticity = 0.45f;
    [self.animator addBehavior:itemBehaviour];
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
    
    __weak EZAlbumTablePage* weakSelf = self;
    BOOL triggerByNote = [[EZDataUtil getInstance].pushNotes objectForKey:note.noteID] != nil;
    int pos = [self findPhoto:note.srcID matchID:note.matchedID photos:_combinedPhotos];
    EZDEBUG(@"upload srcPhotoID:%@, uploaded:%i, matchedID:%@, uploaded:%i, position:%i, match type:%i, triggerByNotes:%i", note.srcPhoto.photoID, note.srcPhoto.uploaded, note.matchedID, note.matchedPhoto.uploaded, pos, note.matchedPhoto.type, triggerByNote);
    if(pos <  0){
        //EZDEBUG(@"Quit for not find the id:%@, let's find in total photos:%i", note.srcID, [EZDataUtil getInstance].mainNonSplits.count);
        pos = [self findPhoto:note.srcID matchID:note.matchedID photos:[EZDataUtil getInstance].mainPhotos];
        EZDisplayPhoto* disPhoto = [[EZDataUtil getInstance].mainPhotos objectAtIndex:pos];
        disPhoto.isFront = NO;
        disPhoto.photo.photoRelations = @[note.matchedPhoto];
        disPhoto.isFirstTime = YES;
        //disPhoto.photo.createdTime = note.createdTime;//note.srcPhoto.createdTime;
        [[EZDataUtil getInstance] storeAllPhotos:@[disPhoto.photo]];
        //if(triggerByNote){
            //EZPerson* ps = pid2person(note.matchedPhoto.personID);
            //NSIndexPath* visible = [[weakSelf.tableView visibleCells] objectAtIndex:0];
        
        if(triggerByNote){
            [self setCurrentUser:currentLoginUser readyBlock:^(id obj){
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:pos inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }];
        }
        
        //}
        return;
    }
    
    EZDisplayPhoto* disPhoto = [_combinedPhotos objectAtIndex:pos];
    disPhoto.isFront = NO;
    
    //NSMutableArray* ma = [[NSMutableArray alloc] initWithArray:disPhoto.photo.photoRelations];
    //[ma addObject:note.matchedPhoto]
    disPhoto.photo.photoRelations = @[note.matchedPhoto];
    disPhoto.isFirstTime = YES;
    disPhoto.photoPos = disPhoto.photo.photoRelations.count - 1;
    //[[EZMessageCenter getInstance] postEvent:EZNoteCountChange attached:@(1)];
    //EZPerson* otherPerson = pid2person(note.matchedPhoto.personID);
    //otherPerson.pendingEventCount += 1;
    [[EZDataUtil getInstance] storeAllPhotos:@[disPhoto.photo]];
    EZDEBUG(@"matchedPhoto converstion:%@, url:%@, disPhotoID:%@", note.matchedPhoto.conversations, note.matchedPhoto.screenURL, disPhoto.photo.photoID);
    //disPhoto.photo = note.srcPhoto;
    //[_combinedPhotos addObject:disPhoto];
    //preloadimage(note.matchedPhoto.screenURL);
    //[[EZDataUtil getInstance] preloadImage:note.matchedPhoto.screenURL success:^(id sender) {
    NSIndexPath* visible = [[weakSelf.tableView indexPathsForVisibleRows] objectAtIndex:0];
    if(triggerByNote || visible.row == pos){
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:pos  inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
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
    BOOL triggerByNotes = [[EZDataUtil getInstance].pushNotes objectForKey:note.noteID] != nil;
    EZDEBUG(@"srcPhotoID:%@,matchID:%@ uploaded:%i, matched:%@, type:%i, triggerByNotes:%i", note.srcPhoto.photoID,note.matchedID, note.srcPhoto.uploaded, matched.photoID, note.srcPhoto.type, triggerByNotes);
    __weak EZAlbumTablePage* weakSelf = self;
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
        EZDEBUG(@"This is a photoRequest srcID:%@, UI type:%i, matchID:%@,relations:%i, dataMainPhoto:%i, currentID:%@", note.srcPhoto.photoID,note.srcPhoto.typeUI, note.matchedPhoto.photoID, note.srcPhoto.photoRelations.count, [EZDataUtil getInstance].mainPhotos.count, _currentUser.name);
        EZDisplayPhoto* disPhoto = [[EZDisplayPhoto alloc] init];
        disPhoto.isFront = YES;
        disPhoto.photo = note.srcPhoto;
        note.srcPhoto.photoRelations = @[note.matchedPhoto];
        note.srcPhoto.createdTime = [NSDate date];
        [[EZDataUtil getInstance] storeAllPhotos:@[note.srcPhoto]];
        
        //if(_currentUser){
        [[EZDataUtil getInstance].mainPhotos addObject:disPhoto];
        //[[EZDataUtil getInstance].mainNonSplits addObject:note.srcPhoto];
        //}
        EZPerson* ps =  [[EZDataUtil getInstance]updatePerson:note.senderPerson];
        [ps adjustPendingEventCount:1];
        [[EZMessageCenter getInstance] postEvent:EZNoteCountChange attached:@(1)];
        if(_currentUser && ![note.matchedPhoto.personID isEqualToString:_currentUser.personID] && _currentUser.filterType != kPhotoWaitFilter){
            EZDEBUG(@"Quit for not displayable");
            if(triggerByNotes){
                EZDEBUG(@"trigger by notes, scroll to the object");
                [self setCurrentUser:ps readyBlock:^(id obj){
                    [weakSelf.combinedPhotos addObject:disPhoto];
                    //[_nonsplitted addObject:note.srcPhoto];
                    [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.combinedPhotos.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    [weakSelf scrollToBottom:YES];
                }];
            }
            return;
            
        }
        [_combinedPhotos addObject:disPhoto];
                //[_nonsplitted addObject:note.srcPhoto];
        if(_combinedPhotos.count){
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            if(triggerByNotes){
                [weakSelf scrollToBottom:NO];
            }
        }else{
            [self.tableView reloadData];
        }
        return;
        
    }
    
    NSArray* matchedArrs = nil;
    //if(_currentUser == nil && [_currentUser.personID isEqualToString:note.otherID]){
    //    matchedArrs = [[NSArray alloc] initWithArray:_combinedPhotos];
    //}else{
    matchedArrs = [[NSArray alloc] initWithArray:[EZDataUtil getInstance].mainPhotos];
    //}
    //NSMutableArray* matchedPhotos = [[NSMutableArray alloc] init];
    int pos = -1;
    BOOL alreadyIn = false;
    for (int i = 0; i < matchedArrs.count; i++) {
        EZDisplayPhoto* ph = [matchedArrs objectAtIndex:i];
        if([ph.photo.photoID isEqualToString:note.srcID]){
            //[matchedPhotos addObject:ph];
            if(pos < 0){
                pos = i;
            }
            if(ph.photo.photoRelations.count){
                EZPhoto* match = [ph.photo.photoRelations objectAtIndex:0];
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
   
    EZDisplayPhoto* disPhoto = [matchedArrs objectAtIndex:pos];
    EZPhoto* orgin = disPhoto.photo;
    
    for(EZPhoto* pt in orgin.photoRelations){
        if([pt.photoID isEqualToString:note.matchedPhoto.photoID]){
            EZDEBUG(@"photo id already existed");
            return;
        }
    }
    NSMutableArray* ma = [[NSMutableArray alloc] initWithArray:orgin.photoRelations];
    [ma addObject:note.matchedPhoto];
    
    orgin.photoRelations = ma;
    [[EZDataUtil getInstance] storeAllPhotos:@[orgin]];
 
    disPhoto.isFront = NO;
    disPhoto.photoPos = ma.count - 1;
    disPhoto.isFirstTime = YES;
    //EZPerson* ps = [[EZDataUtil getInstance] updatePerson:note.senderPerson];
    //ps.pendingEventCount += 1;
    //[ps adjustPendingEventCount:1];
    //[ps save];
    //[[EZDataUtil getInstance]storeAllPersons:@[ps]];
    [[EZMessageCenter getInstance] postEvent:EZNoteCountChange attached:@(1)];
    //if(_currentUser){
        //[[EZDataUtil getInstance].mainPhotos addObject:disPhoto];
    //}
    if(_currentUser && ![note.matchedPhoto.personID isEqualToString:_currentUser.personID]){
        EZDEBUG(@"Quit for not displayable");
        return;
    }
    EZDEBUG(@"Recieved match event otherID:%@, photoID:%@", note.otherID, note.srcPhoto.photoID);
    /**
    for(int i = 0; i < _combinedPhotos.count; i++){
        EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:i];
        if([dp.photo.photoID isEqualToString:disPhoto.photo.photoID]){
            //[_combinedPhotos insertObject:disPhoto atIndex:i];
            //[self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            break;
            //[self.tableView endUpdates];
        }
    }
     **/
    
}

//I alway search from the non-split
- (void) saveMatchedPhoto:(EZNote*)note
{
    
}


- (NSMutableArray*) splitPhotosOld:(NSArray*)photos
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

- (void) setLocalLike:(EZNote*)note isPush:(BOOL)isPush
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
            //[[EZDataUtil getInstance] storeAllPhotos:@[ph]];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            if(isPush){
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            break;
        }
    }
}

- (void) addLike:(EZNote*)note
{
    __weak EZAlbumTablePage* weakSelf = self;
    NSArray* matchedArrs = [[NSArray alloc] initWithArray:[EZDataUtil getInstance].mainPhotos];
    BOOL triggerByNote = [[EZDataUtil getInstance].pushNotes objectForKey:note.noteID] != nil;
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
                    if(!_currentUser){
                        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                        if(triggerByNote){
                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        }
                    }else{
                        //[self setLocalLike:note isPush:triggerByNote];
                        if(triggerByNote){
                            EZDEBUG(@"will show the like");
                            //if(![self isVisibleController]){
                            [self.navigationController popToViewController:self animated:NO];
                            [self setCurrentUser:currentLoginUser readyBlock:^(id sender){
                                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                            }];
                            //}
                        }
                    }
                    break;
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
    NSArray* totalNonSplit = [EZDataUtil getInstance].mainPhotos;
    for(int i = 0; i < totalNonSplit.count; i ++){
        EZDisplayPhoto* disPhoto = [totalNonSplit objectAtIndex:i];
        EZPhoto* photo = disPhoto.photo;
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
            EZDisplayPhoto* dp = [self wrapPhoto:pt];
            [_combinedPhotos insertObject:dp atIndex:0];
            [[EZDataUtil getInstance].mainPhotos insertObject:dp atIndex:0];
            count ++;
            [stored addObject:pt];
        }
    }
    //_fillCount = totalCount - _nonsplitted.count;
    EZDEBUG(@"total count:%i, _combinedPhoto:%i, fillCount:%i, stored:%i", totalCount, _combinedPhotos.count, _fillCount, stored.count);
    [[EZDataUtil getInstance] storeAllPhotos:stored];
    [self.tableView reloadData];
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
    if(_combinedPhotos.count == 1){
        [self.tableView reloadData];
    }else{
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
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
            //NSArray* splitted = [self splitPhotos:@[pt]];
            //for(EZPhoto* sp in splitted){
                //EZDisplayPhoto* dp = [self wrapPhoto:sp];
                //[_combinedPhotos insertObject:dp atIndex:0];
            [self fillCombinePhotos:finded];
                
            count ++;
            //}
            //[_nonsplitted insertObject:pt atIndex:0];
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
    [self setupContentViewControllerAnimatorProperties];

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
    
    EZClickImage* imageButton = [[EZClickImage alloc] initWithFrame:CGRectMake(0, 6, 46, 46)];

    _iconButton =  [[EZEnlargedView alloc] initWithFrame:imageButton.frame innerView:imageButton enlargeRatio:EZEnlargeIconRatio];
    imageButton.contentMode = UIViewContentModeScaleAspectFill;
    imageButton.image = [UIImage imageNamed:@"feather_icon"];
    imageButton.userInteractionEnabled = false;
    [imageButton enableRoundImage];
    _iconButton.releasedBlock = ^(id obj){
        [weakSelf titleClicked:nil];
    };
    
    
    EZHairButton* hairButton = [[EZUIUtility sharedEZUIUtility] createShotButton];
    hairButton.userInteractionEnabled = false;
    EZEnlargedView* clickView = [[EZEnlargedView alloc] initWithFrame:hairButton.frame innerView:hairButton enlargeRatio:EZEnlargeIconRatio];
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
    
    _rightCycleButton.longPressBlock = ^(id obj){
        EZDEBUG(@"long pressed get called");
        if(weakSelf.asset){
            [weakSelf popAlbumSender];
        }
    };
    
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
    [_leftCyleButton setTitle:DefaultEmptyString forState:UIControlStateNormal];
    [_leftCyleButton addSubview:_iconButton];
    
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
    if(!currentLoginID){
        _leftCyleButton.hidden = YES;
        _rightCycleButton.hidden = YES;
    }
    
    [_leftCyleButton addTarget:self action:@selector(titleClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) titleClicked:(id)obj
{
    _leftMessageCount.hidden = YES;
    
    //dispatch_later(0.3, ^(){
    //[weakSelf.leftText setTextColor:[UIColor whiteColor]];
    //});
    if(self.navigationController.viewControllers.count == 1){
        [self showMenu:nil];
    }

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
    
    if(_combinedPhotos.count){
        return _combinedPhotos.count;
    }else{
        if(!_currentUser.filterType){
            return 1;
        }
    }
    return 0;
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
        if(indexPath.row >= _combinedPhotos.count){
            return;
        }
        EZDEBUG(@"indexPath no more visible:%i", indexPath.row);
        EZPhotoCell* pc  = (EZPhotoCell*)[tableView cellForRowAtIndexPath:indexPath];
        EZDEBUG(@"before release image size:%@", NSStringFromCGSize(pc.frontImage.image.size));
        pc.frontImage.image = nil;
        [pc.frontImage cleanAllPhotos];
        
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
        [self loadImage:weakCell url:photo.screenURL retry:2 path:path position:0];
    }
}

- (void) loadImage:(EZPhotoCell*)weakCell  url:(NSString*)secondURL retry:(int)count path:(NSIndexPath*)path position:(NSInteger)position
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
    UIImageView* imageView = [weakCell.frontImage.imageViews objectAtIndex:position];
    imageView.image = nil;
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
            //weakCell.frontImage.image = fileurl2image(localURL);
            imageView.image = fileurl2image(localURL);
        }else{
            UIView* snapShot = [weakCell.frontImage snapshotViewAfterScreenUpdates:NO];
            [weakCell.frontImage addSubview:snapShot];
            //[weakCell setImageWithURL:str2url(localURL)];
            imageView.image = fileurl2image(localURL);
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
            imageView.image = blurred;
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
    }];
}


- (void) displayChat:(EZPhotoCell*)cell ownerPhoto:(EZPhoto*)ownp otherPhoto:(EZPhoto*)otherp
{
    
    EZDEBUG(@"own Conversation count:%i, other count:%i", ownp.conversations.count, otherp.conversations.count);
    if(ownp.conversations.count){
        NSDictionary* conversation = [ownp.conversations objectAtIndex:0];
        cell.ownTalk.text = [conversation objectForKey:@"text"];
    }else{
        //cell.ownTalk.text = @"";
        cell.ownTalk.text = formatRelativeTime(ownp.createdTime);
    }
    
    if(otherp.conversations.count){
        NSDictionary* conversation = [otherp.conversations objectAtIndex:0];
        cell.otherTalk.text = [conversation objectForKey:@"text"];
    }else{
        //cell.otherTalk.text = @"";
        if(otherp.typeUI){
            cell.otherTalk.text = @"";
        }else{
            cell.otherTalk.text =formatRelativeTime(otherp.createdTime);
        }
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
        //cell.frontImage.backgroundColor = ClickedColor;
        cell.waitingInfo.text =[NSString stringWithFormat:macroControlInfo(@"等待%@的照片"), otherPerson.name?otherPerson.name:@"朋友"];
        cell.waitingInfo.hidden = NO;
        cell.otherIcon.hidden = YES;
        cell.otherName.hidden = YES;
        cell.andSymbol.hidden = YES;
        cell.ownTalk.hidden = YES;
        cell.authorName.hidden = YES;
        cell.headIcon.hidden = YES;
        cell.gradientView.hidden = YES;
        cell.frontImage.pageControl.hidden = YES;
    }else{
        cell.waitingInfo.hidden = YES;
    }
}

- (void) switchImage:(EZPhotoCell*)weakCell displayPhoto:(EZDisplayPhoto*)cp front:(EZPhoto*)front back:(EZPhoto*)back animate:(BOOL)animate path:(NSIndexPath*)path position:(NSInteger)pos
{
    
    EZPhoto* photo = nil;
    NSString* localFull = checkimageload(back.screenURL);
    EZDEBUG(@"try to local url:%@, local:%@, back is:%i, back type:%i", back.screenURL, localFull, (int)back, back.type);
    //if(!localFull && !back.type){
    //    return;
    //}
    weakCell.rotateCount += 1;
    weakCell.activityView.hidden = YES;
    [weakCell.activityView stopAnimating];
    if(animate){
        UIView* snapShot = [weakCell.rotateContainer snapshotViewAfterScreenUpdates:NO];
        //snapShot.backgroundColor = [UIColor redColor];
        //snapShot.frame = weakCell.frontImage.frame;
        //snapShot.backgroundColor = RGBA(255, 128, 128, 128);
        snapShot.layer.zPosition = 3000;
        [weakCell.rotateContainer addSubview:snapShot];
        
        //UIView* view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
        //view.backgroundColor = [UIColor redColor];
        //[view addSubview:snapShot];
        //[TopView addSubview:snapShot];
        
        
        //weakCell.frontImage.image = nil;
        if(cp.isFront){
            photo = back;
            [weakCell setFrontFormat:false];
            [self setWaitingInfo:weakCell displayPhoto:cp back:back];
            if(back.type == kPhotoRequest || ([cp.photo.exchangePersonID isNotEmpty] && back == nil)){
                //weakCell.frontImage.image = [UIImage imageNamed:@"background.png"];
                weakCell.frontImage.image = nil;
                EZDEBUG(@"waiting for response");
            }else if(photo == nil){
                weakCell.frontImage.image = nil;
                //[[EZUIUtility sharedEZUIUtility] showErrorInfo:macroControlInfo(@"Network not available") delay:1.0 view:self.view];
                
            }
            else
            {
                [self loadImage:weakCell url:photo.screenURL retry:0 path:path position:pos];
            }
        }else{
            photo = front;
            [weakCell setFrontFormat:true];
            weakCell.waitingInfo.hidden = YES;
            //[weakCell.frontImage setImage:[front getScreenImage]];
            [self loadFrontImage:weakCell photo:front file:front.assetURL path:path];
        }
        
    
        dispatch_later(0.15, ^(){
        [UIView flipTransition:snapShot dest:weakCell.frontImage container:weakCell.rotateContainer isLeft:cp.isFront duration:EZRotateAnimDuration complete:^(id obj){
            [snapShot removeFromSuperview];
            EZPerson* person = pid2person(photo.personID);
            EZDEBUG(@"person id:%@, name:%@", photo.personID, person.name);
        }];}
       );
    }else{
        weakCell.frontImage.image = nil;
        if(cp.isFront){
            photo = back;
            [weakCell setFrontFormat:false];
            [self setWaitingInfo:weakCell displayPhoto:cp back:back];
            if(back.type == kPhotoRequest || ([cp.photo.exchangePersonID isNotEmpty] && back == nil)){
                //weakCell.frontImage.image = [UIImage imageNamed:@"background.png"];
            }
            else if(photo == nil){
                //[[EZUIUtility sharedEZUIUtility] showErrorInfo:macroControlInfo(@"Network not available") delay:1.0 view:self.view];
            }

            else{
                weakCell.waitingInfo.hidden = YES;
                [self loadImage:weakCell url:photo.screenURL retry:0 path:path position:pos];
            }
        }else{
            photo = front;
            [weakCell setFrontFormat:true];
            weakCell.waitingInfo.hidden = YES;
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


#pragma mark - Dragging control.
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //EZDEBUG(@"Begin dragging point:%@, size:%@", NSStringFromCGPoint(scrollView.contentOffset), NSStringFromCGSize(scrollView.contentSize));
    //_isScrolling = true;
    if(_assetView.image){
        [_assetView setY:_tableView.contentSize.height];
        _assetView.hidden = NO;
    }
    _innerFirstTime = false;
    
    //int pos = self.tableView.contentOffset.y / CurrentScreenHeight;
    if(!self.tableView.indexPathsForVisibleRows.count){
        return;
    }
        
    
    NSIndexPath* visiblePath = [self.tableView.indexPathsForVisibleRows objectAtIndex:0];
    if(visiblePath.row < _combinedPhotos.count){
        EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:visiblePath.row];
        if(dp.isFront && dp.photo.typeUI != kPhotoRequest){
            _rotateIndex = visiblePath;
            _scrollBeginPos = self.tableView.contentOffset.y;
            _rotateCell = (EZPhotoCell*)[self.tableView cellForRowAtIndexPath:visiblePath];
            UIView* snapShot = [_rotateCell.frontImage snapshotViewAfterScreenUpdates:NO];
            snapShot.tag = 2012;
            snapShot.layer.zPosition = 3000;
            [_rotateCell.rotateContainer addSubview:snapShot];
            EZPhoto* backPhoto = nil;
            if(dp.photo.photoRelations.count > dp.photoPos){
                backPhoto = [dp.photo.photoRelations objectAtIndex:dp.photoPos];
            }
            [self switchImage:_rotateCell displayPhoto:dp front:dp.photo back:backPhoto animate:NO path:visiblePath position:dp.photoPos];
            
            //CGFloat delta = fabsf(_scrollBeginPos - self.tableView.contentOffset.y)/CurrentScreenHeight;
            CATransform3D trans = CATransform3DRotate(CATransform3DIdentity, M_PI/2.0, 0.0, 1.0, 0.0);
            trans.m34 = 1/3000.0;
            _rotateCell.frontImage.layer.transform = trans;
        }
    }
}



- (void) scrollViewDidScroll:(UIScrollView*)scrollView{
    //EZDEBUG(@"did scroll get called");
    if(_scrollBlock){
        _scrollBlock(@(true));
        _scrollBlock = nil;
    }
    if(_rotateCell){
        CGFloat delta = fabsf(_scrollBeginPos - self.tableView.contentOffset.y)/CurrentScreenHeight;
        CATransform3D trans = CATransform3DRotate(CATransform3DIdentity, M_PI*delta, 0.0, 1.0, 0.0);
        trans.m34 = 1/1000.0;
        
        //[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
        [_rotateCell.rotateContainer viewWithTag:2012].layer.transform = trans;
        if(delta > 0.5){
            [_rotateCell.rotateContainer viewWithTag:2012].hidden = YES;
            CGFloat gapAngle = ((1.0 - delta)/0.5) * M_PI_2;
            
            CATransform3D frontTrans = CATransform3DRotate(CATransform3DIdentity, gapAngle, 0.0, 1.0, 0.0);
            trans.m34 = 1/1000.0;
            _rotateCell.frontImage.layer.transform = frontTrans;
        }else{
            [_rotateCell.rotateContainer viewWithTag:2012].hidden = NO;
        }
        
        //} completion:^(BOOL complete){
        //    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(){
        //        weakCell.container.layer.transform = CATransform3DIdentity;
        //    } completion:nil];
        //}];

    }
}


- (void) popAlbumSender
{
    _raiseAssetCamera = true;
    DLCImagePickerController* picker = [self embedCamera:_asset personID:_currentUser.personID];
    //[_tableView addSubview:_innerPicker.view];
    //[_innerPicker.view setY:0];
    //[_innerPicker viewWillAppear:YES];
    //[_innerPicker viewDidAppear:YES];
    //_leftCyleButton.hidden = YES;
    //_rightCycleButton.hidden = YES;
    //dispatch_later(0.1, ^(){
    _innerCameraRaised = YES;
    //});
    _innerFirstTime = YES;
    //_bottomView = _innerPicker.view;
    __weak EZAlbumTablePage* weakSelf = self;
    //[_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_combinedPhotos.count inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    picker.innerCancelBlock = ^(id obj){
        weakSelf.raiseAssetCamera = false;
        //weakSelf.leftCyleButton.hidden = NO;
        //weakSelf.rightCycleButton.hidden = NO;
        //UIView* snapShot = [weakSelf.innerPicker.view snapshotViewAfterScreenUpdates:NO];
        //[weakSelf.view addSubview:snapShot];
        //weakSelf.tableView.contentInset = UIEdgeInsetsZero;
        //weakSelf.tableView.contentSize = CGSizeMake(0, weakSelf.combinedPhotos.count * CurrentScreenHeight);
        //[weakSelf.innerPicker.view removeFromSuperview];
        //weakSelf.innerPicker = nil;
        //weakSelf.innerCameraRaised = false;
        //[UIView animateWithDuration:0.2 animations:^(){
        //snapShot.alpha = 0.0;
        //} completion:^(BOOL complete){
        //    [snapShot removeFromSuperview];
        //}];
        //weakSelf.bottomView = nil;
    };
    _isPushCamera = YES;
    [self.navigationController pushViewController:picker animated:YES];
}


- (void) scrollViewDidScrollOld:(UIScrollView *)scrollView{
    EZDEBUG(@"Did scroll get called");
    if(!_raiseAssetCamera && _asset && !_currentUser.filterType){
        CGFloat exceedY = scrollView.contentOffset.y + CurrentScreenHeight - scrollView.contentSize.height;
        if(exceedY > 90){
            
            
        }

    }else if(_innerCameraRaised && !_innerFirstTime){
         CGFloat exceedY = scrollView.contentSize.height - scrollView.contentOffset.y;
        if(exceedY > 20){
            //[_innerPicker cancelClicked];
            [_innerPicker embededCancel];
            _innerPicker.innerCancelBlock(nil);
        }
    }
}

- (void) scrollViewDidEndDraggingOld:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    EZDEBUG(@"content offset:%f, total height:%f, decelerate:%i", scrollView.contentOffset.y, scrollView.contentSize.height, decelerate);
    
    CGFloat exceedY = scrollView.contentOffset.y + CurrentScreenHeight - scrollView.contentSize.height;
    if(exceedY > 90){
        if(_asset && !_currentUser.filterType){
            _raiseAssetCamera = true;
            
            [UIView animateWithDuration:0.3 animations:^(){
                _tableView.contentInset = UIEdgeInsetsMake(0, 0, CurrentScreenHeight, 0);
                _tableView.contentOffset= CGPointMake(0, _tableView.contentSize.height);
                //_tableView.contentInset = UIEdgeInsetsMake(0, 0, CurrentScreenHeight, 0);
            } completion:^(BOOL completed){
                //[self raiseCamera:_asset personID:_currentUser.personID];
            }];
            
            //dispatch_later(0.2, ^(){
            //    [self raiseCamera:_asset personID:_currentUser.personID];
            //});
            //dispatch_later(0.30, ^(){
            //    [self raiseCamera:_asset personID:_currentUser.personID];
            //});
        }
    }
    //if(scrollView.contentOffset.y )
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.tableView refreshCustomScrollIndicatorsWithAlpha:0.0];
    }];
    NSInteger pos = _tableView.contentOffset.y/CurrentScreenHeight;
    if(_combinedPhotos.count > pos){
        EZDisplayPhoto* dp = [_combinedPhotos objectAtIndex:pos];
        if(dp.photo.typeUI == kPhotoRequest){
            _rightCycleButton.hidden = YES;
        }else{
            _rightCycleButton.hidden = NO;
        }
        if(dp.isFirstTime){
            dp.isFirstTime = false;
            if(_currentUser.filterType == kPhotoNewFilter){
                [_currentUser adjustPendingEventCount:-1];
            }
            [self setNoteCount];
        }
    }
    if(!_raiseAnimation){
        _assetView.hidden = YES;
    }
    //if(_raiseAssetCamera){
    //    _raiseAssetCamera = false;
    //    [self raiseCamera:_asset personID:_currentUser.personID];
    //}
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
