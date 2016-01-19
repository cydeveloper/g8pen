//
//  ViewController.m
//  treasurebowl
//
//  Created by AtSu on 2015/5/14.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "ViewController.h"
#import "WebService.h"
#import "IconCreateViewController.h"
#import "Constant.h"
#import "MainMenu.h"
#import "DBManager.h"
#import "Icon.h"
#import <ZXingObjC/ZXingObjC.h>
#import "WebService.h"
#import "AppStateManager.h"
#import "Util.h"
#import "SettingController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property()Icon *currentIcon;
@property()Group *currentGroup;
@property()UICollectionViewCell *currentCell;
@property()NSMutableArray *seqArrary;
@property() CGRect saveRect;
@property() NSIndexPath *saveIndexPath;

@end

MainMenu *mainMenu;
AppStateManager* appStateManager;
WebService* webservice;


int SW ,SH; //screen width , screen height;

@implementation ViewController

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
 
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    SW = screenRect.size.width;
    SH = screenRect.size.height;
    
    mainMenu = [[MainMenu alloc]initByCollectionView:_myCollectionView andViewController:self];
    [mainMenu initButton];
    
    appStateManager = [AppStateManager getSharedInstance];
    webservice = [WebService getSharedInstance]; // initialize
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:lpgr];
    
    [self initBySequence];
    [self checkUserPhone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)checkUserPhone{
    if([appStateManager.block_userphone length]==0){
        [Util makePhoneInputAlert:1  Action:@"getDefaultPhone" Delegate:self];
    }
    else{
    }
}

//count how many iconCell you will create
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_seqArrary count];
}

//create the iconCell in the collectionView by two type 1.name 2.picture name
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _myCollectionView = collectionView;
    
    NSLog(@"row = %ld" , (long)indexPath.row);
    
    if(  [[_seqArrary objectAtIndex:indexPath.row]isKindOfClass:[Icon class]] ){
        
        NSString *identifier = @"Cell";
    
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
        UIImageView *collectionImageView = (UIImageView *)[cell viewWithTag:100];

        Icon *icon = [_seqArrary objectAtIndex:indexPath.row];
        NSLog(@"iconID = %ld name = %@ seq = %ld Group = %@ GroupID = %ld" , (long)icon.icon_ID , icon.name ,(long)icon.sequence , icon.group.name , (long)icon.group_ID);
        collectionImageView.image = [icon getImage];
        return cell;
    }
    else {
        NSString *identifier = @"GroupCell";
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        Group *group = [_seqArrary objectAtIndex:indexPath.row];
        NSLog(@"groupID = %ld name = %@ color = %@ seq = %ld" , group.group_ID , group.name ,group.color , (long)group.sequence);
        
        NSArray *color = [group.color componentsSeparatedByString:@"/"];
        if(color.count == 6){
            cell.backgroundColor = [UIColor colorWithRed:[color[0] floatValue] green:[color[1] floatValue] blue:[color[2] floatValue] alpha:1.0];
        }
        UILabel* label;
        label = (UILabel*)[cell viewWithTag:100];
        label.text = group.name;
        label.font  = [UIFont systemFontOfSize:   SW/[appStateManager getUserBlock]/[group.name length]];
        label.textColor = [UIColor colorWithRed:[color[3] floatValue] green:[color[4] floatValue] blue:[color[5] floatValue] alpha:1.0];
        
        return cell;
    }
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger block_num = [appStateManager getUserBlock];
    return CGSizeMake(SW*(0.9/block_num), SW*(0.9/block_num));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.collectionView performBatchUpdates:nil completion:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id next = segue.destinationViewController;
    
    if([segue.identifier  isEqual: @"goGroup"]){
        [next setValue:_currentGroup.name forKey:@"curGroup"];
        _currentGroup = nil;
    }
    
    if([segue.identifier  isEqual: @"goCreate"]){
        [next setValue:  [NSString stringWithFormat:@"%lu" , (unsigned long)_seqArrary.count]  forKey:@"curSeq"];
    }
    
}

