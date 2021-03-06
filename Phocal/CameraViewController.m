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
#import "PhotosListViewController.h"
#import "UIViewController+Master.h"

#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImage+Resize.h"

@interface CameraViewController () {
    
    BOOL showingBack;
    AVCaptureFlashMode flashMode;
    NSString *flashTitle;
    
}

@property (nonatomic, strong) AVCaptureStillImageOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureDeviceInput *backCameraInput;
@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraInput;
@property (nonatomic, strong) AVCaptureDevice *frontCamera;
@property (nonatomic, strong) AVCaptureDevice *backCamera;
@property (nonatomic, strong) UIImageView *photoPreview;
@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIView *bottomContainer;
@property (nonatomic, strong) UIButton *listButton;
@property (nonatomic, strong) UIButton *takePhoto;
@property (nonatomic, strong) UIButton *uploadThumb;
@property (nonatomic, strong) UIButton *retake;
@property (nonatomic, strong) UIButton *save;

@property (nonatomic, strong) UIButton *flash;
@property (nonatomic, strong) UIButton *flip;

@property (nonatomic, strong) CLLocation *takenLocation;
@property (nonatomic, strong) UIImage *takenPicture;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, retain) UIAlertView* alertView;
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
    _bottomContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_photoPreview removeFromSuperview];
    _previewLayer.hidden = NO;
    
    
    [UIView animateWithDuration:0.25 animations:^{
        
        _flip.alpha = 1;
        _flash.alpha = 1;
        _retake.alpha = 0;
        _save.alpha = 0;
        
        _titleLabel.alpha = 0;
        
        _uploadThumb.alpha = 1;
        _takePhoto.alpha = 1;
        _listButton.alpha = 1;
        
    } completion:^(BOOL finished) {

        [_save removeFromSuperview];
        [_retake removeFromSuperview];
    }];
}

- (void)showSaveModal {
    self.alertView = [[UIAlertView alloc] initWithTitle:nil
                                            message:@"Creating moment..."
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:nil];
    [self.alertView show];
}

