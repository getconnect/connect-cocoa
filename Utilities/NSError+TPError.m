//
//  NSError+TPError.m
//  Connect
//
//  Created by Chad Edrupt on 28/04/2015.
//

#import "NSError+TPError.h"

@implementation NSError (TPError)

static NSString * const TPConnectErrorDomain = @"io.getconnect.ConnectClient";

+ (NSError*)tp_errorWithDescription:(NSString*)description andSuggestion:(NSString*)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: description,
                               NSLocalizedRecoverySuggestionErrorKey: suggestion
                               };
    return [NSError errorWithDomain:TPConnectErrorDomain
                               code:1
                           userInfo:userInfo];
}

+ (NSError*)tp_errorWithDescription:(NSString*)description {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: description
                               };
    return [NSError errorWithDomain:TPConnectErrorDomain
                               code:1
                           userInfo:userInfo];
}

@end
