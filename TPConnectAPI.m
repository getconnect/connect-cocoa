//
//  TPConnectAPI.m
//  Connect
//
//  Created by Chad Edrupt on 27/04/2015.
//

#import "TPConnectAPI.h"
#import "TPEventAPIResponse.h"
#import "NSDictionary+TPJSON.h"
#import "NSError+TPError.h"

static NSString * const TPConnectBaseURL = @"https://api.getconnect.io/";

typedef NS_ENUM(NSInteger, TPHTTPStatusCode) {
    TPHTTPStatusOK = 200,
    TPHTTPStatusUnprocessableEntity = 422,
    TPHTTPStatusServerError = 500,
    TPHTTPStatusConflict = 409,
    TPHTTPStatusBadRequest = 400,
    TPHTTPStatusUnauthorised = 401
};

@interface TPConnectAPI()

@property (nonnull, nonatomic, readonly) NSURL *baseUrl;
@property (nonnull, nonatomic, readonly) NSURL *pushBaseUrl;
@property (nullable, nonatomic, strong) NSString *projectId;
@property (nullable, nonatomic, strong) NSString *apiKey;
@property (nonnull, nonatomic, strong) NSURLSession *session;

@end

@implementation TPConnectAPI

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _baseUrl = [NSURL URLWithString:TPConnectBaseURL];
    _pushBaseUrl = [NSURL URLWithString:@"events/" relativeToURL:_baseUrl];
    _session = [NSURLSession sharedSession];
    
    return self;
}

- (instancetype)initWithProjectId:(NSString*)projectId
                           apiKey:(NSString*)apiKey{
    self = [self initWithProjectId:projectId
                            apiKey:apiKey
              sessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    if (!self) {
        return nil;
    }
    return self;
}

- (instancetype)initWithProjectId:(NSString*)projectId
                           apiKey:(NSString*)apiKey
             sessionConfiguration:(NSURLSessionConfiguration*)configuration {
    self = [super init];
    if (!self) {
        return nil;
    }
    _apiKey = apiKey;
    _projectId = projectId;
    _baseUrl = [NSURL URLWithString:TPConnectBaseURL];
    _pushBaseUrl = [NSURL URLWithString:@"events/" relativeToURL:_baseUrl];
    
    [configuration setHTTPAdditionalHeaders: @{
                                               @"Accept": @"application/json",
                                               @"X-Project-Id": _projectId,
                                               @"X-API-Key": _apiKey
                                               }];
    
    _session = [NSURLSession sessionWithConfiguration:configuration];
    
    return self;
}

+ (instancetype)apiClientWithProjectId:(NSString*)projectId
                            withApiKey:(NSString*)apiKey  {
    TPConnectAPI *apiClient = [[[self class] alloc] initWithProjectId:projectId
                                                               apiKey:apiKey];
    return apiClient;
}

#pragma mark - API Communication

- (void)pushEvent:(TPEvent*)event completionHandler:(void (^)(BOOL success, NSError *error))completionHandler {
    NSError *jsonError;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:event.properties
                                                          options:0
                                                            error:&jsonError];
    if (jsonError) {
        if (completionHandler) {
            completionHandler(NO, jsonError);
        }
        return;
    }
    
    NSURL *collectionURL = [NSURL URLWithString:event.collection
                                  relativeToURL:self.pushBaseUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:collectionURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completionHandler) {
                completionHandler(NO, error);
            }
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        TPHTTPStatusCode status = (TPHTTPStatusCode)httpResponse.statusCode;
        
        if (status == TPHTTPStatusOK) {
            if (completionHandler) {
                completionHandler(YES, nil);
            }
            return;
        }
        
        if (status == TPHTTPStatusUnauthorised) {
            NSError *unauthorisedError = [NSError tp_errorWithDescription:@"Invalid API key"
                                                            andSuggestion:@"Check the Connect portal and get a valid WRITE key"];
            if (completionHandler) {
                completionHandler(NO, unauthorisedError);
            }
            return;
        }
        
        NSError *jsonError;
        NSDictionary *errorDetails = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:&jsonError];
        if (jsonError) {
            if (completionHandler) {
                completionHandler(NO, jsonError);
            }
            return;
        }
        
        NSError *httpError = [self errorForHTTPStatusCode:status
                                                  details:errorDetails];
        if (httpError) {
            if (completionHandler) {
                completionHandler(NO, error);
            }
            return;
        }
        
        if (completionHandler) {
            completionHandler(NO, error);
        }
    }];
    
    [task resume];
}

