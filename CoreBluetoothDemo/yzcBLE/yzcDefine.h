//
//  yzcDefine.h
//  CoreBluetoothDemo
//
//  Created by mac on 16/10/26.
//  Copyright © 2016年 叶志成. All rights reserved.
//

// 自定义Log
#ifdef DEBUG

#define YZCLog(...) NSLog(@"%s %d \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])

#else
#define YZCLog(...)

#endif
