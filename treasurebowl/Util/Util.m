//
//  Notifier.m
//  treasurebowl
//
//  Created by AtSu on 2015/8/26.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//


#import "MBProgressHUD.h"
#import "Macro.h"
#import <UIKit/UIKit.h>
#import "Util.h"
@implementation Util
MBProgressHUD * hud;

+ (void)makeHUDWithTitle:(NSString*)title andMessage:(NSString*)message toView:(UIView *)view {
    hud = [MBProgressHUD showHUDAddedTo: view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = title;
    hud.detailsLabelText=message;
    hud.color = [UIColor grayColor];
    hud.labelColor = [UIColor blackColor];
    hud.detailsLabelColor= [UIColor blackColor];
}

+ (void)stopHUD{
    [hud removeFromSuperview];
    hud = nil;
}

+ (void)makeAlertWithTitle:(NSString*)title andMessage:(NSString*)message withTag:(NSInteger)tag Delegate:(id)delegate{
  
    UIAlertView * alert = [self createBasicAlert:title andMessage:message cancelText:@"OK" withTag:tag Delegate:delegate];
    [alert show];
}

+ (void)makeTwoChoicesAlert:(NSString*)title andMessage:(NSString*)message Delegate:(id)delegate {
    
    UIAlertView* alert = [self createBasicAlert: title andMessage: message cancelText: @"No" withTag: yes_no_alert Delegate: delegate];
    [alert addButtonWithTitle: @"Yes"];
    [alert show];
}

+ (void)makeInputAlert:(NSString *)title andMessage:(NSString*)message Style:(enum UIAlertViewStyle)style withTexts:(NSArray*)texts Tag:(NSInteger)tag Delegate:(id)delegate {
    
    if(style != UIAlertViewStylePlainTextInput && style != UIAlertViewStyleLoginAndPasswordInput)
        return;
    
    
    //NSInteger tag = style == UIAlertViewStylePlainTextInput ? 1 : 2;
    
    UIAlertView* alert = [self createBasicAlert: title andMessage: message cancelText: @"Cancel" withTag: tag Delegate: delegate];
    
    alert.alertViewStyle = style;
    [[alert textFieldAtIndex:0] setPlaceholder: [texts objectAtIndex: 0]];
    
    if(style == UIAlertViewStyleLoginAndPasswordInput) {
        [[alert textFieldAtIndex:1] setSecureTextEntry: NO];
        [[alert textFieldAtIndex:1] setPlaceholder: [texts objectAtIndex: 1]];
    }

    [alert addButtonWithTitle: @"OK"];
    [alert show];
}

+ (void)makePhoneInputAlert:(NSInteger)current_number Action:(NSString *)action Delegate:(id)delegate{
    NSArray* texts;
    UIAlertViewStyle style = current_number == 0 ? UIAlertViewStyleLoginAndPasswordInput : UIAlertViewStylePlainTextInput;
    
    NSInteger tag = 2 - current_number;
    NSString* message;
    

    if( [action isEqualToString:@"getDefaultPhone"]){
        tag = userPhone_alert;
        message = [NSString stringWithFormat: @"give me your phone number %@", action];
    }else if( [action isEqualToString:@"make a phone call"] ){
        message = [NSString stringWithFormat: @"Require %lu more phone number(s) to %@", 2 - current_number, action];
    }else if([action isEqualToString:@"create a shortcut"] ){
        message = [NSString stringWithFormat: @"Require %lu more phone number(s) to %@", 2 - current_number, action];
    }
    
    
    if(current_number == 0) {
        texts = [[NSArray alloc] initWithObjects: @"Phone #1", @"Phone #2", nil];
    } else {
        texts = [[NSArray alloc] initWithObjects: @"Phone numbers", nil];
    }
    
    [self makeInputAlert: @"Oops!" andMessage: message Style: style withTexts: texts Tag:tag Delegate: delegate];
}

+ (UIAlertView*)createBasicAlert:(NSString*)title andMessage:(NSString*)message cancelText:(NSString*)cancel withTag:(NSInteger)tag Delegate:(id)delegate {
    
    
    UIAlertView* alert = [[UIAlertView alloc ] initWithTitle: title
                                       message: message
                                      delegate: delegate
                             cancelButtonTitle: cancel
                             otherButtonTitles: nil];
    [alert setTag: tag];
    return alert;
}

@end
