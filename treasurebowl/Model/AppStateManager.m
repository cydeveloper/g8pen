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


/*   Class : AppStateManager
 *   A sharedInstance, it's purpose is to maintain
 *   data that will be use in different view controller.
 *   It also provide interface between DB and view controller
 *   And also, we can update a property of icon or group by calling method here,
 *   To update it in both db and app in one shot.
 */
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


/**
 * loadUserDefault - load user setting.
 *
 * RETURN user as the default setting
 *
 * Load user setting. The setting is listed in Supporting Files/UserDefault.plist
 */

- (NSUserDefaults*)loadUserDefault {
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    NSURL *defaultPrefsFile = [[NSBundle mainBundle]
                               URLForResource:@"UserDefault" withExtension:@"plist"];
    NSDictionary *defaultPrefs =
    [NSDictionary dictionaryWithContentsOfURL:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
    return user;
}

/**
 * setUserKey - change (key, value) pair in property list.
 * @key: key of the property you want to set
 * @value: yes, the value you want to set
 *
 * this is a general method that you can easy write defaule value into property list.
 */

- (void)setUserKey:(NSString *)key Value:(id)value {
    [self.userDefault setObject:value forKey:key];
    [self.userDefault synchronize];
}

/**
 * setUserKey - change (key, value) pair in property list.
 * @key: key of the property you want to set
 * @value: integer value you want to set
 *
 * Same method as the one above. The only difference is that the value is specify as int.
 */

- (void)setUserKey:(NSString *)key IntValue:(NSInteger)value {
    [self.userDefault setInteger:value forKey:key];
    [self.userDefault synchronize];
}

/**
 * setUserBlock - set how many icon will be displayed in a row.
 * @block_num: number of icon per row
 */

- (void)setUserBlock:(NSInteger)block_num {
    self.block_num_setting = block_num;
    [self setUserKey:@"treasure_blocknum" IntValue:block_num];
}

/**
 * setUserPhone - set the phone number of app user.
 * @phone: phone number
 */

- (void)setUserPhone:(NSString *)phone {
    self.block_userphone = phone;
    [self setUserKey:@"treasure_userphone" Value:phone];
}

/**
 * getUserKey - get value from the given key in property list.
 * @key: key of the property you want to retrieve.
 *
 * RETURN: id of the setting
 */

- (id)getUserKey:(NSString *)key{
    return [self.userDefault objectForKey:key];
}

/**
 * getUserKeyForInt - get int value from the given key in property list.
 * @key: key of the property you want to retrieve.
 *
 * RETURN: int value of the setting
 */
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
 * getIconFromBackendByNameorID - search and retrieve icon from AppStateManager or db
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
    
    // If ID > 0, then it means that he try to use ID as search key
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
    
    // DB support both search in DB and name
    icon = [self.db getIconByName: name ByIconID: ID];
    
    if(icon) {
        iconlist_add(icon);
    }
    return icon;
}

/**
 * the following 2 method will call getIconFromBackend to perform operation.
 */
- (Icon*)getIconByID:(NSInteger)ID {
    return [self getIconFromBackendByName:nil orID:ID];
}

- (Icon*)getIconByName:(NSString *)name {
    return [self getIconFromBackendByName: name orID:-1];
}

/**
 * getGroupFromBackendByNameorID - search and retrieve icon from AppStateManager or db
 * @name: the name of group you want to search for
 * @ID: the id of group you want to search for
 *
 * RETURN: group or nil if not find it in db
 *
 * Search group by using either name or ID as key.
 * If it's not in groupDic, and then search DB for it, and put it into app sate manager.
 */

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
/**
 * the following 2 method will call getGroupFromBackend to perform operation.
 */
- (Group*)getGroupByID:(NSInteger)ID {
    return [self getGroupFromBackendByName:nil orID: ID];
}

- (Group*)getGroupByName:(NSString *)name{
    return [self getGroupFromBackendByName:name orID:-1];
}

#pragma mark deletion methods

/**
 * deleteIconWithName - delete icon from db by name
 * @name: the name of icon you want to delete
 *
 *
 * It has 3 things to do.
 * First is to remove it from AppStateManger,
 * Second is to remove it from the group it belongs
 * And the last steps, we delete it from DB.
 *
 */

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

