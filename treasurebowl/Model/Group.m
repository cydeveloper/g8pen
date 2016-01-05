//
//  Group.m
//  treasurebowl
//
//  Created by AtSu on 2015/5/31.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "Group.h"

@implementation Group

- (id)initWithGroupID:(NSInteger)group_id Name:(NSString *)name Icons_array:(NSMutableArray*) icons_array Icons_id_array:(NSMutableArray *)icons_id_array Color:(NSString *)color Sequence:(NSInteger)sequence {
    self = [self init];
    if(self) {
        self.group_ID = group_id;
        self.name = name;
        self.icons = icons_array;
        self.icons_id_array = icons_id_array;
        self.color = color;
        self.sequence = sequence;
    }
    return self;
}

- (id)initWithGroupID:(NSInteger)group_id Name:(NSString *)name Icons_id_array:(NSMutableArray *)icons_id_array Color:(NSString *)color Sequence:(NSInteger)sequence {
    self = [self init];
    if(self) {
        self.group_ID = group_id;
        self.name = name;
        self.icons_id_array = icons_id_array;
        self.color = color;
        self.sequence = sequence;
    }
    return self;
}

- (id)initWithName:(NSString *)name Icons_id_array:(NSMutableArray *)icons_id_array Color:(NSString *)color Sequence:(NSInteger)sequence {
    self = [self init];
    if(self) {
        self.group_ID = -1;
        self.name = name;
        self.icons_id_array = icons_id_array;
        self.color = color;
        self.sequence = sequence;
    }
    return self;
}
@end
