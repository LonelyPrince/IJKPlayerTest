//
//  STLogReporter.m
//  IJKMediaPlayer
//
//  Created by 陈卫强 on 2016/11/21.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#import "STLogReporter.h"


static NSString* TAG_COMMON = @"common";
static NSString* TAG_OPTLOG = @"log";
static NSString* TAG_PLAYLOG = @"start_time_log";

static STLogReporter* logReporter = nil;
@implementation STLogReporter{
    NSMutableDictionary* _dicLogs;
    
}


+(instancetype) instance{
    if (!logReporter) {
        logReporter = [STLogReporter alloc];
        logReporter->_dicLogs = [NSMutableDictionary dictionary];
        [logReporter initDictionary];
    }
    return logReporter;
}

- (void)dealloc{
    NSLog(@"release log reporter");
}

-(void) initDictionary{
    self->_dicLogs[TAG_COMMON] = [NSMutableDictionary dictionary];
    self->_dicLogs[TAG_OPTLOG] = [NSMutableArray array];
    self->_dicLogs[TAG_PLAYLOG] = [NSMutableDictionary dictionary];
}

-(void) clearDictionary{
    [self->_dicLogs[TAG_COMMON] removeAllObjects];
    [self->_dicLogs[TAG_OPTLOG] removeAllObjects];
    [self->_dicLogs[TAG_PLAYLOG] removeAllObjects];
}

-(NSString*)packJson{
    NSDateFormatter* dateformat =[[NSDateFormatter alloc]init];
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* timenow = [dateformat stringFromDate:[NSDate date]];
    long timeinterval = [[NSDate date] timeIntervalSince1970];
    NSNumber* timenowNum = [NSNumber numberWithLong:timeinterval];
    [_dicLogs[TAG_COMMON] setObject:@"ios" forKey:@"equip_type"];
    [_dicLogs[TAG_COMMON] setObject:timenowNum forKey:@"log_time"];
    [_dicLogs[TAG_COMMON] setObject:timenow forKey:@"log_ftime"];
    if(![NSJSONSerialization isValidJSONObject:_dicLogs]){
        NSLog(@"it is not a JSONObject!");
        return nil;
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_dicLogs options:NSJSONWritingPrettyPrinted error:&error];
    if([jsonData length] > 0 && error == nil) {
        NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
#ifdef _DEBUG
        NSLog(@"log json data:%@",jsonString);
#endif
        [self clearDictionary];
        return jsonString;
    }
    return nil;

}

//http conenct err
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"report log db failed: %@",[error localizedDescription]);
}

-(BOOL) postLog:(NSString*) url{
    NSString* msg = [self packJson];
    if (msg!=nil) {
        
        NSString* dbAddr = url;
        if (dbAddr==nil || dbAddr.length==0) {
            dbAddr = @"http://data.startimestv.com:8080/iosplayer/startimes_player_logs";
        }
        NSURL * dbUrl = [NSURL URLWithString:dbAddr];
        
        //sync post
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:dbUrl];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[msg dataUsingEncoding: NSUTF8StringEncoding]];
        
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (theConnection==nil) {
            NSLog(@"fail to connect log db");
        }
        return YES;
    }
    return NO;
}

-(void) insertCommLog:(NSString*)logKey value:(NSObject*) logValue{
    if (logValue!=nil)
        [self->_dicLogs[TAG_COMMON] setObject:logValue forKey:logKey];
}

-(void) insertPlayLog:(NSString*)logKey value:(NSObject*) logValue{
    @try {
        [self->_dicLogs[TAG_PLAYLOG] setObject:logValue forKey:logKey];
    } @catch (NSException *exception) {
        NSLog(@"insert play log exception=%@", exception);
    } @finally {
        
    }
    
}

-(void) insertStateLog: (NSMutableDictionary*)logs{
    [self->_dicLogs[TAG_OPTLOG] addObject:logs];
}
@end
