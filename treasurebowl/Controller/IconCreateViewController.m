//
//  CashViewController.m
//  treasurebowl
//
//  Created by AtSu on 2015/7/13.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "IconCreateViewController.h"
#import "ViewController.h"
#import "AppStateManager.h"
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ZXingObjC.h>
#import "Util.h"
@interface IconCreateViewController ()

@property (strong, nonatomic) UIImagePickerController* imagePicker;
@property (weak, nonatomic) NSString *curSeq;

@end

@implementation IconCreateViewController

NSInteger currentSeq;

//user default
NSString *PHONE;
NSString *CARD_ID = @"1503111003100606";
//MyIcon folder index
int MYGROUP = 1;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAVD];
    
    // initialize ImagePicker
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)];
    [self.SelectImage setUserInteractionEnabled:YES];
    [self.SelectImage addGestureRecognizer:singleTap];
    
    [self hideAllUI];
    
    PHONE = [AppStateManager getSharedInstance].block_userphone;
    if([PHONE length]==0)DE_LOG("fuck you give me your phone");
    
    //get te sequence to know where the icon should locate
    currentSeq = [_curSeq integerValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imageTap {
    
    // try to create imagePicker
    if(!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        
        // If resource is currently not accessible
        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            NSLog(@"Error occur when tapping image");
            
            // should pop up some alerts
            return;
        }
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [_imagePicker setDelegate:self];
    }
    
    // start imagePicker
    [self presentViewController:_imagePicker animated:YES completion:NULL];
}


#pragma mark imagePickerControllerDelegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* newImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    // Display image on ImageView
    [self.SelectImage setImage:newImage];
    
    // return to original viewController
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self hideAllUI];
    [self checkQRcode];
}

#pragma mark itemPressed_action

- (IBAction)submitPressed {
    
    [self submit];
}


- (IBAction)qrsubmitPressed:(UIButton *)sender {
    
    //already store so just back to main menu
    UICollectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mainMenu"];
    [self showDetailViewController:vc sender:self];
}


- (IBAction)scanButtonPressed:(UIButton *)sender {
    if(![_session isRunning]){
        //[sender setTitle: @"STOP SCAN" forState:UIControlStateNormal];
        [self.view.layer addSublayer:_previewLayer];
        [_session startRunning];
    }
    else {
        //[sender setTitle: @"Start Scan" forState:UIControlStateNormal];
        [_previewLayer removeFromSuperlayer];
        [_session stopRunning];
    }
    
}

-(IBAction)backButtonPressed:(UIButton*)sender{
    DE_LOG("Return to main");
    [self dismissViewControllerAnimated:YES completion:^{}];
}

//check the input info and card then waiting for return to store icon
-(void)submit{
    if(![WebService webStatusCheck]) {
        ALERT_DEVICE_NOT_CONNECTED;
        return;
    }
    
    if(![_text_cardID hasText] || ![_text_name hasText]) {
        [Util makeAlertWithTitle: LOCAL("Oops!")
                      andMessage: LOCAL("Please at least tell us the CardID and the Name.")
                         withTag: normal_alert
                        Delegate: self];
        return;
    }
    
    WebService* webservice = [WebService getSharedInstance];
    Card* submitCard = [[Card alloc] init:_text_cardID.text Status:nil CurrentPoints:0];
    CallPackage* submitPkg = [[CallPackage alloc] initWithCard:submitCard];
    
    [webservice getCardInfo:self CallPkg:submitPkg];
    [Util makeHUDWithTitle: LOCAL("Creating icon for you") andMessage: @"" toView: self.view];
}


#pragma mark WebserviceDelegate method

