//
//  SettingsViewController.m
//  TemperatureSensor
//
//  Created by Mykola Vyshynskyi on 07.04.13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "EditInfoViewController.h"
#import "TemperatureMap.h"

@interface SettingsViewController () <UITextFieldDelegate>

@property (retain, nonatomic) NSMutableDictionary *temperatureMap;
@property (retain, nonatomic) NSMutableArray *temperatureArray;

@property (assign, nonatomic) NSInteger selectedIndex;

@end

@implementation SettingsViewController

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
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editMap:)] autorelease];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults doubleForKey:kMinFrequency]) {
        self.minFrequencyTextField.text = [NSString stringWithFormat:@"%.2f", [defaults doubleForKey:kMinFrequency]];
    } else {
        self.minFrequencyTextField.text = @"100.00";
    }
    
    if ([defaults doubleForKey:kMaxFrequency]) {
        self.maxFrequencyTextField.text = [NSString stringWithFormat:@"%.2f",[defaults doubleForKey:kMaxFrequency]];
    } else {
        self.maxFrequencyTextField.text = @"500.00";
    }
    
    self.considerFrequencyRangeSwitch.on = [defaults boolForKey:kConsiderFrequencyRange];
    
    if ([defaults doubleForKey:kMeasurementFrequency]) {
        self.measurementValueLabel.text = [NSString stringWithFormat:@"%.1f",[defaults doubleForKey:kMeasurementFrequency]];
    } else {
        self.measurementValueLabel.text = @"1";
    }
    
    if ([defaults doubleForKey:kDisplayFrequency]) {
        self.displayValueLabel.text = [NSString stringWithFormat:@"%.f",[defaults doubleForKey:kDisplayFrequency]];
    } else {
        self.displayValueLabel.text = @"1";
    }

    if ([defaults doubleForKey:kDecimalDigits]) {
        self.decimalDigitsValueLabel.text = [NSString stringWithFormat:@"%.f",[defaults doubleForKey:kDecimalDigits]];
    } else {
        self.decimalDigitsValueLabel.text = @"2";
    }

    self.measurementStepper.value = [self.measurementValueLabel.text doubleValue];
    self.displayStepper.value = [self.displayValueLabel.text doubleValue];
    self.decimalDigitsStepper.value = [self.decimalDigitsValueLabel.text doubleValue];

    self.useAverageValueSwitch.on = [defaults boolForKey:kUseAverageValue];
    
    NSNumber *useFrequencyValue = [defaults objectForKey:kUseFrequencyValue];
    self.useFrequencySegmentedControl.selectedSegmentIndex = useFrequencyValue ? [useFrequencyValue integerValue] : 1;

    [self minFrequencyValueChanged:self.minFrequencyTextField];
    [self maxFrequencyValueChanged:self.maxFrequencyTextField];
    [self measurementValueChanged:self.measurementStepper];
    [self displayValueChanged:self.displayStepper];
    [self decimalDigitsChanged:self.decimalDigitsStepper];
    [self useAverageValueSwitchValueChanged:self.useAverageValueSwitch];
//    [self useFrequencySegmentedControlValueChanged:self.useFrequencySegmentedControl];
    
    self.tableView.allowsSelectionDuringEditing = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_minFrequencyLabel release];
    [_maxFrequencyLabel release];
    [_tableView release];
    [_temperatureMap release];
    [_minFrequencyTextField release];
    [_maxFrequencyTextField release];
    [_considerFrequencyRangeSwitch release];
    [_measurementStepper release];
    [_displayStepper release];
    [_decimalDigitsStepper release];
    [_measurementValueLabel release];
    [_displayValueLabel release];
    [_decimalDigitsValueLabel release];
    [_useAverageValueSwitch release];
    [_useFrequencySegmentedControl release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setMinFrequencyLabel:nil];
    [self setMaxFrequencyLabel:nil];
    [self setTableView:nil];
    [self setMinFrequencyTextField:nil];
    [self setMaxFrequencyTextField:nil];
    [self setConsiderFrequencyRangeSwitch:nil];
    [self setMeasurementStepper:nil];
    [self setDisplayStepper:nil];
    [self setDecimalDigitsStepper:nil];
    [self setMeasurementValueLabel:nil];
    [self setDisplayValueLabel:nil];
    [self setDecimalDigitsValueLabel:nil];
    [self setUseAverageValueSwitch:nil];
    [self setUseFrequencySegmentedControl:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark TextField Delegates
/****************************************************************************/
/*							TextField Delegates								*/
/****************************************************************************/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
	return [[TemperatureMap sharedMap].items count] + (tableView.isEditing ? 1 : 0);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Temperature map";
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
    
    if (tableView.isEditing && indexPath.row == 0) {
        [[cell textLabel] setText:@"Insert"];
        [[cell detailTextLabel] setText:nil];
    } else {
        NSDictionary *temperatureInfo = [[TemperatureMap sharedMap] items][indexPath.row - (tableView.isEditing ? 1 : 0)];
        
        [[cell textLabel] setText:temperatureInfo[@"frequency"]];
        [[cell detailTextLabel] setText:temperatureInfo[@"temperature"]];
     }
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath = %@", indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.isEditing && indexPath.row == 0) {
        self.selectedIndex = NSNotFound;
    } else {
        self.selectedIndex = indexPath.row - (tableView.isEditing ? 1 : 0);
    }

    [self performSegueWithIdentifier:@"editMapInfo" sender:nil];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath = %@", indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.isEditing && indexPath.row == 0) {
        self.selectedIndex = NSNotFound;
    } else {
        self.selectedIndex = indexPath.row - (tableView.isEditing ? 1 : 0);
    }
    
    [self performSegueWithIdentifier:@"editMapInfo" sender:nil];    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.isEditing) {
        return UITableViewCellEditingStyleNone;
    }
    
    if(tableView.isEditing && indexPath.row == 0){
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger selected = indexPath.row - (tableView.isEditing ? 1 : 0);
    
    if (editingStyle == UITableViewCellEditingStyleDelete && tableView.isEditing) {
        //put code to handle deletion
        [[TemperatureMap sharedMap] removeItem:[[TemperatureMap sharedMap] items][selected]];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        //put code to handle insertion
    }
    
    [tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editMapInfo"]) {
        EditInfoViewController *editController = segue.destinationViewController;
        if (self.selectedIndex != NSNotFound) {
            editController.temperatureInfo = [[TemperatureMap sharedMap] items][self.selectedIndex];
        }
    }
}

