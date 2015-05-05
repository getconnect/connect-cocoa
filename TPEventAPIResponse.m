//
//  TPEventAPIResponse.m
//  Connect
//
//  Created by Chad Edrupt on 29/04/2015.
//

#import "TPEventAPIResponse.h"

@implementation TPEventAPIResponse

- (instancetype)init {
    self = [self initWithEvent:nil success:NO duplicate:NO message:nil];
    if (!self) {
        return nil;
    }
    return self;
}

- (instancetype)initWithEvent:(TPEvent*)event
                      success:(BOOL)success
                    duplicate:(BOOL)duplicate
                      message:(NSString*)message {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _event = event;
    _success = success;
    _duplicate = duplicate;
    _message = message;
    
    return self;
}


+ (TPEventAPIResponse*)eventAPIResponseFromJSON:(NSDictionary*)json
                                       forEvent:(TPEvent*)event {
    
    NSString *message = json[@"message"];
    NSNumber *success = json[@"success"];
    NSNumber *duplicate = json[@"duplicate"];
    
    return [[TPEventAPIResponse alloc] initWithEvent:event
                                             success:success.boolValue
                                           duplicate:duplicate.boolValue
                                             message:message];
}

@end
