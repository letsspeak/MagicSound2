//
//  MagicSoundAppDelegate.m
//  MagicSound
//
//  Created by masa on 12/02/02.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "MagicSoundAppDelegate.h"
#import "TitleViewController.h"
#import "PlayViewController.h"
#import "GameViewController.h"
#import "EditViewController.h"
#import "OptionViewController.h"

// NSString から NSNumber(unsigned long long)への変換時に使用
unsigned long long myfanc(const char *p)
{
	unsigned long long n = 0;
	/* 数値の取得 */
	while (isdigit(*p)) {
		n = n * 10 + *p - '0';
		p++;
	}
	/* 結果を返す */
	return n;
}

void* GetOpenALAudioData(CFURLRef fileURL, ALsizei* dataSize, ALenum* dataFormat, ALsizei *sampleRate)
{
    OSStatus    err;
    UInt32      size;
    
    // オーディオファイルを開く
    ExtAudioFileRef audioFile;
    err = ExtAudioFileOpenURL(fileURL, &audioFile);
    if (err) {
        goto Exit;
    }
    
    // オーディオデータフォーマットを取得する
    AudioStreamBasicDescription fileFormat;
    size = sizeof(fileFormat);
    err = ExtAudioFileGetProperty(
                                  audioFile, kExtAudioFileProperty_FileDataFormat, &size, &fileFormat);
    if (err) {
        goto Exit;
    }
    
    // アウトプットフォーマットを設定する
    AudioStreamBasicDescription outputFormat;
    outputFormat.mSampleRate = fileFormat.mSampleRate;
    outputFormat.mChannelsPerFrame = fileFormat.mChannelsPerFrame;
    outputFormat.mFormatID = kAudioFormatLinearPCM;
    outputFormat.mBytesPerPacket = 2 * outputFormat.mChannelsPerFrame;
    outputFormat.mFramesPerPacket = 1;
    outputFormat.mBytesPerFrame = 2 * outputFormat.mChannelsPerFrame;
    outputFormat.mBitsPerChannel = 16;
    outputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    err = ExtAudioFileSetProperty(
                                  audioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(outputFormat), &outputFormat);
    if (err) {
        goto Exit;
    }
    
    // フレーム数を取得する
    SInt64  fileLengthFrames = 0;
    size = sizeof(fileLengthFrames);
    err = ExtAudioFileGetProperty(
                                  audioFile, kExtAudioFileProperty_FileLengthFrames, &size, &fileLengthFrames);
    if (err) {
        goto Exit;
    }
    
    // バッファを用意する
    UInt32          bufferSize;
    void*           data;
    AudioBufferList dataBuffer;
    bufferSize = fileLengthFrames * outputFormat.mBytesPerFrame;;
    data = malloc(bufferSize);
    dataBuffer.mNumberBuffers = 1;
    dataBuffer.mBuffers[0].mDataByteSize = bufferSize;
    dataBuffer.mBuffers[0].mNumberChannels = outputFormat.mChannelsPerFrame;
    dataBuffer.mBuffers[0].mData = data;
    
    // バッファにデータを読み込む
    err = ExtAudioFileRead(audioFile, (UInt32*)&fileLengthFrames, &dataBuffer);
    if (err) {
        free(data);
        goto Exit;
    }
    
    // 出力値を設定する
    *dataSize = (ALsizei)bufferSize;
    *dataFormat = (outputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
    *sampleRate = (ALsizei)outputFormat.mSampleRate;
    
Exit:
    // オーディオファイルを破棄する
    if (audioFile) {
        ExtAudioFileDispose(audioFile);
    }
    
    return data;
}




@implementation MagicSoundAppDelegate

@synthesize userMediaItemCollection;
@synthesize musicPlayer;
@synthesize playedMusicOnce;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    /*
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        magicSoundViewController = [[MagicSoundViewController alloc] initWithNibName:@"MagicSoundViewController_iPhone" bundle:nil];
    } else {
        magicSoundViewController = [[MagicSoundViewController alloc] initWithNibName:@"MagicSoundViewController_iPad" bundle:nil];
    }
     */
    
    titleViewController = [[TitleViewController alloc] initWithNibName:@"TitleViewController" bundle:nil];
    playViewController = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
    gameViewController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    editViewController = [[EditViewController alloc] initWithNibName:@"EditViewController" bundle:nil];
    optionViewController = [[OptionViewController alloc] initWithNibName:@"OptionViewController" bundle:nil];
    
    titleViewController.delegate = self;
    playViewController.delegate = self;
    gameViewController.delegate = self;
    editViewController.delegate = self;
    optionViewController.delegate = self;
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:titleViewController];
    navigationController.navigationBarHidden = YES;
    
    // ステータスバーを黒に更新
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
    
    /*
     [self setupApplicationAudio];
     
     [self setPlayedMusicOnce: NO];
     
     [self setNoArtworkImage:	[UIImage imageNamed: @"no_artwork.png"]];		
     
     [self setPlayBarButton:		[[UIBarButtonItem alloc]	initWithBarButtonSystemItem: UIBarButtonSystemItemPlay
     target: self
     action: @selector (playOrPauseMusic:)]];
     
     [self setPauseBarButton:	[[UIBarButtonItem alloc]	initWithBarButtonSystemItem: UIBarButtonSystemItemPause
     target: self
     action: @selector (playOrPauseMusic:)]];
     
     [addOrShowMusicButton	setTitle: NSLocalizedString (@"Add Music", @"Title for 'Add Music' button, before user has chosen some music")
     forState: UIControlStateNormal];
     
     [appSoundButton			setTitle: NSLocalizedString (@"Play App Sound", @"Title for 'Play App Sound' button")
     forState: UIControlStateNormal];
     
     [nowPlayingLabel setText: NSLocalizedString (@"Instructions", @"Brief instructions to user, shown at launch")];
     
     */
    
    
	// Registers this class as the delegate of the audio session.
	[[AVAudioSession sharedInstance] setDelegate: self];
	
	// The AmbientSound category allows application audio to mix with Media Player
	// audio. The category also indicates that application audio should stop playing 
	// if the Ring/Siilent switch is set to "silent" or the screen locks.
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
    /*
     // Use this code instead to allow the app sound to continue to play when the screen is locked.
     [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
     
     UInt32 doSetProperty = 0;
     AudioSessionSetProperty (
     kAudioSessionProperty_OverrideCategoryMixWithOthers,
     sizeof (doSetProperty),
     &doSetProperty
     );
     */
    
    /*
	// Registers the audio route change listener callback function
	AudioSessionAddPropertyListener (
                                     kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     self
                                     );
    
     */
    
	// Activates the audio session.
	
	//NSError *activationError = nil;
	//[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    

    
    
	if ([self useiPodPlayer]) {
        
		musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
		
	} else {
        
		musicPlayer = [MPMusicPlayerController applicationMusicPlayer];

		[musicPlayer setShuffleMode: MPMusicShuffleModeOff];
		[musicPlayer setRepeatMode: MPMusicRepeatModeNone];
	}	
    
    // 曲リストの読み込み
    [self loadUserMediaItemCollection];
    
     
    /////////////////////////////////////////////////////////
    // OpenAL
    
    // OpneALデバイスを開く
    ALCdevice*  device;
    device = alcOpenDevice(NULL);
    
    // OpenALコンテキスを作成して、カレントにする
    ALCcontext* alContext;
    alContext = alcCreateContext(device, NULL);
    alcMakeContextCurrent(alContext);
    
    // バッファとソースを作成する
    alGenBuffers(8, _buffers);
    alGenSources(8, _sources);
    
    int i;
    for (i = 0; i < 8; i++) {
        // サウンドファイルパスを取得する
        NSString*   fileName = nil;
        NSString*   path;
        switch (i) {
            case 0: fileName = @"C4"; break;
            case 1: fileName = @"C#4"; break;
            case 2: fileName = @"D4"; break;
            case 3: fileName = @"D#4"; break;
            case 4: fileName = @"E4"; break;
            case 5: fileName = @"F4"; break;
            case 6: fileName = @"F#4"; break;
            case 7: fileName = @"G4"; break;
        }
        path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"caf"];
        
        // オーディオデータを取得する
        void*   audioData;
        ALsizei dataSize;
        ALenum  dataFormat;
        ALsizei sampleRate;
        audioData = GetOpenALAudioData((__bridge CFURLRef)[NSURL fileURLWithPath:path], &dataSize, &dataFormat, &sampleRate);
        
        // データをバッファに設定する
        alBufferData(_buffers[i], dataFormat, audioData, dataSize, sampleRate);
        
        // バッファをソースに設定する
        alSourcei(_sources[i], AL_BUFFER, _buffers[i]);
    }
        
    /////////////////////////////////////////////////////////
    
    [window addSubview:navigationController.view];     
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

