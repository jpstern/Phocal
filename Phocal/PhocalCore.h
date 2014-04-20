//
//  PhocalCore.h
//  Phocal
//
//  Created by Josh Stern on 3/28/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface PhocalCore : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

- (void)postPhoto:(NSData *)imageData;
- (void)getPhotos:(void (^)(NSArray *))completion;
- (void)getClosestPhotosForLat:(NSNumber *)lat andLng:(NSNumber *)lng completion:(void (^)(NSArray *))completion;
- (void)getLocationLabelForLat:(NSNumber *)lat andLng:(NSNumber *)lng completion:(void (^)(NSDictionary *))completion;

- (NSString *)photoURLForId:(NSString *)photoID;

@end
