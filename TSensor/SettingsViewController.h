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
#define DecimalDigitsDidChangeNotification @"DecimalDigitsDidChangeNotification"
#define UseAverageValueChangeNotification @"UseAverageValueChangeNotification"
#define UseFrequencyValueChangeNotification @"UseFrequencyValueChangeNotification"

#define kMinFrequency @"minFrequency"
#define kMaxFrequency @"maxFrequency"
#define kConsiderFrequencyRange @"considerFrequencyRange"
#define kMeasurementFrequency @"measurementFrequency"
#define kDisplayFrequency @"displayFrequency"
#define kDecimalDigits @"decimalDigits"
#define kUseAverageValue @"useAverageValue"
#define kUseFrequencyValue @"useFrequencyValue"

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *minFrequencyLabel;
@property (retain, nonatomic) IBOutlet UILabel *maxFrequencyLabel;
@property (retain, nonatomic) IBOutlet UITextField *minFrequencyTextField;
@property (retain, nonatomic) IBOutlet UITextField *maxFrequencyTextField;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UISwitch *considerFrequencyRangeSwitch;
@property (retain, nonatomic) IBOutlet UIStepper *measurementStepper;
@property (retain, nonatomic) IBOutlet UIStepper *displayStepper;
@property (retain, nonatomic) IBOutlet UIStepper *decimalDigitsStepper;
@property (retain, nonatomic) IBOutlet UILabel *measurementValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *displayValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *decimalDigitsValueLabel;
@property (retain, nonatomic) IBOutlet UISwitch *useAverageValueSwitch;
@property (retain, nonatomic) IBOutlet UISegmentedControl *useFrequencySegmentedControl;

- (IBAction)minFrequencyValueChanged:(id)sender;
- (IBAction)maxFrequencyValueChanged:(id)sender;
- (IBAction)considerFrequencyRangeSwitchValueChanged:(id)sender;
- (IBAction)measurementValueChanged:(id)sender;
- (IBAction)displayValueChanged:(id)sender;
- (IBAction)decimalDigitsChanged:(id)sender;
- (IBAction)useAverageValueSwitchValueChanged:(id)sender;
- (IBAction)useFrequencySegmentedControlValueChanged:(id)sender;

@end
