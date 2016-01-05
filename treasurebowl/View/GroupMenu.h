//
//  GroupMenu.h
//  treasurebowl
//
//  Created by SunDaMac on 2015/8/9.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Icon.h"

@interface GroupMenu : NSObject

@property()int MODE;
-(id)initByCollectionView:(UICollectionView*)CV andViewController:(UICollectionViewController*)C;
-(id)initByView:(UIView*)View ViewController:(UIViewController*)viewController;


-(void)initButton;
-(void)initMenuButtonForReturn;
-(void)chooseCell:(NSIndexPath *)indexPath;
-(void)setIcon:(Icon*)icon;

@end
