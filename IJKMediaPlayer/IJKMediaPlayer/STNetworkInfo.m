//
//  STNetworkInfo.m
//  IJKMediaPlayer
//
//  Created by 陈卫强 on 2016/11/25.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#import "STNetworkInfo.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


typedef enum{
    networkUnknown,
    networkWifi,
    networkRTT,
    networkCDMA,
    networkEDGE,
    networkEVDO0,
    networkEVDOA,
    networkGPRS,
    networkHSDPA,
    networkHSPA,
    networkHSUPA,
    networkUMTS,
    networkEHRPD,
    nnetworkEVDOB,
    networkHSPAP,
    networkADEN,
    networkLTE,
}enumNetworkType;

@implementation STNetworkInfo{
    Reachability* internetConnectionReach;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}


-(BOOL) initNetworkInfo{
   
    self->_networkType = (int)networkUnknown;
    
    self->internetConnectionReach = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [self->internetConnectionReach startNotifier];
    
    //get country name
    NSLocale *locale = [NSLocale currentLocale];
    self->_areaName = [locale objectForKey:NSLocaleCountryCode];
    [self updateNetworkInfo];
    
    return YES;
}


- (void) updateNetworkInfo{
    
    self->_networkType = networkUnknown;
    switch ([self->internetConnectionReach currentReachabilityStatus]) {
        case ReachableViaWiFi:{
            self->_networkType = networkWifi;
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            CTCarrier* carrier = info.subscriberCellularProvider;
            self->_operatorName =  carrier.carrierName;
            //self->_ipAreaName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value: carrier.isoCountryCode];
        }
            break;
            
        case ReachableViaWWAN:{
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentStatus = info.currentRadioAccessTechnology;
            
            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                
                self->_networkType = networkGPRS;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                
                self->_networkType = networkEDGE;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
                
                self->_networkType = networkCDMA;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
                
                self->_networkType = networkHSDPA;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
                
                self->_networkType = networkHSUPA;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
                
                self->_networkType = networkRTT;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
                
                self->_networkType = networkEVDO0;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
                
                self->_networkType = networkEVDOA;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
                
                self->_networkType = nnetworkEVDOB;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
                
                self->_networkType = networkEHRPD;
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
                
                self->_networkType = networkLTE;
            }
            
            
            CTCarrier* carrier = info.subscriberCellularProvider;
            self->_operatorName =  carrier.carrierName;
            //self->_ipAreaName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value: carrier.isoCountryCode];
            
        }
            break;
            
            
            
        default:
            break;
    }
    
    NSLog(@"update network type, type=%d, iparea=%@", _networkType, self->_ipAreaName);
}

-(void) reachabilityChanged: (NSNotification*) notification {
    Reachability * reach = [notification object];
    if (reach == self->internetConnectionReach)
    {
        if([reach isReachable])
        {
            NSString * temp = [NSString stringWithFormat:@"InternetConnection Notification Says Reachable(%@)", reach.currentReachabilityString];
            NSLog(@"%@", temp);
            [self updateNetworkInfo];
            
        }
        else
        {
            NSString * temp = [NSString stringWithFormat:@"InternetConnection Notification Says Unreachable(%@)", reach.currentReachabilityString];
            NSLog(@"%@", temp);

        }
    }

}

-(void) uninitNetworkInfo{
    [self->internetConnectionReach stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
