/*
 
 File: ViewController.m
 
 Abstract: User interface to display a list of discovered peripherals
 and allow the user to connect to them.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. 
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import <Foundation/Foundation.h>

#import "ViewController.h"
#import "MixerHostAudio.h"
#import "SettingsViewController.h"
#import "TemperatureMap.h"

#define kUpdateTemperatureInterval 1.0

NSString *MixerHostAudioObjectPlaybackStateDidChangeNotification = @"MixerHostAudioObjectPlaybackStateDidChangeNotification";

@interface ViewController ()  <UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) MixerHostAudio            *audioObject;
@property (retain, nonatomic) NSMutableArray            *connectedServices;
@property (retain, nonatomic) NSMutableArray            *temperatures;
@property (retain, nonatomic) NSDictionary              *temperatureMap;
@property (retain, nonatomic) NSTimer                   *timer;
@property (retain, nonatomic) IBOutlet UILabel          *currentlyConnectedSensor;
@property (retain, nonatomic) IBOutlet UILabel          *currentTemperatureLabel;
@property (retain, nonatomic) IBOutlet UITableView      *sensorsTable;
@property (retain, nonatomic) IBOutlet UIStepper        *intervalStepper;
@property (retain, nonatomic) IBOutlet UIButton         *playButton;
@property (assign, nonatomic) double minFrequencyValue;
@property (assign, nonatomic) double maxFrequencyValue;
- (IBAction)intervalStepperChanged;
@end



@implementation ViewController


@synthesize connectedServices;
@synthesize temperatures;
@synthesize currentlyConnectedSensor;
@synthesize sensorsTable;
@synthesize currentTemperatureLabel;
@synthesize intervalStepper;
@synthesize audioObject;


# pragma mark -
# pragma mark User interface methods
// Set the initial multichannel mixer unit parameter values according to the UI state
- (void) initializeMixerSettingsToUI
{
	audioObject.micFxOn = YES;
    audioObject.micFxControl = .5;
    audioObject.micFxType = 2;
    
	currentTemperatureLabel.text = @"go";
}


#pragma mark -
#pragma mark Notification registration
// If this app's audio session is interrupted when playing audio, it needs to update its user interface
//    to reflect the fact that audio has stopped. The MixerHostAudio object conveys its change in state to
//    this object by way of a notification. To learn about notifications, see Notification Programming Topics.
- (void) registerForAudioObjectNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handlePlaybackStateChanged:)
                               name: MixerHostAudioObjectPlaybackStateDidChangeNotification
                             object: audioObject];
    
    [notificationCenter addObserver: self
                           selector: @selector (handleFrequencyAcceptableRangeChanged:)
                               name: FrequencyAcceptableRangeDidChangeNotification
                             object: nil];

    [notificationCenter addObserver: self
                           selector: @selector (handleFrequencyTemperatureMapChanged:)
                               name: FrequencyTemperatureMapDidChangeNotification
                             object: nil];

}


#pragma mark -
#pragma mark Remote-control event handling
// Respond to remote control events
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playOrStop: nil];
                break;
                
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark View lifecycle
/****************************************************************************/
/*								View Lifecycle                              */
/****************************************************************************/
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    connectedServices = [NSMutableArray new];
    temperatures = [NSMutableArray new];
    
    MixerHostAudio *newAudioObject = [[MixerHostAudio alloc] init];
    self.audioObject = newAudioObject;
    [newAudioObject release];
    
    [self registerForAudioObjectNotifications];
    [self initializeMixerSettingsToUI];
    
    [self handleFrequencyAcceptableRangeChanged:nil];
    [self handleFrequencyTemperatureMapChanged:[NSNotification notificationWithName:FrequencyTemperatureMapDidChangeNotification object:[TemperatureMap sharedMap].items]];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings:)] autorelease];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForegroundNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}


