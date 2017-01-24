//
//  YMCAudioPlayer.m
//  AudioPlayerTemplate
//
//  Created by ymc-thzi on 13.08.13.
//  Copyright (c) 2013 ymc-thzi. All rights reserved.
//

#import "YMCAudioPlayer.h"
@implementation YMCAudioPlayer

/*
 * Init the Player with Filename and FileExtension
 */
- (void)initPlayer:(NSString*)audioFile fileExtension:(NSString*)fileExtension
{
    NSURL *audioFileLocationURL = [[NSURL alloc]initFileURLWithPath:audioFile];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileLocationURL error:&error];
}
- (void)playAudio {
    [self.audioPlayer play];
}
- (void)audioVolume:(float)value {
    self.audioPlayer.volume = value;
}
- (void)pauseAudio {
    [self.audioPlayer pause];
}
-(void)stopAudio{
    [self.audioPlayer stop];
}

- (void)playInLoop {
    self.audioPlayer.numberOfLoops = -1;
}
-(NSString*)timeFormat:(float)value{
    
    float minutes = floor(lroundf(value)/60);
    float seconds = lroundf(value) - (minutes * 60);
    
    NSInteger roundedSeconds = lroundf(seconds);
    NSInteger roundedMinutes = lroundf(minutes);
    
    NSString *time = [[NSString alloc]initWithFormat:@"%ld:%02ld",(long)roundedMinutes, (long)roundedSeconds];
    return time;
}

/*
 * To set the current Position of the
 * playing audio File
 */
- (void)setCurrentAudioTime:(float)value {
    [self.audioPlayer setCurrentTime:value];
}

/*
 * Get the time where audio is playing right now
 */
- (NSTimeInterval)getCurrentAudioTime {
    return [self.audioPlayer currentTime];
}

/*
 * Get the whole length of the audio file
 */
- (NSTimeInterval)getAudioDuration {
    return [self.audioPlayer duration];
}

-(void)setRate:(float)rate{

    [self.audioPlayer setEnableRate:YES];
     [self.audioPlayer setRate:rate];
}



@end
