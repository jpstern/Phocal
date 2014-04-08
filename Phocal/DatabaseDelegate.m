//
//  DatabaseDelegate.m
//  Phocal
//
//  Created by Josh Billingham on 4/7/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "DatabaseDelegate.h"
#import <AFNetworking.h>

NSString* kMongoBaseURL = @"http://phocal.aws.af.cm/";

@interface DatabaseDelegate ()

@property (nonatomic, strong) AFHTTPRequestOperationManager* mongoManager;
@property (nonatomic, strong) AFHTTPRequestOperationManager* s3Manager;

@end

@implementation DatabaseDelegate

+ (id)sharedManager {
    static DatabaseDelegate* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DatabaseDelegate alloc] init];
    });
    return manager;
}

- (id)init {
    if (self = [super init]) {
        _mongoManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kMongoBaseURL]];
    }
    
    return self;
}

- (void)postPhoto:(NSData *)imageData {
    [self.mongoManager POST:@"photos" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"photo" fileName:@"file" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success uploading photo! %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure uploading photo! %@", error);
    }];
}

- (void)getPhotos:(void (^)(NSArray *))completion {
    [self.mongoManager GET:@"photos" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response object %@", responseObject);
        completion(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure getting photos %@", error);
        completion(nil);
    }];
}

/*- (void)fetchImageFile:(NSString *)photoID completion:(void (^)(NSData *))completion {
    [self.s3Manager GET:photoID parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"URL: %@", operation.request.URL.absoluteString);
        NSLog(@"Photo fetch success! %@", responseObject);
        completion(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Photo fetch failure! %@", error);
        completion(nil);
    }];
}*/

@end