-(void)pushPlayViewController
{
    // テーブルを更新
    [playViewController.mediaItemCollectionTable reloadData];
    [navigationController pushViewController:playViewController animated:YES];
    
    // ステータスバーを白に更新
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated: YES];
}

-(void)pushGameViewController
{
    [navigationController pushViewController:gameViewController animated:YES];
    
    // 曲の再生を指示
    [gameViewController playMusic];
}

-(void)pushEditViewController
{
    // テーブルを更新
    [editViewController.mediaItemCollectionTable reloadData];
    [navigationController pushViewController:editViewController animated:YES];
}

-(void)pushOptionViewController
{
    [navigationController pushViewController:optionViewController animated:YES];
    // ステータスバーを白に更新
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated: YES];
}

-(void)popBackToTitleViewController
{
    [navigationController popToRootViewControllerAnimated:YES];
    // ステータスバーを黒に更新
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
}

-(void)popViewController
{
    [navigationController popViewControllerAnimated:YES];
}


- (BOOL) useiPodPlayer
    {
    
	if ([[NSUserDefaults standardUserDefaults] boolForKey: PLAYER_TYPE_PREF_KEY]) {
		return YES;		
	} else {
		return NO;
	}
    
}

// EditViewControllerからMediaPickerでの曲選択後に呼び出される関数
- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
    
	// Configure the music player, but only if the user chose at least one song to play
	if (mediaItemCollection) {
        
		// If there's no playback queue yet...
		if (userMediaItemCollection == nil) {
            
			// apply the new media item collection as a playback queue for the music player
			userMediaItemCollection = mediaItemCollection;
			//[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
            //playedMusicOnce = YES;
			
            //[musicPlayer play];
            
            /*
            //////////// Debug ///////////////
            
            
            MPMediaItem *mediaItem = [[mediaItemCollection items] objectAtIndex:0];
            NSLog(@"MPMediaItemPropertyPersistentID = %@", [mediaItem valueForProperty:MPMediaItemPropertyPersistentID]);
            NSLog(@"MPMediaItemPropertyAlbumPersistentID = %@", [mediaItem valueForProperty:MPMediaItemPropertyAlbumPersistentID]);
            
            
            //////////// Debug ///////////////
             */
            
		} else {
            
            /*
			// Take note of whether or not the music player is playing. If it is
			//		it needs to be started again at the end of this method.
			BOOL wasPlaying = NO;
			if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
				wasPlaying = YES;
			}
			
			// Save the now-playing item and its current playback time.
			MPMediaItem *nowPlayingItem			= musicPlayer.nowPlayingItem;
			NSTimeInterval currentPlaybackTime	= musicPlayer.currentPlaybackTime;
             */
            
			// Combine the previously-existing media item collection with the new one
			NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];
			NSArray *newMediaItems				= [mediaItemCollection items];
			[combinedMediaItems addObjectsFromArray: newMediaItems];
			
			[self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: (NSArray *) combinedMediaItems]];
            
            /*
			// Apply the new media item collection as a playback queue for the music player.
			[musicPlayer setQueueWithItemCollection: userMediaItemCollection];
			
			// Restore the now-playing item and its current playback time.
			musicPlayer.nowPlayingItem			= nowPlayingItem;
			musicPlayer.currentPlaybackTime		= currentPlaybackTime;
			
			// If the music player was playing, get it playing again.
			if (wasPlaying) {
				[musicPlayer play];
			}
             */
		}
        
		// Finally, because the music player now has a playback queue, ensure that 
		//		the music play/pause button in the Navigation bar is enabled.
		
	}

    // 曲リストの保存
    [self saveUserMediaItemCollection];
}

