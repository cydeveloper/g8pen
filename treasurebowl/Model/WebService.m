//
//  WebService.m
//  treasurebowl
//
//  Created by AtSu on 2015/5/19.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "WebService.h"
#import "XMLParser.h"
#import "Icon.h"
#import "Base64.h"
#import "Reachability.h"
#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import "UIImage+Resize.h"
#import "DBManager.h"
static WebService* web_service = nil;

static NSString* url_call = @"http://140.114.79.112/call.php?ac="; // base Url for calling

static NSString* CARD_WSDK = @"http://ts.kits.tw/6talkWS/services/CardServiceImpl?wsdl"; // WebService Description Languag
static NSString* CARD_TARGET_NAMESPACE = @"http://impl.service.card.talk";
static NSString* CARD_APIKEY = @"ABE66E483DDD4CFFBF766826C842DE6446CCA2F7"; // API key
static NSString* CARD_FUNC_GETCARDINFO = @"getCardInfo"; // soap function
static NSString* CARD_FUNC_CREATECARD = @"createNewCard";
static NSString* SOAP_ACTION_GETCARDINFO = @"http://ts.kits.tw/6talkWS/services/CardServiceImpl/getCardInfo"; // soap action for get card
static NSString* SOAP_ACTION_CREATECARD = @"http://ts.kits.tw/6talkWS/services/CardServiceImpl/createNewCard";
static NSString* TREASUREBOWL_SHORTCUT_SERVER = @"http://130.211.250.248:80/icons/";
static NSString* TREASUREBOWL_QRCODE_SERVER = @"http://140.114.79.112:8000/icon/qrcodes/";
static NSString* TREASUREBOWL_CSRF_SERVER = @"http://140.114.79.112:8000/qrcodetest";
static NSString* TREASUREBOWL_ICON_URL_BASE = @"http://140.114.79.112:8000/media/pic/";
static NSString* TREASUREBOWL_QRCODE_URL_BASE = @"http://140.114.79.112:8000/media/pic/qrcode_";
static NSString* AESKEY = @"thisistreasureshthisistreasuresh";


@implementation WebService {
    __weak id<WebserviceDelegate> _delegate;
}

/*   Class : WebService
 *   A sharedInstance, mainly use for networking activities
 */
+ (WebService*)getSharedInstance {
    if(!web_service) {
        // web service instance not create
        web_service =[[WebService alloc] init];
    }
    web_service.currentConnection = non;
    web_service.errorStatus = success;
    if(!web_service.csrf_token)
        [web_service requestCSRFToken];
    
    return web_service;
}

#pragma mark Calling method

/**
 * call - call server API to make phone call
 * @delegate: the delegation view controller we will inform later
 * @callPkg: contains the card that use to call, and the phone numbers that will be called later
 *
 * Compose cardID, and two (or more) phone number together, and send the composed string to server API as parameter.
 * The phone call will come after about 1 - 4 sec.
 */


- (void)call:(id<WebserviceDelegate>) delegate CallPkg:(CallPackage *)callPkg{
    
    // Add component to Array, and use method to concatenate them into a string
    NSArray* param = [[NSArray alloc] initWithObjects: callPkg.card.cardID,
                      @"&from=", [callPkg.phoneArray objectAtIndex:0], @"&to=", [callPkg.phoneArray objectAtIndex:1], nil];
    
    NSString* url = [url_call stringByAppendingString:[param componentsJoinedByString:@""]];
    
    DE_LOG("Preparing to send request to server.");
    
    AFHTTPRequestOperationManager* op = [AFHTTPRequestOperationManager manager];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // directly launch a HTTP GET request.
    [op GET:url parameters:NULL success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // call success
        [delegate callComplete: success];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // connection failed
        DE_LOG("resp %@", operation.responseString);
        [delegate callComplete: connectionFailed];
    }];
}

