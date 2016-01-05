//
//  GroupViewController.m
//  treasurebowl
//
//  Created by SunDaMac on 2015/8/9.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "GroupViewController.h"
#import "WebService.h"
#import "IconCreateViewController.h"
#import "Constant.h"
#import "GroupMenu.h"
#import "DBManager.h"
#import "Icon.h"
#import <ZXingObjC/ZXingObjC.h>
#import "WebService.h"
#import "AppStateManager.h"
#import "Util.h"
@interface GroupViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property()Icon *currentIcon;
@property()Group *currentGroup;
@property (weak, nonatomic) NSString *curGroup;
@end

GroupMenu *groupMenu;
AppStateManager* appStateManager;

int SW ,SH; //screen width , screen height;

@implementation GroupViewController


//init function
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"GroupName = %@" , _curGroup);
    _currentGroup = [appStateManager getGroupByName:_curGroup];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    SW = screenRect.size.width;
    SH = screenRect.size.height;
    
    groupMenu = [[GroupMenu alloc]initByCollectionView:_myCollectionView andViewController:self];
    [groupMenu initButton];
    
    appStateManager = [AppStateManager getSharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//count how many iconCell you will create
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSLog(@"there aere %lu icons in group" ,(unsigned long)[_currentGroup.icons_id_array count]);
    return  [_currentGroup.icons_id_array count];
}

//create the iconCell in the collectionView by two type 1.name 2.picture name
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _myCollectionView = collectionView;
    
    NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *collectionImageView = (UIImageView *)[cell viewWithTag:100];
    
    /*Icon*icon;
     NSArray* Icons = [appStateManager getIcons];
     icon = Icons[indexPath.row];*/
    NSInteger iconId = [_currentGroup.icons_id_array[indexPath.row]integerValue];
    Icon * icon = [appStateManager getIconByID:iconId];
    NSLog(@"iconID = %ld name = %@ seq = %ld phone1 = %@  Group = %ld" , (long)icon.icon_ID , icon.name ,(long)icon.sequence , icon.phone_num[0] , icon.group_ID);
    
    collectionImageView.image = [icon getImage];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SW*0.45, SW*0.45);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

//if any cell be choosed
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Icon*icon;
    icon = [appStateManager getIconByID:[_currentGroup.icons_id_array[indexPath.row] integerValue]];
    _currentIcon = icon;
    [groupMenu setIcon:icon];
    if(groupMenu.MODE == 4){
        
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Warning"
                                                         message:@"Are you sure to delete icon?"
                                                        delegate:self
                                               cancelButtonTitle:@"No"
                                               otherButtonTitles: nil];
        [alert setTag:0];
        [alert addButtonWithTitle:@"Yes"];
        [alert show];
        
    }
    else [groupMenu chooseCell:indexPath];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //delete alert
    if(alertView.tag == 0){
        if (buttonIndex == 0){//NO
        }
        else if(buttonIndex == 1){//YES
            [self deleteIcon:_currentIcon];
        }
    }
    //calling and only one phone number
    else if(alertView.tag == 1){
        if (buttonIndex == 1) {//OK
            UITextField *phoneNum = [alertView textFieldAtIndex:0];
            if(phoneNum.text.length==0)[self makeAlertWithTitle:@"Wanning"andMessage:@"No enter phone number"];
            else {
                [_currentIcon.phone_num addObject:phoneNum.text];
                _currentIcon.total_number++;
                [appStateManager updateIcon: _currentIcon];
                //DBManager* db = [DBManager getSharedInstance];
                //[db updateIcon:_currentIcon];
            }
        }
    }
    
    //calling and no any phone number
    else if(alertView.tag == 2){
        if (buttonIndex == 1){//OK
            UITextField *phoneNum1 = [alertView textFieldAtIndex:0];
            UITextField *phoneNum2 = [alertView textFieldAtIndex:1];
            
            if(phoneNum1.text.length==0 || phoneNum2.text.length==0)[self makeAlertWithTitle:@"Wanning"andMessage:@"No enter enough phone number"];
            else{
                [_currentIcon.phone_num addObject:phoneNum1.text];
                [_currentIcon.phone_num addObject:phoneNum2.text];
                _currentIcon.total_number+=2;
                [appStateManager updateIcon:_currentIcon];
            }
        }
    }
    
}

#pragma mark WebserviceDelegate Method
- (void)getCardInfoReturn:(CallPackage *)call_data ErrorStatus:(int)errorCode{
    
    NSLog(@"getCardInfoReturn");
    [WebService getSharedInstance].currentConnection = non; // clear connection state
    
    if(errorCode == getCardFailed_notExist) {
        NSLog(@"Card not exist");
        return;
    }
    
    
    // insert or update card.
    [appStateManager updateCard:call_data.card];
    
    if(call_data.doCall) {
        if(errorCode == getCardFailed_notEnough) {
            NSLog(@"Not enough money");
            return;
        }
        
        [[WebService getSharedInstance] call:self CallPkg: call_data];
    }
}

-(void)deleteIcon:(Icon*)icon{
    [appStateManager deleteIconWithName:_currentIcon.name];
    UICollectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mainMenu"];
    [self showDetailViewController:vc sender:self];
    
}


- (void)callComplete:(int)errorCode {
    
    [Util stopHUD];
    [WebService getSharedInstance].currentConnection = non; // clear connection state
    if(errorCode == connectionFailed) {
        [Util makeAlertWithTitle: @"Oops!"
                      andMessage: @"Cannot connect to server, please try it later ..."
                         withTag: normal_alert
                        Delegate: self];
        return;
    }
    [Util makeAlertWithTitle: @"Success!"
                  andMessage: @"The call will come in in just a few second!"
                     withTag: normal_alert
                    Delegate: self];
    
}

