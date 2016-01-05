//
//  XMLParser.h
//  treasurebowl
//
//  Created by AtSu on 2015/5/21.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLParser : NSObject<NSXMLParserDelegate> {
    NSError* errorPointer;
    NSDictionary* result_dic;
}

+ (NSDictionary*)JSONForXMLData:(NSData*) data Error:(NSError *)errorPointer;
@end
