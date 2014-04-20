//
//  PhocalCore.m
//  Phocal
//
//  Created by Josh Stern on 3/28/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "PhocalCore.h"

//NSString* kMongoBaseURL = @"http://phocal.aws.af.cm/";

#define API_BASE_PATH @"http://phocal.aws.af.cm/"
#define API_BASE_URL [NSURL URLWithString:API_BASE_PATH]

@implementation PhocalCore

+ (instancetype)sharedClient {
    
    static PhocalCore *client = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        client = [[PhocalCore alloc] initWithBaseURL:API_BASE_URL];
        client.requestSerializer = [AFJSONRequestSerializer serializer];
        client.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions: NSJSONReadingMutableContainers];
        
    });
    
    return client;
}

- (void)postPhoto:(NSData *)imageData withLocation:(CLLocation*)location {
    
    [self POST:@"photos" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"photo" fileName:@"file" mimeType:@"image/jpeg"];
        
        [formData appendPartWithFormData: [[@([location.timestamp timeIntervalSince1970]*1000) stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:@"time"];
        
        [formData appendPartWithFormData: [[@(location.coordinate.latitude) stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:@"lat"];
        
        [formData appendPartWithFormData: [[@(location.coordinate.longitude) stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:@"lng"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success uploading photo! %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure uploading photo! %@", error);
    }];
}

- (void)getPhotos:(void (^)(NSArray *))completion {
    [self GET:@"photos" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response object %@", responseObject);
        completion(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure getting photos %@", error);
        completion(nil);
    }];
}

@end
