//
//  card.m
//  treasurebowl
//
//  Created by AtSu on 2015/5/20.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "card.h"

@implementation Card

- (id)initWithDBID:(NSInteger)db_ID CardID:(NSString *)cardID Status:(NSString *)status CurrentPoints:(double)currentPoints {
    self = [super init];
    
    if(self) {
        self.db_ID = db_ID;
        self.cardID = cardID;
        self.currentPoints = currentPoints;
        self.status = status;
    }
    return self;
}


- (id)init:(NSString *) cardID Status:(NSString*)status CurrentPoints:(double)currentPoints{
    self = [super init];
    
    if(self) {
        self.db_ID = -1;
        self.cardID = cardID;
        self.currentPoints = currentPoints;
        self.status = status;
    }
    return self;
}

@end
