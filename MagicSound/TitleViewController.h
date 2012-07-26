//
//  TitleViewController.h
//  MagicSound
//
//  Created by masa on 12/02/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@interface TitleViewController : UIViewController

@property (nonatomic, strong) id<MagicSoundDelegate> delegate;

-(IBAction)playButtonDidPush:(id)sender;
-(IBAction)editButtonDidPush:(id)sender;
-(IBAction)optionButtonDidPush:(id)sender;

@end
