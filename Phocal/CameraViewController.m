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
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIImageView *photoPreview;
@property (nonatomic, strong) UIView *headerView;

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

- (void)cancelPhoto {
    
    _headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_photoPreview removeFromSuperview];
    _previewLayer.hidden = NO;
}

- (void)takeImageHandler {
    
    [self takePhoto:^(UIImage *image) {
       
        _headerView.backgroundColor = [UIColor blackColor];

        _previewLayer.hidden = YES;
        NSLog(@"%f", image.size.height);
        NSLog(@"%f", image.size.width);
        _photoPreview = [[UIImageView alloc] initWithImage:image];
        CGRect rect = _photoPreview.frame;
        rect.origin.y = 40;
        _photoPreview.frame = rect;
        [self.view addSubview:_photoPreview];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 100, 40);
        [button setTitle:@"Cancel" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cancelPhoto) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:button];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor=[UIColor blackColor];
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPreset640x480; // TODO: should be full qual.
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = CGRectMake(0, 0, 320, 320 + 40);
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (device) {
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        [session addInput:input];
        
        _output = [[AVCaptureStillImageOutput alloc] init];
        [session addOutput:_output];
        
        [session startRunning];
    }
    
    [self.view.layer addSublayer:_previewLayer];
    
    
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    _headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:_headerView];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 360, 320, self.view.frame.size.height - 360)];
    container.backgroundColor = [UIColor blackColor];
    [self.view addSubview:container];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
     UIImage *cameraIcon = [UIImage imageNamed:@"cameraButton"];
    [button setImage:cameraIcon forState:UIControlStateNormal];
    button.frame = CGRectMake(130, 0, 60, 60);
    button.center = CGPointMake(container.frame.size.width / 2, container.frame.size.height / 2);
    [button addTarget:self action:@selector(takeImageHandler) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button];
    
    UIButton *photoViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *photoIcon = [UIImage imageNamed:@"list"];
    
    photoViewButton.frame = CGRectMake(10, 0, 44, 44);
    photoViewButton.center = CGPointMake(photoViewButton.center.x, container.frame.size.height / 2);
    photoViewButton.tintColor = [UIColor whiteColor];
    [photoViewButton setImage:photoIcon forState:UIControlStateNormal];
    [photoViewButton addTarget:self action:@selector(photoView) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:photoViewButton];
    
    UIButton *uploadViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
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
                        [container addSubview:uploadViewButton];
                        uploadViewButton.frame = CGRectMake(270, 0, 44, 44);
                        uploadViewButton.center = CGPointMake(uploadViewButton.center.x, container.frame.size.height / 2);

                        *stop = YES;
                        }
                }];
            }
            else
            {
//                uploadViewButton.hidden=YES;
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
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //do something with the image
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)albumView
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (UIImage *)crop:(UIImage *)image from:(CGSize)src to:(CGSize)dst
{
    CGPoint cropCenter = CGPointMake((src.width/2), (src.height/2));
    CGPoint cropStart = CGPointMake((cropCenter.x - (dst.width/2)), (cropCenter.y - (dst.height/2)));
    CGRect cropRect = CGRectMake(cropStart.x, cropStart.y, dst.width, dst.height);
    
    CGImageRef cropRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    UIImage* cropImage = [UIImage imageWithCGImage:cropRef];
    CGImageRelease(cropRef);
    
    return cropImage;
}

- (void)takePhoto:(void(^)(UIImage *))done {
        
    AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
    
    [_output captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
//        UIImage *croppedImage = [self crop:<#(UIImage *)#> from:<#(CGSize)#> to:<#(CGSize)#>]
        
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
            NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:jpegData];
        
        

        UIImage *cropImage = [CameraViewController cropImage:image toRect:CGRectMake(0, 80, 320, 320)];
        
//            CGImageRef cropRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 40, 320, 320));
//            UIImage* cropImage = [UIImage imageWithCGImage:cropRef];
//            CGImageRelease(cropRef);
        
            NSData *imageData = UIImageJPEGRepresentation(cropImage, 1);
            
            [[PhocalCore sharedClient] postPhoto:imageData];
            
//            dispatch_async(dispatch_get_main_queue(), ^{
        
                done(cropImage);
                
//            });
//        });
        
//        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
//                                                                    imageDataSampleBuffer,
//                                                                    kCMAttachmentMode_ShouldPropagate);
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
//            if (error) {
//                //                    [self displayErrorOnMainQueue:error withMessage:@"Save to camera roll failed"];
//              return;
//            }
//            
//            NSLog(@"Took picture");
//            
//            
//        }];
        
        
        
        
        
//        if (attachments)
//            CFRelease(attachments);
//        
    }];
}

static inline double radians (double degrees) {return degrees * M_PI/180;}

+(UIImage*)cropImage:(UIImage*)originalImage toRect:(CGRect)rect{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], rect);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    CGContextRef bitmap = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    
    if (originalImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -rect.size.height);
        
    } else if (originalImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -rect.size.width, 0);
        
    } else if (originalImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (originalImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, rect.size.width, rect.size.height);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, rect.origin.y, rect.size.width, rect.size.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    
    UIImage *resultImage=[UIImage imageWithCGImage:ref];
    CGImageRelease(imageRef);
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return resultImage;
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
