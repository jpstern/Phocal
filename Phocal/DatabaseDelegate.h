//
//  DatabaseDelegate.h
//  Phocal
//
//  Created by Josh Billingham on 4/7/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseDelegate : NSObject

+ (id)sharedManager;

- (void)postPhoto:(NSData *)imageData;
- (void)getPhotos:(void (^)(NSArray *))completion;
//- (void)fetchImageFile:(NSString *)photoID completion:(void (^)(NSData *))completion;

@end
