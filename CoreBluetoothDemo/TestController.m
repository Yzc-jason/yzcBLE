//
//  TestController.m
//  CoreBluetoothDemo
//
//  Created by 叶志成 on 16/8/6.
//  Copyright © 2016年 叶志成. All rights reserved.
//

#import "TestController.h"
#import "yzcBLE.h"

@interface TestController()

@property (weak, nonatomic) IBOutlet UITextField *textField;


@end

@implementation TestController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)getStepAction:(id)sender
{
    NSString *str = @"GET,STEP";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [[BlueToothManager sharedInstance] writeWithData:data  rsp:^(NSData *data) {
        NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@---%@",data,result);
    }];
}

- (IBAction)setTimeAction:(id)sender
{
    NSString *time = @"SET,DT,201608061121";
    NSData *data = [time dataUsingEncoding:NSUTF8StringEncoding];
    [[BlueToothManager sharedInstance] writeWithData:data  rsp:^(NSData *data) {
        NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@---%@",data,result);
    }];
}

- (IBAction)getHeatRateAction:(id)sender
{
    NSString *rate = @"GET,H_R";
    NSData *data = [rate dataUsingEncoding:NSUTF8StringEncoding];
    [[BlueToothManager sharedInstance] writeWithData:data  rsp:^(NSData *data) {
        NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@---%@",data,result);
    }];
}

- (IBAction)sendData:(id)sender
{
    NSString *text = self.textField.text;
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [[BlueToothManager sharedInstance] writeWithData:data  rsp:^(NSData *data) {
        NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@---%@",data,result);
    }];
}

@end
