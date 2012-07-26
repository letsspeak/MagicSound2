//
//  Defines.h
//  MagicSound
//
//  Created by masa on 12/02/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol MagicSoundDelegate

// Methods for ViewController
-(void)pushPlayViewController;
-(void)pushGameViewController;
-(void)pushEditViewController;
-(void)pushOptionViewController;
-(void)popBackToTitleViewController;
-(void)popViewController;

// Methods for Media Playey
- (BOOL) useiPodPlayer;
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection;
- (void)selectMusicFromMediaItemCollection:(NSUInteger)index;
- (void)deleteMusicFromMediaItemCollection:(NSUInteger)index;
- (void)createQueryAndMediaItemCollectionFromSelectedMusic;
- (NSNumber*)getPlaybackDurationOfSelectedMusic;
- (void)playSelectedMusic;
- (void)stopMusic;
- (NSTimeInterval)getCurrentPlaybackTimeOfPlayingMusic;

// OpenALTest
- (void)OpenALSoundTestPlay;


@end