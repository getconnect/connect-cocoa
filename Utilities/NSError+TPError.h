//
//  NSError+TPError.h
//  Connect
//
//  Created by Chad Edrupt on 28/04/2015.
//  Copyright (c) 2015 Tipi HQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (TPError)
NS_ASSUME_NONNULL_BEGIN

+ (NSError*)tp_errorWithDescription:(NSString*)description andSuggestion:(NSString*)suggestion;
+ (NSError*)tp_errorWithDescription:(NSString*)description;

NS_ASSUME_NONNULL_END
@end
