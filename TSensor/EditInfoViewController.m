//
//  EditInfoViewController.m
//  TemperatureSensor
//
//  Created by Mykola Vyshynskyi on 07.04.13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "EditInfoViewController.h"
#import "SettingsViewController.h"
#import "TemperatureMap.h"

@interface EditInfoViewController ()

@end

@implementation EditInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveMap:)] autorelease];
    
    if (self.temperatureInfo) {
        self.temperatureText.text = self.temperatureInfo[@"temperature"];
        self.frequencyText.text = self.temperatureInfo[@"frequency"];
        self.frequencyText.enabled = NO;
        self.frequencyText.textColor = [UIColor lightGrayColor];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_frequencyText release];
    [_temperatureText release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setFrequencyText:nil];
    [self setTemperatureText:nil];
    [super viewDidUnload];
}

- (void)saveMap:(id)sender {
    if (!self.frequencyText.text.length) {
        [[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Frequency is required field" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease] show];
        return;
    }

    if (!self.temperatureText.text.length) {
        [[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Temperature is required field" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease] show];
        return;
    }

    if (self.temperatureInfo) {
        self.temperatureInfo[@"temperature"] = self.temperatureText.text;
        [[TemperatureMap sharedMap] editItem:self.temperatureInfo];
    } else {
        NSMutableDictionary *newInfo = [NSMutableDictionary dictionary];
        newInfo[@"frequency"] = self.frequencyText.text;
        newInfo[@"temperature"] = self.temperatureText.text;
        [[TemperatureMap sharedMap] addItem:newInfo];
        NSLog(@"newInfo = %@", newInfo);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
