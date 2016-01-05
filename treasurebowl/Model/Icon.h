//
//  Icon.h
//  treasurebowl
//
//  Created by AtSu on 2015/5/18.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Group;
@class UIImage;
@interface Icon : NSObject

@property(nonatomic) NSInteger icon_ID; // icon ID
@property(nonatomic) NSString* card_ID; // Card ID
@property(nonatomic) NSString* icon_url; // the path that save the icon image
@property(nonatomic) NSString* shortcut_url;

@property(nonatomic) NSInteger total_number; // total number of phone
@property(nonatomic) NSMutableArray *phone_num; // An array store the phone

@property(nonatomic) NSString* name; // icon name
@property(nonatomic) NSInteger sequence; // position in main ui

@property(nonatomic, weak) Group* group;
@property(nonatomic) NSInteger group_ID;


- (id)initWithCardID:(NSString*)card_ID IconID:(NSInteger)icon_ID IconURL:(NSString*) icon_url
         shortcutUrl:(NSString*)shortcut_url TotNum:(NSInteger) total_number
            PhoneNum:(NSMutableArray*) phone_num Name:(NSString*) name
            Sequence:(NSInteger) sequence GroupID:(NSInteger) group_ID Group:(Group*) group;


- (id)initWithCardID:(NSString *)card_ID IconID:(NSInteger)icon_ID IconURL:(NSString*) icon_url
         shortcutUrl:(NSString*)shortcut_url TotNum:(NSInteger)total_number
            PhoneNum:(NSMutableArray *)phone_num Name:(NSString *)name
            Sequence:(NSInteger)sequence GroupID:(NSInteger)group_ID;

- (id)initWithCardID:(NSString*)card_ID IconID:(NSInteger)icon_ID IconURL:(NSString*) icon_url
         shortcutUrl:(NSString*)shortcut_url TotNum:(NSInteger) total_number
            PhoneNum:(NSMutableArray*) phone_num Name:(NSString*) name
            Sequence:(NSInteger) sequence;

- (UIImage*)getImage;
@end