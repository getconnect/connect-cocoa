//
//  TPEventStore.h
//  Connect
//
//  Created by Chad Edrupt on 29/04/2015.
//  Copyright (c) 2015 Tipi HQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPEvent.h"

@interface TPEventStore : NSObject
NS_ASSUME_NONNULL_BEGIN

+ (instancetype) eventStoreWithApiKey:(NSString*)apiKey;

- (void)addEvent:(TPEvent*)event;
- (void)addEvent:(TPEvent*)event withCompletionHandler:(void (^)(void))completionHandler;

- (void)removeEventWithId:(NSString*)eventId fromCollection:(NSString*)collectionName;

- (void)fetchPendingEventsWithCompletionHandler:(void (^)(NSMutableDictionary *pendingEvents))completionHandler;

- (void)deleteAllPendingEvents:(void (^)(void))completionHandler;

@property (nonatomic, strong) NSString *databasePath;

NS_ASSUME_NONNULL_END
@end
