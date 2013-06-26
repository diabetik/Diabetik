//
//  VKRSSound.m
//
//  Created by Vilem Kurz on 9.8.2011.
//  Copyright 2011 Cocoa Miners. All rights reserved.

#import "VKRSSound.h"
#import <AudioToolbox/AudioToolbox.h>

@interface VKRSSound () {
    
    SystemSoundID handle;
}

- (void)playFinished;

@end

@implementation VKRSSound

static void soundFinished (SystemSoundID mySSID, void *vkrsSound) {
    
    [(__bridge VKRSSound *)vkrsSound playFinished];   
}

- (id)initWithSoundFileURL:(NSURL *)url {
    
    self = [super init];
    
    if (self) {        
         
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) url, &handle);
        AudioServicesAddSystemSoundCompletion (handle, NULL, NULL, soundFinished, (__bridge void *)(self));
    }
    
    return self;
}

- (void)dealloc {
    
    AudioServicesRemoveSystemSoundCompletion(handle);
    AudioServicesDisposeSystemSoundID(handle);
}

- (void)play {
    
    AudioServicesPlaySystemSound(handle);
}

- (void)playFinished {

    [self.delegate soundDidFinishPlaying:self];
}

@end
