//
//  BLEModel.h
//  CoreBluetoothDemo
//
//  Created by 叶志成 on 16/7/29.
//  Copyright © 2016年 叶志成. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEModel : NSObject

@property (nonatomic, strong) NSNumber *RSSI;

@property (nonatomic, strong) NSDictionary *advertisementData;

@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) CBCentralManager *central;


@end
