//
//  BlueToothManager.m
//  CoreBluetoothDemo
//
//  Created by 叶志成 on 16/7/28.
//  Copyright © 2016年 叶志成. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueToothManager.h"
#import "yzcDefine.h"

<<<<<<< HEAD
static NSString *const serviceStrUUID = @"6e400001-b5a3-f393-e0a9-e50e24dcca9e";
static NSString *const characteristicUUID = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
static NSString *const noticharacteristicUUID = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
=======
static NSString *const characteristicUUID = @"FFF1";
static NSString *const noticharacteristicUUID = @"FFF2";
>>>>>>> 29a9fe281fbbd51d34e8c91ee5e6f19539edccc7

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

/** 需要自动重连的外设 */
@property (nonatomic, strong) NSMutableArray *reConnectPeripherals;


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
        _characteristicUUID = [CBUUID UUIDWithString:characteristicUUID];
        _noticharacteristicUUID = [CBUUID UUIDWithString:noticharacteristicUUID];
        _reConnectPeripherals = [NSMutableArray array];
    }
    return self;
}

#pragma mark: - 懒加载
- (CBCentralManager *)cMgr
{
    if (!_cMgr) {
    

#if  __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_0
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 //蓝牙power没打开时alert提示框
                                 [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey,
                                 //重设centralManager恢复的IdentifierKey
                                 @"yzcBluetoothRestore",CBCentralManagerOptionRestoreIdentifierKey,
                                 nil];
        
#else
        NSDictionary *options = nil;
#endif
        
        NSArray *backgroundModes = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"UIBackgroundModes"];
        if ([backgroundModes containsObject:@"bluetooth-central"]) {
            //后台模式
            _cMgr = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:options];
        }
        else {
            //非后台模式
            _cMgr = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
        }
        
       
    }
    
    return _cMgr;
}


#pragma mark - CBCentralManagerDelegate

// 只要中心管理者初始化,就会触发此代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{


    switch (central.state) {
            
        case CBCentralManagerStateUnknown:
            YZCLog(@"状态未知");
            break;
            
        case CBCentralManagerStateResetting:
            
        case CBCentralManagerStateUnsupported:
            YZCLog(@"设备不支持蓝牙");
            break;
            
        case CBCentralManagerStateUnauthorized:
            YZCLog(@"设备未授权使用蓝牙");
            break;
            
        case CBCentralManagerStatePoweredOff:
            YZCLog(@"蓝牙未开启");
            break;
            
        case CBCentralManagerStatePoweredOn:
        {
            [self.cMgr scanForPeripheralsWithServices:self.isFilter ? self.services : nil
                                              options:nil];
        }
            break;  
            
        default:
            break;
    }
<<<<<<< HEAD
    if (title.length) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:title delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }
=======
    
    
>>>>>>> 29a9fe281fbbd51d34e8c91ee5e6f19539edccc7
}


- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    
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
    self.peripheral = peripheral;
    self.peripheral.delegate = self;
    NSArray *services = [[NSArray alloc]initWithObjects:self.serviceUUID, nil];
    [self.peripheral discoverServices:services];
    if (self.connectBlock) {
        self.isConnected = YES;
        self.connectBlock(peripheral);
    }
}

// 外设连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    YZCLog(@"%@=连接失败",peripheral.name);
    self.isConnected = NO;
}

// 丢失连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"蓝牙已断开" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"好", nil];
        [alertView show];
    }
    
    YZCLog(@" %@=断开连接", peripheral.name);
    self.isConnected = NO;
    if (self.cannelBlock) {
        self.cannelBlock(peripheral);
        [self.reConnectPeripherals removeObject:peripheral];
    }else{
        if (self.isReconnection) { //重连操作
            if ([self.reConnectPeripherals containsObject:peripheral]) {
                
                [self.cMgr connectPeripheral:peripheral options:nil];
            }
        }
    }
}

#pragma mark - 外设代理
// 发现外设的服务后调用的方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
   
    if (error) {
        YZCLog(@" error = %@", error.localizedDescription);
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
            NSLog(@"characteristic UUID");
        }else if([characteristic.UUID.UUIDString isEqualToString:noticharacteristicUUID]) {
            self.noticharacteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.noticharacteristic];
<<<<<<< HEAD
             NSLog(@"noticharacteristic UUID");
=======
             YZCLog(@"订阅写入成功UUID");
>>>>>>> 29a9fe281fbbd51d34e8c91ee5e6f19539edccc7
        }
    }
}

// 更新特征的value的时候会调用
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error) {
        YZCLog( @"error = %@", error.localizedDescription);
        return;
    }
    
    if (self.deviceBlock) {
        self.deviceBlock(characteristic.value);
    }else{
        YZCLog(@"deviceBlock为nil");
    }
}


#pragma mark - 自定义方法
- (void)writeWithData:(NSData *)data rsp:(DeviceRsp)rsp
{
    
    [_peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    self.deviceBlock = rsp;
}
    
- (void)stopScan
{
    [self.cMgr stopScan];
}

- (void)connectedWithPeripheral:(CBPeripheral *)peripheral block:(ConnectPeripheralSuccess)block
{
    [self.cMgr stopScan];
    if (peripheral == nil) {
        return;
    }
    [self.cMgr connectPeripheral:peripheral options:nil];
    self.connectBlock = block;
    if (self.isReconnection) {
        [self.reConnectPeripherals addObject:peripheral];
    }
}

- (void)setBlockOnDiscoverToPeripherals:(ScanPeripheral)block
{
    
    [self cMgr];
    
    [self.cMgr scanForPeripheralsWithServices:self.isFilter ? self.services : nil   // 通过某些服务筛选外设
                                      options:nil]; // dict,条件
    self.peripheralBlock = block;
}

- (void)cannelWithPeripheral:(CBPeripheral *)peripheral block:(CannelPeripheral)block
{
    [self.cMgr cancelPeripheralConnection:peripheral];
    self.cannelBlock = block;
}


@end
