//
//  Singleton.h
//  weighme
//
//  Created by Vilem Kurz on 1.3.2012.
//  Copyright (c) 2012 Cocoa Miners. All rights reserved.
//

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t pred = 0; \
__strong static id _sharedObject = nil; \
dispatch_once(&pred, ^{ \
_sharedObject = block(); \
}); \
return _sharedObject; \
