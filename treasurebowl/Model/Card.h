//
//  card.h
//  treasurebowl
//
//  Created by AtSu on 2015/5/20.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject


@property(nonatomic)NSInteger db_ID;
@property(nonatomic)NSString* cardID;
@property(nonatomic)NSString* status;
@property(nonatomic)double currentPoints;


- (id)initWithDBID:(NSInteger)db_ID CardID:(NSString*) cardID Status:(NSString*) status CurrentPoints:(double) currentPoints ;
- (id)init:(NSString*) cardID Status:(NSString*) status CurrentPoints:(double) currentPoints ;


@end
