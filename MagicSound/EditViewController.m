//
//  EditViewController.m
//  MagicSound
//
//  Created by masa on 12/02/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MagicSoundAppDelegate.h"
#import "EditViewController.h"

@implementation EditViewController

static NSString *kCellIdentifier = @"Cell";

@synthesize delegate;
@synthesize mediaItemCollectionTable;

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

- (void)viewDidAppear:(BOOL)animated
{    
    [super viewDidAppear:animated];
    // [self.mediaItemCollectionTable setEditing:YES animated:YES];    
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
     
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

-(IBAction)backButtonDidPush:(id)sender
{
    [delegate popBackToTitleViewController];
}

-(IBAction)addButtonDidPush:(id)sender
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    
    
    picker.delegate						= self;
    picker.allowsPickingMultipleItems	= NO;   // 追加できる曲は1曲ずつ
    picker.prompt						= NSLocalizedString (@"Add music to Edit list", "Prompt in media item picker");
    
    // The media item picker uses the default UI style, so it needs a default-style
    //		status bar to match it visually
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated: YES];
    
    [self presentModalViewController: picker animated: YES];
}

#pragma mark Media item picker delegate methods________

// MediaPickerで追加曲をタッチして決定した際に呼び出される関数
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection 
{
    
	// Dismiss the media item picker.
	[self dismissModalViewControllerAnimated: YES];
	
	// musicPlayerの更新
    [delegate updatePlayerQueueWithMediaCollection: mediaItemCollection];
    
    // テーブルを更新
    [self.mediaItemCollectionTable reloadData];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
}

// MediaPickerでCancelをタッチした際に呼び出される関数
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
	[self dismissModalViewControllerAnimated: YES];
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
}

#pragma mark Table view methods________________________

// To learn about using table views, see the TableViewSuite sample code  
//		and Table View Programming Guide for iPhone OS.

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger)section {
    
    NSLog(@"tableView : numberOfRowsInSection called.");
    
    MagicSoundAppDelegate *appDelegate = (MagicSoundAppDelegate *) self.delegate;
	MPMediaItemCollection *currentQueue = appDelegate.userMediaItemCollection;
	return [currentQueue.items count];
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    
    NSLog(@"tableView : cellForRowAtIndexPath called.");
    
	NSInteger row = [indexPath row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kCellIdentifier];
	
	if (cell == nil) {
        
		cell = [[UITableViewCell alloc] initWithFrame: CGRectZero 
									   reuseIdentifier: kCellIdentifier];
	}
    
    MagicSoundAppDelegate *appDelegate = (MagicSoundAppDelegate *) self.delegate;
	MPMediaItemCollection *currentQueue = appDelegate.userMediaItemCollection;
	MPMediaItem *anItem = (MPMediaItem *)[currentQueue.items objectAtIndex: row];
	
	if (anItem) {
		cell.textLabel.text = [anItem valueForProperty:MPMediaItemPropertyTitle];
	}
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
	return cell;
}

//	 To conform to the Human Interface Guidelines, selections should not be persistent --
//	 deselect the row after it has been selected.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    NSLog(@"tableView : didSelectRowAtIndexPath called.");
    
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    [delegate selectMusicFromMediaItemCollection:indexPath.row];
    
    
    // 編集画面へいく処理が必要
    
}

- (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [delegate deleteMusicFromMediaItemCollection:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
	}  else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, 
		// insert it into the array, and add a new row to the table view.
	}   
}

@end
