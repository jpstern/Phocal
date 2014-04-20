//
//  Jam
//
//  Copyright (c) 2013 Marmalade Studios, LLC. All rights reserved.
//

#import "LocationDelegate.h"

@interface LocationDelegate ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

static LocationDelegate* sharedDelegate = nil;
static CLLocation *location = nil;

static void (^nextCompetion)(CLLocation*);

@implementation LocationDelegate

+ (LocationDelegate *)sharedInstance {
    if (sharedDelegate == nil) {
        sharedDelegate = [[LocationDelegate alloc] init];
    }
    return sharedDelegate;
}

+ (CLLocation *)getLoc {
    return location;
}

- (id)init {
    if (self = [super init]) {
        // setup location
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; //TODO: too much?
        [_locationManager setDelegate:self];
    }
    return self;
}

- (void)refresh:(void (^)(CLLocation *loc))completion {
    if (location && ![self isOld]) {
        NSLog(@"running refresh");
        if(completion) completion(location);
    } else {
        NSLog(@"running refresh, with new location");
        nextCompetion = completion;
        [self.locationManager startUpdatingLocation];
    }
}

- (BOOL)isOld {
    NSTimeInterval howRecent = [location.timestamp timeIntervalSinceNow];
    return abs(howRecent) > 60.0*15; // last 15 minutes
}

- (BOOL)isLocDifferent:(CLLocation *)loc {
    NSLog(@"loc: %@, loc2 %@", location, loc);
    CLLocationDistance d = [location distanceFromLocation:loc];
    
    NSLog(@"distanc between points: %f, accuracy %f", d, loc.horizontalAccuracy);
    return d > loc.horizontalAccuracy;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Needed"
                               message:@"Please enable Location Services"
                              delegate:nil
                     cancelButtonTitle:nil
                     otherButtonTitles:nil];
    [alert show];

    NSLog(@"%@", error);
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // set the known location of the current user, no matter how old
    location = [locations lastObject];
    
    NSTimeInterval howRecent = [location.timestamp timeIntervalSinceNow];
    if (abs(howRecent) < 15.0 && nextCompetion) {
        
        // If it's a relatively recent event, turn off updates to save power.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        
        // we got a good location, lets go
        [manager stopUpdatingLocation];
        
        // call the block once.
        nextCompetion(location);
        nextCompetion = nil;
        
        
    }
}

@end
