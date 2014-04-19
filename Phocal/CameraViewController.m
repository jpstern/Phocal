//
//  CameraViewController.m
//  Phocal
//
//  Created by Josh Stern on 3/29/14.
//  Copyright (c) 2014 Josh. All rights reserved.
//

#import "CameraViewController.h"

#import "DatabaseDelegate.h"
#import "MasterViewController.h"

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
    imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    NSData *imageData = UIImageJPEGRepresentation(image,1.0);
    [[PhocalCore sharedClient] postPhoto:imageData];
    [picker dismissModalViewControllerAnimated:YES];
    
    //do something with the image
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)albumView
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


- (void)takePhoto {
        
    AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
    
    [_output captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
