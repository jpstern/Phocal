//
//  Jam
//
//  Copyright (c) 2013 Marmalade Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h> //TODO: move this out to a delegate (or user)?

@interface LocationDelegate : NSObject <CLLocationManagerDelegate>

// this delegate is meant to grab the users location once.
// once init'd the calling refresh will update the user object

+ (LocationDelegate*)sharedInstance;
+ (CLLocation*)getLoc;
- (id)init;
- (void)refresh:(void (^)(CLLocation *loc))completion;
- (BOOL)isOld;
- (BOOL)isLocDifferent:(CLLocation*)loc;

@end
