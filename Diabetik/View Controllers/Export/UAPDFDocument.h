//
//  UAPDFDocument.h
//  Diabetik
//
//  Created by Nial Giacomelli on 13/04/2013.
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

static const NSString *UAPDFDocumentFontName = @"UAPDFDocumentFontName";
static const NSString *UAPDFDocumentFontSize = @"UAPDFDocumentFontSize";
static const NSString *UAPDFDocumentFontColor = @"UAPDFDocumentFontColor";

@class UAPDFDocument;
@protocol UAPDFDocumentDelegate <NSObject>

@required
- (void)drawPDFTableHeaderInDocument:(UAPDFDocument *)document
                      withIdentifier:(NSString *)identifier
                             content:(id)content
                   contentAttributes:(NSDictionary *)contentAttributes
                         contentRect:(CGRect)contentRect
                            cellRect:(CGRect)cellRect;
- (void)drawPDFTableCellInDocument:(UAPDFDocument *)document
                    withIdentifier:(NSString *)identifier
                           content:(id)content
                 contentAttributes:(NSDictionary *)contentAttributes
                       contentRect:(CGRect)contentRect
                          cellRect:(CGRect)cellRect
                      cellPosition:(CGPoint)position;
- (NSDictionary *)attributesForPDFCellInDocument:(UAPDFDocument *)document
                                  withIdentifier:(NSString *)identifier
                                        rowIndex:(NSInteger)rowIndex
                                     columnIndex:(NSInteger)columnIndex;

@end

@interface UAPDFDocument : NSObject
@property (nonatomic, assign) id<UAPDFDocumentDelegate> delegate;
@property (nonatomic, strong) NSMutableData *data;

@property (nonatomic, assign) CGRect pageFrame;
@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, assign) CGFloat currentY;
@property (nonatomic, assign) NSInteger pageCount;

// Logic
- (void)close;
- (void)createNewPage;

// Drawing
- (void)drawImage:(UIImage *)image
       atPosition:(CGPoint)position;
- (void)drawTableWithRows:(NSArray *)rows
               andColumns:(NSArray *)columns
               atPosition:(CGPoint)position
                    width:(CGFloat)tableWidth
               identifier:(NSString *)identifier;
- (void)drawText:(NSString *)string
      atPosition:(CGPoint)position
        withFont:(UIFont *)font;
- (void)drawText:(NSString *)string
          inRect:(CGRect)rect
        withFont:(UIFont *)font
       alignment:(NSTextAlignment)alignment
   lineBreakMode:(UILineBreakMode)lineBreakMode;

@end
