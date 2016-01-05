//
//  MainMenu.h
//  treasurebowl
//
//  Created by SunDaMac on 2015/6/10.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <iOS-Color-Picker/FCColorPickerViewController.h>
#import "Icon.h"

@interface MainMenu : NSObject<FCColorPickerViewControllerDelegate>

@property()int MODE;
-(id)initByCollectionView:(UICollectionView*)CV andViewController:(UICollectionViewController*)C;
-(id)initByView:(UIView*)View ViewController:(UIViewController*)viewController;

-(void)initButton;
-(void)initMenuButtonForReturn;
-(void)chooseCell:(NSIndexPath *)indexPath;
-(void)setIcon:(Icon*)icon;

@end
