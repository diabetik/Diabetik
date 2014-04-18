//
//  UASettingsLicensesViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 03/06/2013.
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

#import "UASettingsLicensesViewController.h"

@interface UASettingsLicensesViewController ()
{
    UIWebView *webView;
}
@end

@implementation UASettingsLicensesViewController

#pragma mark - Setup
- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.title = NSLocalizedString(@"Licenses", nil);
    }
    return self;
}
- (void)loadView
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectZero];
    baseView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    webView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    [baseView addSubview:webView];
    
    self.view = baseView;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    webView.frame = self.view.frame;
    
    NSString *licenseText = @"";
    NSArray *licenses = @[@"AFNetworking-License", @"AppSoundEngine-License", @"MBProgressHUD-License", @"HockeyApp-License", @"UAAppReviewManager-License", @"Reachability-License", @"FXBlurView-License", @"LXReorderableCollectionViewFlowLayout-License"];
    for(NSString *license in licenses)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:license ofType:@"txt"];
        if(bundlePath)
        {
            NSError *error = nil;
            NSString *contents = [NSString stringWithContentsOfFile:bundlePath encoding:NSUTF8StringEncoding error:&error];
            if(!error)
            {
                licenseText = [licenseText stringByAppendingFormat:@"<h2>%@</h2>", [license stringByReplacingOccurrencesOfString:@"-License" withString:@""]];
                licenseText = [licenseText stringByAppendingFormat:@"<p>%@</p>", contents];
            }
        }
    }

    NSString *html = @"<html><head><style>body { font: 87.5% 'Avenir Next', 'Helvetica Neue', Arial, Helvetica, sans-serif; padding: 10px; color: #414141 } p { padding-bottom: 20px }</style></head><body style=\"background-color: transparent;\">";
    html = [html stringByAppendingString:[licenseText stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"]];
    html = [html stringByAppendingString:@"</body></html>"];
    
    [webView loadHTMLString:html baseURL:nil];
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    webView.frame = self.view.bounds;
    webView.scrollView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 0.0f, 0.0f);
    webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, 0.0f, 0.0f);
}


@end
