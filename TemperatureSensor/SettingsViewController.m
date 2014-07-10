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
    
    self.considerFrequencyRangeSwitch.on = [defaults boolForKey:@"considerFrequencyRange"];
    
    [self minFrequencyValueChanged:self.minFrequencyTextField];
    [self maxFrequencyValueChanged:self.maxFrequencyTextField];
    
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
    [super dealloc];
}

- (void)viewDidUnload {
    [self setMinFrequencyLabel:nil];
    [self setMaxFrequencyLabel:nil];
    [self setTableView:nil];
    [self setMinFrequencyTextField:nil];
    [self setMaxFrequencyTextField:nil];
    [self setConsiderFrequencyRangeSwitch:nil];
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
        self.maxFrequencyLabel.text = [NSString stringWithFormat:@"MAX %.2f", [self.maxFrequencyTextField.text doubleValue]];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setDouble:[self.maxFrequencyTextField.text doubleValue] forKey:kMaxFrequency];
        
        if ([defaults synchronize]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FrequencyAcceptableRangeDidChangeNotification object:nil];
        }

        NSLog(@"defaults = %@", [defaults dictionaryRepresentation]);
    }
}

- (IBAction)minFrequencyValueChanged:(id)sender
{
    if (sender == self.minFrequencyTextField) {
        self.minFrequencyLabel.text = [NSString stringWithFormat:@"MIN %.2f", [self.minFrequencyTextField.text doubleValue]];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setDouble:[self.minFrequencyTextField.text doubleValue] forKey:kMinFrequency];
        
        if ([defaults synchronize]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FrequencyAcceptableRangeDidChangeNotification object:nil];
        }
        
        NSLog(@"defaults = %@", [defaults dictionaryRepresentation]);
    }
}

- (IBAction)considerFrequencyRangeSwitchValueChanged:(id)sender {
    if (sender == self.considerFrequencyRangeSwitch) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:self.considerFrequencyRangeSwitch.on forKey:@"considerFrequencyRange"];

        if ([defaults synchronize]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FrequencyConsiderRangeDidChangeNotification object:nil];
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
