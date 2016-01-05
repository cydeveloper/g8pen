//
//  XMLParser.m
//  treasurebowl
//
//  Created by AtSu on 2015/5/21.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "XMLParser.h"

@interface XMLParser (Internal)

- (id)initWithError:(NSError *) error;
- (NSDictionary*)objectWithData:(NSData*) data;

@end

@implementation XMLParser


- (id)initWithError:(NSError *)error {
    self = [super init];
    if(self) {
        self->errorPointer = error;
    }
    return self;
}

- (NSDictionary*)objectWithData:(NSData *)data {
    NSDictionary* dic = nil;
    
    NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:data];
    
    // set delegate (let NSXMLParser do the job for XMLParser)
    xmlParser.delegate = self;
    
    BOOL result = [xmlParser parse];
    
    if(result) {
        dic = self->result_dic;
    }
    return dic;
}

+ (NSDictionary*)JSONForXMLData:(NSData*) data Error:(NSError*) errorPointer {
    // Currently only Webservice will use this method
    XMLParser* reader = [[XMLParser alloc] initWithError:errorPointer];
    NSDictionary* jsonDic = [reader objectWithData:data];
    return jsonDic;
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    // Parse string to JSON dictionart.
    NSLog(@"found String %@", string);
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    // assign the json dictionary to XMLParser.
    result_dic = jsonDic;
}


@end
