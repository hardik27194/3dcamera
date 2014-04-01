//
//  EZNote.h
//  FeatherCV
//
//  Created by xietian on 14-3-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EZNoteMatch @"match"
#define EZNoteLike @"like"
#define EZNoteUpload @"upload"
#define EZNoteJoined @"joined"
#define EZNoteFriendAdd @"add"
#define EZNoteFriendKick @"kick"


@class  EZPhoto;
@class EZPerson;
@interface EZNote : NSObject

@property (nonatomic, strong) NSString* noteID;



@property (nonatomic, strong) NSString* type;
//MongoUtil.save('notes', {'type':'like','personID':str(photo['personID']),'photoID':photoID,"otherID":personID,"like":likeStr})
//Like it or not.
//Only useful when use like as type
@property (nonatomic, strong) NSString* photoID;
@property (nonatomic, assign) BOOL like;
@property (nonatomic, strong) NSString* otherID;


//match flag
//'notes', {'type':'match','personID':str(subPhoto['personID']), 'srcID':pid, 'matchedID':str(srcID),
@property (nonatomic, strong) NSString* srcID;

@property (nonatomic, strong) EZPhoto* srcPhoto;
@property (nonatomic, strong) NSString* matchedID;

@property (nonatomic, strong) NSDate* createdTime;

@property (nonatomic, strong) EZPhoto* matchedPhoto;

@property (nonatomic, strong) EZPerson* person;

@property (nonatomic, strong) EZPerson* senderPerson;

- (void) fromJson:(NSDictionary*)dict;

@end