- (void)showErroModal {
    self.alertView =
    [[UIAlertView alloc] initWithTitle:@"Upload Error"
                               message:@"Sorry, we couldn't create your Moment! Is your Internet working?"
                              delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [self.alertView show];
}

- (void)showNoGeoModal {
    NSString* msg = @"Sorry, the photo you selected does not have a location. Without a location, we can't make a Moment! Check that your Camera has Location Services turned on in Settings > Privacy > Location Services";
    self.alertView = [[UIAlertView alloc] initWithTitle:@"No Location"
                                                message:msg delegate:nil
                                      cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [self.alertView show];
}

-(void)dismissModal {
    [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)savePhoto {
    
    // Post the photo to the DB right away.
    NSData *data = UIImageJPEGRepresentation(_takenPicture, 0.3);
    [self showSaveModal];
    [[PhocalCore sharedClient] postPhoto:data withLocation:_takenLocation completion:^(NSArray *arr) {
        if (!arr || arr.count == 0) {
            NSLog(@"Upload error.");
            [_photoPreview removeFromSuperview];
            _previewLayer.hidden = NO;
            
            // Take down the save modal and put up an error modal.
            [self dismissModal];
            [self showErroModal];
            return;
        }
        
        _headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _bottomContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [_photoPreview removeFromSuperview];
        _previewLayer.hidden = NO;

        [self.masterViewController displayMoments];
        [self.masterViewController.photosListController addPhotoFromUpload:arr[0]];
        [self dismissModal];
    }];

    [UIView animateWithDuration:0.25 animations:^{
        
        _flip.alpha = 1;
        _flash.alpha = 1;
        _retake.alpha = 0;
        _save.alpha = 0;
        
        _titleLabel.alpha = 0;
        
        _uploadThumb.alpha = 1;
        _takePhoto.alpha = 1;
        _listButton.alpha = 1;
        
    } completion:^(BOOL finished) {
     
        [_save removeFromSuperview];
        [_retake removeFromSuperview];
        
    }];

}

- (void)takeImageHandler {
    
    [self takePhoto:^(UIImage *image, CLLocation *location) {
       
        
        _headerView.backgroundColor = [UIColor colorWithRed:43.0/255 green:43.0/255 blue:43.0/255 alpha:1];
        _bottomContainer.backgroundColor = [UIColor colorWithRed:43.0/255 green:43.0/255 blue:43.0/255 alpha:1];

        _previewLayer.hidden = YES;
        
        image = [image imageCrop:image];
        
        _takenPicture = image;
        _takenLocation = location;
        
        NSInteger yPos = (self.view.frame.size.height - 320) / 2;
        _photoPreview = [[UIImageView alloc] initWithFrame:CGRectMake(0, yPos, 320, 320)];
        _photoPreview.image = image;
        _photoPreview.clipsToBounds = YES;
        _photoPreview.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:_photoPreview];
        
        if (!showingBack) {
            
            CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI), CGAffineTransformMakeScale(1.0, -1.0));
            _photoPreview.transform = transform;
        }
        
        
        _retake = [UIButton buttonWithType:UIButtonTypeCustom];
        _retake.frame = CGRectMake(0, 0, 100, _bottomContainer.frame.size.height);
        _retake.center = CGPointMake(_retake.center.x, _bottomContainer.frame.size.height / 2);
        [_retake setImage:[UIImage imageNamed:@"trash"] forState:UIControlStateNormal];
//        [_retake setTitle:@"Retake" forState:UIControlStateNormal];
        [_retake addTarget:self action:@selector(cancelPhoto) forControlEvents:UIControlEventTouchUpInside];
        _retake.alpha = 0;
        [_bottomContainer addSubview:_retake];
        
        _save = [UIButton buttonWithType:UIButtonTypeCustom];
        _save.frame = CGRectMake(200, 0, 100, _bottomContainer.frame.size.height);
        _save.center = CGPointMake(_save.center.x, _bottomContainer.frame.size.height / 2);
        [_save setImage:[UIImage imageNamed:@"sendPhoto"] forState:UIControlStateNormal];
//        [_save setTitle:@"Save" forState:UIControlStateNormal];
        [_save addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
        _save.alpha = 0;
        [_bottomContainer addSubview:_save];
        
        
        int index = rand() % _titles.count;
        _titleLabel.text = _titles[index];
        NSLog(@"%d", index);
        [UIView animateWithDuration:0.25 animations:^{
           
            _flip.alpha = 0;
            _flash.alpha = 0;
            
            _titleLabel.alpha = 1;
            
            _retake.alpha = 1;
            _save.alpha = 1;
            
            _uploadThumb.alpha = 0;
            _takePhoto.alpha = 0;
            _listButton.alpha = 0;
            
        } completion:^(BOOL finished) {
            
        }];
        
    }];
}

- (void)disableFlash {
    
    [_flash setTitle:@"   Off" forState:UIControlStateNormal];
}

- (void)enableFlash {
    
    [_flash setTitle:flashTitle forState:UIControlStateNormal];
}

- (void)toggleFlash {
    
    if (!showingBack) return;
    
    NSString *title = nil;
    
    if (flashMode == AVCaptureFlashModeAuto) {
        
        flashMode = AVCaptureFlashModeOff;
        title = @"   Off";
    }
    else if (flashMode == AVCaptureFlashModeOff) {
        
        flashMode = AVCaptureFlashModeOn;
        title = @"   On";
    }
    else {
        
        flashMode = AVCaptureFlashModeAuto;
        title = @"   Auto";
    }

    flashTitle = title;
    
    if ([_backCamera isFlashModeSupported:AVCaptureFlashModeAuto])
    {
        NSError *error = nil;
        [_backCamera lockForConfiguration:&error];
        if (!error) [_backCamera setFlashMode:flashMode];
        [_backCamera unlockForConfiguration];
    }

    [_flash setTitle:title forState:UIControlStateNormal];
    
}

- (void)flipView {

    if (showingBack) {
        
        showingBack = NO;
        [_session removeInput:_backCameraInput];
        [_session addInput:_frontCameraInput];
        
        [self disableFlash];
        _flash.enabled = NO;
    }
    else {
        
        showingBack = YES;
        [_session removeInput:_frontCameraInput];
        [_session addInput:_backCameraInput];
        
        [self enableFlash];
        _flash.enabled = YES;
        
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titles = @[@"NICE!", @"GOOD SHOT!", @"ANSEL! IS THAT YOU?", @"NICE ANGLE!", @"YOU ARE A GOD!", @"THE CROWD GOES WILD!", @"NICE PHOCUS... GET IT?", @"CLASSIC!", @"GREAT PIC!", @"CHA CHING!", @"LOOKS GREAT!", @"IMPRESSIVE!", @"DON'T QUIT YOUR DAY JOB!", @"WOW!"];
    
    
    // Do any additional setup after loading the view.
    _session = [[AVCaptureSession alloc] init];
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.bounds;
    
    flashMode = AVCaptureFlashModeAuto;
    showingBack = YES;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            _frontCamera = device;
        }
        if ([device position] == AVCaptureDevicePositionBack) {
            _backCamera = device;
        }
    }
    
    AVCaptureDevice *device = _backCamera;
    if (device) {
        
        if ([_backCamera isFlashModeSupported:AVCaptureFlashModeAuto])
        {
            NSError *error = nil;
            [_backCamera lockForConfiguration:&error];
            if (!error) [_backCamera setFlashMode:flashMode];
            [_backCamera unlockForConfiguration];
        }
        
        NSError *error = nil;
        _backCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:_backCamera error:&error];
        _frontCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:_frontCamera error:&error];
        [_session addInput:_backCameraInput];
        
        _output = [[AVCaptureStillImageOutput alloc] init];
        [_session addOutput:_output];
        
        [_session startRunning];
    }
    
    [self.view.layer addSublayer:_previewLayer];
    
    
    NSInteger size = (self.view.frame.size.height - 320) / 2;
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, size)];
    _headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:_headerView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, _headerView.frame.size.height)];
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.alpha = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLabel];
    
    _flash = [UIButton buttonWithType:UIButtonTypeCustom];
    _flash.frame = CGRectMake(200, 0, 100, _headerView.frame.size.height);
    _flash.center = CGPointMake(_flash.center.x, _headerView.frame.size.height / 2);
    [_flash setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    [_flash setTitle:@"   Auto" forState:UIControlStateNormal];
    [_flash.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [_flash addTarget:self action:@selector(toggleFlash) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_flash];
    
    _flip = [UIButton buttonWithType:UIButtonTypeCustom];
    _flip.frame = CGRectMake(0, 0, 100, _headerView.frame.size.height);
    _flip.center = CGPointMake(_flip.center.x, _headerView.frame.size.height / 2);
    [_flip setImage:[UIImage imageNamed:@"flipCamera"] forState:UIControlStateNormal];
    [_flip addTarget:self action:@selector(flipView) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_flip];
    
    _bottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 320 + size, 320, self.view.frame.size.height - (320 + size))];
    _bottomContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:_bottomContainer];
    
    _takePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    _takePhoto.frame = CGRectMake(0, 0, 70, 70);
    _takePhoto.center = CGPointMake(_bottomContainer.frame.size.width / 2, _bottomContainer.frame.size.height / 2);
    [_takePhoto setImage:[UIImage imageNamed:@"cameraButton"] forState:UIControlStateNormal];
    [_takePhoto addTarget:self action:@selector(takeImageHandler) forControlEvents:UIControlEventTouchUpInside];
    [_bottomContainer addSubview:_takePhoto];
    
    _listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _listButton.frame = CGRectMake(30, 0, 44, 44);
    _listButton.center = CGPointMake(_listButton.center.x, _bottomContainer.frame.size.height / 2);
    [_listButton setImage:[UIImage imageNamed:@"stackedPhoto"] forState:UIControlStateNormal];
    [_listButton addTarget:self action:@selector(showPhotoView) forControlEvents:UIControlEventTouchUpInside];
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
                        [_uploadThumb setImage:rotated forState:UIControlStateNormal];
                        [_uploadThumb addTarget:self action:@selector(showAlbumView) forControlEvents:UIControlEventTouchUpInside];
                        [_bottomContainer addSubview:_uploadThumb];
                        _uploadThumb.contentMode = UIViewContentModeScaleAspectFit;
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

