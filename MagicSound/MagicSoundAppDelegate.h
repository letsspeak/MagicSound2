//
//  MagicSoundAppDelegate.h
//  MagicSound
//
//  Created by masa on 12/02/02.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>

#import "Defines.h"
#import "TitleViewController.h"
#import "PlayViewController.h"
#import "GameViewController.h"
#import "EditViewController.h"
#import "OptionViewController.h"

#define PLAYER_TYPE_PREF_KEY @"player_type_preference"
#define USER_MEDIA_ITEMS_KEY @"user_media_items"

unsigned long long myfanc(const char *p);
void* GetOpenALAudioData(CFURLRef fileURL, ALsizei* dataSize, ALenum* dataFormat, ALsizei *sampleRate);

@interface MagicSoundAppDelegate : UIResponder <UIApplicationDelegate, MagicSoundDelegate>{

    UIWindow *window;
    UINavigationController *navigationController;
    
    // ViewControllers
    TitleViewController *titleViewController;
    PlayViewController *playViewController;
    GameViewController *gameViewController;
    EditViewController *editViewController;
    OptionViewController *optionViewController;
    
    // MusicPlayer
    MPMediaItemCollection		*userMediaItemCollection;
    MPMusicPlayerController		*musicPlayer;
    NSNumber                    *selectedMusic;
    BOOL						playedMusicOnce;
    
    // 再生のためのデータ保持用
    MPMediaQuery                *playMediaQuery;
    MPMediaItem                 *playMediaItem;
    NSNumber                    *playPlaybackDuration;
    
    // for OpenAL
    ALuint  _buffers[8];
    ALuint  _sources[8];
    
}

@property (nonatomic, strong) MPMediaItemCollection	*userMediaItemCollection;
@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property (readwrite) BOOL playedMusicOnce;

///////////////////////////////////////////////////////////////
// MagicSoundDelegate method

// ViewControllers
-(void)pushPlayViewController;
-(void)pushGameViewController;
-(void)pushEditViewController;
-(void)pushOptionViewController;
-(void)popBackToTitleViewController;
-(void)popViewController;

// MPMediaItemCollection & MusicPlayer
- (BOOL)useiPodPlayer;
- (void)updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection;
- (void)selectMusicFromMediaItemCollection:(NSUInteger)index;
- (void)deleteMusicFromMediaItemCollection:(NSUInteger)index;
- (void)createQueryAndMediaItemCollectionFromSelectedMusic;
- (NSNumber*)getPlaybackDurationOfSelectedMusic;
- (void)playSelectedMusic;
- (void)stopMusic;
- (NSTimeInterval)getCurrentPlaybackTimeOfPlayingMusic;

// OpenALTest
- (void)OpenALSoundTestPlay;

///////////////////////////////////////////////////////////////

// for MPMediaItemCollection
- (void)saveUserMediaItemCollection;
- (void)loadUserMediaItemCollection;

@end
