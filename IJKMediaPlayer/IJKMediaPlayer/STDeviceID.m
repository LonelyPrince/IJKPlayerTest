//
//  STDeviceID.m
//  IJKMediaPlayer
//
//  Created by 陈卫强 on 2016/11/25.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#import "STDeviceID.h"

@implementation STDeviceID

static NSString *kServiceName = @"com.startimes.onlinetv"; //把YOUR_APP_BundleIdentifier换成应用的bundleId
static NSString *kDeviceID = @"player_deviceid";


+(NSString *) createDevID{
    NSString *uuid = nil;
    if(NSClassFromString(@"NSUUID")) { // only available in iOS >= 6.0
        
        uuid = [[NSUUID UUID] UUIDString];
    }
    else{
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef cfuuid = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        CFRelease(uuidRef);
        uuid = [((__bridge NSString *) cfuuid) copy];
        CFRelease(cfuuid);

    }
    NSString* devid = @"ios_";
    devid = [devid stringByAppendingString:uuid];
    return devid;
}

+(Boolean)saveDevID:(NSString *)value key:(NSString*)key inService:(NSString*)service {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
    [keychainItem setObject: (id)kSecClassGenericPassword forKey:(id)kSecClass];
    [keychainItem setObject: (id)kSecAttrAccessibleAlways forKey:(id)kSecAttrAccessible];
    NSData* encodedKey = [key dataUsingEncoding:NSUTF8StringEncoding];
    [keychainItem setObject: encodedKey forKey:(id)kSecAttrAccount];
    [keychainItem setObject: encodedKey forKey:(id)kSecAttrGeneric];
    [keychainItem setObject: service forKey:(id)kSecAttrService];
    [keychainItem setObject: [value dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
    SecItemDelete((__bridge CFDictionaryRef)keychainItem);
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
    if (status!=noErr) {
        NSLog(@"fail to save uuid to keychain, key=%@, service=%@", key, service);
        return NO;
    }
    return YES;
//    [[NSUserDefaults standardUserDefaults] setObject: uuid forKey: kUUID ];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(NSString*)getUUIDFromKeychain:(NSString*)key inService:(NSString *)service{
    
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    NSData *encodedKey = [key dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedKey forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedKey forKey:(id)kSecAttrAccount];
    [searchDictionary setObject:service forKey:(id)kSecAttrService];
    [searchDictionary setObject: (id)kSecAttrAccessibleAlways forKey:(id)kSecAttrAccessible];
    [searchDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    
    CFTypeRef result = nil;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)searchDictionary,
                                          &result);
    if (status != noErr) {
        NSLog(@"read keychain failed, key=%@, serivce=%@", key, service);
    }else{
        NSLog(@"read keychain succssed,key=%@, serivce=%@", key, service);
    }
    NSData *uuidData = (__bridge NSData *)result;
    NSString *uuid = nil;
    if (uuidData) {
        uuid = [[NSString alloc] initWithData:uuidData encoding:NSUTF8StringEncoding];
        return uuid;
    }
    return nil;
}


+(NSString*)getDeviceID{

    NSString* service = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if (service==nil) {
        service = kServiceName;
    }
    NSString* devID = [STDeviceID getUUIDFromKeychain:kDeviceID inService:service];
    if(devID==nil)
    {
        devID = [STDeviceID createDevID];
        if( ![STDeviceID saveDevID:devID key:kDeviceID inService:kServiceName])
        {
            return @"";
        }
    }
    
    NSLog(@"get device id=%@", devID);
    return devID;
}

@end
