//
//  UAMediaController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 24/02/2013.
//  Copyright (c) 2013-2014 Nial Giacomelli
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>

@interface UAMediaController : NSObject

+ (id)sharedInstance;

// Logic
- (void)saveImage:(UIImage *)image
     withFilename:(NSString *)filename
          success:(void (^)(void))successCallback
          failure:(void (^)(NSError *))failureCallback;
- (void)deleteImageWithFilename:(NSString *)filename
                        success:(void (^)(void))successCallback
                        failure:(void (^)(NSError *))failureCallback;
- (UIImage *)imageWithFilename:(NSString *)filename;
- (void)imageWithFilenameAsync:(NSString *)filename
                       success:(void (^)(UIImage *))successCallback
                       failure:(void (^)(void))failureCallback;

// Helpers
- (UIImage *)resizeImage:(UIImage *)image
                  toSize:(CGSize)newSize;
+ (BOOL)canStoreMedia;

@end
