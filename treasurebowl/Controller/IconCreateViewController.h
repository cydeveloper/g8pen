//
//  CashViewController.h
//  treasurebowl
//
//  Created by AtSu on 2015/7/13.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebService.h"
@import AVFoundation;
@interface IconCreateViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, WebserviceDelegate ,AVCaptureMetadataOutputObjectsDelegate ,
    UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *SelectImage;

@property (strong, nonatomic) IBOutlet UITextField *text_cardID;
@property (strong, nonatomic) IBOutlet UITextField *text_name;

@property (strong, nonatomic) IBOutlet UILabel *label_cardID;
@property (strong, nonatomic) IBOutlet UILabel *label_name;

@property (strong, nonatomic) IBOutlet UIButton *buttonSubmit;
@property (strong, nonatomic) IBOutlet UIButton *buttonQRSubmit;

@property (weak, nonatomic) IBOutlet UIButton *buttonScan;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;
-(void)storeQRIcon:(Icon*) icon imgData:(NSData*) image;
-(void)menuButtonPressed;
@end