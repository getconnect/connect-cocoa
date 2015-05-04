//
//  TPEventStore.m
//  Connect
//
//  Created by Chad Edrupt on 29/04/2015.
//  Copyright (c) 2015 Tipi HQ. All rights reserved.
//

#import "TPEventStore.h"
#import "NSError+TPError.h"
#import <YapDatabase/YapDatabase.h>

@interface TPEventStore()

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) YapDatabase *db;
@property (nonatomic, strong) YapDatabaseConnection *connection;

@end

@implementation TPEventStore

#pragma mark - Lifecycle

- (instancetype)init {
    self = [self initWithApiKey:nil];
    if (!self) {
        return nil;
    }
    return self;
}

- (instancetype)initWithApiKey:(NSString*)apiKey {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _apiKey = apiKey;
    
    NSString *databaseName = [NSString stringWithFormat:@"connect-%@.sqlite", apiKey];
    
    NSURL *baseURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                            inDomain:NSUserDomainMask
                                                   appropriateForURL:nil
                                                              create:YES
                                                               error:NULL];
    
    NSURL *databaseURL = [baseURL URLByAppendingPathComponent:databaseName isDirectory:NO];
    _databasePath = databaseURL.filePathURL.path;
    
    _db = [[YapDatabase alloc] initWithPath:_databasePath];
    _connection = [_db newConnection];
    
    return self;
}

+ (instancetype) eventStoreWithApiKey:(NSString*)apiKey {
    TPEventStore *eventStore = [[[self class] alloc] initWithApiKey:apiKey];
    return eventStore;
}

#pragma mark - Inputs & Outputs

- (void)addEvent:(TPEvent*)event {
    [self addEvent:event withCompletionHandler:^{}];
}

- (void)addEvent:(TPEvent*)event withCompletionHandler:(void (^)(void))completionHandler {
    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction){
        [transaction setObject:event.properties forKey:event.properties[@"id"] inCollection:event.collection];
        if (completionHandler) {
            completionHandler();
        }
    }];
}

- (void)removeEventWithId:(NSString*)eventId fromCollection:(NSString*)collectionName {
    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeObjectForKey:eventId inCollection:collectionName];
    }];
}

- (void)fetchPendingEventsWithCompletionHandler:(void (^)(NSMutableDictionary *pendingEvents))completionHandler {
    NSMutableDictionary *batch = [NSMutableDictionary dictionary];
    
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [transaction enumerateKeysAndObjectsInAllCollectionsUsingBlock:^(NSString *collection, NSString *key, id object, BOOL *stop) {
            NSMutableArray *collectionBatch = batch[collection];
            if (!collectionBatch) {
                collectionBatch = [NSMutableArray array];
                batch[collection] = collectionBatch;
            }
            
            TPEvent *event = [TPEvent eventWithProperties:object
                                            forCollection:collection];
            [collectionBatch addObject:event];
        }];
        completionHandler(batch);
    }];
}

- (void)deleteAllPendingEvents:(void (^)(void))completionHandler {
    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction removeAllObjectsInAllCollections];
        if (completionHandler) {
            completionHandler();
        }
    }];
}


@end
