//
//  GroupMenu.m
//  treasurebowl
//
//  Created by SunDaMac on 2015/8/9.
//  Copyright (c) 2015年 AtSu. All rights reserved.
//

#import "GroupMenu.h"
#import "GroupViewController.h"

@interface GroupMenu()

@property() UICollectionView *myCollectionView ;
@property() UIView* norm_view;
@property() GroupViewController *myCollectionViewController;
@property() GroupViewController* norm_viewController;
@property() UICollectionViewCell *currentCell;
@property() CGRect saveRect;
@property() UIButton *backButton;
@property() UIButton *menuButton ,*callButton ,*shareButton ,*shortcutButton , *modifyButton;
@property() UIButton *trashButton , *settingButton , *cashButton;
@property() NSMutableArray* deletes;
@property() UILabel* iconName;
@property() Icon*currentIcon;
@end

int SW ,SH;

@implementation GroupMenu

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


-(void)initButton{
    
    _backButton = [[UIButton alloc]init];
    [_backButton setFrame:CGRectMake(SW*0 , SH*0 , SW*0.2, SH*0.125)];
    [_backButton  setBackgroundImage:[UIImage imageNamed:@"groupback.png"] forState:UIControlStateNormal];
    [_backButton  addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_myCollectionViewController.view addSubview:_backButton ];
    
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
    
    _shareButton = [[UIButton alloc] init];
    _shareButton.alpha = 0;
    [_shareButton setFrame:CGRectMake(SW*0.225, SH*0.5, SW*0.25, SW*0.25)];
    [_shareButton setBackgroundImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(shareButtonPressed)  forControlEvents:UIControlEventTouchUpInside];
    [_myCollectionViewController.view addSubview:_shareButton];
    
    _modifyButton = [[UIButton alloc] init];
    _modifyButton.alpha = 0;
    [_modifyButton setFrame:CGRectMake(SW*0.525, SH*0.65, SW*0.25, SW*0.25)];
    [_modifyButton setBackgroundImage:[UIImage imageNamed:@"modify.png"] forState:UIControlStateNormal];
    [_modifyButton addTarget:self action:@selector(modifyButtonPressed)  forControlEvents:UIControlEventTouchUpInside];
    [_myCollectionViewController.view addSubview:_modifyButton];
    
    _shortcutButton = [[UIButton alloc] init];
    _shortcutButton.alpha = 0;
    [_shortcutButton setFrame:CGRectMake(SW*0.225, SH*0.65, SW*0.25, SW*0.25)];
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
}

-(void)setIcon:(Icon*)icon{
    _currentIcon = icon;
}

-(void)chooseCell:(NSIndexPath *)indexPath{
    
    if(_MODE == 0){
        //catch the cell user choose
        UICollectionViewCell *cell =[_myCollectionView cellForItemAtIndexPath:indexPath];
        
        [UIView transitionWithView:_myCollectionView
                          duration:0.5
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            //any animatable attribute here.
                            for(UICollectionView *tmp in _myCollectionView.visibleCells){
                                //add animation to all cell here
                                tmp.alpha = 0.3;
                            }
                            
                            _currentCell = cell;
                            _currentCell.alpha=1;
                            _saveRect = _currentCell.frame;
                            //move to center
                            _currentCell.frame = CGRectMake(SW*0.25, SH*0.1+_myCollectionView.contentOffset.y, SW*0.5, SW*0.5);
                            //put cell in front of all cells
                            [_myCollectionView bringSubviewToFront:_currentCell];
                            
                            _callButton.alpha = 1;
                            _shareButton.alpha = 1;
                            _modifyButton.alpha = 1;
                            _shortcutButton.alpha = 1;
                            
                            _iconName.text = _currentIcon.name;
                            _iconName.alpha = 1;
                            
                            [_menuButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
                            
                        } completion:^(BOOL finished) {
                            //whatever you want to do upon completion
                            _MODE = 1;
                        }];
        
    }
    
}


