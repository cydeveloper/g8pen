//
//  DBManager.h
//  treasurebowl
//
//  Created by AtSu on 2015/5/14.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//
// a DB for icon info.
#import <UIKit/UIKit.h>
#import "Icon.h"
#import "Group.h"
#import "Card.h"
#import "Macro.h"
#define INT_PARAM(A) [NSNumber numberWithInteger:A]
#define FLOAT_PARAM(A) [NSNumber numberWithFloat:A]

#define COL_DATA(row, str) [row objectForKey:@str]
#define STR_FORM(str, ...) [[NSString stringWithFormat: @str, ##__VA_ARGS__] UTF8String]

#define STMT_DATABASE_TABLE     STR_FORM(                                        \
                                "create table if not exists %@ "                 \
                                "(icon_ID integer primary key autoincrement,     \
                                card_ID text, icon_url text, shortcut_url text,  \
                                total_number integer, phone_num text, name text, \
                                sequence integer, group_ID integer);"            \
                                                                                 \
                                "create table if not exists %@ "                 \
                                "( group_ID integer primary key autoincrement,   \
                                name text, icons_id_array text, color text,      \
                                sequence integer);"                              \
                                                                                 \
                                "create table if not exists %@ "                 \
                                "(card_ID text primary key, status text          \
                                , currentPoints real);"                          \
                                , iconTable, groupTable, cashTable)


#define STMT_INSERT_GROUP       STR_FORM("INSERT INTO %@ ( name, icons_id_array, color, sequence)" \
                                " VALUES(?, ?, ?, ?)", groupTable)

#define STMT_REPLACE_GROUP      STR_FORM("REPLACE INTO %@ ( group_ID, name, icons_id_array, color, sequence)" \
                                " VALUES( ?, ?, ?, ?, ?)", groupTable)

#define STMT_DELETE_GROUP       STR_FORM("DELETE FROM %@ WHERE name=?", groupTable)

#define STMT_GET_GROUP_BY_ID(X) STR_FORM("SELECT group_ID, name, icons_id_array, \
                                color, sequence FROM %@ WHERE group_ID=%ld", \
                                groupTable, X)

#define STMT_GET_GROUP_BY_NAME  STR_FORM("SELECT group_ID, name, icons_id_array, \
                                color, sequence FROM %@ WHERE name=?", groupTable)

#define STMT_GET_GROUPS         STR_FORM("SELECT group_ID, name, icons_id_array, \
                                color, sequence FROM %@ ORDER BY sequence ASC", groupTable)

#define STMT_INSERT_ICON        STR_FORM("INSERT INTO %@ ( card_ID, icon_url, shortcut_url, total_number, \
                                phone_num, name, sequence, group_ID)" \
                                " VALUES(?, ?, ?, ?, ?, ?, ?, ?)", iconTable)

#define STMT_REPLACE_ICON       STR_FORM("REPLACE INTO %@ ( icon_ID, card_ID, icon_url, shortcut_url, \
                                total_number, phone_num, name, sequence, group_ID)" \
                                " VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)", iconTable)

#define STMT_DELETE_ICON        STR_FORM("DELETE FROM %@ WHERE name=?", iconTable)

#define STMT_GET_ICON_BY_ID(X)  STR_FORM("SELECT icon_ID, card_ID, icon_url, shortcut_url, total_number, \
                                phone_num, name, sequence, group_ID FROM %@ WHERE icon_ID=%ld", iconTable, ID)

#define STMT_GET_ICON_BY_NAME   STR_FORM("SELECT icon_ID, card_ID, icon_url, shortcut_url, total_number, \
                                phone_num, name, sequence, group_ID FROM %@ WHERE name=?", iconTable)

#define STMT_GET_ICONS          STR_FORM("SELECT icon_ID, card_ID, icon_url, shortcut_url, total_number, \
                                phone_num, name, sequence, group_ID FROM %@  ORDER BY sequence ASC", iconTable)

#define STMT_INSERT_CARD        STR_FORM("INSERT INTO %@ ( card_ID, status, currentPoints) VALUES(?, ?, ?)", cashTable)

#define STMT_REPLACE_CARD       STR_FORM("REPLACE INTO %@ ( card_ID, status, currentPoints)" \
                                " VALUES( ?, ?, ?)", cashTable)

#define STMT_DELETE_CARD        STR_FORM("DELETE FROM %@ WHERE card_ID=?", cashTable)

#define STMT_GET_CARD           STR_FORM("SELECT card_ID, status, currentPoints FROM %@ WHERE card_ID=?", cashTable)

#define STMT_GET_CARDS          STR_FORM("SELECT card_ID, status, currentPoints FROM %@", cashTable)

#define ICON_INIT_BY_ROW(row)   [[Icon alloc] \
                                initWithCardID:  COL_DATA(row, "card_ID")                     IconID      : [COL_DATA(row, "icon_ID") integerValue] \
                                IconURL       :  COL_DATA(row, "icon_url")                    shortcutUrl :  COL_DATA(row, "shortcut_url") \
                                TotNum        : [COL_DATA(row, "total_number") integerValue]  PhoneNum    : [DBManager turnTextToArray: COL_DATA(row, "phone_num")] \
                                Name          :  COL_DATA(row, "name")                        Sequence    : [COL_DATA(row, "sequence") integerValue] \
                                GroupID       : [COL_DATA(row, "group_ID") integerValue]]


#define GROUP_INIT_BY_ROW(row)  [[Group alloc] \
                                initWithGroupID: [COL_DATA(row, "group_ID") integerValue]                      Name : COL_DATA(row, "name") \
                                Icons_id_array : [DBManager turnTextToArray:COL_DATA(row, "icons_id_array")]   Color: COL_DATA(row, "color") \
                                Sequence       : [COL_DATA(row, "sequence") integerValue]]

#define CARD_INIT_BY_ROW(row)  [[Card alloc] \
                               init        :  COL_DATA(row, "card_ID") \
                               Status      :  COL_DATA(row, "status")           CurrentPoints : [COL_DATA(row, "currentPoints") floatValue]]

@interface DBManager : NSObject {
    NSString *dbPath;
}

+ (DBManager*)getSharedInstance;
+ (NSString*)getDBPath;
- (BOOL)createDB;

- (BOOL)insertIcon:(Icon*) icon;
- (BOOL)removeIconByName:(NSString*)name;
- (id)getIconByName:(NSString*)name ByIconID:(NSInteger)ID;
- (NSArray*)getIcons;
//- (id)getIconByIconID:(NSString*) iconID;
//- (BOOL)updateIcon:(Icon*) icon;


- (BOOL)insertGroup:(Group*) group;
- (BOOL)removeGroupByName:(NSString*) name;
- (id)getGroupByName:(NSString*)name ByGroupID:(NSInteger)ID;
- (NSArray*)getGroups;
//- (id)getGroupByDBID:(NSString*) db_ID;


- (BOOL)insertCard:(Card*) card;
- (BOOL)removeCard:(NSString*) cardID;
- (id)getCardByCardID:(NSString*) cardID;
- (NSArray*)getCards;
//- (id)getCardByDBID:(NSString*) db_ID;
//- (BOOL)updateGroup:(Group*) group;
//- (BOOL)updateCard:(Card*) card;

+ (NSString*)splitArrayToText:(NSMutableArray*) phone_num;
+ (NSMutableArray*)turnTextToArray:(NSString*) phone_text;
@end