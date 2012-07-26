//
//  PlayViewController.m
//  MagicSound
//
//  Created by masa on 12/02/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlayViewController.h"
#import "MagicSoundAppDelegate.h"

@implementation PlayViewController

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

-(IBAction)backButtonDidPush:(id)sender
{
    [delegate popBackToTitleViewController];
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
    [delegate pushGameViewController];
}

@end
