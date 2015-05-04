//
//  TPConnectClient.h
//  Connect
//
//  Created by Chad Edrupt on 27/04/2015.
//  Copyright (c) 2015 Tipi HQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPConnectClient : NSObject

NS_ASSUME_NONNULL_BEGIN

/**
 
 Use this method to configure the shared Connect Client
 
 @param apiKey Your connect API key.
 @return The configured shared client.
 */
+ (instancetype)sharedClientWithAPIKey:(NSString *)apiKey;

/**
 
 The shared Connect Client
 
 @return The shared client if it has been configured with -sharedClientWithAPIKey: otherwise it returns nil.
 */

+ (nullable instancetype)sharedClient;

/**
 
 Initializes a client ready to be used.
 Use this method if you would rather not use the shared singleton.
 
 @param apiKey Your connect API key.
 @return A configured Connect Client
 */

+ (instancetype)clientWithApiKey:(NSString *)apiKey;

/**
 
 Add an event to the queue
 
 This method queues the event for sending. Call -pushAllPendingEvents to persist the event to Connect.
 The event will be stored on the disk until a call to -pushAllPendingEvents is succesful.
 
 Event properties are supplied as an NSDictionary. Nested NSDictionaries and NSArrays are allowed as well.
 The following types are supported NSDictionary, NSArray, NSString, NSNumber and NSDate (Note NSDates will be converted to ISO8601 strings before being sent to Connect).
 
 @param event An NSDictionary that consists of key/value pairs. Nested NSDictionaries and NSArrays are allowed as well.
 @param collectionName The name of the collection to add the event too.
 @param error A reference to an NSError
 */
- (BOOL)addEvent:(NSDictionary*)event toCollection:(NSString*)collectionName withError:(NSError *__autoreleasing *)error;

/**
 
 Push an event directly to Connect
 
 Use -addEvent:toCollection:withError if you want TPConnectClient to manage batch sends to Connect and network failures.
 However you can use this method to send an event directly to a Connect collection if you would like.
 
 @param event An NSDictionary that consists of key/value pairs. In the same format as -addEvent:toCollection:withError
 @param collectionName The name of the collection to add the event too.
 @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes two arguments: a BOOL informing if the push was successful and otherwise an error informing why not.
 */
- (void)pushEvent:(NSDictionary *)event toCollection:(NSString *)collectionName completionHandler:(void (^)(BOOL success, NSError *__nullable error))completionHandler;

/**
 
 Push an event batch directly to Connect
 
 Use -addEvent:toCollection:withError if you want TPConnectClient to manage batch sends to Connect and network failures.
 However you can use this method to send a batch of events directly to a Connect if you would like.
 
 @param event An NSDictionary where the keys are the name of the collection and values are NSArrays of NSDictionarys that contain the events properties.
 @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes two arguments: an NSDictionary informing of the success of each event in the batch grouped by collection. And an error if the requst itself failed.
 */
- (void)pushEventBatch:(NSDictionary *)eventBatch completionHandler:(void (^)(NSDictionary *__nullable results, NSError *__nullable error))completionHandler;

/**
 
 Push all queued events to Connect
 
 This pushes all added events to Connect in a single batch.
 
 A possible strategy is to use -addEvent:toCollection:withError thoughout your app and then call this method in -applicationDidEnterBackground: of your AppDelegate.
 
 Use -pushAllPendingEventsWithCompletionHandler: if you would prefer to be informed of the result of the request.
 
 */
- (void)pushAllPendingEvents;

/**
 
 Push all queued events to Connect
 
 This pushes all added events to Connect in a single batch.
 
 A possible strategy is to use -addEvent:toCollection:withError thoughout your app and then call this method in -applicationDidEnterBackground: of your AppDelegate.
 
 Use -pushAllPendingEvents if you aren't concerned about the result of this request.
 
 @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes two arguments: an NSDictionary informing of the success of each event in the batch grouped by collection. And an error if the requst itself failed.
 */
- (void)pushAllPendingEventsWithCompletionHandler:(void (^)(NSDictionary *__nullable results, NSError *__nullableerror))completionHandler;

NS_ASSUME_NONNULL_END

@end