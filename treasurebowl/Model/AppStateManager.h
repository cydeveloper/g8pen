//
//  AppStateManager.h
//  treasurebowl
//
//  Created by AtSu on 2015/8/5.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define INT_KEY(A) [NSNumber numberWithInteger:A]
@class DBManager;
@class Icon;
@class Group;
@class Card;
@interface AppStateManager : NSObject

@property(nonatomic)DBManager* db;
@property(nonatomic)NSUserDefaults* userDefault;
@property(nonatomic)NSMutableArray* iconList;
@property(nonatomic)NSMutableArray* groupList;
@property(nonatomic)NSMutableArray* cardList;
@property(nonatomic)NSMutableDictionary* iconDic_id;
@property(nonatomic)NSMutableDictionary* groupDic_id;
@property(nonatomic)NSMutableDictionary* cardDic_id;
@property(nonatomic)NSMutableDictionary* iconDic_name;
@property(nonatomic)NSMutableDictionary* groupDic_name;
@property(nonatomic)NSInteger block_num_setting;
@property(nonatomic)NSString* block_userphone;

+ (AppStateManager*)getSharedInstance;

/* as private methods
 * - (void)loadIcon;
 * - (void)loadGroup;
 */
- (NSArray*)getIcons;
- (NSArray*)getGroups;
- (NSArray*)getCards;

#pragma mark userdefault
- (NSUserDefaults*)loadUserDefault;
- (void)setUserKey:(NSString*)key Value:(id)value;
- (void)setUserKey:(NSString *)key IntValue:(NSInteger)value;
- (void)setUserBlock:(NSInteger)block_num;
- (void)setUserPhone:(NSString*)phone;
- (id)getUserKey:(NSString*)key;
- (NSInteger)getUserKeyForInt:(NSString*)key;
- (NSInteger)getUserBlock;

#pragma mark retrival methods
- (Icon*)getIconByName:(NSString*) name;
- (Icon*)getIconByID:(NSInteger) ID;

- (Group*)getGroupByName:(NSString*) name;
- (Group*)getGroupByID:(NSInteger) ID;

#pragma mark deletion methods
- (BOOL)deleteIconWithName:(NSString*) name;
- (BOOL)deleteGroupWithName:(NSString*) name;
- (BOOL)deleteCardWithID:(NSString*) ID;
#pragma mark create methods
- (BOOL)addNewIcon:(Icon*)icon toGroup:(Group*)group;
- (BOOL)addNewGroup:(Group*) group;
- (BOOL)addNewCard:(Card*) card;
#pragma mark update methods
- (BOOL)updateIcon:(Icon*) icon;
- (BOOL)updateGroup:(Group*) group;
- (BOOL)updateCard:(Card*) card;

#pragma mark iconModify methods
- (BOOL)addPhoneToIcon:(Icon*) icon Phone:(NSString*)phone;

#pragma mark relationModify methods
- (BOOL)iconJoinGroup:(Group*)group Icon:(Icon*)icon;
- (BOOL)iconLeaveGroup:(Group*)group Icon:(Icon*)icon;
//- (void)refreshIconAndGroupData;


@end