#pragma mark triggerWebservice method
- (void)startCalling:(Icon *)icon {
    
    
    [Util makeHUDWithTitle: @"Start Calling" andMessage: @"" toView: self.view];
    if(![WebService webStatusCheck]) {
        [Util makeAlertWithTitle: @"Oops!"
                      andMessage: @"Your device is not connected to the network"
                         withTag: stopHUD_alert
                        Delegate:self];
        return;
    }
    
    WebService* web_service = [WebService getSharedInstance];
    [web_service tryMakeCall:self Icon:icon];
}

- (void)createShortcut:(Icon *)icon {
    
    [Util makeHUDWithTitle: @"Creating shortcut for you ..." andMessage: @"" toView: self.view];
    if(![WebService webStatusCheck]) {
        [Util makeAlertWithTitle: @"Connection failed" andMessage: @"Your device is not connected to the network" withTag: 8 Delegate: self];
        
        return;
    }
    
    
    if(![icon.shortcut_url isEqualToString:@"NNN"]) {
        // Shortcut URL exist, open url.
        [WebService openShorcutUrlInSafari: icon.shortcut_url];
        [Util stopHUD];
    } else {
        // Shortcut URL not exist at server side
        // send POST request to create one
        [[WebService getSharedInstance] createIconShortcut:self Icon:icon];
    }
    
    
}

- (void)createShortcutReturn:(NSString *)url ErrorStatus:(int)errorCode {
    
    [Util stopHUD];
    if(errorCode == connectionFailed) {
        [Util makeAlertWithTitle: @"Oops!"
                      andMessage: @"Cannot connect to server, please try it later ..."
                         withTag: stopHUD_alert
                        Delegate: self];
        return;
    }
    
    /* update database */
    _currentIcon.shortcut_url = url;
    [appStateManager updateIcon: _currentIcon];
    [WebService openShorcutUrlInSafari: _currentIcon.shortcut_url];
}

- (void)createNewCardComplete:(Card *)newCard ErrorStatus:(int)errorCode {
    DBManager* db = [DBManager getSharedInstance];
    [WebService getSharedInstance].currentConnection = non; // clear connection state
    
    if(errorCode == createCardFailed) {
        NSLog(@"create Card failed!");
        
        // should retry to get CardInfo back
        
        return;
    }
    NSLog(@"createCard success! insert new card into database %@", newCard.status);
    [db insertCard: newCard];
}

- (void)createShareQRcode:(Icon *) icon {
    
    [Util makeHUDWithTitle: LOCAL("Creating sharing QRCode for you ...") andMessage: @"" toView: self.view];
    
    if(![WebService webStatusCheck]) {
        ALERT_DEVICE_NOT_CONNECTED;
        [Util stopHUD];
        return;
    }
    
    [[WebService getSharedInstance] createQRCodeURL:self Icon:icon];
}

- (void)createQRCodeURLReturn:(NSString*) url ErrorStatus:(int)errorCode {
    [Util stopHUD];
    DE_LOG("%@", url);
    [[WebService getSharedInstance] getQRcodePicture:self URL:url];
}

- (void)getQRCodePictureReturn:(UIImage *)img ErrorStatus:(int)errorCode {
    if(errorCode == connectionFailed) {
        DE_LOG("get qrcode failed");
    } else {
        NSString * message = @"This is my QRCode of Treasure bowl!";
        NSArray * shareItems = @[message, img];
        
        UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
        
        [self presentViewController:avc animated:YES completion:nil];

    }
}

#pragma mark button_press

-(void)menuButtonPressed{
    NSLog(@"Menu pressed");
    _currentIcon = nil;
}
-(void)callButtonPressed{
    
    DE_LOG("total = %ld" , (long)_currentIcon.total_number);
    if(_currentIcon.total_number < 2){
        [Util makePhoneInputAlert: _currentIcon.total_number Action: @"make a phone call" Delegate: self];
    } else {
        DE_LOG("call currentIconName = %@ phone1 = %@ phone2 = %@" , _currentIcon.name ,_currentIcon.phone_num[0] , _currentIcon.phone_num[1]);
        [self startCalling:_currentIcon];
    }
    
}
-(void)shareButtonPressed{
    NSLog(@"share currentIconName = %@" , _currentIcon.name);
    [self createShareQRcode:_currentIcon];
}

-(void)shortcutButtonPressed{
    
    if(_currentIcon.total_number < 2) {
        [Util makePhoneInputAlert: _currentIcon.total_number Action: @"create a shortcut" Delegate: self];
        return;
    }
    
    [self createShortcut: _currentIcon];
}
-(void)modifyButtonPressed{
    NSLog(@"Modify pressed");
}

-(void)trashButtonPressed{
}
-(void)settingButtonPressed{
    UIStoryboard* board = self.storyboard;
    UIViewController* mainVC =[board instantiateViewControllerWithIdentifier:@"setting"];
    [self presentViewController:mainVC animated:YES completion:NULL];
}
-(void)cashButtonPressed{
    UIStoryboard* board = self.storyboard;
    UIViewController* mainVC =[board instantiateViewControllerWithIdentifier:@"cash"];
    [self presentViewController:mainVC animated:YES completion:NULL];
}

#pragma mark alert method

-(void)makeAlertWithTitle:(NSString*)title andMessage:(NSString*)message{
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:title
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
    [alert setTag:100];
    [alert show];
}



@end

