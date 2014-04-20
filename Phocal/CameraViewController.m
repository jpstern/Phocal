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


@property (nonatomic, strong) UIView *bottomContainer;
@property (nonatomic, strong) UIButton *listButton;
@property (nonatomic, strong) UIButton *takePhoto;
@property (nonatomic, strong) UIButton *uploadThumb;
@property (nonatomic, strong) UIButton *retake;
@property (nonatomic, strong) UIButton *save;

@property (nonatomic, strong) CLLocation *takenLocation;
@property (nonatomic, strong) UIImage *takenPicture;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

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
    
    [UIView animateWithDuration:0.25 animations:^{
        
        _retake.alpha = 0;
        _save.alpha = 0;
        
        _uploadThumb.alpha = 1;
        _takePhoto.alpha = 1;
        _listButton.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)savePhoto {
    
    [_photoPreview removeFromSuperview];
    _previewLayer.hidden = NO;

    [UIView animateWithDuration:0.25 animations:^{
        
        _retake.alpha = 0;
        _save.alpha = 0;
        
        _uploadThumb.alpha = 1;
        _takePhoto.alpha = 1;
        _listButton.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
    
    NSData *data = UIImageJPEGRepresentation(_takenPicture, 0.3);
    
    [[PhocalCore sharedClient] postPhoto:data withLocation:_takenLocation];
}

- (void)takeImageHandler {
    
    [self takePhoto:^(UIImage *image, CLLocation *location) {
       
        _headerView.backgroundColor = [UIColor blackColor];

        _previewLayer.hidden = YES;

        CGFloat width = image.size.width;
        
        CGFloat scale = width / self.view.frame.size.width;
    
        image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationRight];
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, 1280, 1280));
//        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, 1080, 1280));
        image = [UIImage imageWithCGImage:imageRef scale:1280/1080 orientation:UIImageOrientationRight];
        CGImageRelease(imageRef);
        
        _takenPicture = image;
        _takenLocation = location;
        
        _photoPreview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        _photoPreview.image = image;
        _photoPreview.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:_photoPreview];
        
        
        
        _retake = [UIButton buttonWithType:UIButtonTypeCustom];
        _retake.frame = CGRectMake(10, 10, 100, 50);
        [_retake setTitle:@"Retake" forState:UIControlStateNormal];
        [_retake addTarget:self action:@selector(cancelPhoto) forControlEvents:UIControlEventTouchUpInside];
        _retake.alpha = 0;
        [_bottomContainer addSubview:_retake];
        
        _save = [UIButton buttonWithType:UIButtonTypeCustom];
        _save.frame = CGRectMake(210, 10, 100, 50);
        [_save setTitle:@"Save" forState:UIControlStateNormal];
        [_save addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
        _save.alpha = 0;
        [_bottomContainer addSubview:_save];
        
        [UIView animateWithDuration:0.25 animations:^{
           
            _retake.alpha = 1;
            _save.alpha = 1;
            
            _uploadThumb.alpha = 0;
            _takePhoto.alpha = 0;
            _listButton.alpha = 0;
            
        } completion:^(BOOL finished) {
            
        }];
        
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
//    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
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
    
    _bottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 320, 320, self.view.frame.size.height - 320)];
    _bottomContainer.backgroundColor = [UIColor colorWithRed:43/255.0 green:43/255.0 blue:43/255.0 alpha:1];
    [self.view addSubview:_bottomContainer];
    
    _takePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
     UIImage *cameraIcon = [UIImage imageNamed:@"cameraButton"];
    [_takePhoto setImage:cameraIcon forState:UIControlStateNormal];
    _takePhoto.frame = CGRectMake(0, 0, 85, 85);
    _takePhoto.center = CGPointMake(_bottomContainer.frame.size.width / 2, _bottomContainer.frame.size.height / 2);
    [_takePhoto addTarget:self action:@selector(takeImageHandler) forControlEvents:UIControlEventTouchUpInside];
    [_bottomContainer addSubview:_takePhoto];
    
    _listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *photoIcon = [UIImage imageNamed:@"back_arrow"];
    
    _listButton.frame = CGRectMake(30, 0, 44, 44);
    _listButton.center = CGPointMake(_listButton.center.x, _bottomContainer.frame.size.height / 2);
    _listButton.tintColor = [UIColor whiteColor];
    
    [_listButton setImage:photoIcon forState:UIControlStateNormal];
    [_listButton addTarget:self action:@selector(photoView) forControlEvents:UIControlEventTouchUpInside];
    [_bottomContainer addSubview:_listButton];
    
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
                        UIImage *rotated = [UIImage imageWithCGImage:uploadIcon.CGImage scale:1 orientation:UIImageOrientationRight];
                        _uploadThumb = [UIButton buttonWithType:UIButtonTypeCustom];
                        [_uploadThumb setBackgroundImage:rotated forState:UIControlStateNormal];
                        [_uploadThumb addTarget:self action:@selector(albumView) forControlEvents:UIControlEventTouchUpInside];
                        [_bottomContainer addSubview:_uploadThumb];
                        _uploadThumb.adjustsImageWhenHighlighted = NO;
                        _uploadThumb.frame = CGRectMake(240, 0, 60, 60);
                        _uploadThumb.layer.cornerRadius = 8.0f;
                        _uploadThumb.clipsToBounds = YES;
                        _uploadThumb.layer.masksToBounds = YES;
                        _uploadThumb.center = CGPointMake(_uploadThumb.center.x, _bottomContainer.frame.size.height / 2);

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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    });
    
   // uploadViewButton.tintColor = [UIColor whiteColor];
    
    //    [photoViewButton setTitle:@"Photos" forState:UIControlStateNormal];
    
    
}

- (void)photoView
{
    [[(MasterViewController*)_master masterScroll] setContentOffset:CGPointMake(0,0) animated:YES];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSDictionary *metadata = rep.metadata;
        
        UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
        
        NSData *imageData = UIImageJPEGRepresentation(image,1.0);
        
        NSLog(@"METADATA %@", metadata);
        
        //[[PhocalCore sharedClient] postPhoto:imageData];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failureBlock:^(NSError *error) {
        // error handling
    }];
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

- (void)takePhoto:(void(^)(UIImage *, CLLocation *loc))done {
        
    AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
    
    [[LocationDelegate sharedInstance] refresh:^(CLLocation *loc) {
        
        [_output captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
            NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:jpegData];
            
//            [[PhocalCore sharedClient] postPhoto:jpegData withLocation:loc];
            
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
