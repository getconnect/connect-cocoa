//
//  NSDictionary+TPJSON.h
//  Connect
//
//  Created by Chad Edrupt on 28/04/2015.
//  Copyright (c) 2015 Tipi HQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (TPJSON)
NS_ASSUME_NONNULL_BEGIN

- (nullable NSString*)tp_buildJSONString:(NSError *__autoreleasing *)error;

NS_ASSUME_NONNULL_END
@end