// テーブルで選択された曲のpersistendIDを(NSNumber)selectedMusicにわたす関数
- (void)selectMusicFromMediaItemCollection:(NSUInteger)index;
{
    MPMediaItem *mediaItem = [[userMediaItemCollection items] objectAtIndex:index];
    NSLog(@"MPMediaItemPropertyPersistentID = %@", [mediaItem valueForProperty:MPMediaItemPropertyPersistentID]);
    
    selectedMusic = [mediaItem valueForProperty:MPMediaItemPropertyPersistentID];
}

// EditViewで削除指定された曲をuserMediaItemCollectionから削除する関数
- (void)deleteMusicFromMediaItemCollection:(NSUInteger)index;
{
    if([userMediaItemCollection count] == 1){
        // 最後の要素を削除した場合は削除フェーズではなくnilセットで対処する
        [self setUserMediaItemCollection:nil];
    }else{
        NSMutableArray *deletedMediaItems	= [[userMediaItemCollection items] mutableCopy];
        [deletedMediaItems removeObjectAtIndex:index];
        [self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: (NSArray *) deletedMediaItems]];        
    }
    
    // 曲リストの保存
    [self saveUserMediaItemCollection];

}

// selectedMusic(persistentID)からqueryとMediaItemを生成して保存する関数
-(void)createQueryAndMediaItemCollectionFromSelectedMusic
{
    if(!selectedMusic){
        NSLog(@"ERROR : selectedMusic is nil.");
        return;
    }
    
    // MediaQueryの生成
    playMediaQuery = [MPMediaQuery songsQuery];
    MPMediaPropertyPredicate * pred;
    pred = [MPMediaPropertyPredicate predicateWithValue:selectedMusic
                                            forProperty:MPMediaItemPropertyPersistentID
                                         comparisonType:MPMediaPredicateComparisonEqualTo];
    [playMediaQuery addFilterPredicate:pred];
    
    // MediaItemColelctionの生成
    NSArray *playArray = [playMediaQuery items];
    MPMediaItemCollection *playMediaItemCollection = [[MPMediaItemCollection alloc] initWithItems:playArray];
    playMediaItem = [[playMediaItemCollection items] objectAtIndex:0];
    
}

