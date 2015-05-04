//
//  TPEventAPIResponse.h
//  Connect
//
//  Created by Chad Edrupt on 29/04/2015.
//  Copyright (c) 2015 Tipi HQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPEvent.h"

@interface TPEventAPIResponse : NSObject
NS_ASSUME_NONNULL_BEGIN

- (instancetype)initWithEvent:(TPEvent* __nullable)event
                      success:(BOOL)success
                    duplicate:(BOOL)duplicate
                      message:(NSString* __nullable)message NS_DESIGNATED_INITIALIZER;

+ (TPEventAPIResponse*)eventAPIResponseFromJSON:(NSDictionary*)json forEvent:(TPEvent*)event;

@property (nullable, nonatomic, strong) TPEvent *event;
@property (nonatomic) BOOL success;
@property (nonatomic) BOOL duplicate;
@property (nullable, nonatomic, strong) NSString *message;

NS_ASSUME_NONNULL_END
@end
