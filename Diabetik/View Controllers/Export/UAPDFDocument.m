//
//  UAPDFDocument.m
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

#import "UAPDFDocument.h"

#define kTableCellPadding 5.0f

@implementation UAPDFDocument
@synthesize contentFrame = _contentFrame;

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if(self)
    {
        self.pageFrame = CGRectMake(0, 0, 612, 792);
        self.contentFrame = CGRectMake(45, 39, 512, 714);
        
        self.pageCount = 1;
        self.data = [[NSMutableData alloc] init];
        
        UIGraphicsBeginPDFContextToData(self.data, CGRectZero, nil);
        [self createNewPage];
    }
    
    return self;
}

#pragma mark - Logic
- (void)close
{
    UIGraphicsEndPDFContext();
}
- (void)createNewPage
{
    UIGraphicsBeginPDFPageWithInfo(self.pageFrame, nil);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
    
    [[NSString stringWithFormat:@"%ld", (long)self.pageCount] drawInRect:CGRectMake(self.pageFrame.origin.x, self.pageFrame.origin.y + self.pageFrame.size.height - 32.0f, self.pageFrame.size.width, 32.0f)
                                                   withAttributes:@{NSFontAttributeName: [UAFont standardDemiBoldFontWithSize:10.0f], NSParagraphStyleAttributeName: paragraphStyle}];
    
    self.pageCount ++;
}

