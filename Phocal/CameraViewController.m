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

- (void)savePhoto {
    
    
}

- (void)takeImageHandler {
    
    [self takePhoto:^(UIImage *image, CLLocation *location) {
       
        _headerView.backgroundColor = [UIColor blackColor];

        _previewLayer.hidden = YES;

        CGFloat width = image.size.width;
        
        CGFloat scale = width / self.view.frame.size.width;
    
        image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationRight];
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, 1080, 1280));
        image = [UIImage imageWithCGImage:imageRef scale:1280/1080 orientation:UIImageOrientationRight];
        CGImageRelease(imageRef);
        
        _photoPreview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        _photoPreview.image = image;
        _photoPreview.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:_photoPreview];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, 10, 50, 50);
        [button setTitle:@"X" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cancelPhoto) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
        button1.frame = CGRectMake(260, 10, 50, 50);
        [button1 setTitle:@"Save" forState:UIControlStateNormal];
        [button1 addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button1];
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor=[UIColor blackColor];
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
//    session.sessionPreset = AVCaptureSessionPreset640x480; // TODO: should be full qual.
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    _previewLayer.frame = CGRectMake(0, 0, 320, 320 + 40);
    
    _previewLayer.frame = self.view.bounds;
    
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
//    [self.view addSubview:_headerView];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 320, 320, self.view.frame.size.height - 320)];
    container.backgroundColor = [UIColor blackColor];
    [self.view addSubview:container];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
     UIImage *cameraIcon = [UIImage imageNamed:@"cameraButton"];
    [button setImage:cameraIcon forState:UIControlStateNormal];
    button.frame = CGRectMake(130, 350, 60, 60);
//    button.center = CGPointMake(container.frame.size.width / 2, container.frame.size.height / 2);
    [button addTarget:self action:@selector(takeImageHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
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
    
    NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSDictionary *metadata = rep.metadata;
        NSLog(@"%@", metadata);
        
        UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
        
        NSData *imageData = UIImageJPEGRepresentation(image,1.0);
        
        NSLog(@"METADATA %@", metadata);
        
        //[[PhocalCore sharedClient] postPhoto:imageData];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failureBlock:^(NSError *error) {
        // error handling
    }];
    //do something with the image
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

- (void)takePhoto:(void(^)(UIImage *, CLLocation *loc))done {
        
    AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
    
    [[LocationDelegate sharedInstance] refresh:^(CLLocation *loc) {
        
        [_output captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
            NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:jpegData];
            
            [[PhocalCore sharedClient] postPhoto:jpegData withLocation:loc];
            
            done (image, loc);
        
        }];
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
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, rect.size.width, rect.size.height), imageRef);
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

@end
