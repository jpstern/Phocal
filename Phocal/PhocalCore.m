//
//  PhocalCore.m
//  Phocal
//
//  Created by Josh Stern on 3/28/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "PhocalCore.h"

#define API_BASE_PATH @"www.google.com"
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

@end
