//
//  NSDate+TP8601.m
//  Connect
//
//  Created by Chad Edrupt on 28/04/2015.
//

#import "NSDate+TP8601.h"
#import "NSDateFormatter+TP8601.h"

@implementation NSDate (TP8601)

- (NSString*)tp_iso8601String {
    NSDateFormatter *formatter = [NSDateFormatter tp_iso8601DateFormatter];
    return [formatter stringFromDate:self];
}

@end
