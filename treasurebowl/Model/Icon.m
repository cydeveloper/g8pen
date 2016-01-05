//
//  Icon.m
//  treasurebowl
//
//  Created by AtSu on 2015/5/18.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Icon.h"
#import "Group.h"

@implementation Icon

#pragma mark init with group
- (id)initWithCardID:(NSString *)card_ID IconID:(NSInteger)icon_ID IconURL:(NSString *)icon_url shortcutUrl:(NSString *)shortcut_url TotNum:(NSInteger)total_number PhoneNum:(NSMutableArray *)phone_num Name:(NSString *)name Sequence:(NSInteger)sequence GroupID:(NSInteger)group_ID Group:(Group *)group {
    
    self = [super init];
    
    if(self) {
        self.card_ID = card_ID;
        self.icon_ID = icon_ID;
        self.icon_url = icon_url;
        self.total_number = total_number;
        self.phone_num = phone_num;
        self.name = name;
        self.sequence = sequence;
        self.group = group;
        self.group_ID = group_ID;
        if(shortcut_url) self.shortcut_url = shortcut_url;
        else self.shortcut_url = [NSString stringWithFormat:@"NNN"];
    }
    
    return self;
}

#pragma mark init with groupID only
- (id)initWithCardID:(NSString *)card_ID IconID:(NSInteger)icon_ID IconURL:(NSString *)icon_url shortcutUrl:(NSString *)shortcut_url TotNum:(NSInteger)total_number PhoneNum:(NSMutableArray *)phone_num Name:(NSString *)name Sequence:(NSInteger)sequence GroupID:(NSInteger)group_ID {
    
    self = [super init];
    
    if(self) {
        self.card_ID = card_ID;
        self.icon_ID = icon_ID;
        self.icon_url = icon_url;
        self.total_number = total_number;
        self.phone_num = phone_num;
        self.name = name;
        self.sequence = sequence;
        self.group_ID = group_ID;
        if(shortcut_url) self.shortcut_url = shortcut_url;
        else self.shortcut_url = [NSString stringWithFormat:@"NNN"];
    }
    
    return self;
}

#pragma mark init with no group

- (id)initWithCardID:(NSString *)card_ID IconID:(NSInteger)icon_ID IconURL:(NSString *)icon_url shortcutUrl:(NSString *)shortcut_url TotNum:(NSInteger)total_number PhoneNum:(NSMutableArray *)phone_num Name:(NSString *)name Sequence:(NSInteger)sequence {
    
    self = [super init];
    
    if(self) {
        self.card_ID = card_ID;
        self.icon_ID = icon_ID;
        self.icon_url = icon_url;
        self.total_number = total_number;
        self.phone_num = phone_num;
        self.name = name;
        self.sequence = sequence;
        if(shortcut_url) self.shortcut_url = shortcut_url;
        else self.shortcut_url = [NSString stringWithFormat:@"NNN"];
    }
    
    return self;
}

- (UIImage*)getImage {
    //NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString* filePath = [[path objectAtIndex:0] stringByAppendingString: self.name];
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:self.icon_url];
    NSLog(@"gett %@", self.icon_url);
    return image;
}

@end