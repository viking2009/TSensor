//
//  TemperatureMap.m
//  TemperatureSensor
//
//  Created by Mykola Vyshynskyi on 07.04.13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "TemperatureMap.h"

#define FrequencyTemperatureMapDidChangeNotification @"FrequencyTemperatureMapDidChangeNotification"

@implementation TemperatureMap {
    NSMutableArray *_items;
}

+ (TemperatureMap*)sharedMap {
    static TemperatureMap *_sharedMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMap = [[TemperatureMap alloc] init];
    });
    
    return _sharedMap;
}

#pragma mark - Public

- (NSMutableArray*)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[defaults objectForKey:@"temparatureMap"] isKindOfClass:[NSArray class]]) {
            NSArray *temparatureMap = [defaults objectForKey:@"temparatureMap"];
            for (NSDictionary *mapInfo in temparatureMap) {
                [_items addObject:[mapInfo mutableCopy]];
            };
            
            NSSortDescriptor *frequencySort = [NSSortDescriptor sortDescriptorWithKey:@"frequency" ascending:YES];
            [_items sortUsingDescriptors:@[frequencySort]];
        }
    }
    
    return _items;
}

- (void)addItem:(id)item {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, item);
    [self.items addObject:item];
    
    NSSortDescriptor *frequencySort = [NSSortDescriptor sortDescriptorWithKey:@"frequency" ascending:YES];
    [self.items sortUsingDescriptors:@[frequencySort]];
    
    [self save];
}

- (void)removeItem:(id)item {
    [self.items removeObject:item];
    
    NSSortDescriptor *frequencySort = [NSSortDescriptor sortDescriptorWithKey:@"frequency" ascending:YES];
    [self.items sortUsingDescriptors:@[frequencySort]];

    [self save];
}

- (void)editItem:(id)item {
    //[self.items addObject:item];
    
    NSSortDescriptor *frequencySort = [NSSortDescriptor sortDescriptorWithKey:@"frequency" ascending:YES];
    [self.items sortUsingDescriptors:@[frequencySort]];
    
    [self save];
}

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.items forKey:@"temparatureMap"];
    
    if ([defaults synchronize]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FrequencyTemperatureMapDidChangeNotification object:self.items];
    }
}

@end