/**
 * tryMakeCall - first step of calling process, create a callPkg to transfer data.
 * @delegate: the delegation view controller we will inform later
 * @icon: the icon that trigger the call method.
 *
 * This method will take out essential information for connection, and pack it into callPkg
 */


- (void)tryMakeCall:(id<WebserviceDelegate>)delegate Icon:(Icon *)icon {
    
    // Create Call Pkg here //
    Card* card = [[Card alloc] init:icon.card_ID Status:NULL CurrentPoints:0];
    CallPackage* callPkg = [[CallPackage alloc] initWithCard:card PhoneArray:icon.phone_num DoCall:YES];
    WebService* web_service = [WebService getSharedInstance];
    [web_service getCardInfo:delegate CallPkg:callPkg];
}

#pragma mark Card Method


/**
 * getCardInfo - Get Card info from server.
 * @delegate: the delegation view controller we will inform later
 * @callPkg: contain the cardID and phone number. Only the CardID will be used in this method
 *
 * Get card info to check whether the card is valid to use. The delegation method will check if
 * we need to make phone call after the card info received.
 */
- (void)getCardInfo:(id<WebserviceDelegate>)delegate CallPkg:(CallPackage *)callPkg {
    
    _call_data = callPkg;
    _errorStatus = success;
    
    NSString* soapMsg = [WebService createGetCardInfoEnvelope: _call_data.card.cardID];
    
    NSURL* url = [NSURL URLWithString:CARD_WSDK];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    NSString* msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]];
    
    // set a HTTP POST request data.
    [request setHTTPMethod: @"POST"];
    [request addValue: @"application/soap+xml; charset=utf-8" forHTTPHeaderField: @"Content-Type"];
    [request addValue: msgLength forHTTPHeaderField: @"Content-Length"];
    [request addValue: SOAP_ACTION_GETCARDINFO forHTTPHeaderField: @"SOAPAction"];
    [request setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    // init op with request
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest: request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // set completion callback function
    // this part is different from the 'call' function
    // because the AFNetworking POST request is more complicate than GET.
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData* data = [operation responseData];
        NSDictionary* JsonObj = [XMLParser JSONForXMLData:data Error:nil];
        DE_LOG("%@", [JsonObj description]);
        
        _call_data.card.status = [JsonObj objectForKey:@"status"];
        _call_data.card.currentPoints = [[JsonObj objectForKey:@"currentPoint"] floatValue];
        
        if(![_call_data.card.status isEqualToString:@"SUCCESS"]) {
            C_FAIL_CUZ("getCard", "not exits");
            _errorStatus = getCardFailed_notExist;
        } else if(_call_data.card.currentPoints <= 0) {
            C_FAIL_CUZ("getCard", "not enough money");
            _errorStatus = getCardFailed_notEnough;
        }
        
        [delegate getCardInfoReturn: _call_data ErrorStatus: _errorStatus];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DE_LOG("resp %@", operation.responseString);
        [delegate getCardInfoReturn: nil ErrorStatus: connectionFailed];
    }];
    
    // launch HTTP POST request with callback block.
    [op start];
    
}

/**
 * createCard - create a cardID by sending request to SOAP server
 * @delegation: the delegation view controller we will inform later
 * @initPoint: the points the new card will contain
 *
 * This method should be called after retrieve receipt from PayPal ... etc
 *
 * WARNING: the create card flow are not complete yet, IT SHOULD RETRY WHEN THE CONNECTION FAILED
 */

