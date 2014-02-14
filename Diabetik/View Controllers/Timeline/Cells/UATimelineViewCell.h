//
//  UATimelineViewCell.h
//  Diabetik
//
//  Created by Nial Giacomelli on 23/01/2013.
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

#import <UIKit/UIKit.h>

@interface UATimelineViewCell : UAGenericTableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) NSDictionary *metadata;
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) UITextView *notesTextView;

// Logic
- (void)setPhotoImage:(UIImage *)image;
- (void)setMetaData:(NSDictionary *)data;
- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer
          withController:(UIViewController *)controller
               indexPath:(NSIndexPath *)indexPath
            andTableView:(UITableView *)tableView;

// Accessors
- (void)setDate:(NSDate *)aDate;

// Helpers
+ (CGFloat)additionalHeightWithMetaData:(NSDictionary *)data width:(CGFloat)width;

@end
