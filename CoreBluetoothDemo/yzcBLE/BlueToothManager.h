//
//  BlueToothManager.h
//  CoreBluetoothDemo
//
//  Created by 叶志成 on 16/7/28.
//  Copyright © 2016年 叶志成. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEModel.h"

typedef void (^DeviceRsp)(NSData *data);
typedef void (^ScanPeripheral)(BLEModel *model);
typedef void (^ConnectPeripheralSuccess)(CBPeripheral *peripheral);
typedef void (^CannelPeripheral)(CBPeripheral *peripheral);

@interface BlueToothManager : NSObject
/** 连接状态 */
@property (nonatomic, assign) BOOL isConnected;
/** 是否重连 */
@property (nonatomic, assign) BOOL isReconnection;
/** 是否过滤掉其他设备 */
@property (nonatomic, assign) BOOL isFilter;

@property (nonatomic, copy) NSString *characteristicUUIDString;

@property (nonatomic, copy) NSString *noticharacteristicUUIDString;

/** UUID数组 */
@property (nonatomic, strong) NSArray *services;

/**
 *  单例
 *
 *  @return
 */
+(id)sharedInstance;

/**
 *  写数据到外设
 *
 *  @param data 数据
 *  @param rsp  外设的返回值
 */
- (void)writeWithData:(NSData *)data rsp:(DeviceRsp)rsp;
/**
 *  停止扫描
 */
- (void) stopScan;
/**
 *  连接设备
 *
 *  @param peripheral peripheral
 */
- (void)connectedWithPeripheral:(CBPeripheral *)peripheral block:(ConnectPeripheralSuccess)block;
/**
 *  断开链接
 *
 *  @param peripheral 外设
 *  @param block
 */
- (void)cannelWithPeripheral:(CBPeripheral *)peripheral block:(CannelPeripheral)block;

/**
 扫描外设

 @param block   回调
 @param service 搜索指定UUID，过滤其他设备
 */
- (void)setBlockOnDiscoverToPeripherals:(ScanPeripheral)block;

@end