- (void)createCard:(id<WebserviceDelegate>)delegate initPoint:(double)initPoint {
    
    _created_card = [[Card alloc] init:[WebService generateCardID] Status:NULL CurrentPoints:initPoint];
    _errorStatus = success;
    
    NSString* soapMsg = [WebService createCreateCardEnvelope: _created_card.cardID initPoint: initPoint];
    
    NSURL* url = [NSURL URLWithString:CARD_WSDK];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    NSString* msgLength = [NSString stringWithFormat: @"%lu", (unsigned long)[soapMsg length]];
    
    [request setHTTPMethod: @"POST"];
    [request addValue: @"application/soap+xml; charset=utf-8" forHTTPHeaderField: @"Content-Type"];
    [request addValue: msgLength forHTTPHeaderField: @"Content-Length"];
    [request addValue: SOAP_ACTION_CREATECARD forHTTPHeaderField: @"SOAPAction"];
    [request setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    // init op with request.
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest: request];
    
    // set op completion callback block.
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData* data = [operation responseData];
        NSDictionary* JsonObj = [XMLParser JSONForXMLData:data Error:nil];
        
        JsonObj = [XMLParser JSONForXMLData:data Error:nil];
        _created_card.status = [JsonObj objectForKey:@"status"];
        
        if(![_created_card.status isEqualToString:@"SUCCESS"]) {
            _errorStatus = createCardFailed;
        }
        
        [delegate createNewCardComplete: _created_card ErrorStatus: _errorStatus];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        C_FAIL("CreateCard");
        [delegate createNewCardComplete: nil ErrorStatus: _errorStatus];
    }];
    
    // launch HTTP POST request
    [op start];
}

#pragma mark Icon methods

/**
 * createIconShortcut - post the icon info to the python server to create a webpage for it.
 * @delegate: the delegation view controller that we will inform later
 * @icon: the icon which needs to create a shortcut
 *
 * This method can only create shortcut when phone isn't empty.
 * WARNING: this method is not complete yet, and need to be include into create Icon method.
 *          Also, the encryption part and decryption still not complete yet.
 */

- (void)createIconShortcut:(id<WebserviceDelegate>)delegate Icon:(Icon *)icon {
    
    _errorStatus = success;
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: TREASUREBOWL_SHORTCUT_SERVER]];
    NSData* imageData = UIImagePNGRepresentation([[icon getImage] resizedImage: CGSizeMake(64, 64) interpolationQuality: kCGInterpolationMedium]);
    
    // Base64 help encoding image as jsonString
    // You can only put image data in json object with Base64 form
    [Base64 initialize];
    
    NSString* imageString = [Base64 encode:imageData];
    NSString* shortcut_url = [WebService generateShortcutUrl: imageString Name: icon.name];
    NSString* phone_str = [DBManager splitArrayToText:icon.phone_num];
    
    // put infomation in key / object mapping
    NSArray* key = [NSArray arrayWithObjects: @"icon_id", @"icon_name", @"card_ID", @"shortcut_url", @"icon_image", @"icon_phones", @"icon_card", nil];
    NSArray* obj = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%ld", icon.icon_ID], icon.name, icon.card_ID, shortcut_url, imageString, phone_str, icon.card_ID, nil];
    NSDictionary* jsonDic = [NSDictionary dictionaryWithObjects: obj forKeys: key];
    NSError* error;
    // turn dictionary into JSON format and encrypt
    NSData* jsonObject = [NSJSONSerialization dataWithJSONObject:jsonDic options:kNilOptions error:&error];
    NSData* jsonEncrypt = [WebService AESEncryptData:jsonObject WithKey:AESKEY];
    
    _shortcut_waiting_url = shortcut_url;
    
    
    [request setHTTPMethod:@"POST"];
    [request addValue:[NSString stringWithFormat:@"%ld", [jsonObject length]] forHTTPHeaderField:@"CLEN"];
    [request addValue: @"application/json" forHTTPHeaderField: @"Accept"];
    [request addValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody: jsonEncrypt];
    
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest: request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(![operation.responseString isEqualToString:@"Success"]) {
            C_FAIL_CUZ("createIconShortcut", "server problem");
            _errorStatus = createIconShortcutFailed_server;
        }
        
        [delegate createShortcutReturn: _shortcut_waiting_url ErrorStatus: _errorStatus];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DE_LOG("resp %@", operation.responseString);
        [delegate createShortcutReturn: _shortcut_waiting_url ErrorStatus: connectionFailed];
    }];
    
    // launch HTTP POST request
    [op start];
}

