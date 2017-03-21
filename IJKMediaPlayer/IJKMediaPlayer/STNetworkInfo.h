//
//  STNetworkInfo.h
//  IJKMediaPlayer
//
//  Created by 陈卫强 on 2016/11/25.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Reachability.h>



@interface STNetworkInfo : NSObject
-(BOOL) initNetworkInfo;
-(void) uninitNetworkInfo;


@property (readonly) int networkType;
@property (nonatomic, readonly) NSString* ipAreaName;
@property (nonatomic, readonly) NSString* areaName;
@property (nonatomic, readonly) NSString*  operatorName;
@end
