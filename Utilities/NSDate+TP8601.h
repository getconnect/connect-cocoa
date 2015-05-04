//
//  NSDate+TP8601.h
//  Connect
//
//  Created by Chad Edrupt on 28/04/2015.
//  Copyright (c) 2015 Tipi HQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TP8601)
NS_ASSUME_NONNULL_BEGIN

- (NSString*)tp_iso8601String;

NS_ASSUME_NONNULL_END
@end