- (void)createQRCodeURL:(id<WebserviceDelegate>)delegate Icon:(Icon *)icon {
    
    AFHTTPRequestOperationManager *httpManager = [AFHTTPRequestOperationManager manager];
    [httpManager.requestSerializer setValue:_csrf_token forHTTPHeaderField:@"X-CSRFToken"];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSData* imageData = UIImagePNGRepresentation([[icon getImage] resizedImage: CGSizeMake(128, 128) interpolationQuality: kCGInterpolationMedium]);
    NSString* imagename = [NSString stringWithFormat:@"%@%@.png", icon.name, [WebService generateQRCodePostfix]];
    [httpManager POST:TREASUREBOWL_QRCODE_SERVER parameters: nil constructingBodyWithBlock:^(id<AFMultipartFormData> formdata){
        NSString* phone_1 = @"";
        NSString* phone_2 = @"";
        
        if([icon.phone_num objectAtIndex:0]) {
            phone_1 = [icon.phone_num objectAtIndex:0];
        }
        
        if(icon.total_number >= 2 && [icon.phone_num objectAtIndex:1]) {
            phone_2 = [icon.phone_num objectAtIndex:1];
        }
        
        [formdata appendPartWithFileData:imageData name:@"iconfile" fileName: imagename mimeType:@"image/*"];
        [formdata appendPartWithFormData:[icon.card_ID dataUsingEncoding:NSUTF8StringEncoding] name:@"cardnumber"];
        [formdata appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"friendemail"];
        [formdata appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"friendname"];
        [formdata appendPartWithFormData:[phone_1 dataUsingEncoding:NSUTF8StringEncoding] name:@"yourphone"];
        [formdata appendPartWithFormData:[icon.name dataUsingEncoding:NSUTF8StringEncoding] name:@"name"];
        [formdata appendPartWithFormData:[phone_2 dataUsingEncoding:NSUTF8StringEncoding] name:@"friendphone"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* return_url = [NSString stringWithFormat:@"%@%@", TREASUREBOWL_QRCODE_URL_BASE, imagename];
        DE_LOG("Generating QRCode done");
        
        DE_LOG("name %@", imagename);
        [delegate createQRCodeURLReturn: return_url ErrorStatus:success];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DE_LOG("resp %@", operation.responseString);
        NSLog(@"Error: %@", error);
        [delegate createQRCodeURLReturn: NULL ErrorStatus: connectionFailed];
    }];
}

- (void)getOriginalPicture:(id<WebserviceDelegate>)delegate PictureName:(NSString *)picName Icon:(Icon*) icon {
    NSString* targetURL = [NSString stringWithFormat:@"%@%@", TREASUREBOWL_ICON_URL_BASE, picName];
    AFHTTPRequestOperationManager *op = [AFHTTPRequestOperationManager manager];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    DE_LOG("send %@", targetURL);
    [op GET: targetURL parameters:NULL success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData* data = responseObject;
        //DE_LOG("%@",data);
        [delegate storeQRIcon:icon imgData:data];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DE_LOG("failed!");

    }];

}

- (void)getQRcodePicture:(id<WebserviceDelegate>)delegate URL:(NSString*) url {
    AFHTTPRequestOperationManager *op = [AFHTTPRequestOperationManager manager];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op GET:url parameters:NULL success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData* data = responseObject;
        UIImage* image = [UIImage imageWithData:data];

        [delegate getQRCodePictureReturn:image ErrorStatus:success];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DE_LOG("GET CSRF FAILED!");
        DE_LOG("%@", error);
        DE_LOG("%@", operation.responseString);
        [delegate getQRCodePictureReturn:nil ErrorStatus:connectionFailed];

    } ];
}


