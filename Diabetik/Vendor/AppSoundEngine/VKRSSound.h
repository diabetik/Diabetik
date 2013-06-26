//
//  VKRSSound.h
//
//  Created by Vilem Kurz on 9.8.2011.
//  Copyright 2011 Cocoa Miners. All rights reserved.


#import <Foundation/Foundation.h>

@protocol VKRSSoundDelegate;

@interface VKRSSound : NSObject

@property (nonatomic, weak) id <VKRSSoundDelegate> delegate;

- (id)initWithSoundFileURL:(NSURL *)url;
- (void)play;

@end

@protocol VKRSSoundDelegate

- (void)soundDidFinishPlaying:(VKRSSound *)sound;

@end
