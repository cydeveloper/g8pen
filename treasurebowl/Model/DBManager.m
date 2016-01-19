//
//  DBManager.m
//  treasurebowl
//
//  Created by AtSu on 2015/5/14.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//
//  doQuery & doRowQuery is inspired by misato
#import <Foundation/Foundation.h>
#import "DBManager.h"
#import <sqlite3.h>

@implementation DBManager

static DBManager *sharedInstance = nil;
static sqlite3* db = nil;
static NSString* dbName = @"db_iconinfo";
static NSString* iconTable = @"ICONTABLE";
static NSString* groupTable = @"GROUPTABLE";
static NSString* cashTable = @"CASHTABLE";
static sqlite3_stmt* db_stmt = nil;
static NSString* text_spliter = @"&_\"Q&";


/**
 * getSharedInstance - get the singleton referenced
 *
 * RETURN: return the only reference of database to caller
 *
 * Initialize at first call.
 */

+ (DBManager*)getSharedInstance {
    if(!sharedInstance) {
        //db not initialize yet, create one
        sharedInstance = [[super allocWithZone:NULL] init];
        [sharedInstance createDB];
        
    }
    
    return sharedInstance;
}

+ (NSString*)getDBPath {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); /*Get internal path*/
    NSString* docDirectory = [paths objectAtIndex:0];
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString* db_fileName = [NSString stringWithFormat:@"%@.sqlite", dbName];
    return [docDirectory stringByAppendingPathComponent:db_fileName];
}

/**
 * createDB - create data table
 *
 * RETURN: return YES if successfully create or open it, else NO
 */

- (BOOL)createDB {
    BOOL result = YES;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    dbPath = [DBManager getDBPath];
    DE_LOG("%@", dbPath);
    /* Check if db already exist at target path */
    if(![fileMgr fileExistsAtPath:dbPath]) {

        const char *dbPath_char = [dbPath UTF8String];
        
        if(sqlite3_open(dbPath_char, &db) == SQLITE_OK) {

            char *errMsg;
            const char *sql_stmt = STMT_DATABASE_TABLE;

            if(sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                
                DE_LOG("Create failed, %s", errMsg);
                sqlite3_free(errMsg);
                errMsg = NULL;
                result = NO;
            }
            sqlite3_close(db);
        }
    }
    return result;
}

#pragma mark DatabaseGroup Methods

/**
 * insertGroup - insert a new data or update the existing one in group table
 * @group: the group that the caller gonna save it into database
 *
 * RETURN: return YES if successfully insert or update it.
 *
 * it calls the doQuery method to perform the raw sqlite3 query.
 */

- (BOOL)insertGroup:(Group *)group {
    
    BOOL result = NO;
    /*check if the data already exist in database*/
    Group* check_db = group.group_ID > 0 ? [sharedInstance getGroupByName: nil ByGroupID: group.group_ID]
                      : [sharedInstance getGroupByName: group.name ByGroupID: -1];
    NSMutableArray* params = [[NSMutableArray alloc] initWithObjects: group.name,
                              [DBManager splitArrayToText: group.icons_id_array], group.color, INT_PARAM(group.sequence), nil];
    
    if(check_db) {
        /* it's in database, update it with replace statement */
        DE_LOG("update");
        [params insertObject: INT_PARAM(check_db.group_ID) atIndex: 0];
        result = [sharedInstance doQuery: STMT_REPLACE_GROUP withParam: params];
    } else {
        DE_LOG("insert");
        result = [sharedInstance doQuery: STMT_INSERT_GROUP withParam: params];
    }
    
    return result;
}

/**
 * removeGroupByName - remove a specific group data from database table
 * @name: the name of the group that will be removed from table
 *
 * RETURN: YES if successfully remove it from table
 */

- (BOOL)removeGroupByName:(NSString *)name {
    NSArray* param  = [[NSArray alloc] initWithObjects: name, nil];
    return [sharedInstance doQuery: STMT_DELETE_GROUP withParam: param];
}

/**
 * getGroupByNameByGroupID - retrieve a specific group data
 * @name: the name of the group that you try to retrive from database
 * @ID  : the id of the group that you try to retrive from database
 *
 * RETURN: group data if it exist in database, nil if it doesn't exist
 *
 * you only need to pass one param to this method.
 * passing two params won't help, it will only pick name as key for searching.
 */