- (void)requestCSRFToken {
    AFHTTPRequestOperationManager *op = [AFHTTPRequestOperationManager manager];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    [op GET: TREASUREBOWL_CSRF_SERVER parameters:NULL success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString* cookie = [operation.response.allHeaderFields  objectForKey:@"Set-Cookie"];
        NSString* extract = [[[[cookie componentsSeparatedByString:@";"] objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1]; // extract from other value
        DE_LOG("Request CSRF");
        DE_LOG("%@", extract);
        _csrf_token = extract;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DE_LOG("GET CSRF FAILED!");
        DE_LOG("%@", error);
        DE_LOG("%@", operation.responseString);
    }];
}

#pragma mark Util methods
/**
 * webStatusCheck - check the device's current status of connection
 *
 * RETURN: YES if currently available for connection, else return NO
 */

+ (BOOL)webStatusCheck {
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
        return NO;
    
    return YES;
}

/**
 * AESEncryptData - encrypt NSData to AES256 form
 * @data: original data that needs to be encrypted
 * @key: key that use to encrypt
 *
 * RETURN: return encrypted data, or nil for failed encryption.
 *
 * For data safety purpose, AESEncrypt can help you keep data as a secret
 * WARNING: Not being used in createShortcut method yet, should implement it later.
 */

+ (NSData*)AESEncryptData:(NSData*)data WithKey:(NSString*) key  {
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        NSData* output = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        // NSString* str = [[NSString alloc] initWithData: test encoding: NSUTF8StringEncoding];
        return output;
    }
    
    free(buffer); //free the buffer;
    return nil;
}


/**
 * createGetCardInfoEnvelope - create SOAP getCardInfoEnvelope
 * @cardID: card that we want to know about it's status
 *
 * For readibility purpose, seperate this part from getCardInfo method.
 */

+ (NSString*)createGetCardInfoEnvelope:(NSString *)cardID {
    
    return [NSString stringWithFormat:
            @"<v:Envelope\n"
            "xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
            "xmlns:d=\"http://www.w3.org/2001/XMLSchema\"\n"
            "xmlns:c=\"http://www.w3.org/2003/05/soap-encoding\"\n"
            "xmlns:v=\"http://www.w3.org/2003/05/soap-envelope\">\n"
            "<v:Header />\n"
            "<v:Body>\n"
            "<%@ xmlns=\"%@\">\n"
            "<APIKey>%@</APIKey>\n"
            "<cardID>%@</cardID>\n"
            "</%@>\n"
            "</v:Body>\n"
            "</v:Envelope>\n", CARD_FUNC_GETCARDINFO, CARD_TARGET_NAMESPACE, CARD_APIKEY, cardID, CARD_FUNC_GETCARDINFO];
}

/**
 * createCreateCardEnvelop - create SOAP CreateCard Envelope
 * @cardID: card that we want to create
 * @initPoint: the points that the card should have.
 *
 * For readibility purpose, seperate this part from createCard method.
 */

+ (NSString*)createCreateCardEnvelope:(NSString*)cardID initPoint:(double)initPoint {
    
    return [NSString stringWithFormat:
            @"<v:Envelope\n"
            "xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
            "xmlns:d=\"http://www.w3.org/2001/XMLSchema\"\n"
            "xmlns:c=\"http://www.w3.org/2003/05/soap-encoding\"\n"
            "xmlns:v=\"http://www.w3.org/2003/05/soap-envelope\">\n"
            "<v:Header />\n"
            "<v:Body>\n"
            "<%@ xmlns=\"%@\">\n"
            "<APIKey>%@</APIKey>\n"
            "<cardID>%@</cardID>\n"
            "<initPoint>%f</initPoint>"
            "</%@>\n"
            "</v:Body>\n"
            "</v:Envelope>\n", CARD_FUNC_CREATECARD, CARD_TARGET_NAMESPACE, CARD_APIKEY, cardID, initPoint, CARD_FUNC_CREATECARD];
}

