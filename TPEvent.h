//
//  TPEvent.h
//  Connect
//
//  Created by Chad Edrupt on 28/04/2015.
//  Copyright (c) 2015 Tipi HQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPEvent : NSObject
NS_ASSUME_NONNULL_BEGIN

+ (instancetype)eventWithProperties:(NSDictionary*)properties
                      forCollection:(NSString*)collection;

/**
 
 Prepares the event for serialization
 
 Validates that it only contains legal property names.
 And converts types to valid JSON types.
 
 @param error An error pointer that will be set if a validation error occurs
 @return YES if everything was succesful, NO if an error occured
 */
- (BOOL)process:(out NSError *__autoreleasing *)error;

/**
 
 Prepares a batch of events for serialization
 
 Validates that they only contains legal property names.
 And converts types to valid JSON types.
 
 @param eventBatch An NSDictionary containing the events grouped by collection.
 @param error An error pointer that will be set if a validation error occurs on any event in the batch.
 @return An NSDictionary containing Collection names as the key and NSArrays of TPEvents as the values.
 */
+ (NSDictionary* __nullable)processBatch:(NSDictionary*)eventBatch
                        error:(NSError *__autoreleasing *)error;

/**
 The events properties as an NSDictionary. If -process: has been called these will be ready for serialization
 */
@property (nonatomic, readonly) NSDictionary *properties;

/**
 The collection that this event belongs in
 */
@property (nullable, nonatomic, readonly) NSString *collection;

NS_ASSUME_NONNULL_END
@end
