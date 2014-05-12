//
//  SettingsViewController.h
//  TemperatureSensor
//
//  Created by Mykola Vyshynskyi on 07.04.13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FrequencyAcceptableRangeDidChangeNotification @"FrequencyAcceptableRangeDidChangeNotification"
#define FrequencyTemperatureMapDidChangeNotification @"FrequencyTemperatureMapDidChangeNotification"

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *minFrequencyLabel;
@property (retain, nonatomic) IBOutlet UILabel *maxFrequencyLabel;
@property (retain, nonatomic) IBOutlet UITextField *minFrequencyTextField;
@property (retain, nonatomic) IBOutlet UITextField *maxFrequencyTextField;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)minFrequencyValueChanged:(id)sender;
- (IBAction)maxFrequencyValueChanged:(id)sender;

@end