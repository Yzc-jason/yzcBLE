//
//  ViewController.m
//  CoreBluetoothDemo
//
//  Created by 叶志成 on 16/7/28.
//  Copyright © 2016年 叶志成. All rights reserved.
//

#import "ViewController.h"
#import "yzcBLE/yzcBLE.h"
#import "TestController.h"


@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *dataSoure;


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSoure = [NSMutableArray array];
    BlueToothManager *manager = [BlueToothManager sharedInstance];
//    manager.isFilter = YES;
    manager.isReconnection = YES;
    manager.services = @[[CBUUID UUIDWithString:@"0783B03E-8535-B5A0-7140-A304D2495CB7"]];
    [[BlueToothManager sharedInstance] setBlockOnDiscoverToPeripherals:^(BLEModel *model) {
        [self.dataSoure addObject:model];
        [self.tableView reloadData];
    }];
}


#pragma mark - tableViewDelegate & tableViewDataSource


// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSoure.count;
}
// 行高,调用顺序比cellForRowAtIndexPath方法优先
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

// 点击Cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLEModel *model = self.dataSoure[indexPath.row];
    [[BlueToothManager sharedInstance] connectedWithPeripheral:model.peripheral block:^(CBPeripheral *peripheral) {
        NSString *msg = [NSString stringWithFormat:@"连接%@成功",model.peripheral.name];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        TestController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TestController"];
        vc.title = @"测试数据";
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
}

// Cell循环利用
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    BLEModel *model = self.dataSoure[indexPath.row];
    cell.textLabel.text = model.peripheral.name;
    
    return cell;
}
@end
