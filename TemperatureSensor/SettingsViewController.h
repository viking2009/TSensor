//
//  SettingsViewController.h
//  TemperatureSensor
//
//  Created by Mykola Vyshynskyi on 07.04.13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FrequencyConsiderRangeDidChangeNotification @"FrequencyConsiderRangeDidChangeNotification"
#define FrequencyAcceptableRangeDidChangeNotification @"FrequencyAcceptableRangeDidChangeNotification"
#define FrequencyTemperatureMapDidChangeNotification @"FrequencyTemperatureMapDidChangeNotification"
#define FrequencyMeasurementIntervalDidChangeNotification @"FrequencyMeasurementIntervalDidChangeNotification"
#define FrequencyDisplayIntervalDidChangeNotification @"FrequencyDisplayIntervalDidChangeNotification"

#define kMinFrequency @"minFrequency"
#define kMaxFrequency @"maxFrequency"
#define kConsiderFrequencyRange @"considerFrequencyRange"
#define kMeasurementFrequency @"measurementFrequency"
#define kDisplayFrequency @"displayFrequency"

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *minFrequencyLabel;
@property (retain, nonatomic) IBOutlet UILabel *maxFrequencyLabel;
@property (retain, nonatomic) IBOutlet UITextField *minFrequencyTextField;
@property (retain, nonatomic) IBOutlet UITextField *maxFrequencyTextField;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UISwitch *considerFrequencyRangeSwitch;
@property (retain, nonatomic) IBOutlet UIStepper *measurementStepper;
@property (retain, nonatomic) IBOutlet UIStepper *displayStepper;
@property (retain, nonatomic) IBOutlet UILabel *measurementValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *displayValueLabel;

- (IBAction)minFrequencyValueChanged:(id)sender;
- (IBAction)maxFrequencyValueChanged:(id)sender;
- (IBAction)considerFrequencyRangeSwitchValueChanged:(id)sender;
- (IBAction)measurementValueChanged:(id)sender;
- (IBAction)displayValueChanged:(id)sender;

@end
