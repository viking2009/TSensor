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

@interface SettingsViewController ()

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
    if ([defaults doubleForKey:@"minFrequency"]) {
        self.minFrequencyStepper.value = [defaults doubleForKey:@"minFrequency"];
    } else {
        self.minFrequencyStepper.value = 100;
    }
    
    if ([defaults doubleForKey:@"maxFrequency"]) {
        self.maxFrequencyStepper.value = [defaults doubleForKey:@"maxFrequency"];
    } else {
        self.maxFrequencyStepper.value = 500;
    }
    
    [self minFrequencyStepperValueChanged:self.minFrequencyStepper];
    [self maxFrequencyStepperValueChanged:self.maxFrequencyStepper];
    
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
    [_minFrequencyStepper release];
    [_maxFrequencyStepper release];
    [_tableView release];
    [_temperatureMap release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setMinFrequencyLabel:nil];
    [self setMaxFrequencyLabel:nil];
    [self setMinFrequencyStepper:nil];
    [self setMaxFrequencyStepper:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
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
- (IBAction)maxFrequencyStepperValueChanged:(id)sender
{
    if (sender == self.maxFrequencyStepper) {
        self.minFrequencyStepper.maximumValue = self.maxFrequencyStepper.value;
        self.maxFrequencyLabel.text = [NSString stringWithFormat:@"MAX %.f", self.maxFrequencyStepper.value];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setDouble:self.maxFrequencyStepper.value forKey:@"maxFrequency"];
        
        if ([defaults synchronize]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FrequencyAcceptableRangeDidChangeNotification object:nil];
        }
    }
}

- (IBAction)minFrequencyStepperValueChanged:(id)sender
{
    if (sender == self.minFrequencyStepper) {
        self.maxFrequencyStepper.minimumValue = self.minFrequencyStepper.value;
        self.minFrequencyLabel.text = [NSString stringWithFormat:@"MIN %.f", self.minFrequencyStepper.value];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setDouble:self.minFrequencyStepper.value forKey:@"minFrequency"];
        
        if ([defaults synchronize]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FrequencyAcceptableRangeDidChangeNotification object:nil];
        }
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