- (id)getGroupByName:(NSString *)name ByGroupID:(NSInteger)ID {
    
    Group* group = nil;
    NSArray* ret;
    NSDictionary* row;
    
    if(name) {
        ret = [sharedInstance doRowQuery: STMT_GET_GROUP_BY_NAME withName: name];
    } else {
        ret = [sharedInstance doRowQuery: STMT_GET_GROUP_BY_ID(ID) withName: nil];
    }
    
    /* The nil cases below imply that the target data doesn't exist in database */
    if([ret count] > 0) {
        row = [ret objectAtIndex: 0];
        if(!row)
            return nil;
    } else
        return nil;
    
    group = GROUP_INIT_BY_ROW(row);
    
    return group;
}


/**
 * getGroups - retrieve all the group data from database
 *
 * RETURN: nil if there is nothing in database, else return an array of Group
 *
 * the data array will be sorted by sequence(property of group).
 */

- (NSArray*)getGroups {
    
    NSMutableArray* groups = nil;
    NSArray* rows = [sharedInstance doRowQuery: STMT_GET_GROUPS withName: nil];
    
    /* No group exists in database */
    if([rows count] <= 0)
        return nil;
    
    groups = [[NSMutableArray alloc] init];
    
    for(NSDictionary* row in rows) {
        /* parse data from columns to group */
        Group* group = GROUP_INIT_BY_ROW(row);
        [groups addObject: group];
    }
    
    return groups;
}



#pragma mark DatabaseIcon Methods

/**
 * insertIcon - insert an icon data or update the existing one in database
 * @icon: the icon that will be insertd or updated
 *
 * RETURN: YES if successfully finish the query, NO otherwise.
 *
 * the data array will be sorted by sequence(property of icon)
 */

- (BOOL)insertIcon:(Icon *)icon {

    BOOL result = NO;
    /* check if the icon already exist in database */
    Icon* check_db = icon.icon_ID > 0 ? [sharedInstance getIconByName: nil ByIconID: (int)icon.icon_ID]
                     : [sharedInstance getIconByName: icon.name ByIconID: -1];
    NSMutableArray* params = [[NSMutableArray alloc] initWithObjects: icon.card_ID, icon.icon_url, icon.shortcut_url,
                              INT_PARAM(icon.total_number), [DBManager splitArrayToText: icon.phone_num], icon.name,
                              INT_PARAM(icon.sequence), INT_PARAM(icon.group_ID), nil];
    
    if(check_db) {
        /* it's in database, update it with replace statement */
        DE_LOG("update");
        [params insertObject: INT_PARAM(check_db.icon_ID) atIndex: 0];
        result = [sharedInstance doQuery: STMT_REPLACE_ICON withParam: params];
    } else {
        DE_LOG("insert");
        result = [sharedInstance doQuery: STMT_INSERT_ICON withParam: params];
    }
    
    return result;
}

/**
 * removeIconByName - remove a specific icon from database
 * @name: the name of the icon that will be removed from database
 *
 * RETURN: YES if successfully remove it, NO otherwise.
 */

- (BOOL)removeIconByName:(NSString *)name {
    NSArray* param = [[NSArray alloc] initWithObjects: name, nil];
    return [sharedInstance doQuery: STMT_DELETE_ICON withParam: param];
}

/**
 * getIconByNameByIconID - retrieve a specific icon from database
 * @name: the name of the icon that you try to retrive from database
 * @ID  : the id of the icon that you try to retrive from database
 *
 * RETURN: icon data if it exist in database, nil otherwise.
 *
 * you only need to pass one param to it.
 * if you pass two param, it will pick the name as the key for searching.
 */

- (id)getIconByName:(NSString *)name ByIconID:(NSInteger)ID {
    
    Icon* icon = nil;
    NSArray* ret;
    NSDictionary* row;
    
    if(name) {
        ret = [sharedInstance doRowQuery: STMT_GET_ICON_BY_NAME withName: name];
    } else {
        ret = [sharedInstance doRowQuery: STMT_GET_ICON_BY_ID(ID) withName: nil];
    }
    
    if([ret count] > 0) {
        row = [ret objectAtIndex: 0];
        if(!row)
            return nil;
    } else
        return nil;
    
    icon = ICON_INIT_BY_ROW(row);
    return icon;
}

/**
 * getIcons - retrieve all icon data from databse
 *
 * RETURN: an Array of icons or nil if there is nothing in database.
 */

