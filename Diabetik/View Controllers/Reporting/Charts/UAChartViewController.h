//
//  UAChartViewController.h
//  Diabetik
//
//  Created by Nial Giacomelli on 17/05/2013.
//  Copyright 2013 Nial Giacomelli
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

#import <ShinobiCharts/ShinobiChart.h>
#import "NSDate+Extension.h"
#import "UABaseViewController.h"

@interface UAChartViewController : UABaseViewController
{
    NSDictionary *chartData;
    UIButton *closeButton;
}

@property (nonatomic, strong) ShinobiChart *chart;
@property (nonatomic, assign) CGRect initialRect;

// Setup
- (id)initWithData:(NSArray *)data;
- (void)setupChart;
- (NSDictionary *)parseData:(NSArray *)theData;

// Logic
- (BOOL)hasEnoughDataToShowChart;

@end