#pragma mark -
#pragma mark App IO
/****************************************************************************/
/*                              App IO Methods                              */
/****************************************************************************/
/** Increase or decrease the maximum alarm setting */
- (IBAction)maxFrequencyValueChanged:(id)sender
{
    NSLog(@"sender = %@", sender);
    if (sender == self.maxFrequencyTextField) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setDouble:[self.maxFrequencyTextField.text doubleValue] forKey:kMaxFrequency];
        
        if ([defaults synchronize]) {
            self.maxFrequencyLabel.text = [NSString stringWithFormat:@"MAX %.2f", [self.maxFrequencyTextField.text doubleValue]];

            [[NSNotificationCenter defaultCenter] postNotificationName:FrequencyAcceptableRangeDidChangeNotification object:nil];
        }

        NSLog(@"defaults = %@", [defaults dictionaryRepresentation]);
    }
}

- (IBAction)minFrequencyValueChanged:(id)sender
{
    if (sender == self.minFrequencyTextField) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setDouble:[self.minFrequencyTextField.text doubleValue] forKey:kMinFrequency];
        
        if ([defaults synchronize]) {
            self.minFrequencyLabel.text = [NSString stringWithFormat:@"MIN %.2f", [self.minFrequencyTextField.text doubleValue]];

            [[NSNotificationCenter defaultCenter] postNotificationName:FrequencyAcceptableRangeDidChangeNotification object:nil];
        }
        
        NSLog(@"defaults = %@", [defaults dictionaryRepresentation]);
    }
}

- (IBAction)considerFrequencyRangeSwitchValueChanged:(id)sender {
    if (sender == self.considerFrequencyRangeSwitch) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:self.considerFrequencyRangeSwitch.on forKey:kConsiderFrequencyRange];

        if ([defaults synchronize]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FrequencyConsiderRangeDidChangeNotification object:nil];
        }

        NSLog(@"defaults = %@", [defaults dictionaryRepresentation]);
    }
}

- (IBAction)measurementValueChanged:(id)sender {
    if (sender == self.measurementStepper) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setDouble:self.measurementStepper.value forKey:kMeasurementFrequency];
        
        if ([defaults synchronize]) {
            self.measurementValueLabel.text = [NSString stringWithFormat:@"%.1f", self.measurementStepper.value];
            [[NSNotificationCenter defaultCenter] postNotificationName:FrequencyMeasurementIntervalDidChangeNotification object:nil];
        }
        
        NSLog(@"defaults = %@", [defaults dictionaryRepresentation]);
    }
}

- (IBAction)displayValueChanged:(id)sender {
    if (sender == self.displayStepper) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setDouble:self.displayStepper.value forKey:kDisplayFrequency];
        
        if ([defaults synchronize]) {
            self.displayValueLabel.text = [NSString stringWithFormat:@"%.f", self.displayStepper.value];
            [[NSNotificationCenter defaultCenter] postNotificationName:FrequencyDisplayIntervalDidChangeNotification object:nil];
        }
        
        NSLog(@"defaults = %@", [defaults dictionaryRepresentation]);
    }
}

- (IBAction)decimalDigitsChanged:(id)sender {
    if (sender == self.decimalDigitsStepper) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setDouble:self.decimalDigitsStepper.value forKey:kDecimalDigits];
        
        if ([defaults synchronize]) {
            self.decimalDigitsValueLabel.text = [NSString stringWithFormat:@"%.f", self.decimalDigitsStepper.value];
            [[NSNotificationCenter defaultCenter] postNotificationName:DecimalDigitsDidChangeNotification object:nil];
        }
        
        NSLog(@"defaults = %@", [defaults dictionaryRepresentation]);
    }

}

- (IBAction)useAverageValueSwitchValueChanged:(id)sender {
    if (sender == self.useAverageValueSwitch) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:self.useAverageValueSwitch.on forKey:kUseAverageValue];
        
        if ([defaults synchronize]) {
            self.displayStepper.enabled = self.useAverageValueSwitch.on;
            self.displayValueLabel.enabled = self.useAverageValueSwitch.on;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UseAverageValueChangeNotification object:nil];
        }
        
        NSLog(@"defaults = %@", [defaults dictionaryRepresentation]);
    }
}

- (IBAction)useFrequencySegmentedControlValueChanged:(id)sender {
    if (sender == self.useFrequencySegmentedControl) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@(self.useFrequencySegmentedControl.selectedSegmentIndex) forKey:kUseFrequencyValue];
        
        if ([defaults synchronize]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:UseFrequencyValueChangeNotification object:nil];
        }
        
        NSLog(@"defaults = %@", [defaults dictionaryRepresentation]);
    }
}

- (void)editMap:(id)sender {
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
    
    if (self.tableView.isEditing) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editMap:)] autorelease];
    } else {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editMap:)] autorelease];
    }
    
    [self.tableView reloadData];
}

@end
