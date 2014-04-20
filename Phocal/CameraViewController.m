//
//  CameraViewController.m
//  Phocal
//
//  Created by Josh Stern on 3/29/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "CameraViewController.h"

#import "MasterViewController.h"
#import "LocationDelegate.h"

#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CameraViewController ()

@property (nonatomic, strong) AVCaptureStillImageOutput *output;

@end

@implementation CameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor blackColor];
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPreset640x480; // TODO: should be full qual.
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.bounds;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        [session addInput:input];
        
        _output = [[AVCaptureStillImageOutput alloc] init];
        [session addOutput:_output];
        

        [session startRunning];
    }
    
    [self.view.layer addSublayer:layer];
    
    int pos = self.view.frame.size.height-54;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
     UIImage *cameraIcon = [UIImage imageNamed:@"cameraButton"];
    [button setImage:cameraIcon forState:UIControlStateNormal];
    button.frame = CGRectMake(130, pos-30, 60, 60);
    [button addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    UIButton *photoViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *photoIcon = [UIImage imageNamed:@"list"];
    
    
    
    photoViewButton.frame = CGRectMake(10, pos, 44, 44);
    //photoViewButton.tintColor = [UIColor whiteColor];
    [photoViewButton setImage:photoIcon forState:UIControlStateNormal];
    [photoViewButton addTarget:self action:@selector(photoView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoViewButton];
    
    UIButton *uploadViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
   // UIImage *uploadIcon = [UIImage imageNamed:@"arrow"];
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
    {
            if (nil != group && group.numberOfAssets!=0)
            {
                
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1]
                options:0
                usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
                {
                    if (nil != result)
                    {
                        ALAssetRepresentation *repr = [result defaultRepresentation];
                        UIImage *uploadIcon = [UIImage imageWithCGImage:[repr fullResolutionImage]];
                        [uploadViewButton setImage:uploadIcon forState:UIControlStateNormal];
                        [uploadViewButton addTarget:self action:@selector(albumView) forControlEvents:UIControlEventTouchUpInside];
                        [self.view addSubview:uploadViewButton];
                        uploadViewButton.frame = CGRectMake(270, pos, 44, 44);

                        *stop = YES;
                        }
                }];
            }
            else
            {
                //uploadViewButton.hidden=YES;
            }
        
                                     
            *stop = NO;
    }
    failureBlock:^(NSError *error)
    {
        NSLog(@"error: %@", error);
    }];
    
    
   // uploadViewButton.tintColor = [UIColor whiteColor];
    
    //    [photoViewButton setTitle:@"Photos" forState:UIControlStateNormal];
    
    
}

- (void)photoView
{
    [[(MasterViewController*)_master masterScroll] setContentOffset:CGPointMake(0,0) animated:YES];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    NSData *imageData = UIImageJPEGRepresentation(image,1.0);
    [[PhocalCore sharedClient] postPhoto:imageData];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *referenceURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSDictionary *metadata = rep.metadata;
        NSLog(@"%@", metadata);
        
    } failureBlock:^(NSError *error) {
        // error handling
    }];
    //do something with the image
}



-(void)albumView
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    
}


- (void)takePhoto {
        
    AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
    
    [[LocationDelegate sharedInstance] refresh:^(CLLocation *loc) {
        
        [_output captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            // violently stolen from here:
            // http://stackoverflow.com/questions/5125323/problem-setting-exif-data-for-an-image
            CFDictionaryRef metaDict = CMCopyDictionaryOfAttachments(NULL, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
            CFMutableDictionaryRef mutable = CFDictionaryCreateMutableCopy(NULL, 0, metaDict);
            
            NSMutableDictionary * mutableGPS = [self getGPSDictionaryForLocation:loc];
            CFDictionarySetValue(mutable, kCGImagePropertyGPSDictionary, (__bridge const void *)(mutableGPS));
            
            // set the dictionary back to the buffer
            CMSetAttachments(imageDataSampleBuffer, mutable, kCMAttachmentMode_ShouldPropagate);
            
            // trivial simple JPEG case
            NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                                        imageDataSampleBuffer,
                                                                        kCMAttachmentMode_ShouldPropagate);
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    //                    [self displayErrorOnMainQueue:error withMessage:@"Save to camera roll failed"];
                    return;
                }
                
                NSLog(@"Took picture");
                
                [[PhocalCore sharedClient] postPhoto:jpegData];
            }];
            
            if (attachments)
                CFRelease(attachments);
            
        }];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//http://stackoverflow.com/questions/3884060/saving-geotag-info-with-photo-on-ios4-1/5314634#5314634
- (NSMutableDictionary *)getGPSDictionaryForLocation:(CLLocation *)location {
    NSMutableDictionary *gps = [NSMutableDictionary dictionary];
    
    // GPS tag version
    [gps setObject:@"2.2.0.0" forKey:(NSString *)kCGImagePropertyGPSVersion];
    
    // Time and date must be provided as strings, not as an NSDate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
    [formatter setDateFormat:@"yyyy:MM:dd"];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];
    
    // Latitude
    CGFloat latitude = location.coordinate.latitude;
    if (latitude < 0) {
        latitude = -latitude;
        [gps setObject:@"S" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    } else {
        [gps setObject:@"N" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    
    // Longitude
    CGFloat longitude = location.coordinate.longitude;
    if (longitude < 0) {
        longitude = -longitude;
        [gps setObject:@"W" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    } else {
        [gps setObject:@"E" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    }
    [gps setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    
    // Altitude
    CGFloat altitude = location.altitude;
    if (!isnan(altitude)){
        if (altitude < 0) {
            altitude = -altitude;
            [gps setObject:@"1" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        } else {
            [gps setObject:@"0" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        }
        [gps setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    }
    
    // Speed, must be converted from m/s to km/h
    if (location.speed >= 0){
        [gps setObject:@"K" forKey:(NSString *)kCGImagePropertyGPSSpeedRef];
        [gps setObject:[NSNumber numberWithFloat:location.speed*3.6] forKey:(NSString *)kCGImagePropertyGPSSpeed];
    }
    
    // Heading
    if (location.course >= 0){
        [gps setObject:@"T" forKey:(NSString *)kCGImagePropertyGPSTrackRef];
        [gps setObject:[NSNumber numberWithFloat:location.course] forKey:(NSString *)kCGImagePropertyGPSTrack];
    }
    
    return gps;
}

@end
