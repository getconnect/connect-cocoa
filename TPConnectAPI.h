//
//  TPConnectAPI.h
//  Connect
//
//  Created by Chad Edrupt on 27/04/2015.
//

#import <Foundation/Foundation.h>
#import "TPEvent.h"

@interface TPConnectAPI : NSObject
NS_ASSUME_NONNULL_BEGIN

- (instancetype)initWithProjectId:(NSString*)projectId
                           apiKey:(NSString*)apiKey
             sessionConfiguration:(NSURLSessionConfiguration*)configuration;

+ (instancetype)apiClientWithProjectId:(NSString*)projectId
                            withApiKey:(NSString*)apiKey;

- (void)pushEvent:(TPEvent*)event completionHandler:(void (^__nullable)(BOOL success, NSError*__nullable))completionHandler;

- (void)pushEventBatch:(NSDictionary*)eventBatch completionHandler:(void (^__nullable)(NSDictionary*__nullable individualResults, NSError*__nullable error))completionHandler;

NS_ASSUME_NONNULL_END
@end
