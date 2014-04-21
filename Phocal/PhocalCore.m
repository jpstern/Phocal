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

        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *UUID = [userDefaults objectForKey:@"x-hash"];
        if (!UUID) {
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            UUID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
            CFRelease(uuid);
            
            [userDefaults setObject:UUID forKey:@"x-hash"];
            [userDefaults synchronize];
        }
        
        [client.requestSerializer setValue:UUID forHTTPHeaderField:@"x-hash"];        
    });
    
    return client;
}

- (void)likePhotoForID:(NSString *)photoID {
    
    NSString *path = [NSString stringWithFormat:@"photo/%@/vote", photoID];
    
    [self POST:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        NSLog(@"%@", error);
    }];
}

- (void)postPhoto:(NSData *)imageData withLocation:(CLLocation*)location completion:(void (^)(NSDictionary *))completion  {
    
    [self POST:@"photos" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"photo" fileName:@"file" mimeType:@"image/jpeg"];
        
        [formData appendPartWithFormData: [[@([location.timestamp timeIntervalSince1970]*1000) stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:@"time"];
        
        [formData appendPartWithFormData: [[@(location.coordinate.latitude) stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:@"lat"];
        
        [formData appendPartWithFormData: [[@(location.coordinate.longitude) stringValue] dataUsingEncoding:NSUTF8StringEncoding] name:@"lng"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success uploading photo! %@", responseObject);
        completion(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure uploading photo! %@", error);
        completion(nil);
    }];
}

- (void)getPhotos:(void (^)(NSArray *))completion {
    NSLog(@"request header for x-hash: %@", [self.requestSerializer HTTPRequestHeaders][@"x-hash"]);
    [self GET:@"photos" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"response object %@", responseObject);
        completion(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure getting photos %@", error);
        completion(nil);
    }];
}

- (void)getClosestPhotosForLat:(NSNumber *)lat andLng:(NSNumber *)lng completion:(void (^)(NSArray *))completion {
    NSDictionary* params = @{ @"lat": lat, @"lng": lng };
    [self GET:@"photos" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success! Response: %@", responseObject);
        completion(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure! Error: %@", error);
    }];
}
//
//- (void)getLocationLabelForLat:(NSNumber *)lat andLng:(NSNumber *)lng completion:(void (^)(NSDictionary*))completion {
//    NSString * path = @"maps/api/place/nearbysearch/json";
//    NSDictionary* params = @{ @"location":[NSString stringWithFormat:@"%f,%f", [lat floatValue], [lng floatValue]],
//                              @"rankby":@"distance",
//                              @"types":@"accounting|airport|amusement_park|aquarium|art_gallery|atm|bakery|bank|bar|beauty_salon|bicycle_store|book_store|bowling_alley|bus_station|cafe|campground|car_dealer|car_rental|car_repair|car_wash|casino|cemetery|church|city_hall|clothing_store|convenience_store|courthouse|dentist|department_store|doctor|electrician|electronics_store|embassy|establishment|finance|fire_station|florist|food|funeral_home|furniture_store|gas_station|general_contractor|grocery_or_supermarket|gym|hair_care|hardware_store|health|hindu_temple|home_goods_store|hospital|insurance_agency|jewelry_store|laundry|lawyer|library|liquor_store|local_government_office|locksmith|lodging|meal_delivery|meal_takeaway|mosque|movie_rental|movie_theater|moving_company|museum|night_club|painter|park|parking|pet_store|pharmacy|physiotherapist|place_of_worship|plumber|police|post_office|real_estate_agency|restaurant|roofing_contractor|rv_park|school|shoe_store|shopping_mall|spa|stadium|storage|store|subway_station|synagogue|taxi_stand|train_station|travel_agency|university|veterinary_care|zoo",
//                              @"sensor":@"false",
//                              @"key":@"AIzaSyD242pkuyIkgiaDl_6zfCNBFyUta9sUCZ0" };
//        
//    // Use a different afnetworking manager because we have a different base URL.
//    AFHTTPRequestOperationManager* latManager =
//        [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://maps.googleapis.com/"]];
//    latManager.requestSerializer = [AFJSONRequestSerializer serializer];
//    
//    NSLog(@"fetching %@", [[NSURL URLWithString:path relativeToURL:latManager.baseURL] absoluteString]);
//
//    [latManager GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //NSLog(@"location response: %@", responseObject);
//        completion(responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"location fetch error: %@", error);
//        completion(nil);
//    }];
//}

- (NSString *)photoURLForId:(NSString *)photoID {
    return [NSString stringWithFormat:@"http://s3.amazonaws.com/Phocal/%@", photoID];
}


@end