- (NSArray*)getIcons {
    NSMutableArray* icons = nil;
    NSArray* rows = [sharedInstance doRowQuery: STMT_GET_ICONS withName: nil];
    
    if([rows count] <= 0)
        return nil;
    
    icons = [[NSMutableArray alloc] init];
    
    for(NSDictionary* row in rows) {
        Icon* icon = ICON_INIT_BY_ROW(row);
        [icons addObject: icon];
    }
    
    
    return icons;
}


#pragma mark DatabaseCard Methods

/**
 * insertCard - insert a card data or update the existing one in database
 * @card: the card data that will be inserted or updated later
 *
 * RETURN: YES if successfully finish the query, NO if it fails.
 */

- (BOOL)insertCard:(Card *)card {
    
    BOOL result = NO;
    NSMutableArray* params = [[NSMutableArray alloc] initWithObjects: card.cardID, card.status, FLOAT_PARAM(card.currentPoints), nil];
    Card* check_db = [sharedInstance getCardByCardID: card.cardID];
    
    if(check_db) {
        DE_LOG("update");
        // card.db_ID = check_db.db_ID;
        // [params insertObject: INT_PARAM(card.db_ID) atIndex: 0];
        result = [sharedInstance doQuery: STMT_REPLACE_CARD withParam: params];
    } else {
        DE_LOG("insert");
        result = [sharedInstance doQuery: STMT_INSERT_CARD withParam: params];
    }
    
    return result;
}

/**
 * removeCard - remove a specific card from database
 * @cardID: the card id of the card that you want to remove from database
 *
 * RETURN: YES if remove it successfully, else NO.
 */

- (BOOL)removeCard:(NSString *)cardID {
    NSArray* param = [[NSArray alloc] initWithObjects: cardID, nil];
    return [sharedInstance doQuery: STMT_DELETE_CARD withParam: param];
}

/**
 * getCardByCardID - retrieve a specific card from database
 * @cardID: the card id of the card that you try to retrieve from database
 *
 * RETURN: card data if it exist in database, nil if it doesn't exist.
 */

- (id)getCardByCardID:(NSString *)cardID {
    
    Card* card = nil;
    NSArray* ret = [sharedInstance doRowQuery: STMT_GET_CARD withName: cardID];
    NSDictionary* row;
    
    if([ret count] > 0) {
        row = [ret objectAtIndex: 0];
        if(!row)
            return nil;
    } else
        return nil;

    card = CARD_INIT_BY_ROW(row);
   
    return card;
}

/**
 * getCards - retrieve all card from database
 *
 * RETURN: an array contains cards
 */

- (NSArray*)getCards {
    
    NSMutableArray* cards = nil;
    NSArray* rows = [sharedInstance doRowQuery: STMT_GET_CARDS withName: nil];
    
    if([rows count] <= 0)
        return nil;
    
    cards = [[NSMutableArray alloc] init];
    for(NSDictionary* row in rows) {
        Card* card = CARD_INIT_BY_ROW(row);
        [cards addObject: card];
    }
    
    return cards;
}

#pragma mark generalQuery methods

/**
 * doQuery - perform a database query with specific database statement.
 * @query: query that specify db operation.
 * @params: parameter in the @query
 *
 * RETURN: success or failed
 *
 * To avoid things like SQL injection, we have to separate the statement and parameter,
 * and use bind to bind parameter with it. The binding process will ensure the things
 * save into db is valid.
 */

- (BOOL)doQuery:(const char*)query withParam:(NSArray*) params {
    
    BOOL result = YES;
    const char* dbPath_char = [dbPath UTF8String];
    
    if(sqlite3_open(dbPath_char, &db) == SQLITE_OK) {
        // open db and prepare it.
        sqlite3_prepare_v2(db, query, -1, &db_stmt, NULL);
        
        param_binder(params); // bind parameter.
        
        
        // sqlite3_step will execute statement
        if(sqlite3_step(db_stmt) == SQLITE_ERROR) {
            C_FAIL("doQuery");
            result = NO;
        }
        
        sqlite3_finalize(db_stmt); // finish statement
        sqlite3_close(db);
    } else {
        C_FAIL("open DB");
        result = NO;
    }
    
    return result;
}


/**
 * doRowQuery - retrieve a data row from database
 * @query: query that specify db operation.
 * @name: name of row you want to retrieve
 *
 * RETURN: NSArray contain row data, or rows data
 *
 * also use bind to avoid injection. It will check db_stmt to
 * determine whether we need to retrieve all rows or just one row.
 */

