//
//  STLogReporter.h
//  IJKMediaPlayer
//
//  Created by 陈卫强 on 2016/11/21.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>

//common keys
static  NSString* KEY_NETWORK = @"network";
static  NSString* KEY_EQUIPID = @"equipID";
static  NSString* KEY_OPERATOR = @"operator";
static  NSString* KEY_AREA = @"area";
static  NSString* KEY_IPAREA = @"ipAreaName";
static  NSString* KEY_SESSIONID= @"sessionID";
static  NSString* KEY_VIDEO_TOTALTIME = @"video_totaltime";
static  NSString* KEY_APP_VERSION = @"version";
static  NSString* KEY_LIVE = @"isLive";
static  NSString* KEY_EVENTID = @"eventID";
static  NSString* KEY_PLAY_URL = @"uri";



@interface STLogReporter : NSObject
+(instancetype) instance;
-(BOOL) postLog:(NSString*) url;
-(void) insertCommLog:(NSString*)key value:(NSObject*) obj;
-(void) insertPlayLog:(NSString*)key value:(NSObject*) obj;
-(void) insertStateLog: (NSMutableDictionary*)opt;
@end
