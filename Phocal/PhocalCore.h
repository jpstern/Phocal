//
//  PhocalCore.h
//  Phocal
//
//  Created by Josh Stern on 3/28/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#import <CoreLocation/CoreLocation.h>

@interface PhocalCore : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

- (void)postPhoto:(NSData *)imageData withLocation:(CLLocation*)location;
- (void)getPhotos:(void (^)(NSArray *))completion;


@end
