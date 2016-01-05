//
//  GroupViewController.h
//  treasurebowl
//
//  Created by SunDaMac on 2015/8/9.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "WebService.h"
#import "Icon.h"

@interface GroupViewController: UICollectionViewController<WebserviceDelegate>



-(void)menuButtonPressed;
-(void)callButtonPressed;
-(void)shareButtonPressed;
-(void)shortcutButtonPressed;
-(void)modifyButtonPressed;
-(void)trashButtonPressed;
-(void)settingButtonPressed;
-(void)cashButtonPressed;
- (void)startCalling:(Icon*) icon;

@end