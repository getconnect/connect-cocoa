//
//  NSDateFormatter+TP8601.m
//  Connect
//
//  Created by Chad Edrupt on 28/04/2015.
//  Copyright (c) 2015 Tipi HQ. All rights reserved.
//

#import "NSDateFormatter+TP8601.h"

@implementation NSDateFormatter (TP8601)

+ (NSDateFormatter*) tp_iso8601DateFormatter
{
    static dispatch_once_t once;
    static NSDateFormatter *formatter = nil;
    
    dispatch_once(&once, ^{
        formatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [formatter setLocale:enUSPOSIXLocale];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    });
    
    return formatter;
}

@end
