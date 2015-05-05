//
//  NSDateFormatter+TP8601.h
//  Connect
//
//  Created by Chad Edrupt on 28/04/2015.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (TP8601)
NS_ASSUME_NONNULL_BEGIN

+ (NSDateFormatter*)tp_iso8601DateFormatter;

NS_ASSUME_NONNULL_END
@end
