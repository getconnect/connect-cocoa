//
//  TPEvent.m
//  Connect
//
//  Created by Chad Edrupt on 28/04/2015.
//

#import "TPEvent.h"
#import "NSDictionary+TPJSON.h"
#import "NSDate+TP8601.h"
#import "NSError+TPError.h"

@interface TPEvent()

@property (nullable, nonatomic, strong) NSString *collectionName;
@property (nonnull, nonatomic, strong) NSMutableDictionary *internalProperties;

@end

@implementation TPEvent

@dynamic properties;

#pragma mark Lifecycle

- (instancetype)init {
    self = [self initWithProperties:nil forCollection:nil];
    if (!self) {
        return nil;
    }
    return self;
}

- (instancetype)initWithProperties:(NSDictionary*)properties
                     forCollection:(NSString*)collectionName {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (properties) {
        _internalProperties = [properties mutableCopy];
    } else {
        _internalProperties = [NSMutableDictionary dictionary];
    }
    _collectionName = collectionName;
    
    return self;
}

+ (instancetype)eventWithProperties:(NSDictionary*)properties
                      forCollection:(NSString*)collection {
    TPEvent *event = [[[self class] alloc] initWithProperties:properties
                                                forCollection:collection];
    return event;
}

#pragma mark Getters & Setters

- (NSDictionary *)properties {
    return self.internalProperties;
}

- (NSString*)collection {
    return self.collectionName;
}

#pragma mark Event Processing

- (BOOL)process:(NSError *__autoreleasing *)error {
    if (![self validate:error]) {
        return NO;
    }
    
    [self addDefaultProperties];
    
    self.internalProperties = [self transformValue:self.internalProperties];
    
    return YES;
}

- (BOOL)validate:(NSError *__autoreleasing *)error {
    
    NSError *validationError;
    
    if (self.collectionName.length == 0) {
        validationError = [NSError tp_errorWithDescription:@"The collection name was null or empty"
                                             andSuggestion:@"Ensure that you provide a valid collection name"];
    }
    
    if (self.internalProperties.count <= 0) {
        validationError = [NSError tp_errorWithDescription:@"The event cannot be sent. It contains no properties"
                                             andSuggestion:@"Ensure that you provide a non-empty dictionary of your events properties"];
    };
    
    for (NSString *key in self.internalProperties.allKeys) {
        if ([key rangeOfString:@"tp_" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            NSString *description = [NSString stringWithFormat:@"The event cannot be sent. The key %@ uses a reserved property prefix", key];
            validationError = [NSError tp_errorWithDescription:description
                                        andSuggestion:@"Ensure that you properties names don't contain 'tp_'"];
        }
    }
    
    if (validationError && error != NULL) {
        *error = validationError;
    }
    
    return validationError == nil;
}

- (void)addDefaultProperties {
    if (![self.internalProperties.allKeys containsObject:@"id"]) {
        [self.internalProperties setValue:NSUUID.UUID.UUIDString forKey:@"id"];
    }
    
    if (![self.internalProperties.allKeys containsObject:@"timestamp"]) {
        [self.internalProperties setValue:[NSDate date] forKey:@"timestamp"];
    }
}

- (id)transformValue:(id)value {
    if (!value) {
        return value;
    }
    
    if ([value isKindOfClass:[NSDate class]]) {
        return [value tp_iso8601String];
    }
    
    if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArray = [NSMutableArray array];
        for (id item in value) {
            [newArray addObject:[self transformValue:item]];
        }
        return newArray;
    }
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *newDictionary = [NSMutableDictionary dictionary];
        NSArray *keys = [value allKeys];
        for (NSString *key in keys) {
            id newValue = [self transformValue:[value valueForKey:key]];
            [newDictionary setValue:newValue forKey:key];
        }
        return newDictionary;
    }
    
    return value;
}

#pragma - Batch processing

+ (NSDictionary*)processBatch:(NSDictionary*)eventBatch
                        error:(NSError *__autoreleasing *)error {
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    for (NSString* collectionName in [eventBatch allKeys]) {
        
        id value = eventBatch[collectionName];
        
        if (![value isKindOfClass:[NSArray class]]) {
            if (error != NULL) {
                *error = [NSError tp_errorWithDescription:@"Invalid format, NSDictionary values must be NSArrays"
                                            andSuggestion:@"Ensure the NSDictonary contains only NSArrays keyed by collection name"];
            }
            return nil;
        }
        
        NSMutableArray *eventsInCollection = [NSMutableArray array];
        for (id eventData in (NSArray*)value) {
            if (![eventData isKindOfClass:[NSDictionary class]]) {
                if (error != NULL) {
                    *error = [NSError tp_errorWithDescription:@"Invalid format, Events in each collection array must be of type NSDictionary"
                                                andSuggestion:@"Ensure the event data is of type NSDictionary"];
                }
                return nil;
            }
            
            TPEvent *event = [TPEvent eventWithProperties:eventData
                                            forCollection:collectionName];
            
            BOOL successful = [event process:error];
            if (!successful) {
                return nil;
            }
            
            [eventsInCollection addObject:event];
        }
        
        [results setValue:eventsInCollection forKey:collectionName];
    }
    
    return results;
}


@end
