//
//  ViewController.m
//  BonjourServerDeclare
//
//  Created by tongguan on 16/6/20.
//  Copyright © 2016年 MinorUncle. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/NSNetServices.h>

@interface ViewController ()<NSNetServiceDelegate,NSStreamDelegate>
{
    NSNetService* _serverce;

}
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _serverce = [[NSNetService alloc]initWithDomain:@"local." type:@"_connent._tcp." name:@"" port:9000];
//    NSData* data = [NSData dataWithBytes:"1234567890" length:11];
    
//    [_serverce setTXTRecordData:data];
    _serverce.delegate = self;
    [_serverce publishWithOptions:NSNetServiceListenForConnections];
//      [_serverce publish];

    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)netServiceDidPublish:(NSNetService *)sender{
    NSLog(@"netServiceDidPublish");
}
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *, NSNumber *> *)errorDict{
    NSLog(@"didNotPublish error:%@",errorDict);
}
- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream{
    NSLog(@"didAcceptConnectionWithInputStream");
    inputStream.delegate = self;
    outputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [inputStream open];
    [outputStream open];
}
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
        {
            NSLog(@"NSStreamEventOpenCompleted");
        }
            break;
        case NSStreamEventHasBytesAvailable:
        {
            NSLog(@"NSStreamEventHasBytesAvailable");
            uint8_t buffer[10] = {0};
            [((NSInputStream*)aStream) read:buffer maxLength:10];
            NSLog(@"read:%s",buffer);
        }
            break;
        case NSStreamEventHasSpaceAvailable:
        {
            NSLog(@"NSStreamEventHasSpaceAvailable");
            [((NSOutputStream*)aStream) write:(UInt8*)"world" maxLength:10];
            sleep(1);
        }
            break;
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"NSStreamEventErrorOccurred");
        }
            break;
        case NSStreamEventEndEncountered:
        {
            NSLog(@"NSStreamEventEndEncountered");
        }
            break;
            
        default:
            break;
    }
}
//- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data{
//    NSString* str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"didUpdateTXTRecordData:%@",str);
//}
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSString* str = @"1234567890";
//    NSData* data = [NSData dataWithBytes:str.UTF8String length:str.length];
//    [_serverce setTXTRecordData:data];
//    [_serverce startMonitoring];
//    NSLog(@"setTXTRecordData:%@",str);
//}

- (void)didReceiveMemoryWarning {
  

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