- (NSArray*)doRowQuery:(const char*)query withName:(NSString*)name {
    
    NSMutableArray* list = nil;
    NSMutableDictionary* row = nil;
    
    const char* dbPath_char = [dbPath UTF8String];
    
    if(sqlite3_open(dbPath_char, &db) == SQLITE_OK) {
        
        if(sqlite3_prepare_v2(db, query, -1, &db_stmt, NULL) != SQLITE_OK) {
            sqlite3_close(db);
            return nil;
        }
        
        if(name)
            sqlite3_bind_text(db_stmt, 1, [name UTF8String], -1, NULL);
        
        list = [[NSMutableArray alloc] init];
        
        while(sqlite3_step(db_stmt) == SQLITE_ROW) {
            // will keep stepping if the db_stmt want to retrieve many row.
            
            // count how many cols are there in current row.
            int cols = sqlite3_column_count(db_stmt);
            row = [[NSMutableDictionary alloc] init];
            
            for(int i = 0; i < cols; i ++) {
                const char* col_name = sqlite3_column_name(db_stmt, i);
                NSString* NS_col_name = [NSString stringWithCString: col_name encoding: NSUTF8StringEncoding];
                int type = sqlite3_column_type(db_stmt, i);
                
                // decode each column, and put them back to dictionary "row"
                // by there column name
                switch(type) {
                    case SQLITE_INTEGER: {
                        int num = sqlite3_column_int(db_stmt, i);
                        [row setObject: [NSNumber numberWithInt: num] forKey: NS_col_name];
                        break;
                    }
                    case SQLITE_TEXT: {
                        NSString* text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(db_stmt, i)];
                        [row setObject: text forKey: NS_col_name];
                        break;
                    }
                    case SQLITE_FLOAT: {
                        float num = sqlite3_column_double(db_stmt, i);
                        [row setObject: [NSNumber numberWithFloat: num] forKey: NS_col_name];
                        break;
                    }
                    default: {
                        C_FAIL("doRowQuery");
                        break;
                    }
                }
            }
            
            [list addObject: row];
        }
        
        sqlite3_finalize(db_stmt);
        sqlite3_close(db);
    } else {
        C_FAIL("open DB");
    }
    
    return list;
}


#pragma mark util
/**
 * param_binder - bind parameter to db_stmt
 * @params: params that need to bind to db_stmt
 *
 * To avoid SQL injection
 */


static inline void param_binder(NSArray* params) {
    
    int cnt = 0;
    
    for(id param in params) {
        
        cnt ++;
        // check type of each parameter, and bind it to db_stmt
        if([param isKindOfClass: [NSString class]]) {
            // NSLog(@"param %d : NSString : %@", cnt, param);
            sqlite3_bind_text(db_stmt, cnt, [(NSString*)param UTF8String], -1, NULL);
        } else if([param isKindOfClass: [NSNumber class]]) {
            
            if(!strcmp([(NSNumber*)param objCType], @encode(float)))
            {
                // NSLog(@"param %d : float : %f", cnt, [param doubleValue]);
                sqlite3_bind_double(db_stmt, cnt, [param doubleValue]);
                
            } else if(!strcmp([(NSNumber*)param objCType], @encode(int64_t))
                      || !strcmp([(NSNumber*)param objCType], @encode(int)))
            {
                // NSLog(@"param %d : int : %d", cnt, [param intValue]);
                sqlite3_bind_int(db_stmt, cnt, [param intValue]);
            }
        }
        
    }
}

/**
 * the following two function is used to turn array into a string,
 * or turn string back to an array. Sometimes we want to save a unknown
 * length or similar property, so we will put this kind of attribute in same NSArray,
 * and encode it as a stirng and store in db.
 */

+ (NSString*)splitArrayToText:(NSMutableArray *)phone_num {
    // Utility for spliting phone_num array to text form that  are suit for DB.
    if(!phone_num) {
        return @"empty";
    }
    return [phone_num componentsJoinedByString: text_spliter];
}

+ (NSMutableArray*)turnTextToArray:(NSString*) phone_text {
    // Convert the text in DB back to phone_num array.
    if([phone_text isEqualToString:@"empty"]) {
        return nil;
    }
    return [NSMutableArray arrayWithArray:[phone_text componentsSeparatedByString: text_spliter]];
}


@end