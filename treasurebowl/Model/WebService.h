//
//  WebService.h
//  treasurebowl
//
//  Created by AtSu on 2015/5/19.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallPackage.h"
#import "Macro.h"

@class Icon;
@class UIImage;
@protocol WebserviceDelegate
// Protocol method.
// delegate needs to implement this.
- (void)getCardInfoReturn:(CallPackage*)call_data ErrorStatus:(int)errorCode;
- (void)callComplete:(int) errorCode;
- (void)createNewCardComplete:(Card*)newCard ErrorStatus:(int)errorCode;
- (void)createShortcutReturn:(NSString*) url ErrorStatus:(int)errorCode;
- (void)createQRCodeURLReturn:(NSString*) url ErrorStatus:(int)errorCode;
- (void)getQRCodePictureReturn:(UIImage*) img ErrorStatus:(int)errorCode;
-(void)storeQRIcon:(Icon*) icon imgData:(NSData*) image;

@end

@interface WebService : NSObject

typedef enum connectionType {
    non = 0,
    getCard,
    calling,
    createCard,
    createIconShortcut,
    createQRCodeURL,
    getQRCodeData,
    requestCSRF,
} ConnectionType;

typedef enum errorCode {
    success = 0,
    getCardFailed,
    getCardFailed_notExist,
    getCardFailed_notEnough,
    callingFailed,
    callingFailed_server,
    createCardFailed,
    createCardFailed_server,
    createIconShortcutFailed_unknown,
    createIconShortcutFailed_server,
    connectionFailed
} ErrorCode;

@property(nonatomic)CallPackage* call_data;
@property(nonatomic)Card* created_card;
@property(nonatomic)NSString* shortcut_waiting_url;
@property(nonatomic)NSString* qrcode_waiting_url;
@property(nonatomic)NSInteger qrcode_data_len;
@property(nonatomic)ConnectionType currentConnection;
@property(nonatomic)ErrorCode errorStatus;
@property(nonatomic)NSString* csrf_token;

+ (WebService*)getSharedInstance; // only need one Webservice Manager.

- (void)call:(id<WebserviceDelegate>)delegate CallPkg:(CallPackage*) callPkg;
- (void)tryMakeCall:(id<WebserviceDelegate>)delegate Icon:(Icon*) icon;
- (void)getCardInfo:(id<WebserviceDelegate>)delegate CallPkg:(CallPackage*) callPkg;
- (void)createCard:(id<WebserviceDelegate>)delegate initPoint:(double)initPoint;
- (void)createIconShortcut:(id<WebserviceDelegate>)delegate Icon:(Icon*) icon;
- (void)createQRCodeURL:(id<WebserviceDelegate>)delegate Icon:(Icon*) icon;
- (void)getOriginalPicture:(id<WebserviceDelegate>)delegate PictureName:(NSString*) picName Icon:(Icon*) icon;
- (void)getQRcodePicture:(id<WebserviceDelegate>)delegate URL:(NSString*) url;
- (void)requestCSRFToken;

+ (BOOL)webStatusCheck;
+ (NSData*)AESEncryptData:(NSData*)data WithKey:(NSString*) key;
+ (NSString*)createGetCardInfoEnvelope:(NSString*) cardID; // for create SOAPAction Envelope
+ (NSString*)createCreateCardEnvelope:(NSString*)cardID initPoint:(double) initPoint;
+ (NSString*)generateCardID;
+ (NSString*)generateQRCodePostfix;
+ (NSString*)generateShortcutUrl:(NSString*)param Name:(NSString*)icon;
+ (void)openShorcutUrlInSafari:(NSString*)url;
+ (NSString*)getCSRFFromCookie;

- (BOOL)shareToFacebook:(UIImage*) image;
- (BOOL)shareToLine:(UIImage*) image;
@end
