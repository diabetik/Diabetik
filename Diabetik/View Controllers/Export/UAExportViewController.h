//
//  UAExportViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 01/04/2013.
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

#import <MessageUI/MFMailComposeViewController.h>

#import "UABaseViewController.h"
#import "OrderedDictionary.h"
#import "UAPDFDocument.h"

@interface UAExportViewController : UABaseTableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate, UAPDFDocumentDelegate, UATooltipViewControllerDelegate>

- (void)refreshView;

// UI
- (void)performExport:(id)sender;
- (OrderedDictionary *)fetchEvents;
- (void)showTips;

// Export
- (NSData *)generateCSVData;
- (NSData *)generatePDFData;

@end
