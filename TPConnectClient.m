//
//  TPConnectClient.m
//  Connect
//
//  Created by Chad Edrupt on 27/04/2015.
//  Copyright (c) 2015 Tipi HQ. All rights reserved.
//

#import "TPConnectClient.h"
#import "TPConnectAPI.h"
#import "TPEventStore.h"
#import "TPEvent.h"
#import "TPEventAPIResponse.h"

static NSString * const TPConnectErrorDomain = @"io.getconnect.ConnectClient";
static TPConnectClient *sharedClient = nil;

@interface TPConnectClient ()

@property (readwrite, nonatomic, strong) NSString *apiKey;
@property (nonnull, nonatomic, strong) TPConnectAPI *apiClient;
@property (nonnull, nonatomic, strong) TPEventStore *eventStore;
@property (nonnull, nonatomic, strong) NSDictionary *currentEvents;

@end

@implementation TPConnectClient

#pragma mark - Lifecycle

- (instancetype)initWithApiKey:(NSString *)apiKey {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _apiKey = apiKey;
    _apiClient = [TPConnectAPI apiClientWithKey:apiKey];
    _eventStore = [TPEventStore eventStoreWithApiKey:apiKey];
    
    return self;
}

+ (instancetype)clientWithApiKey:(NSString *)apiKey {
    return [[[self class] alloc] initWithApiKey:apiKey];
}

+ (instancetype)sharedClient {
    return sharedClient;
}

+ (instancetype)sharedClientWithAPIKey:(NSString *)apiKey {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self class] clientWithApiKey:apiKey];
    });
    return sharedClient;
}

#pragma mark - Event Pushing

- (BOOL)addEvent:(NSDictionary*)event
    toCollection:(NSString*)collectionName
       withError:(NSError *__autoreleasing *)error {
    
    TPEvent *newEvent = [TPEvent eventWithProperties:event
                                       forCollection:collectionName];
    
    BOOL successful = [newEvent process:error];
    if (!successful) {
        return NO;
    }
    
    [self.eventStore addEvent:newEvent];
    
    return YES;
}

- (void)pushEvent:(NSDictionary *)event
     toCollection:(NSString *)collectionName
completionHandler:(void (^)(BOOL success, NSError *error))completionHandler {
    
    TPEvent *newEvent = [TPEvent eventWithProperties:event
                                       forCollection:collectionName];
    
    NSError *processingError;
    [newEvent process:&processingError];
    if (processingError) {
        if (completionHandler) {
            completionHandler(NO, processingError);
        }
    }
    
    [self.apiClient pushEvent:newEvent
            completionHandler:completionHandler];
}

- (void)pushEventBatch:(NSDictionary *)eventBatch
     completionHandler:(void (^)(NSDictionary *results, NSError *error))completionHandler {
    
    NSError *processingError;
    NSDictionary *processedEvents = [TPEvent processBatch:eventBatch
                                                    error:&processingError];
    if (processingError) {
        if (completionHandler) {
            completionHandler(nil, processingError);
        }
        return;
    }
    
    [self.apiClient pushEventBatch:processedEvents
                 completionHandler:completionHandler];
}


- (void)pushAllPendingEvents {
    [self pushAllPendingEventsWithCompletionHandler:^(NSDictionary *results, NSError *error) {}];
}
- (void)pushAllPendingEventsWithCompletionHandler:(void (^)(NSDictionary *results, NSError *error))completionHandler {
    
    [self.eventStore fetchPendingEventsWithCompletionHandler:^(NSMutableDictionary *pendingEvents) {
        [self.apiClient pushEventBatch:pendingEvents completionHandler:^(NSDictionary * results, NSError *error) {
            if (error) {
                if (completionHandler) {
                    completionHandler(nil, error);
                }
                return;
            }
            
            for (NSString *collection in [results allKeys]) {
                for (TPEventAPIResponse *response in results[collection]) {
                    if (response.success || response.duplicate) {
                        [self.eventStore removeEventWithId:response.event.properties[@"id"]
                                            fromCollection:collection];
                    }
                }
            }
            
            if (completionHandler) {
                completionHandler(results, nil);
            }
        }];
    }];
}

#pragma mark - Event Removing

- (void)removePendingEventWithId:(NSString*)eventId fromCollection:(NSString*)collectionName {
    [self.eventStore removeEventWithId:eventId
                        fromCollection:collectionName];
}

- (void)removeAllPendingEvents {
    [self.eventStore deleteAllPendingEvents:nil];
}

@end
