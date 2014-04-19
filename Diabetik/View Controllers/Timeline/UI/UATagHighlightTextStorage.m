//
//  UATagHighlightTextStorage.m
//  Diabetik
//
//  Created by Nial Giacomelli on 24/01/2014.
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

#import "UATagHighlightTextStorage.h"
#import "UATagController.h"

@implementation UATagHighlightTextStorage
{
    NSMutableAttributedString *_backingStore;
}

#pragma mark - Setup
- (id)init
{
    if(self = [super init])
    {
        _backingStore = [NSMutableAttributedString new];
    }
    return self;
}

#pragma mark - Reading
- (NSString *)string
{
    return [_backingStore string];
}
- (NSDictionary *)attributesAtIndex:(NSUInteger)location
                     effectiveRange:(NSRangePointer)range
{
    return [_backingStore attributesAtIndex:location effectiveRange:range];
}

#pragma mark - Writing
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self beginEditing];
    [_backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    [self endEditing];
}
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];
    [_backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

#pragma mark - Tag highlighting logic
- (void)processEditing
{
    NSRegularExpression *regex = [UATagController tagRegularExpression];
	NSRange paragraphRange = [self.string paragraphRangeForRange:self.editedRange];
	[self removeAttribute:NSForegroundColorAttributeName range:paragraphRange];
    [self removeAttribute:@"tag" range:paragraphRange];
    [self addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:163.0f/255.0f green:174.0f/255.0f blue:171.0f/255.0f alpha:1.0f] range:paragraphRange];
    
	[regex enumerateMatchesInString:self.string options:0 range:paragraphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *tagValue = [[self.string substringWithRange:result.range] stringByReplacingOccurrencesOfString:@"#" withString:@""];
		[self addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f green:192.0f/255.0f blue:180.0f/255.0f alpha:1.0f] range:result.range];
        [self addAttribute:@"tag" value:tagValue range:result.range];
	}];
    
    [super processEditing];
}
@end
