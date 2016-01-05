//
//  CallPackage.h
//  treasurebowl
//
//  Created by AtSu on 2015/5/23.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
@interface CallPackage : NSObject

@property(nonatomic)Card* card;
@property(nonatomic)NSArray* phoneArray;
@property(nonatomic)BOOL doCall;

- (id)initWithCard:(Card*) card PhoneArray:(NSArray*) phoneArray DoCall:(BOOL) doCall;
- (id)initWithCard:(Card*) card;
@end