- (void)pushEventBatch:(NSDictionary*)eventBatch
     completionHandler:(void (^)(NSDictionary *individualResults, NSError *error))completionHandler {
    
    NSError *processingError;
    NSData *requestBody = [self processBatch:eventBatch error:&processingError];
    if (processingError) {
        if (completionHandler) {
            completionHandler(nil, processingError);
        }
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.pushBaseUrl];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completionHandler) {
                completionHandler(nil, error);
            }
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        TPHTTPStatusCode status = (TPHTTPStatusCode)httpResponse.statusCode;
        
        if (status == TPHTTPStatusOK) {
            NSError *jsonError;
            NSDictionary *responseDetails = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:NSJSONReadingAllowFragments
                                                                              error:&jsonError];
            if (jsonError) {
                if (completionHandler) {
                    completionHandler(nil, jsonError);
                }
                return;
            }
            
            NSDictionary *processedResponseDetails = [self processBatchResponse:responseDetails
                                                                      forEvents:eventBatch];
            if (completionHandler) {
                completionHandler(processedResponseDetails, nil);
            }
            return;
        }
        
        if (status == TPHTTPStatusUnauthorised) {
            NSError *unauthorisedError = [NSError tp_errorWithDescription:@"Invalid API key"
                                                            andSuggestion:@"Check the Connect portal and get a valid WRITE key"];
            if (completionHandler) {
                completionHandler(nil, unauthorisedError);
            }
            return;
        }
        
        NSError *unknownError = [NSError tp_errorWithDescription:@"An unkown errror occured"
                                                        andSuggestion:@"Check the Connect documentation"];
        if (completionHandler) {
            completionHandler(nil, unknownError);
        }
    }];
    
    [task resume];
    
}

#pragma mark - Processing

- (NSData*)processBatch:(NSDictionary*)eventBatch error:(NSError *__autoreleasing *)error {
    
    NSMutableDictionary *groupedCollectionEvents = [NSMutableDictionary dictionary];
    
    for (NSString *collectionName in [eventBatch allKeys]) {
        
        id value = [eventBatch valueForKey:collectionName];
        if (![value isKindOfClass:[NSArray class]]) {
            if (error != NULL) {
                *error = [NSError tp_errorWithDescription:@"Invalid format, NSDictionary values must be NSArrays"
                                            andSuggestion:@"Ensure the NSDictonary contains only NSArrays of TPEvents keyed by collection name"];
            }
            return nil;
        }
        
        NSMutableArray *collectionEvents = [NSMutableArray array];
        
        NSArray *events = (NSArray*)value;
        for (id event in events) {
            if (![event isKindOfClass:[TPEvent class]]) {
                if (error != NULL) {
                    *error = [NSError tp_errorWithDescription:@"Invalid format, NSArrays in NSDictionary should only contain TPEvents"
                                                andSuggestion:@"Ensure the NSDictonary contains only NSArrays of TPEvents keyed by collection name"];
                }
                return nil;
            }
            
            TPEvent *tpEvent = (TPEvent*)event;
            [collectionEvents addObject:tpEvent.properties];
        }
        
        [groupedCollectionEvents setValue:collectionEvents forKey:collectionName];
    }
    
    NSError *jsonError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:groupedCollectionEvents
                                                   options:0
                                                     error:&jsonError];
    if (jsonError) {
        *error = jsonError;
        return nil;
    }
    
    return data;
}

- (NSDictionary*)processBatchResponse:(NSDictionary*)response forEvents:(NSDictionary*)events {
    
    NSMutableDictionary *batchResults = [NSMutableDictionary dictionary];
    
    for (NSString *collectionName in [response allKeys]) {
        
        NSMutableArray *collectionResults = [NSMutableArray array];
        
        NSArray *responses = response[collectionName];
        NSArray *eventsInCollection = events[collectionName];
        
        for (NSInteger i=0; i < [responses count]; i++) {
            NSDictionary *eventResponse = responses[i];
            TPEvent *event = eventsInCollection[i];
            
            TPEventAPIResponse *eventApiResponse = [TPEventAPIResponse eventAPIResponseFromJSON:eventResponse
                                                                                       forEvent:event];
            [collectionResults addObject:eventApiResponse];
        }
        
        [batchResults setValue:collectionResults forKey:collectionName];
    }
    
    return batchResults;
}

- (NSError*)errorForHTTPStatusCode:(TPHTTPStatusCode)code details:(NSDictionary*)details {
    
    switch (code) {
        case TPHTTPStatusUnprocessableEntity: {
            NSString *message = [NSString stringWithFormat:@"%@: %@", details[@"field"], details[@"description"]];
            NSString *suggestion = [NSString stringWithFormat:@"Ensure the property  '%@' is in suitable format", details[@"field"]];
            
            return [NSError tp_errorWithDescription:message
                                      andSuggestion:suggestion];
            break;
        }
        case TPHTTPStatusServerError:
        case TPHTTPStatusConflict:
        case TPHTTPStatusBadRequest:
            return [NSError tp_errorWithDescription:details[@"errorMessage"]];
            break;
        case TPHTTPStatusUnauthorised:
            return [NSError tp_errorWithDescription:@"Unauthorised"];
            break;
        case TPHTTPStatusOK:
            return nil;
            break;
    }
}

@end