// If using a nonmixable audio session category, as this app does, you must activate reception of
//    remote-control events to allow reactivation of the audio session when running in the background.
//    Also, to receive remote-control events, the app must be eligible to become the first responder.
- (void) viewDidAppear: (BOOL) animated
{    
    [super viewDidAppear: animated];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    // this alert needs to be here, becuase if its anywhere in the viewDidLoad sequence you'll
    // get the error: applications are expected to have a root view controller at en of app launch...
    
    if(audioObject.inputDeviceIsAvailable == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Mic is not available. Please terminate the app. Then connect an input device and restart. Or you can use the app now without a mic."  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
}


- (BOOL) canBecomeFirstResponder
{    
    return YES;
}

- (void)showSettings:(id)sender
{
    [self stop];
    [self performSegueWithIdentifier:@"showSettings" sender:sender];
}

- (void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void) viewWillDisppear: (BOOL) animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    [super viewWillDisappear: animated];
}

- (void) viewDidUnload
{
    [self setCurrentlyConnectedSensor:nil];
    [self setCurrentTemperatureLabel:nil];
    [self setSensorsTable:nil];
    [self setIntervalStepper:nil];
    [self setConnectedServices:nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MixerHostAudioObjectPlaybackStateDidChangeNotification
                                                  object: audioObject];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: FrequencyAcceptableRangeDidChangeNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: FrequencyTemperatureMapDidChangeNotification
                                                  object: nil];
    
    [self setAudioObject:nil];
    
    [super viewDidUnload];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) dealloc 
{    
    [currentTemperatureLabel release];
    [sensorsTable release];
    [intervalStepper release];
    
    [currentlyConnectedSensor release];
    [connectedServices release];

    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: MixerHostAudioObjectPlaybackStateDidChangeNotification
                                                  object: audioObject];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: FrequencyAcceptableRangeDidChangeNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: FrequencyTemperatureMapDidChangeNotification
                                                  object: nil];
    
    [audioObject release];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];

    [super dealloc];
}


#pragma mark -
#pragma mark TableView DataSource
/****************************************************************************/
/*							TableView DataSource							*/
/****************************************************************************/

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [temperatures count];
}


#pragma mark -
#pragma mark TableView Delegates
/****************************************************************************/
/*							TableView Delegates								*/
/****************************************************************************/
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell	*cell;
	//NSArray			*devices;
	//NSInteger		row	= [indexPath row];
    static NSString *cellID = @"DeviceList";
    
	cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell)
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
    
    NSDictionary *temperatureInfo = temperatures[indexPath.row];
    NSString *value = [NSString stringWithFormat:@"%@ (%@)", temperatureInfo[@"frequency"], temperatureInfo[@"temperature"]];
    
    [[cell textLabel] setText:value];
    [[cell detailTextLabel] setText:temperatureInfo[@"date"]];
    
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


#pragma mark -
#pragma mark App IO
/****************************************************************************/
/*                              App IO Methods                              */
/****************************************************************************/
/** Increase or decrease the maximum alarm setting */
- (IBAction) intervalStepperChanged
{
    if (audioObject.isPlaying) {
        
        if ([self.timer isValid]) {
            [self.timer invalidate];
        }
        // this updated the pitch field at regular intervals
        
        //[NSTimer scheduledTimerWithTimeInterval:kUpdateTemperatureInterval
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.intervalStepper.value
                                                      target:self
                                                    selector:@selector(updateTemperature:)
                                                    userInfo:audioObject
                                                     repeats: YES];
    }


}


// This is the timer callback method
//
// it checks the value of instance variables in MixerHostAudio
// and displays them at regular intervals

// in the crazy convoluted world of objective-c
// userInfo conveniently points to AudioObject
//

