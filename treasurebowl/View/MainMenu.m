//
//  MainMenu.m
//  treasurebowl
//
//  Created by SunDaMac on 2015/6/10.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "MainMenu.h"
#import "ViewController.h"
#import "AppStateManager.h"

@interface MainMenu()

@property() UICollectionView *myCollectionView ;
@property() ViewController *myCollectionViewController;

@property() UICollectionViewCell *currentCell;
@property() CGRect saveRect;
@property() UIButton *menuButton ,*callButton , *shortcutButton;
@property() UIButton *trashButton , *settingButton , *cashButton;
@property() UIButton *addButton , *addIconButton , *addGroupButton;

@property() UIView *createGroup;
@property() UIButton *colorButton1 , *colorButton2 , *createButton;
@property() UITextField *groupName;

@property() NSMutableArray* deletes;
@property() UILabel* iconName;
@property() Icon*currentIcon;

@end

int SW ,SH;
int colorButton = 0;

@implementation MainMenu

-(id)initByCollectionView:(UICollectionView*)CV andViewController:(UICollectionViewController*)VC{
    self = [super init];
    if(self){
        _myCollectionView = CV;
        _myCollectionViewController = VC;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        SW = screenRect.size.width;
        SH = screenRect.size.height;
        
        _deletes = [[NSMutableArray alloc]init];
        
    }
    return self;
}


-(void)setIcon:(Icon*)icon{
    _currentIcon = icon;
}

-(void)chooseCell:(NSIndexPath *)indexPath{
    //MODE 0 is the idle status
    if(_MODE == 0){
        //catch the cell user choose
        UICollectionViewCell *cell =[_myCollectionView cellForItemAtIndexPath:indexPath];
        
        [UIView transitionWithView:_myCollectionView
                          duration:0.5
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            //dark everything but selected cell
                            for(UICollectionView *tmp in _myCollectionView.visibleCells)tmp.alpha = 0.3;
                            _addButton.alpha = 0.3;
                            cell.alpha=1;
                            //save the selected cell and its original location and size
                            _currentCell = cell;
                            _saveRect = _currentCell.frame;
                            //move to center
                            _currentCell.frame = CGRectMake(SW*0.25, SH*0.1+_myCollectionView.contentOffset.y, SW*0.5, SW*0.5);
                            //put cell in front of all cells
                            [_myCollectionView bringSubviewToFront:_currentCell];
                            //show operation UI and icon name
                            _callButton.alpha = 1;
                            _shortcutButton.alpha = 1;
                            _iconName.text = _currentIcon.name;
                            _iconName.alpha = 1;
                            
                            [_menuButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
                            
                        } completion:^(BOOL finished) {
                           
                            _MODE = 1;
                        }];
    }
    
}

-(void)openSubButtonOfMenu:(BOOL)B{
    if(B){
        _trashButton.frame = CGRectMake(SW*0.13, SH*0.64, SW*0.2, SH*0.125);
        _settingButton.frame = CGRectMake(SW*0.3, SH*0.7, SW*0.2, SH*0.125);
        _cashButton.frame = CGRectMake(SW*0.4, SH*0.825, SW*0.2, SH*0.125);
        [_menuButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    }
    else{
        _trashButton.frame = CGRectMake(SW*0.1 , SH*0.825 , SW*0.2, SH*0.125);
        _settingButton.frame = CGRectMake(SW*0.1 , SH*0.825 , SW*0.2, SH*0.125);
        _cashButton.frame = CGRectMake(SW*0.1 , SH*0.825 , SW*0.2, SH*0.125);
        [_menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    }
}


-(void)menuButtonPressed{
    NSLog(@"menu");
    //idle state
    if(_MODE==0){
        [UIView transitionWithView:_myCollectionView
                          duration:0.3
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            [self openSubButtonOfMenu:true];
                            
                        } completion:^(BOOL finished) {
                            _MODE = 3;
                        }];
    }
    //cell selected state
    else if(_MODE==1){
        [_myCollectionViewController menuButtonPressed];
        [UIView transitionWithView:_myCollectionView
                          duration:0.5
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            //light all things
                            for(UICollectionView *tmp in _myCollectionView.visibleCells)tmp.alpha = 1;
                            _addButton.alpha = 1;
                            //put back the selected icon
                            [_myCollectionView sendSubviewToBack:_currentCell];
                            _currentCell.frame = _saveRect;
                            _currentCell = nil;
                            //hide icon operation UI
                            _callButton.alpha= 0;
                            _shortcutButton.alpha = 0;
                            _iconName.alpha = 0;
                            
                            [_menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
                        } completion:^(BOOL finished) {
                            _MODE=0;
                        }];
    }
    // addButton be selected
    else if(_MODE==2){
        [UIView transitionWithView:_myCollectionView
                          duration:0.5
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            //light all things
                            _myCollectionView.frame = CGRectMake(0, 0 , SW, SH);
                            _myCollectionView.alpha = 1;
                            //move the button UI from center to out of screen
                            _addIconButton.frame =CGRectMake(SW*0.275, -SW*0.45 , SW*0.45, SW*0.45);
                            _addGroupButton.frame =CGRectMake(SW*0.275, -SW*0.45 , SW*0.45, SW*0.45);
                            _createGroup.frame = CGRectMake(-SW*0.8, SH*0.3, SW*0.8, SH*0.4);
                            
                            [_menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
                        } completion:^(BOOL finished) {
                            _MODE = 0;
                        }];
        
    }
    //menu subButton are opened state
    else if(_MODE==3){
        [UIView transitionWithView:_myCollectionView
                          duration:0.3
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            [self openSubButtonOfMenu:false];
                        } completion:^(BOOL finished) {
                            _MODE = 0;
                        }];
    }
    //trash state
    else if(_MODE==4){
        [UIView transitionWithView:_myCollectionView
                          duration:0.3
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            [self openSubButtonOfMenu:false];
                            //remove all the delete label on the view
                            for(int i = 0; i<[_deletes count] ; i++){
                                [(UIImageView*)[_deletes objectAtIndex:i]removeFromSuperview];
                            }
                        } completion:^(BOOL finished) {
                            _MODE = 0;
                        }];
    }
    
}


