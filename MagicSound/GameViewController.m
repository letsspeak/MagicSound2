//
//  GameViewController.m
//  MagicSound
//
//  Created by masa on 12/02/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"

@implementation GameViewController

@synthesize delegate;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)doneButtonDidPush:(id)sender
{
    [playbackTimer invalidate];
    
    [delegate stopMusic];
    [delegate popViewController];
}

-(void)playMusic
{
    [delegate createQueryAndMediaItemCollectionFromSelectedMusic];
    
    NSNumber *playbackDuration = [delegate getPlaybackDurationOfSelectedMusic];
    NSLog(@"playbackDuration = %@", playbackDuration);
    
    [delegate playSelectedMusic];
    
    // タイマーを生成
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self
                                                   selector:@selector(tickPlaybackTimer:)
                                                   userInfo:nil repeats:YES];    
}

-(void)tickPlaybackTimer:(NSTimer*)timer
{
    NSTimeInterval currentPlayback = [delegate getCurrentPlaybackTimeOfPlayingMusic];
    NSLog(@"currentPlayback = %f", currentPlayback);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan called.");
    [delegate OpenALSoundTestPlay];
}

@end
