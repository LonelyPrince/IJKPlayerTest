/*
 * IJKFFMoviePlayerController.h
 *
 * Copyright (c) 2013 Zhang Rui <bbcallen@gmail.com>
 *
 * This file is part of ijkPlayer.
 *
 * ijkPlayer is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * ijkPlayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with ijkPlayer; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#import "IJKMediaPlayback.h"
#import "IJKFFMonitor.h"
#import "IJKFFOptions.h"

// media meta
#define k_IJKM_KEY_FORMAT         @"format"
#define k_IJKM_KEY_DURATION_US    @"duration_us"
#define k_IJKM_KEY_START_US       @"start_us"
#define k_IJKM_KEY_BITRATE        @"bitrate"

// stream meta
#define k_IJKM_KEY_TYPE           @"type"
#define k_IJKM_VAL_TYPE__VIDEO    @"video"
#define k_IJKM_VAL_TYPE__AUDIO    @"audio"
#define k_IJKM_VAL_TYPE__UNKNOWN  @"unknown"

#define k_IJKM_KEY_CODEC_NAME      @"codec_name"
#define k_IJKM_KEY_CODEC_PROFILE   @"codec_profile"
#define k_IJKM_KEY_CODEC_LONG_NAME @"codec_long_name"

// stream: video
#define k_IJKM_KEY_WIDTH          @"width"
#define k_IJKM_KEY_HEIGHT         @"height"
#define k_IJKM_KEY_FPS_NUM        @"fps_num"
#define k_IJKM_KEY_FPS_DEN        @"fps_den"
#define k_IJKM_KEY_TBR_NUM        @"tbr_num"
#define k_IJKM_KEY_TBR_DEN        @"tbr_den"
#define k_IJKM_KEY_SAR_NUM        @"sar_num"
#define k_IJKM_KEY_SAR_DEN        @"sar_den"
// stream: audio
#define k_IJKM_KEY_SAMPLE_RATE    @"sample_rate"
#define k_IJKM_KEY_CHANNEL_LAYOUT @"channel_layout"

#define kk_IJKM_KEY_STREAMS       @"streams"

typedef enum IJKLogLevel {
    k_IJK_LOG_UNKNOWN = 0,
    k_IJK_LOG_DEFAULT = 1,

    k_IJK_LOG_VERBOSE = 2,
    k_IJK_LOG_DEBUG   = 3,
    k_IJK_LOG_INFO    = 4,
    k_IJK_LOG_WARN    = 5,
    k_IJK_LOG_ERROR   = 6,
    k_IJK_LOG_FATAL   = 7,
    k_IJK_LOG_SILENT  = 8,
} IJKLogLevel;

@interface IJKFFMoviePlayerController : NSObject <IJKMediaPlayback>


//specific: init player with url and options
//param: aUrl, video url or file path
//       options, ffmpeg options, nil for default options
//return: !=nil, succeed to create instance
//          nil, fail to create instance
- (id)initWithContentURL:(NSURL *)aUrl
             withOptions:(IJKFFOptions *)options playView:(UIView*)playView;

//specific: init player with url and options
//param: aUrl, video url or file path
//       options, ffmpeg options, nil for default options
//playView: usually should be nil, but client should save the render view created by IJKFFMoviePlayerController  internal when changing stream hd/sd/ad, and reuse it for next play
//return: !=nil, succeed to create instance
//          nil, fail to create instance
- (id)initWithContentURLString:(NSString *)aUrlString
                   withOptions:(IJKFFOptions *)options playView:(UIView*)playView;

//start player
- (void)prepareToPlay:(NSTimeInterval) startTime;
- (void)play;
- (void)pause;
- (void)seek:(NSTimeInterval) targetTime;
//stop player
- (void)shutdown;

//set console log level
- (void)setLogLevel:(IJKLogLevel)logLevel;

//set domain/ip dic info for predns, key=domainName(NSString) value=remoteIp(NSArray)
- (Boolean)setPreDNSInfo:(NSDictionary<NSString*, NSArray*>*) dicIPs;


//support multi audio and subtitles
-(int) selectStream: (int) stream flag:(int) onoff;

//get dictionary<string, string> of audio/subtitle tracks, key==stream index, value=language name
//when recv notificaiton of IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
-(NSDictionary*)getAudioTracks;
-(NSDictionary*)getSubtitleTracks;


//reprot background log to db
@property(nonatomic) NSString* logDBUrl;
@property(nonatomic) BOOL isReportLog;
@property(nonatomic) int isLive;
@property(nonatomic, readonly) int selectedAudio;    //current audio stream index
@property(nonatomic, readonly) int selectedSubtitle; //current subtitle stream indexls



//start play fast
@property(nonatomic) BOOL fastDisplay;
//http keepalive for play hls
@property(nonatomic) BOOL httpKeepAlive;



//usually not used by user
//-------------------------------------------------------------------------------
- (void)setOptionValue:(NSString *)value
                forKey:(NSString *)key
            ofCategory:(IJKFFOptionCategory)category;

- (void)setOptionIntValue:(int64_t)value
                   forKey:(NSString *)key
               ofCategory:(IJKFFOptionCategory)category;

- (void)setFormatOptionValue:       (NSString *)value forKey:(NSString *)key;
- (void)setCodecOptionValue:        (NSString *)value forKey:(NSString *)key;
- (void)setSwsOptionValue:          (NSString *)value forKey:(NSString *)key;
- (void)setPlayerOptionValue:       (NSString *)value forKey:(NSString *)key;

- (void)setFormatOptionIntValue:    (int64_t)value forKey:(NSString *)key;
- (void)setCodecOptionIntValue:     (int64_t)value forKey:(NSString *)key;
- (void)setSwsOptionIntValue:       (int64_t)value forKey:(NSString *)key;
- (void)setPlayerOptionIntValue:    (int64_t)value forKey:(NSString *)key;


+ (void)setLogReport:(BOOL)preferLogReport;

+ (BOOL)checkIfFFmpegVersionMatch:(BOOL)showAlert;
+ (BOOL)checkIfPlayerVersionMatch:(BOOL)showAlert
                            version:(NSString *)version;

//not used for user
- (void)stop;
- (void)setPauseInBackground:(BOOL)pause;
- (BOOL)isVideoToolboxOpen;
- (BOOL)isPlaying;

@property(nonatomic, readonly) CGFloat fpsInMeta;
@property(nonatomic, readonly) CGFloat fpsAtOutput;
@property(nonatomic) BOOL shouldShowHudView;


@property (nonatomic, retain) id<IJKMediaUrlOpenDelegate> segmentOpenDelegate;
@property (nonatomic, retain) id<IJKMediaUrlOpenDelegate> tcpOpenDelegate;
@property (nonatomic, retain) id<IJKMediaUrlOpenDelegate> httpOpenDelegate;
@property (nonatomic, retain) id<IJKMediaUrlOpenDelegate> liveOpenDelegate;

@property (nonatomic, retain) id<IJKMediaNativeInvokeDelegate> nativeInvokeDelegate;
//-------------------------------------------------------------------------------
- (void)didShutdown;

#pragma mark KVO properties
@property (nonatomic, readonly) IJKFFMonitor *monitor;

@end

#define IJK_FF_IO_TYPE_READ (1)
void IJKFFIOStatDebugCallback(const char *url, int type, int bytes);
void IJKFFIOStatRegister(void (*cb)(const char *url, int type, int bytes));

void IJKFFIOStatCompleteDebugCallback(const char *url,
                                      int64_t read_bytes, int64_t total_size,
                                      int64_t elpased_time, int64_t total_duration);
void IJKFFIOStatCompleteRegister(void (*cb)(const char *url,
                                            int64_t read_bytes, int64_t total_size,
                                            int64_t elpased_time, int64_t total_duration));
