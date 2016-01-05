//
//  AppStateManager.m
//  treasurebowl
//
//  Created by AtSu on 2015/8/5.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "AppStateManager.h"
#import "DBManager.h"
#import "Icon.h"
#import "Group.h"
@implementation AppStateManager
static AppStateManager* sharedInstance = nil;

+ (AppStateManager*)getSharedInstance {
    if(!sharedInstance) {
        DE_LOG("APM init");
        sharedInstance = [[AppStateManager alloc] init];
        sharedInstance.userDefault = [sharedInstance loadUserDefault];
        sharedInstance.block_num_setting = [sharedInstance getUserKeyForInt:@"treasure_blocknum"];
        sharedInstance.block_userphone = [sharedInstance getUserKey:@"treasure_userphone"];
        sharedInstance.db = [DBManager getSharedInstance];
        sharedInstance.iconDic_id = [[NSMutableDictionary alloc] init];
        sharedInstance.iconDic_name = [[NSMutableDictionary alloc] init];
        sharedInstance.groupDic_id = [[NSMutableDictionary alloc] init];
        sharedInstance.groupDic_name = [[NSMutableDictionary alloc] init];
        sharedInstance.cardDic_id = [[NSMutableDictionary alloc] init];
        DE_LOG("Block setting: %lu", sharedInstance.block_num_setting);
        // load icon and group for use.
        [sharedInstance loadIcon];
        [sharedInstance loadGroup];
        [sharedInstance loadCard];
    
        if([sharedInstance getGroupByID:1]==nil){
            
            //NSLog(@"list num = %lu" , (unsigned long)[[appStateManager getGroups]count]);
            
            DE_LOG("FIRST");
            Group* group = [[Group alloc] initWithName:@"My" Icons_id_array:nil Color:@"0.49/0.49/0.52/1.0/1.0/1.0" Sequence:0];
            group.group_ID = 1;

            [sharedInstance addNewGroup: group];
        
        }
    
    }
    
    
    return sharedInstance;
}

#pragma mark userdefault

