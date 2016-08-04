//
//  BlueToothManager.m
//  CoreBluetoothDemo
//
//  Created by 叶志成 on 16/7/28.
//  Copyright © 2016年 叶志成. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueToothManager.h"

static NSString *const serviceStrUUID = @"FFF0";
static NSString *const characteristicUUID = @"FFF1";
static NSString *const noticharacteristicUUID = @"FFF2";

@interface BlueToothManager()<CBPeripheralDelegate,CBCentralManagerDelegate>

/** 中心管理者 */
@property (nonatomic, strong) CBCentralManager *cMgr;

/** 连接到的外设 */
@property (nonatomic, strong) CBPeripheral *peripheral;

/** 特征值 */
@property (nonatomic, strong) CBCharacteristic *characteristic;

/** 接收数据通道*/
@property (nonatomic, strong) CBCharacteristic *noticharacteristic;

/** 特征UUID */
@property (nonatomic, strong) CBUUID *characteristicUUID;

/** 通知UUID */
@property (nonatomic, strong) CBUUID *noticharacteristicUUID;

/** 服务UUID */
@property (nonatomic, strong) CBUUID *serviceUUID;

/** 写入数据回调 */
@property (nonatomic, copy) DeviceRsp deviceBlock;

/** 扫描外设回调 */
@property (nonatomic, copy) ScanPeripheral peripheralBlock;

/** 连接成功回调 */
@property (nonatomic, copy) ConnectPeripheralSuccess connectBlock;

/** 连接失败回调 */
@property (nonatomic, copy) CannelPeripheral cannelBlock;

@end

@implementation BlueToothManager

//单例
+(id)sharedInstance {
    static BlueToothManager *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[self alloc] init];
    });
    return share;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serviceUUID = [CBUUID UUIDWithString:serviceStrUUID];
        _characteristicUUID = [CBUUID UUIDWithString:characteristicUUID];
        _noticharacteristicUUID = [CBUUID UUIDWithString:noticharacteristicUUID];
    }
    return self;
}

#pragma mark: - 懒加载
- (CBCentralManager *)cMgr
{
    if (!_cMgr) {
        _cMgr = [[CBCentralManager alloc] initWithDelegate:self
                                                     queue:dispatch_get_main_queue()
                                                   options:nil];
    }
    return _cMgr;
}


#pragma mark - CBCentralManagerDelegate

// 只要中心管理者初始化,就会触发此代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *title = @"";
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            title = @"设备不支持蓝牙";
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
//            NSLog(@"CBCentralManagerStateUnsupported");
            title = [NSString stringWithFormat:@"打开蓝牙来允许“%@”连接到配件",app_Name];
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            title = [NSString stringWithFormat:@"打开蓝牙来允许“%@”连接到配件",app_Name];
            break;
        case CBCentralManagerStatePoweredOn:
        {
            // 在中心管理者成功开启后再进行一些操作
            // 搜索外设
            [self.cMgr scanForPeripheralsWithServices:nil // 通过某些服务筛选外设
                                              options:nil]; // dict,条件
        }
            break;
            
        default:
            break;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:title delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}


/**
 *  发现外设后调用的方法
 *
 *  @param central           中心管理者
 *  @param peripheral         外设
 *  @param advertisementData 外设携带的数据
 *  @param RSSI              外设发出的蓝牙信号强度
 */
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    
    BLEModel *model = [[BLEModel alloc] init];
    model.RSSI = RSSI;
    model.peripheral = peripheral;
    model.advertisementData = advertisementData;
    model.central = central;
    if (self.peripheralBlock) {
        self.peripheralBlock(model);
    }
}

/**
 *   中心管理者连接外设成功
 *
 *  @param central    中心管理者
 *  @param peripheral 外设
 */
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    self.peripheral.delegate = self;
    NSArray *services = [[NSArray alloc]initWithObjects:self.serviceUUID, nil];
    self.peripheral = peripheral;
    [self.peripheral discoverServices:services];
    if (self.connectBlock) {
        self.isConnected = YES;
        self.connectBlock(peripheral);
    }
}

// 外设连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%s, line = %d, %@=连接失败", __FUNCTION__, __LINE__, peripheral.name);
    self.isConnected = NO;
}

// 丢失连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%s, line = %d, %@=断开连接", __FUNCTION__, __LINE__, peripheral.name);
    if (self.cannelBlock) {
        self.isConnected = NO;
        self.cannelBlock(peripheral);
    }
}

#pragma mark - 外设代理
// 发现外设的服务后调用的方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
   
    if (error) {
        NSLog(@"%s, line = %d, error = %@", __FUNCTION__, __LINE__, error.localizedDescription);
        return;
    }
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// 发现外设服务里的特征的时候调用的代理方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:characteristicUUID]) {
            self.characteristic = characteristic;
        }else if([characteristic.UUID.UUIDString isEqualToString:noticharacteristicUUID]) {
            self.noticharacteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.noticharacteristic];
             NSLog(@"订阅写入成功UUID");
        }
    }
}

// 更新特征的value的时候会调用
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error) {
        NSLog(@"%s, line = %d, error = %@", __FUNCTION__, __LINE__, error.localizedDescription);
        return;
    }
    
    if (self.deviceBlock) {
        self.deviceBlock(characteristic.value);
    }else{
        NSLog(@"deviceBlock为nil");
    }
}


#pragma mark - 自定义方法
- (void)writeWithData:(NSData *)data rsp:(DeviceRsp)rsp
{
    
    [_peripheral writeValue:data forCharacteristic:_characteristic type:CBCharacteristicWriteWithResponse];
    self.deviceBlock = rsp;
}

- (void) stopScan
{
    [self.cMgr stopScan];
}

- (void) connectedWithPeripheral:(CBPeripheral *)peripheral block:(ConnectPeripheralSuccess)block
{
    [self.cMgr stopScan];
    if (peripheral == nil) {
        return;
    }
    [self.cMgr connectPeripheral:peripheral options:nil];
    self.connectBlock = block;
}

- (void) setBlockOnDiscoverToPeripherals:(ScanPeripheral)block
{
    [self cMgr];
    [self.cMgr scanForPeripheralsWithServices:nil // 通过某些服务筛选外设
                                      options:nil]; // dict,条件
    self.peripheralBlock = block;
}

- (void) cannelWithPeripheral:(CBPeripheral *)peripheral block:(CannelPeripheral)block
{
    [self.cMgr cancelPeripheralConnection:peripheral];
    self.cannelBlock = block;
}


@end
