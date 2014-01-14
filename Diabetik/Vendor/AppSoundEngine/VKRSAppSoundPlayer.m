//
//  VKRSAppSoundPlayer.m
//
//  With additions made by Nial Giacomelli for Diabetik
//
//  Created by Vilem Kurz on 9.8.2011.
//  Copyright 2011 Cocoa Miners. All rights reserved.

#import "VKRSAppSoundPlayer.h"
#import "VKRSAPSSingleton.h"

@interface VKRSAppSoundPlayer ()

@property (nonatomic, copy) NSMutableDictionary *sounds;
@property (nonatomic, copy) NSMutableArray *soundsToPlay;

@end

@implementation VKRSAppSoundPlayer

+ (id)sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}
- (id)init
{
    self = [super init];
    
    if (self) {
        _sounds = [[NSMutableDictionary alloc] initWithCapacity:0];
        _soundsToPlay = [[NSMutableArray alloc] initWithCapacity:0];
        _soundsEnabled = YES;
    }
    
    return self;
}
- (void)playSound:(NSString *)sound
{
    if (!self.soundsEnabled) return;
    
    VKRSSound *soundToPlay = [self.sounds objectForKey:sound];
    if(soundToPlay)
    {
        if ([self.soundsToPlay count] == 0) {
            [soundToPlay play];
        }
        
        [self.soundsToPlay addObject:soundToPlay];
    }
}
- (void)addSoundWithFilename:(NSString *)filename andExtension:(NSString *)extension
{
    
    NSURL *soundFileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:extension];
    VKRSSound *aSound = [[VKRSSound alloc] initWithSoundFileURL:soundFileURL];
    aSound.delegate = self;
    [self.sounds setObject:aSound forKey:filename];     
}

#pragma mark - VKRSSoundDelegate methods
- (void)soundDidFinishPlaying:(VKRSSound *)sound
{
    if([self.soundsToPlay count])
    {
        [self.soundsToPlay removeObjectAtIndex:0];
    }
    
    if ([self.soundsToPlay count]) {
        VKRSSound *soundToPlay = [self.soundsToPlay objectAtIndex:0];
        [soundToPlay play];
    }
}

@end