-(void)menuButtonPressed{
    NSLog(@"menu");
    if(_MODE==0){
        [UIView transitionWithView:_myCollectionView
                          duration:0.3
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            _trashButton.frame = CGRectMake(SW*0.13, SH*0.64, SW*0.2, SH*0.125);
                            _settingButton.frame = CGRectMake(SW*0.3, SH*0.7, SW*0.2, SH*0.125);
                            _cashButton.frame = CGRectMake(SW*0.4, SH*0.825, SW*0.2, SH*0.125);
                            [_menuButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
                        } completion:^(BOOL finished) {
                            _MODE = 3;
                        }];
    }
    else if(_MODE==1){
        [UIView transitionWithView:_myCollectionView
                          duration:0.5
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            //any animatable attribute here.
                            
                            
                            // modified 0713: check instance, if the press call is from collectionView
                            // do the following things(handle cells)
                            for(UICollectionView *tmp in _myCollectionView.visibleCells){
                                //add animation to cell here
                                tmp.alpha = 1;
                                
                                [_myCollectionView sendSubviewToBack:_currentCell];
                                _currentCell.frame = _saveRect;
                                _currentCell = nil;
                            }
                            //[_myCollectionViewController menuButtonPressed];
                            
                            _callButton.alpha= 0;
                            _shareButton.alpha = 0;
                            _modifyButton.alpha = 0;
                            _shortcutButton.alpha = 0;
                            _iconName.alpha = 0;
                            
                            [_menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
                        } completion:^(BOOL finished) {
                            _MODE=0;
                        }];
    }
    else if(_MODE==2){
        [UIView transitionWithView:_myCollectionView
                          duration:0.5
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            
                            _myCollectionView.frame = CGRectMake(0, 0 , SW, SH);
                            _myCollectionView.alpha = 1;
                            
                            [_menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
                            
                        } completion:^(BOOL finished) {
                            //whatever you want to do upon completion
                            _MODE = 0;
                        }];
        
    }
    else if(_MODE==3){
        [UIView transitionWithView:_myCollectionView
                          duration:0.3
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            _trashButton.frame = CGRectMake(SW*0.1 , SH*0.825 , SW*0.2, SH*0.125);
                            _settingButton.frame = CGRectMake(SW*0.1 , SH*0.825 , SW*0.2, SH*0.125);
                            _cashButton.frame = CGRectMake(SW*0.1 , SH*0.825 , SW*0.2, SH*0.125);
                            [_menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
                        } completion:^(BOOL finished) {
                            _MODE = 0;
                        }];
    }
    else if(_MODE==4){
        [UIView transitionWithView:_myCollectionView
                          duration:0.3
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            _trashButton.frame = CGRectMake(SW*0.1 , SH*0.825 , SW*0.2, SH*0.125);
                            _settingButton.frame = CGRectMake(SW*0.1 , SH*0.825 , SW*0.2, SH*0.125);
                            _cashButton.frame = CGRectMake(SW*0.1 , SH*0.825 , SW*0.2, SH*0.125);
                            [_menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
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
    for(int i = 0; i<[_myCollectionView  numberOfItemsInSection:0] ; i++){
        
        UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"delete.png"]];
        image.frame = CGRectMake((i%2)*(SW*0.5)+SW*0.02 , (i/2)*(SW*0.475)+SH*0.07 , SW*0.1,  SW*0.1);
        
        [_myCollectionView addSubview:image];
        [_deletes addObject:image];
    }
    
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
-(void)shareButtonPressed{
     [_myCollectionViewController shareButtonPressed];
}
-(void)modifyButtonPressed{
    [_myCollectionViewController modifyButtonPressed];
}
-(void)shortcutButtonPressed{
    [_myCollectionViewController shortcutButtonPressed];
}
-(void)backButtonPressed{
    [_myCollectionViewController dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark forNormalController

-(void)initMenuButtonForReturn {
    
    // this method is for creating a menu button //
    // which can only navigate back to main menu //
    
    _menuButton = [[UIButton alloc] init];
    [_menuButton setFrame:CGRectMake(SW*0.05, SH*0.8 , SW*0.3, SW*0.3)];
    [_menuButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [_menuButton addTarget:self action:@selector(returnButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_norm_viewController.view addSubview:_menuButton];
}

-(void)returnButtonPressed {
    //[_norm_viewController  menuButtonPressed];
    _callButton.alpha= 0;
    _shareButton.alpha = 0;
    
    [_menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
}


@end