- (void)showPhotoView
{
    [self.masterViewController displayMoments];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    [self presentViewController:_imagePicker animated:YES completion:nil];
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
        CLLocation *loc = [asset valueForProperty:ALAssetPropertyLocation];
        
        if (!loc) {
            [self showNoGeoModal];
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
        NSData *imageData = UIImageJPEGRepresentation(image,1.0);
        
        [self showSaveModal];
        [[PhocalCore sharedClient] postPhoto:imageData withLocation:loc completion:^(NSArray *arr) {
            if (!arr || arr.count == 0) {
                NSLog(@"Upload error.");
                [_photoPreview removeFromSuperview];
                _previewLayer.hidden = NO;
                
                // Take down the save modal and put up an error modal.
                [self dismissModal];
                [self showErroModal];
                return;
            }
            
            [self.masterViewController displayMoments];
            [self.masterViewController.photosListController addPhotoFromUpload:arr[0]];
            [self dismissModal];
        }];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failureBlock:^(NSError *error) {
        // error handling
    }];
    //do something with the image
}

-(void)showAlbumView
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
    
    _takePhoto.enabled = NO;
    AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
    
    [[LocationDelegate sharedInstance] refresh:^(CLLocation *loc) {
        
        [_output captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
            _takePhoto.enabled = YES;
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
