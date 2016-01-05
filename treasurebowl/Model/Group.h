//
//  Group.h
//  treasurebowl
//
//  Created by AtSu on 2015/5/31.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject

@property(nonatomic)NSInteger group_ID;
@property(nonatomic)NSString* name;
@property(nonatomic)NSMutableArray* icons; // an array of Icons
@property(nonatomic)NSMutableArray* icons_id_array; // for fast access
@property(nonatomic)NSString* color;
@property(nonatomic)NSInteger sequence;

- (id)initWithGroupID:(NSInteger)group_id Name:(NSString*)name Icons_array:(NSMutableArray*)icons_array Icons_id_array:(NSMutableArray*)icons_id_array Color:(NSString*)color Sequence:(NSInteger) sequence;

- (id)initWithGroupID:(NSInteger)group_id Name:(NSString*)name Icons_id_array:(NSMutableArray*)icons_id_array Color:(NSString*)color Sequence:(NSInteger) sequence;

- (id)initWithName:(NSString*)name Icons_id_array:(NSMutableArray*)icons_id_array Color:(NSString*)color Sequence:(NSInteger) sequence;


@end
