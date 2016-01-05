//
//  SettingController.m
//  treasurebowl
//
//  Created by SunDaMac on 2015/9/24.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "SettingController.h"
#import "ViewController.h"
#import "AppStateManager.h"
#import "Constant.h"

@implementation SettingController{
    NSArray *settingData;
}

AppStateManager* appStateManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appStateManager = [AppStateManager getSharedInstance];
    
    settingData = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4",nil];

    _settingPicker.dataSource = self;
    _settingPicker.delegate = self;
    
    _settingPicker.tintColor = [UIColor whiteColor];
    
    [_settingPicker selectRow:2 inComponent:0 animated:YES];
    
    _userPhoneText.text = appStateManager.block_userphone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    switch (component) {
        case 0:
            return [settingData count];
            break;
        default:
            return 0;
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
     [[AppStateManager getSharedInstance] setUserBlock:[[settingData objectAtIndex:row] integerValue]];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [settingData objectAtIndex:row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    //[self dismissViewControllerAnimated:YES completion:^{}];
    
    appStateManager.block_userphone = _userPhoneText.text;
    
    UIStoryboard* board = self.storyboard;
    UIViewController* mainVC =[board instantiateViewControllerWithIdentifier:@"mainMenu"];
    [self presentViewController:mainVC animated:YES completion:NULL];

    
}


+(int) setUserPhone:(NSString *)phone {
    int result = 1;
    NSCharacterSet* illegal_char = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
    if([phone rangeOfCharacterFromSet:illegal_char].location != NSNotFound) {
        DE_LOG("contain illegal character");
        result = -1;
    } else if([phone length] == 0) {
        DE_LOG("You enter nothing you muthafucka");
        result = -2;
        
    } else {
        [[AppStateManager getSharedInstance] setUserPhone: phone];
    }
    DE_LOG("survive!");
    return result;
}

@end