#pragma mark - Rendering
- (void)drawImage:(UIImage *)image
       atPosition:(CGPoint)position
{
    [image drawAtPoint:position];
    
    self.currentY = position.y + image.size.height;
}
- (void)drawTableWithRows:(NSArray *)rows
               andColumns:(NSArray *)columns
               atPosition:(CGPoint)position
                    width:(CGFloat)tableWidth
               identifier:(NSString *)tableIdentifier
{
    CGFloat x = position.x, y = position.y;
    
    NSMutableArray *headerTitles = [NSMutableArray array];
    for(NSDictionary *column in columns)
    {
        [headerTitles addObject:[column objectForKey:@"title"]];
    }
    
    CGFloat headerHeight = [self heightForRow:headerTitles
                                  withColumns:columns
                                   atPosition:position
                              tableIdentifier:tableIdentifier
                                        width:tableWidth];
    
    // Make sure our header won't push us onto a new page
    if((y + headerHeight) > CGRectGetMaxY(self.contentFrame))
    {
        [self createNewPage];
        y = self.contentFrame.origin.y;
    }
    
    // Render our table headers
    NSInteger columnIndex = 0, rowIndex = 0;
    for(NSDictionary *column in columns)
    {
        double columnWidthPercentage = [[column objectForKey:@"width"] doubleValue];
        double columnSize = (tableWidth/100)*columnWidthPercentage;
        
        NSString *headerTitle = [column objectForKey:@"title"];
        
        NSDictionary *attributes = [self.delegate attributesForPDFCellInDocument:self
                                                                  withIdentifier:tableIdentifier
                                                                        rowIndex:rowIndex
                                                                     columnIndex:columnIndex];
        if(attributes)
        {
            [self.delegate drawPDFTableHeaderInDocument:self
                                         withIdentifier:tableIdentifier
                                                content:headerTitle
                                      contentAttributes:attributes
                                            contentRect:CGRectMake(x+kTableCellPadding, y+kTableCellPadding, columnSize-(kTableCellPadding*2), headerHeight-(kTableCellPadding*2))
                                               cellRect:CGRectMake(x, y, columnSize, headerHeight)];
        }
        
        x += columnSize;
        columnIndex++;
    }
    y += headerHeight;
    
    // Render our table content
    columnIndex = 0;
    rowIndex = 1;
    for(NSArray *row in rows)
    {
        CGFloat rowHeight = [self heightForRow:row
                                   withColumns:columns
                                    atPosition:CGPointMake(position.x, y)
                               tableIdentifier:tableIdentifier
                                         width:tableWidth];
        
        x = position.x;
        
        // Make sure our header won't push us onto a new page
        if((y + rowHeight) > CGRectGetMaxY(self.contentFrame))
        {
            [self createNewPage];
            y = self.contentFrame.origin.y;
        }
        
        for(NSDictionary *column in columns)
        {
            double columnWidthPercentage = [[column objectForKey:@"width"] doubleValue];
            double columnSize = (tableWidth/100)*columnWidthPercentage;
            
            NSDictionary *attributes = [self.delegate attributesForPDFCellInDocument:self
                                                                      withIdentifier:tableIdentifier
                                                                            rowIndex:rowIndex
                                                                         columnIndex:columnIndex];
            if(attributes)
            {
                NSString *data = [row objectAtIndex:columnIndex];
                [self.delegate drawPDFTableCellInDocument:self
                                           withIdentifier:tableIdentifier
                                                  content:data
                                        contentAttributes:attributes
                                              contentRect:CGRectMake(x+kTableCellPadding, y+kTableCellPadding, columnSize-(kTableCellPadding*2), rowHeight-(kTableCellPadding*2))
                                                 cellRect:CGRectMake(x, y, columnSize, rowHeight)
                                             cellPosition:CGPointMake(columnIndex, rowIndex-1)];
            }
            
            x += columnSize;
            columnIndex ++;
        }
        y += rowHeight;
        columnIndex = 0;
        rowIndex ++;
    }
}
- (CGFloat)heightForRow:(NSArray *)row
            withColumns:(NSArray *)columns
             atPosition:(CGPoint)position
        tableIdentifier:(NSString *)tableIdentifier
                  width:(CGFloat)tableWidth
{
    NSInteger columnIndex = 0;
    CGFloat height = 0.0f;
    for(NSDictionary *column in columns)
    {
        double columnWidthPercentage = [[column objectForKey:@"width"] doubleValue];
        double columnSize = (tableWidth/100)*columnWidthPercentage;
        
        NSInteger rowIndex = 0;
        for(NSString *data in row)
        {
            NSDictionary *attributes = [self.delegate attributesForPDFCellInDocument:self
                                                                      withIdentifier:tableIdentifier
                                                                            rowIndex:rowIndex
                                                                         columnIndex:column];
            if(attributes)
            {

                CGRect textFrame = [data boundingRectWithSize:CGSizeMake(columnSize-(kTableCellPadding*2), CGFLOAT_MAX)
                                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                   attributes:@{NSFontAttributeName:attributes[UAPDFDocumentFontName]}
                                                      context:nil];
                
                if(textFrame.size.height > height) height = textFrame.size.height+(kTableCellPadding*2);
            }
            rowIndex++;
        }
        
        columnIndex++;
    }
    
    return height;
}
- (void)drawText:(NSString *)string
      atPosition:(CGPoint)position
        withFont:(UIFont *)font
{
    CGRect textFrame = [string boundingRectWithSize:CGSizeMake(CGRectGetMaxX(self.contentFrame) - position.x, CGFLOAT_MAX)
                                            options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                         attributes:@{NSFontAttributeName:font}
                                            context:nil];
    CGRect renderFrame = CGRectMake(position.x, position.y, textFrame.size.width, textFrame.size.height);
    
    [self drawText:string inRect:renderFrame withFont:font alignment:NSTextAlignmentLeft lineBreakMode:NSLineBreakByWordWrapping];
}
- (void)drawText:(NSString *)string
          inRect:(CGRect)rect
        withFont:(UIFont *)font
       alignment:(NSTextAlignment)alignment
   lineBreakMode:(UILineBreakMode)lineBreakMode
{
    // Will this spill over onto a new page?
    if(CGRectGetMaxY(rect) > CGRectGetMaxY(self.contentFrame))
    {
        [self createNewPage];
        
        rect.origin.y = self.currentY = self.contentFrame.origin.y;
    }
    else
    {
        self.currentY = rect.origin.y;
    }
    
    // Render our text
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:alignment];
    [paragraphStyle setLineBreakMode:lineBreakMode];
    
    [string drawInRect:rect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle}];
    
    self.currentY += rect.size.height;
}

#pragma mark - Accessors
- (void)setContentFrame:(CGRect)newFrame
{
    _contentFrame = newFrame;
    
    self.currentY = CGRectGetMinY(_contentFrame);
}

@end
