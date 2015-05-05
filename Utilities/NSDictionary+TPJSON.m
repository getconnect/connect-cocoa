//
//  NSDictionary+TPJSON.m
//  Connect
//
//  Created by Chad Edrupt on 28/04/2015.
//

#import "NSDictionary+TPJSON.h"

@implementation NSDictionary (TPJSON)

- (NSString*)tp_buildJSONString:(NSError *__autoreleasing *)error {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:error];
    
    if (!jsonData) return nil;
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
