//
//  ViewController.m
//  BonjourClientSearch
//
//  Created by tongguan on 16/6/20.
//  Copyright © 2016年 MinorUncle. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/NSNetServices.h>
#import <netinet/in.h>
#import <arpa/inet.h>
@interface ViewController ()<NSNetServiceBrowserDelegate,NSNetServiceDelegate,NSStreamDelegate>
{
    NSNetServiceBrowser* _searchService;
    NSMutableArray< NSNetService*>* _services;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _services = [[NSMutableArray alloc]initWithCapacity:4];
    _searchService = [[NSNetServiceBrowser alloc]init];
    _searchService.delegate = self;
    [_searchService searchForServicesOfType:@"_connent._tcp." inDomain:@"local."];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing{
    [_services addObject:service];//一定要引用
    service.delegate = self;
    
    NSLog(@"didFindService name:%@,type:%@,domain:%@",service.name,service.type,service.domain);
    [service resolveWithTimeout:5.0];
}
- (void)netServiceDidResolveAddress:(NSNetService *)service{
    NSLog(@"netServiceDidResolveAddress hostname:%@",service.hostName);
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    BOOL recult =  [service getInputStream:&inputStream outputStream:&outputStream ];
    if (recult) {
        inputStream.delegate = self;
        outputStream.delegate = self;
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [inputStream open];
        [outputStream open];
    }
    NSArray* arry = service.addresses;
    for (NSData* data in arry) {
        struct sockaddr_in *addr = (struct sockaddr_in *)[data bytes];
        NSLog(@"ip:%s,port:%d",inet_ntoa(addr->sin_addr),ntohs(addr->sin_port));
    }
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
-(void)netServiceDidStop:(NSNetService *)sender{
    NSLog(@"netServiceDidStop");
}
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *, NSNumber *> *)errorDict{
    NSLog(@"didNotResolve error:%@",errorDict);
}
//- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data{
//    NSString* str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"didUpdateTXTRecordData:%@",str);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