- (NSNumber*)getPlaybackDurationOfSelectedMusic
{
    if(playPlaybackDuration) return playPlaybackDuration;
    

    if(!playMediaItem){
        NSLog(@"ERROR : playMediaItem is nil.");
        return nil;
    }
    
    // 曲の長さを取得して保存
    playPlaybackDuration = [playMediaItem valueForProperty: MPMediaItemPropertyPlaybackDuration];
    return playPlaybackDuration;
}

// createで生成されたQueryをもとに曲を再生する関数
- (void)playSelectedMusic
{
    if(!playMediaQuery){
        NSLog(@"ERROR : playMediaQuery is nil.");
        return;
    }
    
    // Queryをセットして曲の再生を開始する
    [musicPlayer setQueueWithQuery:playMediaQuery];
    [musicPlayer play];
}


// 曲の再生を停止する関数
- (void)stopMusic
{
    // 曲の再生にかかわる各要素をnilで上書きしておく
    playMediaQuery = nil;
    playMediaItem = nil;
    playPlaybackDuration = nil;

    // 再生を停止する
    [musicPlayer stop];
}

// 再生中の曲のPlaybackTimeを取得する関数
- (NSTimeInterval)getCurrentPlaybackTimeOfPlayingMusic
{
    return [musicPlayer currentPlaybackTime];
}

