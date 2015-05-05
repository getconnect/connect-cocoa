//
//  TPEventAPIResponse.h
//  Connect
//
//  Created by Chad Edrupt on 29/04/2015.
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

/**
 The event that this response belongs to
 */
@property (nullable, nonatomic, strong) TPEvent *event;

/**
 A BOOL indicating if this particular request was persisted in Connect
 */
@property (nonatomic) BOOL success;

/**
 A BOOL indicating if this particular event has already been added to Connect
 */
@property (nonatomic) BOOL duplicate;

/**
 A message outlining why a request was unnsuccessfull. Will be nil if the event was succesfully added.
 */
@property (nullable, nonatomic, strong) NSString *message;

NS_ASSUME_NONNULL_END
@end