// displays temperature (mic input frequency for now)
- (void) updateTemperature: (NSTimer *) timer {
	
    //	float z = [[timer userInfo] frequency];
    //    UInt32 y = [[timer userInfo] micLevel];
    
    NSString *date = [NSString stringWithFormat:@"%@", [timer fireDate]];
    NSString *frequencyValue = [NSString stringWithFormat:@"%d",
                                [[timer userInfo] displayInputFrequency]];
    NSLog(@"displayInputFrequency = %@", frequencyValue);
    NSString *temperatureValue = self.temperatureMap[frequencyValue]?:@"not set";
    
	currentTemperatureLabel.text = frequencyValue;
    
    // update table data
    if ([[timer userInfo] displayInputFrequency] >= self.minFrequencyValue && [[timer userInfo] displayInputFrequency] <= self.maxFrequencyValue) {
        [sensorsTable beginUpdates];
        [temperatures addObject:@{ @"date": date, @"frequency": frequencyValue, @"temperature" : temperatureValue}];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[temperatures count] - 1 inSection:0];
        [sensorsTable insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [sensorsTable endUpdates];
        [sensorsTable scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


/**
 * Create a path with the documents directory and the relative path appended.
 *
 *      @returns The documents path concatenated with the given relative path.
 */
NSString* NIPathForDocumentsResource(NSString* relativePath);

///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* NIPathForDocumentsResource(NSString* relativePath) {
    //static NSString* documentsPath = nil;
    //if (nil == documentsPath) {
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask,
                                                            YES);
         NSString* documentsPath = [dirs objectAtIndex:0];
    //}
    return [documentsPath stringByAppendingPathComponent:relativePath];
}


#pragma mark -
#pragma mark Audio processing graph control

// Handle a play/stop button tap
- (IBAction) playOrStop: (id) sender {
    
    if (audioObject.isPlaying) {
        [self stop];
    } else {
        [self play];
    }
}

- (void) stop {
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [audioObject stopAUGraph];
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    currentTemperatureLabel.text = @"go";
    
    // save results
    NSString *fileName = [NSString stringWithFormat:@"%@.plist", [NSDate date]];
    [temperatures writeToFile:NIPathForDocumentsResource(fileName) atomically:YES];
    
    // clear log
    [temperatures removeAllObjects];
    [sensorsTable reloadData];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void) play {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [audioObject startAUGraph];
    [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];
    
    // this updated the pitch field at regular intervals
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    //[NSTimer scheduledTimerWithTimeInterval:kUpdateTemperatureInterval
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.intervalStepper.value
                                                  target:self
                                                selector:@selector(updateTemperature:)
                                                userInfo:audioObject
                                                 repeats: YES];
}

// Handle a change in playback state that resulted from an audio session interruption or end of interruption
- (void) handlePlaybackStateChanged: (id) notification {
    
    [self playOrStop: nil];
}

- (void) handleFrequencyAcceptableRangeChanged: (id) notification
{    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults doubleForKey:@"minFrequency"]) {
        self.minFrequencyValue = [defaults doubleForKey:@"minFrequency"];
    } else {
        self.minFrequencyValue = 100;
    }
    
    if ([defaults doubleForKey:@"maxFrequency"]) {
        self.maxFrequencyValue = [defaults doubleForKey:@"maxFrequency"];
    } else {
        self.maxFrequencyValue = 500;
    }
    
    NSLog(@"minValue = %f, maxValue = %f", self.minFrequencyValue, self.maxFrequencyValue);
}

- (void) handleFrequencyTemperatureMapChanged: (NSNotification*) notification
{
    if ([notification.object isKindOfClass:[NSArray class]]) {
        NSArray *mapping = notification.object;
        NSMutableDictionary *temperatureMap = [NSMutableDictionary dictionary];
        for (NSDictionary *mapInfo in mapping) {
            NSLog(@"mapInfo = %@", mapInfo);
            temperatureMap[mapInfo[@"frequency"]] = mapInfo[@"temperature"];
        }
        self.temperatureMap = temperatureMap;
    }
    
    NSLog(@"%s self.temperatureMap = %@", __PRETTY_FUNCTION__, self.temperatureMap);
}

- (void) didEnterBackgroundNotification: (id) notification {
    NSLog(@"Entered background...");
    if (audioObject.playing) {
        [self stop];
    }
}

- (void) didEnterForegroundNotification: (id) notification {
    NSLog(@"Entered foreground...");
}

@end
