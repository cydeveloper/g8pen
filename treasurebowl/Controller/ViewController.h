//
//  ViewController.h
//  treasurebowl
//
//  Created by AtSu on 2015/5/14.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Icon.h"
#import "WebService.h"

@interface ViewController : UICollectionViewController <WebserviceDelegate ,UIGestureRecognizerDelegate>
-(void)menuButtonPressed;
-(void)callButtonPressed;
-(void)shareButtonPressed;
-(void)shortcutButtonPressed;
-(void)modifyButtonPressed;
-(void)trashButtonPressed;
-(void)settingButtonPressed;
-(void)cashButtonPressed;
-(void)addIconButtonPressed;
-(void)createGroupPressed:(NSString*)name color:(NSString*)color;
- (void)startCalling:(Icon*) icon;

@end

