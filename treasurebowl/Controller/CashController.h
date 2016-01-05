//
//  CashController.h
//  treasurebowl
//
//  Created by SunDaMac on 2015/9/24.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CashController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *cashTable;

@end
