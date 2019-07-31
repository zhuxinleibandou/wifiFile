//
//  IPManager.m
//  Wi-Fi传输文件
//
//  Created by 朱信磊 on 2019/7/30.
//  Copyright © 2019 com.bandou.app.xib.demo. All rights reserved.
//

#import "IPManager.h"
//Get IP 需要导入的库文件
#import <ifaddrs.h>
#import <arpa/inet.h>

static IPManager *manager;

@interface IPManager()

@end

@implementation IPManager

+ (id)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[IPManager alloc] init];
    });
    return manager;
}

- (NSString *)bd_getIPAddress {
    
    NSString *address = @"error";
    
    struct ifaddrs *interfaces = NULL;
    
    struct ifaddrs *temp_addr = NULL;
    
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        
        // Loop through linked list of interfaces
        
        temp_addr = interfaces;
        
        while(temp_addr != NULL) {
            
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                
                // Check if interface is en0 which is the wifi connection on the iPhone
                
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    
                    // Get NSString from C String
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
        
    }
    
    // Free memory
    
    freeifaddrs(interfaces);
    
    return address;
}

@end
