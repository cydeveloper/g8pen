//
//  CashController.m
//  treasurebowl
//
//  Created by SunDaMac on 2015/9/24.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "CashController.h"
#import "ViewController.h"
#import "AppStateManager.h"

@implementation CashController{
    NSArray *tableData;
}

AppStateManager* appStateManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appStateManager = [AppStateManager getSharedInstance];
    
    tableData = appStateManager.getCards;
    
    //tableData = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10",nil];
    _cashTable.delegate = self;
    _cashTable.dataSource = self;
    _cashTable.backgroundColor = [UIColor grayColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    Card* card = (Card*)[tableData objectAtIndex:indexPath.row];
  
    cell.textLabel.text = card.cardID;
    cell.backgroundColor = [UIColor grayColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    
    return cell;
}


- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}


@end