//if any cell be choosed
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if([[_seqArrary objectAtIndex:indexPath.row]isKindOfClass:[Group class]] ){
        _currentGroup = [_seqArrary objectAtIndex:indexPath.row];
            if(mainMenu.MODE==0){
            [self performSegueWithIdentifier:@"goGroup" sender:self];
            return;
        }
    }
    else {
        _currentIcon = [_seqArrary objectAtIndex:indexPath.row];
        [mainMenu setIcon:_currentIcon];
    }
    if(mainMenu.MODE == 4){
        [Util makeTwoChoicesAlert: LOCAL("Warning")
                       andMessage: LOCAL("Are you sure you want to delete this?")
                         Delegate: self];
    }
    else [mainMenu chooseCell:indexPath];
    
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    //delete alert
    if(alertView.tag == yes_no_alert){
        if(buttonIndex) {
            
            if(_currentIcon) {
                [self deleteIcon:_currentIcon];
            } else if(_currentGroup) {
                [self deleteGroup:_currentGroup];
            }
        }
    } else if(alertView.tag == stopHUD_alert) {
        [Util stopHUD];
    } else if(alertView.tag == userPhone_alert) {
        NSString* phone = [alertView textFieldAtIndex:0].text;
        NSString* title;
        NSString* msg;
        int result = [SettingController setUserPhone:phone];
        if(result < 0) {
            title = @"Fail!";
            msg = @"Illegal phone number";
        } else {
            title = @"Success!";
            msg = @"Now you can enjoy your app";
        }
        [Util makeAlertWithTitle:[NSString stringWithFormat:LOCAL("%@"), title]
                      andMessage:[NSString stringWithFormat:LOCAL("%@"), msg]
                         withTag:normal_alert
                        Delegate:self];
    }else if(alertView.tag > 0 && alertView.tag != normal_alert) {
        
        if(buttonIndex) {

            NSMutableArray* phone_array = [[NSMutableArray alloc] init];
            for(int cnt = 0; cnt < alertView.tag; cnt ++) {
                NSString* phone_text = [alertView textFieldAtIndex: cnt].text;

                if(phone_text.length == 0) {
                    [Util makeAlertWithTitle: LOCAL("Warning")
                                  andMessage: [NSString stringWithFormat: LOCAL("%lu phone numbers is required!"), alertView.tag]
                                     withTag: normal_alert
                                    Delegate: self];
                    return;
                }
                [phone_array addObject: phone_text];
            }

            for(NSString* phone in phone_array) {
                [appStateManager addPhoneToIcon: _currentIcon Phone: phone];
            }
        }
    }
}

#pragma mark triggerWebservice method
- (void)startCalling:(Icon *)icon {
    
    
    [Util makeHUDWithTitle: LOCAL("Start Calling") andMessage: @"" toView: self.view];
    if(![WebService webStatusCheck]) {
        ALERT_DEVICE_NOT_CONNECTED;
        return;
    }

    WebService* web_service = [WebService getSharedInstance];
    [web_service tryMakeCall:self Icon:icon];
}