-(void)trashButtonPressed{
    _MODE = 4;
    //create delete lebal picture to all the cell
    for(int i = 0; i<[_myCollectionView  numberOfItemsInSection:0] ; i++){
         NSInteger block_num = [[AppStateManager getSharedInstance]getUserBlock];
        UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"delete.png"]];
        image.frame = CGRectMake((i%block_num)*(SW*1.0f/block_num)+SW*0.02 , (i/block_num)*(SW*0.475)+SH*0.1 , SW*0.08,  SW*0.08);
        [_myCollectionView addSubview:image];
        [_deletes addObject:image];
    }
    [UIView transitionWithView:_myCollectionView
                      duration:0.3
                       options:UIViewAnimationOptionCurveLinear
                    animations:^{
                        [self openSubButtonOfMenu:false];
                    } completion:^(BOOL finished) {
    }];
    [_myCollectionViewController trashButtonPressed];
}
-(void)settingButtonPressed{
    [_myCollectionViewController settingButtonPressed];
}
-(void)cashButtonPressed{
    [_myCollectionViewController cashButtonPressed];
}
-(void)callButtonPressed{
    [_myCollectionViewController callButtonPressed];
}
-(void)shortcutButtonPressed{
    [_myCollectionViewController shortcutButtonPressed];
}

