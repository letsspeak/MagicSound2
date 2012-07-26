//
//  GameViewController.h
//  MagicSound
//
//  Created by masa on 12/02/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@interface GameViewController : UIViewController{
    NSTimer     *playbackTimer;
}

@property (nonatomic, strong) id<MagicSoundDelegate> delegate;

-(IBAction)doneButtonDidPush:(id)sender;

-(void)playMusic;
-(void)tickPlaybackTimer:(NSTimer*)timer;

@end