- (void)createShortcut:(Icon *)icon {
    
    [Util makeHUDWithTitle: LOCAL("Creating shortcut for you ...") andMessage: @"" toView: self.view];
    if(![WebService webStatusCheck]) {
        ALERT_DEVICE_NOT_CONNECTED;
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

#pragma mark WebserviceDelegate Method
- (void)getCardInfoReturn:(CallPackage *)call_data ErrorStatus:(int)errorCode{


    [WebService getSharedInstance].currentConnection = non; // clear connection state

    if(errorCode == connectionFailed) {
        ALERT_SERVER_ERROR;
        return;
    }
    
    if(errorCode == getCardFailed_notExist) {
        DE_LOG("Card not exist");
        return;
    }
    
    [appStateManager updateCard: call_data.card];
    
    if(call_data.doCall) {
        if(errorCode == getCardFailed_notEnough) {
            DE_LOG("Not enough money");
            [Util makeAlertWithTitle: LOCAL("Oops!")
                          andMessage: LOCAL("The card is out of cash!")
                             withTag: stopHUD_alert
                            Delegate: self];
            return;
        }
        
        [[WebService getSharedInstance] call:self CallPkg: call_data];
    }
}

- (void)callComplete:(int)errorCode {
    
    [Util stopHUD];
    [WebService getSharedInstance].currentConnection = non; // clear connection state
    if(errorCode == connectionFailed) {
        ALERT_SERVER_ERROR;
        return;
    }
    [Util makeAlertWithTitle: LOCAL("Success!")
                  andMessage: LOCAL("The call will come in in just a few second!")
                     withTag: normal_alert
                    Delegate: self];

}

- (void)createNewCardComplete:(Card *)newCard ErrorStatus:(int)errorCode {

    [WebService getSharedInstance].currentConnection = non; // clear connection state
    
    if(errorCode == connectionFailed) {
        ALERT_SERVER_ERROR;
        return;
    }
    
    if(errorCode == createCardFailed) {
        NSLog(@"create Card failed!");
        
        // should retry to get CardInfo back
        
        return;
    }
    DE_LOG("createCard success! insert new card into database %@", newCard.status);
    [appStateManager addNewCard: newCard];
}

- (void)createShortcutReturn:(NSString *)url ErrorStatus:(int)errorCode {
    
    [Util stopHUD];
    if(errorCode == connectionFailed) {
        ALERT_SERVER_ERROR;
        return;
    }
    
    /* update database */
    _currentIcon.shortcut_url = url;
    [appStateManager updateIcon: _currentIcon];
    [WebService openShorcutUrlInSafari: _currentIcon.shortcut_url];
}


#pragma mark button_press

-(void)deleteIcon:(Icon*)icon{
    [appStateManager deleteIconWithName:_currentIcon.name];
    [self initBySequence];
    UICollectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mainMenu"];
    [self showDetailViewController:vc sender:self];
}
-(void)deleteGroup:(Group*)group{
    [appStateManager deleteGroupWithName:_currentGroup.name];
    [self initBySequence];
    UICollectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mainMenu"];
    [self showDetailViewController:vc sender:self];
}


-(void)menuButtonPressed{
    DE_LOG("Menu pressed");
    _currentIcon = nil;
    _currentGroup = nil;
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
    NSLog(@"Share pressed");
    
}

-(void)shortcutButtonPressed{
    
    if(_currentIcon.total_number < 2) {
        [Util makePhoneInputAlert: _currentIcon.total_number  Action: @"create a shortcut" Delegate: self];
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

-(void)addIconButtonPressed;{
    
    [self performSegueWithIdentifier:@"goCreate" sender:self];
}

-(void)createGroupPressed:(NSString*)name color:(NSString*)color{
    Group* group = [[Group alloc] initWithName:name Icons_id_array:nil Color:color Sequence:_seqArrary.count];
    [appStateManager addNewGroup: group];
    
    UICollectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"mainMenu"];
    [self showDetailViewController:vc sender:self];
}

#pragma mark sequence manager

-(void)initBySequence{
    _seqArrary = [[NSMutableArray alloc] init];
    NSArray* Icons = [appStateManager getIcons];
    NSArray* Groups = [appStateManager getGroups];
    
    for(Icon* icon in Icons)if(icon.group==nil)[_seqArrary addObject:icon];
    for(Group* group in Groups)[_seqArrary addObject:group];
    
    NSArray *sortedArray = [_seqArrary  sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
            NSInteger first = [(Icon*)a sequence];
            NSInteger second = [(Icon*)b sequence];
            return first>second;
    }];
    
    _seqArrary = [sortedArray copy];
    for(Icon* tmp in _seqArrary){
        tmp.sequence = [_seqArrary indexOfObject:tmp];
    }
    
    //NSLog(@"seq count = %lu" , (unsigned long)_seqArrary.count);
    //update cell seq
}

#pragma mark long press handle

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"Enter long press");
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    
    if(_currentCell == nil){
        if (indexPath == nil){
            NSLog(@"couldn't find index path");
        }
        else {
            if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
                NSLog(@"Begin");
                UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                _currentCell = cell;
                _saveRect = _currentCell.frame;
                
                 _currentCell.frame = CGRectMake(p.x-SW*0.275 , p.y-SW*0.275 , SW*(1.1/CELL_NUM) , SW*(1.1/CELL_NUM));
                
                if([[_seqArrary objectAtIndex:indexPath.row]isKindOfClass:[Group class]] ){
                    _currentGroup = [_seqArrary objectAtIndex:indexPath.row];
                    _currentIcon = nil;
                }
                else{
                    _currentIcon = [_seqArrary objectAtIndex:indexPath.row];
                    _currentGroup = nil;
                }
                
            }
        }
    }
    else{
        _currentCell.frame = CGRectMake(p.x-SW*0.275 , p.y-SW*0.275 , SW*(1.1/CELL_NUM) , SW*(1.1/CELL_NUM));
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
            NSLog(@"End");
            
            if(indexPath != nil && indexPath == [self.collectionView indexPathForCell:_currentCell]){
                _currentCell.frame = _saveRect;
                _currentCell = nil;
            }
            else {
                
                if([[_seqArrary objectAtIndex:indexPath.row]isKindOfClass:[Group class]] ){
                    if(_currentIcon!=nil){
                        Group *group = [_seqArrary objectAtIndex:indexPath.row];
                        //_currentIcon.sequence = group.icons.count;
                        [appStateManager iconJoinGroup:group Icon:_currentIcon];
                    }
                    
                }
                else {
                    Icon *icon = [_seqArrary objectAtIndex:indexPath.row];
                    NSInteger tmp = icon.sequence;
                    
                    if(_currentGroup!=nil){
                        icon.sequence = _currentGroup.sequence;
                        _currentGroup.sequence = tmp;
                        [appStateManager updateGroup:_currentGroup];
                    }
                    else if(_currentIcon!=nil){
                        icon.sequence = _currentIcon.sequence;
                        _currentIcon.sequence = tmp;
                        [appStateManager updateIcon:_currentIcon];
                    }
                    
                    [appStateManager updateIcon:icon];
                }
            
                UIStoryboard* board = self.storyboard;
                ViewController* mainVC =[board instantiateViewControllerWithIdentifier:@"mainMenu"];
                [self presentViewController:mainVC animated:NO completion:NULL];
            }
        }
    }
}


@end