-(void)addButtonPressed{
    if(_MODE!=0)return;
    [UIView transitionWithView:_myCollectionView
                      duration:0.3
                       options:UIViewAnimationOptionCurveLinear
                    animations:^{
                        //dark all things and show the addButton to center
                        _myCollectionView.alpha = 0.3;
                        _addIconButton.alpha = 1;
                        _addGroupButton.alpha = 1;
                        _addIconButton.frame = CGRectMake(SW*0.275, SH*0.15 , SW*0.45, SW*0.45);
                        _addGroupButton.frame = CGRectMake(SW*0.275, SH*0.5 , SW*0.45, SW*0.45);
                        [_menuButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
                        
                    } completion:^(BOOL finished) {
                        _MODE = 2;
                    }];

}
-(void)addIconButtonPressed{
    [self menuButtonPressed];
    [_myCollectionViewController addIconButtonPressed];
}
-(void)addGroupButtonPressed{
    [UIView transitionWithView:_myCollectionView
                      duration:0.3
                       options:UIViewAnimationOptionCurveLinear
                    animations:^{
                        //move from center to right of screen
                        _addIconButton.frame = CGRectMake(SW, SH*0.15 , SW*0.45, SW*0.45);
                        _addGroupButton.frame = CGRectMake(SW, SH*0.5 , SW*0.45, SW*0.45);
                        _createGroup.frame = CGRectMake(SW*0.1, SH*0.3, SW*0.8, SH*0.4);
                        [_menuButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
                        
                    } completion:^(BOOL finished) {
                        //finally put back to top of screen
                        _addIconButton.frame = CGRectMake(SW*0.275, -SW*0.45 , SW*0.45, SW*0.45);
                        _addGroupButton.frame = CGRectMake(SW*0.275, -SW*0.45 , SW*0.45, SW*0.45);
                    }];
}
-(void)color1ButtonPressed{
    FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPicker];
    colorPicker.color = _colorButton1.backgroundColor;
    colorButton = 1;
    colorPicker.delegate = self;
    [colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [_myCollectionViewController presentViewController:colorPicker animated:YES completion:nil];
}

-(void)color2ButtonPressed{
    FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPicker];
    colorPicker.color = _colorButton2.backgroundColor;
    colorButton = 2;
    colorPicker.delegate = self;
    [colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [_myCollectionViewController presentViewController:colorPicker animated:YES completion:nil];
}
-(void)createButtonPressed{
    const CGFloat *C1 = CGColorGetComponents([_colorButton1.backgroundColor CGColor]);
    const CGFloat *C2 = CGColorGetComponents([_colorButton2.backgroundColor CGColor]);
    
    NSString *colorStr = [NSString stringWithFormat:@"%f/%f/%f/%f/%f/%f" , C1[0] ,C1[1],C1[2] ,C2[0],C2[1], C2[2]];
    
    [_myCollectionViewController createGroupPressed:_groupName.text color:colorStr];
}

#pragma mark - FCColorPickerViewControllerDelegate Methods

-(void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
    if(colorButton==1)_colorButton1.backgroundColor = color;
    else if(colorButton==2)_colorButton2.backgroundColor = color;
    [_myCollectionViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker {
    [_myCollectionViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark init method

-(void)initButton{
    _trashButton = [[UIButton alloc] init];
    [_trashButton setFrame:CGRectMake(SW*0.1 , SH*0.825 , SW*0.2, SH*0.125)];
    [_trashButton setBackgroundImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
    [_trashButton addTarget:self action:@selector(trashButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_myCollectionViewController.view addSubview:_trashButton];
    
    _settingButton = [[UIButton alloc] init];
    [_settingButton setFrame:CGRectMake(SW*0.1 , SH*0.825 , SW*0.2, SH*0.125)];
    [_settingButton setBackgroundImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
    [_settingButton addTarget:self action:@selector(settingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_myCollectionViewController.view addSubview:_settingButton];
    
    _cashButton = [[UIButton alloc] init];
    [_cashButton setFrame:CGRectMake(SW*0.1 , SH*0.825 , SW*0.2, SH*0.125)];
    [_cashButton setBackgroundImage:[UIImage imageNamed:@"cash.png"] forState:UIControlStateNormal];
    [_cashButton addTarget:self action:@selector(cashButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_myCollectionViewController.view addSubview:_cashButton];
    
    _menuButton = [[UIButton alloc] init];
    [_menuButton setFrame:CGRectMake(SW*0.05, SH*0.8 , SW*0.3, SW*0.3)];
    [_menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [_menuButton addTarget:self action:@selector(menuButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_myCollectionViewController.view addSubview:_menuButton];
    
    _callButton = [[UIButton alloc] init];
    _callButton.alpha = 0;
    [_callButton setFrame:CGRectMake(SW*0.525, SH*0.5, SW*0.25, SW*0.25)];
    [_callButton setBackgroundImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateNormal];
    [_callButton addTarget:self action:@selector(callButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_myCollectionViewController.view addSubview:_callButton];
    
    _shortcutButton = [[UIButton alloc] init];
    _shortcutButton.alpha = 0;
    [_shortcutButton setFrame:CGRectMake(SW*0.225, SH*0.5, SW*0.25, SW*0.25)];
    [_shortcutButton setBackgroundImage:[UIImage imageNamed:@"shortcut.png"] forState:UIControlStateNormal];
    [_shortcutButton addTarget:self action:@selector(shortcutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_myCollectionViewController.view addSubview:_shortcutButton];
    
    _iconName = [[UILabel alloc]init];
    _iconName.alpha = 0;
    _iconName.autoresizingMask = UIViewAutoresizingNone;
    _iconName.font  = [UIFont systemFontOfSize:45];
    _iconName.textColor = [UIColor whiteColor];
    _iconName.center = _myCollectionViewController.view.center;
    _iconName.textAlignment = UITextAlignmentCenter;
    [_iconName setFrame:CGRectMake(0, -SH*0.05, SW, SH)];
    [_myCollectionViewController.view addSubview:_iconName];
    
    _addButton = [[UIButton alloc] init];
    [_addButton setTitle:@"Add New" forState:UIControlStateNormal];
    _addButton.titleLabel.font = [UIFont systemFontOfSize:25];
    [_addButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
    [_addButton setFrame:CGRectMake(SW*0.1, SH*0.025 , SW*0.8, SH*0.065)];
    [_addButton addTarget:self action:@selector(addButtonPressed)  forControlEvents:UIControlEventTouchUpInside];
    [_myCollectionViewController.view addSubview:_addButton];
    
    _addIconButton = [[UIButton alloc] init];
    [_addIconButton setTitle:@"New Icon" forState:UIControlStateNormal];
    _addIconButton.titleLabel.font = [UIFont systemFontOfSize:25];
    [_addIconButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
    _addIconButton.alpha = 0;
    [_addIconButton setFrame:CGRectMake(SW*0.275, -SW*0.45 , SW*0.45, SW*0.45)];
    [_addIconButton addTarget:self action:@selector(addIconButtonPressed)  forControlEvents:UIControlEventTouchUpInside];
    [_myCollectionViewController.view addSubview:_addIconButton];
    
    _addGroupButton = [[UIButton alloc] init];
    [_addGroupButton setTitle:@"New Group" forState:UIControlStateNormal];
    _addGroupButton.titleLabel.font = [UIFont systemFontOfSize:25];
    [_addGroupButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
    _addGroupButton.alpha = 0;
    [_addGroupButton setFrame:CGRectMake(SW*0.275, -SW*0.45 , SW*0.45, SW*0.45)];
    [_addGroupButton addTarget:self action:@selector(addGroupButtonPressed)  forControlEvents:UIControlEventTouchUpInside];
    [_myCollectionViewController.view addSubview:_addGroupButton];
    
    _createGroup = [[UIView alloc]init];
    [_createGroup setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
    [_createGroup setFrame:CGRectMake(-SW*0.8, SH*0.3, SW*0.8, SH*0.4)];
    [_myCollectionViewController.view addSubview:_createGroup];
    
    _groupName = [[UITextField alloc]init];
    [_groupName setBackgroundColor:[UIColor whiteColor]];
    [_groupName setFrame:CGRectMake((_createGroup.frame.size.width-SW*0.45)/2 , SH*0.03 , SW*0.45, SH*0.07)];
    [_groupName setFont:[UIFont boldSystemFontOfSize:25]];
    [_createGroup addSubview:_groupName];
    
    _colorButton1 = [[UIButton alloc] init];
    [_colorButton1 setTitle:@"Background Color" forState:UIControlStateNormal];
    _colorButton1.titleLabel.font = [UIFont systemFontOfSize:15];
    [_colorButton1 setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]];
    [_colorButton1 setFrame:CGRectMake((_createGroup.frame.size.width-SW*0.45)/2 , SH*0.13 , SW*0.45, SH*0.07)];
    [_colorButton1 addTarget:self action:@selector(color1ButtonPressed)  forControlEvents:UIControlEventTouchUpInside];
    [_createGroup addSubview:_colorButton1];
    
    _colorButton2 = [[UIButton alloc] init];
    [_colorButton2 setTitle:@"Title Color" forState:UIControlStateNormal];
    _colorButton2.titleLabel.font = [UIFont systemFontOfSize:15];
    [_colorButton2 setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]];
    [_colorButton2 setFrame:CGRectMake((_createGroup.frame.size.width-SW*0.45)/2 , SH*0.23 , SW*0.45, SH*0.07)];
    [_colorButton2 addTarget:self action:@selector(color2ButtonPressed)  forControlEvents:UIControlEventTouchUpInside];
    [_createGroup addSubview:_colorButton2];
    
    _createButton = [[UIButton alloc]init];
    [_createButton setTitle:@"Create" forState:UIControlStateNormal];
    _createButton.titleLabel.font = [UIFont systemFontOfSize:25];
    [_createButton setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]];
    [_createButton setFrame:CGRectMake((_createGroup.frame.size.width-SW*0.2)/2 , SH*0.33 , SW*0.2, SH*0.07)];
    [_createButton addTarget:self action:@selector(createButtonPressed)  forControlEvents:UIControlEventTouchUpInside];
    [_createGroup addSubview:_createButton];
    
}



@end
