//
//  CallPackage.m
//  treasurebowl
//
//  Created by AtSu on 2015/5/23.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "CallPackage.h"

@implementation CallPackage

/*   Class : CallPackage
 *   use for passing essential data between
 *   different View Controller
 */

- (id)initWithCard:(Card *)card PhoneArray:(NSArray *)phoneArray DoCall:(BOOL)doCall{
    self = [super init];
    if(self) {
        self.card = card;
        self.phoneArray = phoneArray;
        self.doCall = doCall;
    }
    return self;
}

- (id)initWithCard:(Card *)card {
    return  [self initWithCard:card PhoneArray:nil DoCall:NO];
}

@end
