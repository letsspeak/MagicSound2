//
//  PlayViewController.h
//  MagicSound
//
//  Created by masa on 12/02/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@interface PlayViewController : UIViewController<UITableViewDelegate>

@property (nonatomic, strong) id<MagicSoundDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *mediaItemCollectionTable;

-(IBAction)backButtonDidPush:(id)sender;

@end
