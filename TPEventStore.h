//
//  TPEventStore.h
//  Connect
//
//  Created by Chad Edrupt on 29/04/2015.
//

#import <Foundation/Foundation.h>
#import "TPEvent.h"

@interface TPEventStore : NSObject
NS_ASSUME_NONNULL_BEGIN

+ (instancetype) eventStoreWithProjectId:(NSString*)projectId;

- (void)addEvent:(TPEvent*)event;
- (void)addEvent:(TPEvent*)event withCompletionHandler:(void (^)(void))completionHandler;

- (void)removeEventWithId:(NSString*)eventId fromCollection:(NSString*)collectionName;

- (void)fetchPendingEventsWithCompletionHandler:(void (^)(NSMutableDictionary *pendingEvents))completionHandler;

- (void)deleteAllPendingEvents:(void (^__nullable)(void))completionHandler;

@property (nonatomic, strong) NSString *databasePath;

NS_ASSUME_NONNULL_END
@end
