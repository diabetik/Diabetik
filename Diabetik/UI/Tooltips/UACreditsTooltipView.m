//
//  UACreditsTooltipView.m
//  Diabetik
//
//  Created by Nial Giacomelli on 17/03/2013.
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

#import "UACreditsTooltipView.h"

@interface UACreditsTooltipView ()
{
    UIScrollView *scrollView;
    NSString *credits;
    
    UILabel *header, *creditsLabel;
    UIView *border;
}

@end

@implementation UACreditsTooltipView

#pragma mark - Logic
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, frame.size.width, frame.size.height-80.0f)];
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.contentInset = UIEdgeInsetsMake(10, 0, 20, 0);
        [self addSubview:scrollView];
        
        credits = @"Aaron Pearce\nAlastair Dent\nAlessio Madeyski\nAlex Smolianitski\nAlexis Gallisá\nAmy Mahon\nAnders Dahlgren\nAndres Lopez Josenge\nAndrew Dunn\nAndrew Hahn\nAndrew Weeks\nAnke Troeder\nAxel Bouaziz\nBean & Ground\nBecca Rice\nBen David Walker\nBen Taylor\nBenjamin De Cock\nBethany Sumner\nBjörn Wissing\nBrady Valentino\nBrandon & Friends\nBrendan Gatens\nCaden Smylie Moortgat\nCameron Macbeth\nCarl Seal\nCaroline Murphy\nChad Jennings\nCharlotte smith\nChase Massingil\nChris Davis\nChris Gilchrist (hitreach.co.uk)\nChris Kay\nChris Magee\nChris Shepherd\nChristine Wilson\nChuq Von Rospach\nCousin Sven\nCraig Elder\nCraig Grannell\nDan Byler\nDan Cowley\nDaniel García\nDaniel Howells\nDaniel Ogden\nDavid Barnard\nDavid Cameron\nDavid Desmond\nDavid S. Rogers\nDavid Smith\nDavid Turner\nDebbie Wilson\nDeclan Boylan\nDerek Arnwine\nDimon Hunter\nDorothy Wygle\nDrew Crowley\nDrew Robinson\nDóczi András\nEdward Oliver Greer\nElijah Madden\nElliot Jay Stocks\nEric Brunson\nEric Nikolaisen\nEva-Lotta Lamm\nEveraldo Coelho\nEveryday Glucose\nField Office\nFilipe Rodriguez\nFlemming Rasmussen\nFrank Sedivy\nFredrik\nGary Barber\nGlynn Smith\nGracie Lyn Davis\nGraeme Swift\nGraham Spencer\nGrant Kindrick\nGreg V.\nGriffiths Preston, Chartered Accountants\nHaily De La Cruz\nHalden Temg aka halden2714\nHannah Rosenblum\nHoward Look\nIan Phillip\nIan Winter\nIrawan Tri Kusumo\nIsaac Moll family\nIvaylo Cherkezov\nJ. Decker\nJC\nJD\nJack Cheng\nJack Smith\nJames Wilson\nJamey B\nJan Van Hee\nJared Franklin\nJartua - Morynga\nJason Moore\nJason Weir\nJaycob Cratchley\nJean-Paul Hounkanrin\nJenni Leder\nJeremy Swinnen\nJesus Carmona Vela\nJoel Jenkins\nJohn Michel\nJohn P Lennard\nJohn R. Siegel, PMP\nJon Gibbins\nJonas Lekevicius\nJonny Lester\nJoshua Ratcliffe\nJuliana de Campos Silva\nJulie Sharp\nJulien Martin\nJustin Hileman\nKaren Jennings\nKevin Healy\nKhürt L. Williams\nKitt Hodsden\nKyle Neath\nLauren Nygard\nLee \"Bug Hunter\" Armstrong\nLee Setford\nLeigh Kaszick\nLorrian Ippoliti\nLou\nLouie Mantia & Erica Schoonmaker\nLuca Soldaini\nLydia de Leeuw\nLyricStatus.com\nM. Decker\nM Somerford\nMagnus von Bromsen\nMarta Armada\nMartin Haynes\nMary Shen\nMathew Rice\nMatt Gibson\nMatt Hendriks\nMatthew Wanderer, Tweakable\nMatthew Willams (@mwilliams)\nMax Fenton\nMichael Christensen\nMichael Duffield\nMichael Fessler\nMichael Flarup\nMichael L. Collard\nMichael Margolis\nMichael Walz\nMike Cohen\nMike Piontek\nMike Snowden\nMike Stanley\nMilly Mather\nmindings.com\nMiranda Barnes\nMitch Smith\nMobin Zadeh Kochak\nMohsen Ahangarani\nMoldova\nNagarajan Natarajan\nNat Burch\nNina Elizabeth Killam\nNonprofit Tech\nOlly Butterfield\nOscar Palmér\nP Huthwaite\nPaddy Donnelly\nPat Allan\nPatrick Gonzaga\nPaul Michael Jones\nPaul Smail\nPedro Ivo Andrade Tavares\n@persand\nPete Wilkinson\nPhilip McDermott\nPierre-Luc Babin\nR. Gruyters\nRachel Peña\nRandall Brown, MD, MBA\nRaph D'Amico\nRich Tyler\nRichard Japenga\nRob Clark\nRob Cleaton\nRob Golbeck\nRobert Leyden\nRobin Andeer\nRyan O'Hara\nSadat Karim\nSawyer Pangborn\nScott & Monika Knight\nScott Segel\nScott Tsuchiyama\nSean Revell\nSean Stopnik\nSebastian Ekholm\nShamil Nunhuck\nShaun Rashid\nSkye G\n@sph\nSteven Bannister\nSteven Hylands\nStuart Griffiths\nStuart Walters\nTara Purdy\nTed Duguay\nThe Miller Family\nThomas Emmerich\nThomas Moore\nTieg\nTimothy Conroy\nTimothy Marsh\nTobias Bayer\nTom Darlow\nTom Higham\nTom Klaver\nTom Styrkowicz\nTreez*\nTuhin Kumar\nTuuli Platner\nTyler Howarth\nTyrel Kelsey\nTĳntje\nVeerle Pieters\nW. Andrew Loe III\nWilli Wu @ Robocat\nXus Badia\nZachary & Alyssa Nicoll\nZigo Webdesign\nZoé Wahl\nannonymous\nkoen@katoen\npsp-flevoland.nl\ntheNielsch\n";
        
        header = [[UILabel alloc] initWithFrame:CGRectMake(floorf(self.frame.size.width/2 - 200.0f/2), 0.0f, 200.0f, 100.0f)];
        header.backgroundColor = [UIColor clearColor];
        header.textColor = [UIColor colorWithRed:18.0f/255.0f green:185.0f/255.0f blue:139.0f/255.0f alpha:1.0f];
        header.numberOfLines = 1;
        header.textAlignment = NSTextAlignmentCenter;
        header.font = [UAFont standardBoldFontWithSize:26.0f];
        header.text = NSLocalizedString(@"Credits", nil);
        header.adjustsFontSizeToFitWidth = YES;
        header.minimumScaleFactor = 0.5f;
        [self addSubview:header];
        
        border = [[UIView alloc] initWithFrame:CGRectMake(floorf(self.frame.size.width/2 - 20.0f), 70.0f, 40.0f, 2.0f)];
        border.backgroundColor = [UIColor colorWithRed:234.0f/255.0f green:237.0f/255.0f blue:236.0f/255.0f alpha:1.0f];
        [self addSubview:border];
  
        creditsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        creditsLabel.backgroundColor = [UIColor clearColor];
        creditsLabel.textColor = [UIColor colorWithRed:115.0f/255.0f green:128.0f/255.0f blue:123.0f/255.0f alpha:1.0f];
        creditsLabel.numberOfLines = 0;
        creditsLabel.textAlignment = NSTextAlignmentCenter;
        creditsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        creditsLabel.font = [UAFont standardRegularFontWithSize:16.0f];
        creditsLabel.text = credits;
    
        [scrollView addSubview:creditsLabel];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    scrollView.frame = CGRectMake(0, 80, self.frame.size.width, self.frame.size.height-80.0f);
    header.frame = CGRectMake(floorf(self.bounds.size.width/2 - 200.0f/2), 0.0f, 200.0f, 100.0f);
    border.frame = CGRectMake(floorf(self.bounds.size.width/2 - 20.0f), 70.0f, 40.0f, 2.0f);
    
    CGRect creditsRect = [credits boundingRectWithSize:CGSizeMake(225, CGFLOAT_MAX)
                                               options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                            attributes:@{NSFontAttributeName:[UAFont standardRegularFontWithSize:16.0f]}
                                               context:nil];
    
    creditsLabel.frame = CGRectMake(floorf(self.frame.size.width/2 - 225/2), 0, 225, creditsRect.size.height);
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, creditsRect.size.height);
    
}
@end