- (NSUserDefaults*)loadUserDefault {
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    NSURL *defaultPrefsFile = [[NSBundle mainBundle]
                               URLForResource:@"UserDefault" withExtension:@"plist"];
    NSDictionary *defaultPrefs =
    [NSDictionary dictionaryWithContentsOfURL:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
    return user;
}

- (void)setUserKey:(NSString *)key Value:(id)value {
    [self.userDefault setObject:value forKey:key];
    [self.userDefault synchronize];
}

- (void)setUserKey:(NSString *)key IntValue:(NSInteger)value {
    [self.userDefault setInteger:value forKey:key];
    [self.userDefault synchronize];
}

- (void)setUserBlock:(NSInteger)block_num {
    self.block_num_setting = block_num;
    [self setUserKey:@"treasure_blocknum" IntValue:block_num];
}

- (void)setUserPhone:(NSString *)phone {
    self.block_userphone = phone;
    [self setUserKey:@"treasure_userphone" Value:phone];
}

- (id)getUserKey:(NSString *)key{
    return [self.userDefault objectForKey:key];
}

- (NSInteger)getUserKeyForInt:(NSString *)key {
    return [self.userDefault integerForKey:key];
}

- (NSInteger)getUserBlock {
    return self.block_num_setting;
}

#pragma mark get method

- (NSArray*)getIcons {
    return self.iconList;
}

- (NSArray*)getGroups {
    return self.groupList;
}

- (NSArray*)getCards {
    return self.cardList;
}

#pragma mark retrieval methods
/**
 * getIconFromDBByNameorID - search and retrieve icon from AppStateManager or db
 * @name: the name of icon you want to search for
 * @ID: the id of icon you want to search for
 *
 * RETURN: icon or nil if not find it in db
 *
 * Search icon by using either name or ID as key.
 * If it's not in iconDic, and then search DB for it.
 */
- (Icon*)getIconFromBackendByName:(NSString *)name orID:(NSInteger)ID{
    
    Icon* icon;
    if(ID > 0) {
        icon = [self.iconDic_id objectForKey: INT_KEY(ID)];
    } else if(name) {
        icon = [self.iconDic_name objectForKey:name];
    } else {
        return nil;
    }
    
    if(icon) {
        return icon;
    }
    
    icon = [self.db getIconByName: name ByIconID: ID];
    
    if(icon) {
        iconlist_add(icon);
    }
    return icon;
}

- (Icon*)getIconByID:(NSInteger)ID {
    return [self getIconFromBackendByName:nil orID:ID];
}

- (Icon*)getIconByName:(NSString *)name {
    return [self getIconFromBackendByName: name orID:-1];
}

- (Group*)getGroupFromBackendByName:(NSString *)name orID:(NSInteger) ID {
    Group* group;
    if(ID > 0) {
        group = [self.groupDic_id objectForKey: INT_KEY(ID)];
    } else if(name) {
        group = [self.groupDic_name objectForKey:name];
    } else {
        return nil;
    }
    
    if(group) {
        return group;
    }
    
    group = [self.db getGroupByName: name ByGroupID: ID];
    
    if(group) {
        grouplist_add(group);
    }
    return group;
}

- (Group*)getGroupByID:(NSInteger)ID {
    return [self getGroupFromBackendByName:nil orID: ID];
}

- (Group*)getGroupByName:(NSString *)name{
    return [self getGroupFromBackendByName:name orID:-1];
}

#pragma mark deletion methods

- (BOOL)deleteIconWithName:(NSString *)name {
    
    Icon* icon = [self getIconByName: name];
    
    // step1. delete it from property
    [self.iconDic_name removeObjectForKey: name];
    [self.iconDic_id removeObjectForKey: INT_KEY(icon.icon_ID)];
    [self.iconList removeObject: icon];
    
    // step2. check if it belongs to any group
    // if it does, remove it from the group.
    if(icon.group) {
        group_remove_icon(icon.group, icon);
        group_update_db(icon.group);
    }
    
    // step3. remove it from db
    [self.db removeIconByName:name];
    icon = nil;
    
    return true;
}

- (BOOL)deleteGroupWithName:(NSString*)name {
    
    Group* group = [self getGroupByName: name];
    
    // step1. delete it from property
    [self.groupDic_name removeObjectForKey: name];
    [self.groupDic_id removeObjectForKey: INT_KEY(group.group_ID)];
    [self.groupList removeObject: group];
    
    // step2. end all the relations between group and its icons
    for(Icon* icon in group.icons) {
        icon_remove_group(icon);
        icon_update_db(icon);
    }
    
    // step3. remove group from db
    // no need to do anything else, just delete it directly.
    // the only thing we need to update is icon.
    [self.db removeGroupByName:name];
    group = nil;
    
    return true;
}


#pragma mark create methods

- (BOOL)addNewIcon:(Icon *)icon toGroup:(Group *)group {
    
    if(!icon_update_db(icon)) {
        NSLog(@"addNewIcon: failed!");
        return NO;
    }
    
    icon.icon_ID = ((Icon*)[self.db getIconByName:icon.name ByIconID: -1]).icon_ID;
    iconlist_add(icon);
    
    if(group) {
        icon_add_to_group_and_array(icon, group, YES);
    }
    
    return YES;
}

- (BOOL)addNewGroup:(Group *)group {
    
    if(!group_update_db(group)) {
        NSLog(@"addNewGroup: failed!");
        return NO;
    }
    
    group.group_ID = ((Group*)[self.db getGroupByName: group.name ByGroupID: -1]).group_ID;
    grouplist_add(group);
    return YES;
}

- (BOOL)addNewCard:(Card *)card {

    if(!card_update_db(card)) {
        NSLog(@"addNewCard: failed!");
        return NO;
    }
    
    cardlist_add(card);
    return YES;
}
#pragma mark update methods

- (BOOL)updateIcon:(Icon *)icon {
    
    if(icon && icon.icon_ID > 0) {
        icon_update_db(icon);
        return YES;
    }
    return NO;
}

- (BOOL)updateGroup:(Group *)group {
    
    if(group && group.group_ID > 0) {
        group_update_db(group);
        return YES;
    }
    return NO;
}

- (BOOL)updateCard:(Card *)card {
    
    if(card) {
        card_update_db(card);
        return YES;
    }
    return NO;
}

#pragma mark iconModify methods

- (BOOL)addPhoneToIcon:(Icon *)icon Phone:(NSString *)phone {
    
    if(!phone)
        return NO;
    
    if(!icon.phone_num)
        icon.phone_num = [[NSMutableArray alloc] init];
    
    [icon.phone_num addObject: phone];
    icon.total_number++;
    if(icon_update_db(icon))
        return YES;
    
    return NO;
}

#pragma mark relationModify methods


- (BOOL)iconJoinGroup:(Group *)group Icon:(Icon *)icon {

    if(!icon || !group) return NO;
    
    icon_add_to_group_and_array(icon, group, YES);
    // group_update_db(group);
    
    return YES;
}

- (BOOL)iconLeaveGroup:(Group *)group Icon:(Icon *)icon {
    
    if(!icon || !group) return NO;
    
    icon_remove_group(icon);
    group_remove_icon(group, icon);
    icon_update_db(icon);
    // group_update_db(group);
    
    return YES;
}

#pragma mark privateObjectModify inlie
static inline void iconlist_add(Icon* icon) {
    
    if (![sharedInstance.iconDic_id objectForKey: INT_KEY(icon.icon_ID)]){
        
        if(!sharedInstance.iconList)
            sharedInstance.iconList = [[NSMutableArray alloc] init];
        
        [sharedInstance.iconList addObject: icon];
        [sharedInstance.iconDic_id setObject: icon forKey: INT_KEY(icon.icon_ID)];
        [sharedInstance.iconDic_name setObject: icon forKey: icon.name];
                NSLog(@"NOT IN LIST, %lu", [sharedInstance.iconList count]);
    }
}

static inline void grouplist_add(Group* group) {
    
    if(![sharedInstance.groupDic_id objectForKey: INT_KEY(group.group_ID)]){

        if(!sharedInstance.groupList)
            sharedInstance.groupList = [[NSMutableArray alloc] init];
        
        [sharedInstance.groupList addObject: group];
        [sharedInstance.groupDic_id setObject: group forKey: INT_KEY(group.group_ID)];
        [sharedInstance.groupDic_name setObject: group forKey: group.name];
    }
}

static inline void cardlist_add(Card* card) {
    NSLog(@"card ID : %@", card.cardID);
    if(![sharedInstance.cardDic_id objectForKey: card.cardID]) {
        
        if(!sharedInstance.cardList)
            sharedInstance.cardList = [[NSMutableArray alloc] init];
        
        [sharedInstance.cardList addObject: card];
        [sharedInstance.cardDic_id setObject: card forKey: card.cardID];
    }
}

static inline void icon_remove_group(Icon* icon) {
    icon.group = nil;
    icon.group_ID = 0;
}

static inline void icon_add_to_group_and_array(Icon* icon, Group* group, BOOL toArray) {
    
    if(!icon) {
        NSLog(@"nil");
        return;
    }
    
    icon.group = group;
    icon.group_ID = group.group_ID;
    [group.icons addObject: icon];
    if(toArray) {
        if(!group.icons_id_array)
            group.icons_id_array = [[NSMutableArray alloc] init];
        
        [group.icons_id_array addObject: [NSString stringWithFormat: @"%d", (int)icon.icon_ID]];
        group_update_db(group);
    }
}

static inline void group_remove_icon(Group* group, Icon* icon) {
    
    if(icon) {
        NSLog(@"Try remove Icon %d", (int)icon.icon_ID);
    }
    
    
    [group.icons removeObject: icon];
    [group.icons_id_array removeObject:[NSString stringWithFormat:@"%d", (int)icon.icon_ID]];
    NSLog(@"%@", [group.icons_id_array description]);
    group_update_db(group);
}



#pragma mark privateDatabaseUpdate inline
static inline BOOL icon_update_db(Icon* icon) {
    return [sharedInstance.db insertIcon: icon];
}

static inline BOOL group_update_db(Group* group) {
    return [sharedInstance.db insertGroup: group];
}

static inline BOOL card_update_db(Card* card) {
    return [sharedInstance.db insertCard: card];
}

#pragma mark internalLoad method

- (void)loadIcon {
    
    self.iconList = [self.db getIcons];
    
    // load into iconDic for fast access.
    for (Icon* icon in self.iconList){
        [self.iconDic_id setObject: icon forKey: INT_KEY(icon.icon_ID)];
        [self.iconDic_name setObject: icon forKey: icon.name];
    }
}

- (void)loadGroup {

    self.groupList = [self.db getGroups];
    
    for (Group* group in self.groupList) {
        group.icons = [[NSMutableArray alloc] init];
        
        for(NSString* key in group.icons_id_array) {
            NSLog(@"load from key : %@", key);
            Icon* icon = [self.iconDic_id objectForKey: INT_KEY([key integerValue])];
            if(self.iconDic_id)
                icon_add_to_group_and_array(icon, group, NO);
        }
        NSLog(@"total %lu, %lu", [group.icons_id_array count], [group.icons count]);
        [self.groupDic_id setObject: group forKey: INT_KEY(group.group_ID)];
        [self.groupDic_name setObject: group forKey: group.name];
    }
}


- (void)loadCard {
    
    self.cardList = [self.db getCards];
    for(Card* card in self.cardList) {
        [self.cardDic_id setObject: card forKey: card.cardID];
    }
    
}
@end