- (void)getCardInfoReturn:(CallPackage *)call_data ErrorStatus:(int)errorCode {
    
    [WebService getSharedInstance].currentConnection = non; // clear connection state
    
    if(errorCode == getCardFailed_notExist) {
        [Util makeAlertWithTitle: LOCAL("Oops!")
                      andMessage: LOCAL("The card you offer does not exits, please make sure if you have entered the correct card ID.")
                         withTag: normal_alert
                        Delegate: self];
        [Util stopHUD];
        return;
    }
    
    if(errorCode == getCardFailed_notEnough) {
        [Util makeAlertWithTitle: LOCAL("Oops!")
                      andMessage: LOCAL("The card you offer does not have enough cash!")
                         withTag: normal_alert
                        Delegate: self];
        [Util stopHUD];
        return;
    }
    
    if([call_data.card.status isEqualToString:@"SUCCESS"]) {
        [[AppStateManager getSharedInstance] addNewCard:call_data.card];
        [self storeIcon];
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

#pragma mark privateImageStore method
//create an icon include self phone number and keep phone2 empty
- (void)storeIcon {
    UIImage* image = _SelectImage.image;
    NSString* icon_name = _text_name.text;
    NSString* card_ID = _text_cardID.text;
    
    NSMutableArray* phone_array = [[NSMutableArray alloc] init];
    [phone_array addObject: PHONE];
    
    // create Image
    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filePath = [[path objectAtIndex:0] stringByAppendingString:
                          [NSString stringWithFormat:@"/%@", icon_name]];
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    AppStateManager* appMgr = [AppStateManager getSharedInstance];
    
    //create new icon and put into MyIcon folder
    Icon* icon = [[Icon alloc] initWithCardID:card_ID IconID:-1 IconURL:filePath shortcutUrl:nil TotNum:1 PhoneNum:phone_array Name:icon_name Sequence:currentSeq GroupID:-1 Group:nil];
    [appMgr addNewIcon: icon toGroup: [appMgr getGroupByID:MYGROUP]];
    [Util stopHUD];
    
    NSLog(@"name = %@ URL = %@" , icon.name  , icon.icon_url );
    
    //return to main menu
    UICollectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mainMenu"];
    [self showDetailViewController:vc sender:self];
}

//parse the receive qrcode and add self phone number then create icon
-(void)retrieveQRIcon:(NSString*)data{
    NSArray *tmpArray = [data componentsSeparatedByString:@","];
    NSString* card_ID = tmpArray[0];
    NSString* phone_1 = tmpArray[1];
    NSString* phone_2 = PHONE;
    NSString* icon_name = tmpArray[3];
    NSString* picture_name = tmpArray[4];
    
    NSMutableArray* phone_array = [[NSMutableArray alloc] init];
    [phone_array addObject: phone_1];
    [phone_array addObject: phone_2];
    
    //here may be modified to get the source picture of icon from server
    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filePath = [[path objectAtIndex:0] stringByAppendingString:icon_name];
    [UIImagePNGRepresentation(_SelectImage.image) writeToFile:filePath atomically:YES];

    
    
    Icon* icon = [[Icon alloc] initWithCardID:card_ID IconID:-1 IconURL:filePath shortcutUrl:nil TotNum:2 PhoneNum:phone_array Name:icon_name Sequence:currentSeq GroupID:-1 Group:nil];
    [[WebService getSharedInstance] getOriginalPicture:self PictureName:picture_name Icon:icon];
    
    //[appMgr addNewIcon:icon toGroup:nil];
    
    //NSLog(@"P1 = %@ , P2 = %@\n", icon.phone_num[0] , icon.phone_num[1]);
    
    //_buttonQRSubmit.alpha = 1 ;
}

-(void)storeQRIcon:(Icon*) icon imgData:(NSData*) image {
    AppStateManager* appMgr = [AppStateManager getSharedInstance];
    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filePath = [[path objectAtIndex:0] stringByAppendingPathComponent:icon.name];
    UIImage* UI_image = [UIImage imageWithData:image];
    _SelectImage.image = UI_image;
    [UIImagePNGRepresentation(UI_image) writeToFile:filePath atomically:YES];
    DE_LOG("%@ path %@", filePath, icon.name);
    icon.icon_url = filePath;
    [appMgr addNewIcon:icon toGroup:nil];
    _buttonQRSubmit.alpha = 1;
}

#pragma mark private UI method
//check is QRcode or not to show different UI
-(void)checkQRcode{
    CGImageRef imageToDecode = _SelectImage.image.CGImage;
    
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode] ;
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    //if it's a qrcode , store directly , else show create icon UI for user
    if (result) {
        NSString *contents = result.text;
        NSLog(@"qrcode : %@" , contents);
        [self retrieveQRIcon:contents];
        
    } else {
        NSLog(@"qrcode can't decode");
        
        [self showCreateUI];
    }
    
}


-(void)hideAllUI{
    _text_cardID.alpha = 0;
    _text_name.alpha = 0;
    _label_cardID.alpha = 0;
    _label_name.alpha = 0;
    _buttonSubmit.alpha = 0;
    _buttonQRSubmit.alpha = 0;
}

-(void)showCreateUI{
    _text_cardID.text = CARD_ID;
    _text_cardID.alpha = 1;
    _text_name.alpha = 1;
    _label_cardID.alpha = 1;
    _label_name.alpha = 1;
    _buttonSubmit.alpha = 1;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

-(void)initAVD{
    _session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    
    // Display full screen
    _previewLayer.frame = CGRectMake(0, -150 ,320,480);
    
    // Add the video preview layer to the view
    //[self.view.layer addSublayer:_previewLayer];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (input) {
        [_session addInput:input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:output];
    
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code]];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    NSString *QRCode = nil;
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            QRCode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            break;
        }
    }
    [_session stopRunning];
    [_previewLayer removeFromSuperlayer];
    
    NSLog(@"QR Code: %@", QRCode);
    [self retrieveQRIcon:QRCode];
    
}



@end