// UserMediaItemCollectionの内容をUserDefaultsに保存する関数
- (void)saveUserMediaItemCollection
{
    NSLog(@"saveUserMediaItemCollection called.");
    
     if([userMediaItemCollection count]){
         
         NSMutableArray *persistentArray = [NSMutableArray array];
         
         // userMediaItemのpersitentIDをNSMutableArray->NSStringに格納する
         for(NSUInteger i = 0; i < [userMediaItemCollection count]; i++){        
             MPMediaItem *mediaItem = [[userMediaItemCollection items] objectAtIndex:i];
             NSString *persistentID = [[NSString alloc] initWithFormat:@"%@",
                                       [mediaItem valueForProperty: MPMediaItemPropertyPersistentID]];
             [persistentArray addObject:persistentID];
             
             //test code
             NSLog(@"save persistentID = %@", persistentID);
        }
        
         // NSMutableArrayを保存する
         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
         [userDefaults setObject:persistentArray forKey:USER_MEDIA_ITEMS_KEY];
         [userDefaults synchronize];
        
    }
}
     
// UserMediaItemCollectionの内容をUserDefaultsから読み込む関数
- (void)loadUserMediaItemCollection
{
    NSLog(@"loadUserMediaItemCollection called.");
    NSArray *loadMediaItems = [[NSUserDefaults standardUserDefaults] objectForKey:USER_MEDIA_ITEMS_KEY];
    
    if(loadMediaItems){
        NSLog(@"loadMediaItems is not nil");
                
        // 取得した配列の全要素を復元する
        for(NSUInteger i = 0; i < [loadMediaItems count]; i++){
            
            // NSStringからNSNumberへ復元する
            NSString *persistentString = [loadMediaItems objectAtIndex:i];
            const char *pS= [persistentString UTF8String];                          //C言語で使える文字列に変換する
            unsigned long long pid_num = myfanc(pS);                                //変換する
            NSNumber *persistentID = [NSNumber numberWithUnsignedLongLong:pid_num]; //Number型に直す
            
            // for debug
            NSLog(@"persistentID(NSNumber) = %@", persistentID);
            
            // persistentIDをもとにqueryを生成しHitしたMPMediaItemをNSArrayに格納する
            MPMediaQuery *query = [[MPMediaQuery alloc] init]; // songsQuery];
            MPMediaPropertyPredicate * pred;
            pred = [MPMediaPropertyPredicate predicateWithValue:persistentID
                                                    forProperty:MPMediaItemPropertyPersistentID
                                                 comparisonType:MPMediaPredicateComparisonEqualTo];
            [query addFilterPredicate:pred];
            NSArray *addMediaItems = [query items];
            
            // HitしたMPMediaItemをuserMediaItemCollectionに格納する
            if(addMediaItems){
                if(userMediaItemCollection){
                    // queryから生成したアイテムと既存アイテムを結合して保存する
                    NSMutableArray *combinedMediaItems	= [[userMediaItemCollection items] mutableCopy];                
                    NSArray *addMediaItems = [query items];
                    [combinedMediaItems addObjectsFromArray: addMediaItems];
                    [self setUserMediaItemCollection: [MPMediaItemCollection collectionWithItems: (NSArray *) combinedMediaItems]];
                }else{
                    // NSArray(MPMediaItem)からMPMediaItemCollectionを生成する
                    userMediaItemCollection = [[MPMediaItemCollection alloc] initWithItems:addMediaItems];
                }
            }
            
        }

    }    
}

// OpenALTest
- (void)OpenALSoundTestPlay;
{
    // オーディオを再生する
    alSourcePlay(_sources[0]);

}


@end
