//
//  EditInfoViewController.h
//  TemperatureSensor
//
//  Created by Mykola Vyshynskyi on 07.04.13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditInfoViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextField *frequencyText;
@property (retain, nonatomic) IBOutlet UITextField *temperatureText;

@property (nonatomic, retain) NSMutableDictionary *temperatureInfo;

@end
