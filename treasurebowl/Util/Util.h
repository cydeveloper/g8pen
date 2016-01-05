//
//  Notifier.h
//  treasurebowl
//
//  Created by AtSu on 2015/8/26.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;
@interface Util : NSObject

typedef enum tagType {
    yes_no_alert = 0,
    normal_alert = 8,
    stopHUD_alert = 16,
    userPhone_alert = 32,
} TagType;


+ (void)makeHUDWithTitle:(NSString*)title andMessage:(NSString*)message toView:(UIView*)view;
+ (void)stopHUD;
+ (void)makeAlertWithTitle:(NSString*)title andMessage:(NSString*)message withTag:(NSInteger)tag Delegate:(id)delegate;
+ (void)makeTwoChoicesAlert:(NSString*)title andMessage:(NSString*)message Delegate:(id)delegate;
+ (void)makeInputAlert:(NSString *)title andMessage:(NSString*)message Style:(enum UIAlertViewStyle)style withTexts:(NSArray*)texts Tag:(NSInteger)tag Delegate:(id)delegate;
+ (void)makePhoneInputAlert:(NSInteger)current_number Action:(NSString*) action Delegate:(id)delegate;
@end
