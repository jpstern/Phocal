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



@end