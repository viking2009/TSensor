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

#define kMinFrequency @"minFrequency"
#define kMaxFrequency @"maxFrequency"
#define kConsiderFrequencyRange @"considerFrequencyRange"

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *minFrequencyLabel;
@property (retain, nonatomic) IBOutlet UILabel *maxFrequencyLabel;
@property (retain, nonatomic) IBOutlet UITextField *minFrequencyTextField;
@property (retain, nonatomic) IBOutlet UITextField *maxFrequencyTextField;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UISwitch *considerFrequencyRangeSwitch;

- (IBAction)minFrequencyValueChanged:(id)sender;
- (IBAction)maxFrequencyValueChanged:(id)sender;
- (IBAction)considerFrequencyRangeSwitchValueChanged:(id)sender;

@end
