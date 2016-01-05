//
//  SettingController.h
//  treasurebowl
//
//  Created by SunDaMac on 2015/9/24.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *settingPicker;
@property (weak, nonatomic) IBOutlet UITextField *userPhoneText;

+ (int)setUserPhone:(NSString*)phone;
@end