/**
 * generateCardID - generate a CardID for creating CardID base on current time.
 *
 * RETURN: return a CardID which is generated by using current time as a factor and do md5 encoding,
 and Alphabet-to-Number encoding
 */

+ (NSString*) generateCardID {
    NSMutableString* output = [NSMutableString stringWithCapacity: 16];
    NSMutableString* NSDigest = [NSMutableString stringWithCapacity: 8];;
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970]; // get current time
    NSString* time = [NSString stringWithFormat:@"%.2f", seconds]; // turn seconds into string
    const char *cStr = [time UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (unsigned int)strlen(cStr), digest); // md5 encoding
    
    for(int i = 0; i < 4; i++) {
        const char* cDigest = [[NSString stringWithFormat: @"%02x", digest[i]] UTF8String];
        
        [NSDigest appendFormat:@"%02x", digest[i]]; /* turn unsigned char to 2 chars in NSString */
        for(int x = 0; x < 2; x++) {
            int ch = cDigest[x] <= '9' ? cDigest[x] - 48 : cDigest[x] - 87; /* encode chars to code */
            [output appendFormat:@"%02d", ch];
        }
    }
    DE_LOG("cardID : %@,  length : %lu", output, [output length]);
    
    return output;
}

/**
 * generateShortcutUrl - generate a shortcut url base on the given name and param
 * @param: param that will be used to encode the url. It is the NSdata of the image that will be sent to server.
 * @name: name that will be used to encode the url. It's the icon name.
 *
 * RETURN: a NSString URL
 *
 * Generate a shortcut url and save it to the icon.
 * WARNING: should be encoded in a formal way.
 */

+ (NSString*)generateShortcutUrl:(NSString*) param Name:(NSString*)name{
    NSMutableString* unfilter_string = [NSMutableString stringWithCapacity: 128];
    NSString* time = [WebService generateCardID];
    
    [unfilter_string insertString: [WebService generateCardID] atIndex: 0];
    [unfilter_string insertString: name atIndex: 0];
    [unfilter_string insertString: [WebService generateCardID] atIndex: 0];
    NSCharacterSet* illegal_char = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"] invertedSet];
    return [[unfilter_string componentsSeparatedByCharactersInSet:illegal_char] componentsJoinedByString:@"ux"];
}

+ (NSString*)generateQRCodePostfix {
    NSString* result = [[WebService generateCardID] substringFromIndex:5];
    return result;
}

+ (void)openShorcutUrlInSafari:(NSString *)url {
    
    NSURL* request = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", TREASUREBOWL_SHORTCUT_SERVER, url]];
    [[UIApplication sharedApplication] openURL: request];
}

+ (NSString*)getCSRFFromCookie {
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:TREASUREBOWL_QRCODE_SERVER]];
    NSString* strCookie = @"";
    DE_LOG("cookie csrf %@", [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]);
    
    for(NSHTTPCookie* cookie in cookies ) {
        if([cookie.name isEqualToString:@"csrftoken"])
            return cookie.value;
    }
    return strCookie;
}


#pragma mark Sharing methods

- (BOOL)shareToFacebook:(UIImage *)image {
    
    if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) {
        [FBSDKMessengerSharer shareImage:image withOptions:nil];
        return YES;
    }
    return NO;
}

- (BOOL)shareToLine:(UIImage *)image {
    
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithUniqueName];
    NSString *pasteboardName = pasteboard.name;
    [pasteboard setData:UIImagePNGRepresentation(image) forPasteboardType:@"treasurebowl"];
    NSString *contentType = @"image";
    NSString *contentKey = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes
    (NULL, (CFStringRef)pasteboardName, NULL, CFSTR(":/?=,!$&'()*+;[]@#"),
     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    NSString *urlString = [NSString stringWithFormat:@"line://msg/%@/%@",
                           contentType, contentKey];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    return NO;
}

@end