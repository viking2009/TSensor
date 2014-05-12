//
//  TemperatureMap.h
//  TemperatureSensor
//
//  Created by Mykola Vyshynskyi on 07.04.13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemperatureMap : NSObject

@property (nonatomic, readonly) NSMutableArray *items;

+ (TemperatureMap *)sharedMap;

- (void)addItem:(id)item;
- (void)removeItem:(id)item;
- (void)editItem:(id)item;

- (void)save;

@end