/**
 * deleteGroupWithName - delete group from db by name
 * @name: the name of group you want to delete
 *
 *
 * It has 3 things to do.
 * First is to remove it from AppStateManger,
 * Second is to kick out all the icon in it.
 * And the last steps, we delete it from DB.
 *
 */

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

/**
 * The following add methods are all in same routine :
 * 1. Try to update DB
 * 2. retrieve it's DB id
 * 3. the add it to the AppStateManager list/dictionary
 By doing this, we can always keep new icons in homescreen,
 * without restart the app.
 */

- (BOOL)addNewIcon:(Icon *)icon toGroup:(Group *)group {
    
    // try to update db
    if(!icon_update_db(icon)) {
        NSLog(@"addNewIcon: failed!");
        return NO;
    }
    
    // retrieve its db id
    icon.icon_ID = ((Icon*)[self.db getIconByName:icon.name ByIconID: -1]).icon_ID;
    iconlist_add(icon); // add it into app state manager
    
    if(group) {
        // if it belongs to a group, then put it in.
        icon_add_to_group_and_array(icon, group, YES);
    }
    
    return YES;
}

- (BOOL)addNewGroup:(Group *)group {
    
    // try to update db.
    if(!group_update_db(group)) {
        NSLog(@"addNewGroup: failed!");
        return NO;
    }
    
    // retrieve db id.
    group.group_ID = ((Group*)[self.db getGroupByName: group.name ByGroupID: -1]).group_ID;
    grouplist_add(group); // add to app state manager
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
    
    // update already exist icon, which id should be larget than 0
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
/**
 * addPhoneToIcon - add a phone number to target icon
 * @icon: target icon
 * @phone: phone number you want to add
 *
 * RETURN: success or not
 *
 * This method will update both icon and icon in db at the same time
 */

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

/**
 * The following method is use to modify both in memory
 * and in db data.
 */

- (BOOL)iconJoinGroup:(Group *)group Icon:(Icon *)icon {

    if(!icon || !group) return NO;
    
    // add Icon to a group, and this inline will also perform update in db
    icon_add_to_group_and_array(icon, group, YES);
    return YES;
}

- (BOOL)iconLeaveGroup:(Group *)group Icon:(Icon *)icon {
    
    if(!icon || !group) return NO;
    
    // remove it from group, and update itself
    icon_remove_group(icon);
    group_remove_icon(group, icon);
    icon_update_db(icon);
    
    return YES;
}

#pragma mark privateObjectModify inlie

/**
 * the following inline is used to help us perform the add/remove operation to list/dictionary
 * maintain in app state manager
 */
static inline void iconlist_add(Icon* icon) {
    
    // add icon into iconList and iconDic maintained in AppstateManager
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
    
    // add group into groupList and groupDic maintained in AppstateManager
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
        // add it into group attribute
        if(!group.icons_id_array)
            group.icons_id_array = [[NSMutableArray alloc] init];
        
        [group.icons_id_array addObject: [NSString stringWithFormat: @"%d", (int)icon.icon_ID]];
        
        // update db
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
    
    // retrieve all icon from db, and put it in iconDic
    self.iconList = [self.db getIcons];
    
    // load into iconDic for fast access.
    for (Icon* icon in self.iconList){
        [self.iconDic_id setObject: icon forKey: INT_KEY(icon.icon_ID)];
        [self.iconDic_name setObject: icon forKey: icon.name];
    }
}

- (void)loadGroup {

    // retrieve all group from db, and put it in groupDic
    self.groupList = [self.db getGroups];
    
    for (Group* group in self.groupList) {
        group.icons = [[NSMutableArray alloc] init];
        
        for(NSString* key in group.icons_id_array) {
            DE_LOG("load from key : %@", key);
            
            // put icon into group
            Icon* icon = [self.iconDic_id objectForKey: INT_KEY([key integerValue])];
            if(self.iconDic_id)
                icon_add_to_group_and_array(icon, group, NO);
        }
        DE_LOG("total %lu, %lu", [group.icons_id_array count], [group.icons count]);
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
