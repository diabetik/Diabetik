//
//  UAMealInputViewController.m
//  Diabetik
//
//  Created by Nial Giacomelli on 05/12/2012.
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

#import "UAMealInputViewController.h"
#import "UAEventInputTextFieldViewCell.h"
#import "UAEventInputTextViewViewCell.h"
#import "UAAppDelegate.h"

@interface UAMealInputViewController ()
{
    UITextField *nameTextField;
    
    NSString *name;
    double grams;
}
@property (nonatomic, assign) NSInteger type;
@end

@implementation UAMealInputViewController
@synthesize type = _type;

#pragma mark - Setup
- (id)init
{
    self = [super init];
    if (self)
    {
        self.title = NSLocalizedString(@"Add Food", nil);
        
        _type = 0;
        grams = 0;
    }
    return self;
}
- (id)initWithEvent:(UAEvent *)theEvent
{
    self = [super initWithEvent:theEvent];
    if(self)
    {
        self.title = NSLocalizedString(@"Edit Food", nil);
        
        UAMeal *meal = (UAMeal *)[self event];
        if(meal)
        {
            name = meal.name;
            grams = [meal.grams doubleValue];
        }
    }
    
    return self;
}

#pragma mark - Logic
- (NSError *)validationError
{
    if(name && [name length])
    {
        if([self.date compare:[NSDate date]] != NSOrderedAscending)
        {
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:NSLocalizedString(@"You cannot enter an event in the future", nil) forKey:NSLocalizedDescriptionKey];
            return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
        }
    }
    else
    {
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:NSLocalizedString(@"Please complete all required fields", nil) forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:kErrorDomain code:0 userInfo:errorInfo];
    }
    
    return nil;
}
- (UAEvent *)saveEvent:(NSError **)error
{
    [self.view endEditing:YES];

    NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
    if(moc)
    {
        UAMeal *meal = (UAMeal *)[self event];
        if(!meal)
        {
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UAMeal" inManagedObjectContext:moc];
            meal = (UAMeal *)[[UAManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
            meal.filterType = [NSNumber numberWithInteger:MealFilterType];
        }
        meal.name = name;
        meal.timestamp = self.date;
        meal.type = [NSNumber numberWithInteger:0];
        meal.grams = [NSNumber numberWithDouble:grams];
        
        if(!notes.length) notes = nil;
        meal.notes = notes;
        
        // Save our geotag data
        if(![self.lat isEqual:meal.lat] || ![self.lon isEqual:meal.lon])
        {
            meal.lat = self.lat;
            meal.lon = self.lon;
        }
        
        // Save our photo
        if(!self.currentPhotoPath || ![self.currentPhotoPath isEqualToString:meal.photoPath])
        {
            // If a photo already exists for this entry remove it now
            if(meal.photoPath)
            {
                [[UAMediaController sharedInstance] deleteImageWithFilename:meal.photoPath success:nil failure:nil];
            }
            
            meal.photoPath = self.currentPhotoPath;
        }
        
        NSArray *tags = [[UATagController sharedInstance] fetchTagsInString:notes];
        [[UATagController sharedInstance] assignTags:tags toEvent:meal];
        
        [moc save:&*error];
        
        return meal;
    }
    else
    {
        if(error)
        {
            *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"No applicable MOC present"}];
        }
    }
    
    return nil;
}
- (BOOL)disablesAutomaticKeyboardDismissal
{
    return YES;
}
- (BOOL)canResignFirstResponder {
    return NO;
}
// UI
- (void)changeDate:(id)sender
{
    self.date = [sender date];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    UAEventInputViewCell *cell = (UAEventInputViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if(cell)
    {
        UITextField *textField = (UITextField *)cell.control;
        [textField setText:[dateFormatter stringFromDate:self.date]];
    }
}
- (void)configureAppearanceForTableViewCell:(UAEventInputViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [cell resetCell];
    
    NSNumberFormatter *valueFormatter = [UAHelper standardNumberFormatter];
    if(indexPath.row == 0)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"What'd you have?", nil);
        textField.text = name;
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.delegate = self;
        textField.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Name", nil)];
    }
    else if(indexPath.row == 1)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"grams (optional)", @"Amount of carbs in grams (this field is optional)");
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.delegate = self;
        textField.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        if(grams > 0)
        {
            textField.text = [valueFormatter stringFromNumber:[NSNumber numberWithDouble:grams]];
        }
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Carbs", @"Amount of carbohydrates")];
    }
    else if(indexPath.row == 2)
    {
        UITextField *textField = (UITextField *)cell.control;
        textField.placeholder = NSLocalizedString(@"Date", nil);
        textField.text = [dateFormatter stringFromDate:self.date];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.delegate = self;
        textField.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
        [datePicker setDate:self.date];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
        textField.inputView = datePicker;
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Date", nil)];
    }
    else if(indexPath.row == 3)
    {
        UAEventNotesTextView *textView = (UAEventNotesTextView *)cell.control;
        textView.text = notes;
        textView.delegate = self;
        textView.inputAccessoryView = [self keyboardShortcutAccessoryView];
        
        [(UILabel *)[cell label] setText:NSLocalizedString(@"Notes", nil)];
        [cell setDrawsBorder:NO];
    }
    cell.control.tag = indexPath.row;
}

#pragma mark - UI
- (UIImage *)navigationBarBackgroundImage
{
    return [UIImage imageNamed:@"MealNavBarBG"];
}
- (UIColor *)tintColor
{
    return [UIColor colorWithRed:254.0f/255.0f green:201.0f/255.0f blue:105.0f/255.0f alpha:1.0f];
}

#pragma mark - UITableViewDatasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UAEventInputViewCell *cell = nil;
    if(indexPath.row == 3)
    {
        cell = (UAEventInputTextViewViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAEventInputTextViewViewCell"];
        if (!cell)
        {
            cell = [[UAEventInputTextViewViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAEventInputTextViewViewCell"];
        }
    }
    else
    {
        cell = (UAEventInputTextFieldViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"UAEventTextFieldViewCell"];
        if (!cell)
        {
            cell = [[UAEventInputTextFieldViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UAEventTextFieldViewCell"];
        }
    }
    
    [self configureAppearanceForTableViewCell:cell atIndexPath:indexPath];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0.0;
    if(indexPath.row == 3)
    {
        dummyNotesTextView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width-88.0f, 0.0f);
        dummyNotesTextView.text = notes;
        height = [dummyNotesTextView height];
    }
    else if(indexPath.row == 4)
    {
        height = 170.0f;
    }
    
    if(height < 44.0f) height = 44.0f;    
    return height;
}

#pragma mark - UAAutocompleteBarDelegate methods
- (NSArray *)suggestionsForAutocompleteBar:(UAAutocompleteBar *)theAutocompleteBar
{
    if(self.activeControlIndexPath.row == 0)
    {
        return [[UAEventController sharedInstance] fetchKey:@"name" forEventsWithFilterType:MealFilterType];
    }
    else
    {
        return [[UATagController sharedInstance] fetchAllTags];
    }
    
    return nil;
}
- (void)autocompleteBar:(UAAutocompleteBar *)theAutocompleteBar didSelectSuggestion:(NSString *)suggestion
{
    if(self.activeControlIndexPath.row == 0)
    {
        __weak typeof(self) weakSelf = self;
        
        // If we're auto-selecting a previous meal, fetch and populate it's carb count too!
        NSManagedObjectContext *moc = [[UACoreDataController sharedInstance] managedObjectContext];
        if(moc)
        {
            [moc performBlockAndWait:^{
                
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"UAEvent" inManagedObjectContext:moc];
                [request setEntity:entity];
                [request setReturnsDistinctResults:YES];
                
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
                [request setSortDescriptors:@[sortDescriptor]];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterType == %d && name == %@", MealFilterType, suggestion];
                [request setPredicate:predicate];
                
                NSError *error = nil;
                NSArray *objects = [moc executeFetchRequest:request error:&error];
                if (objects != nil && [objects count] > 0)
                {
                    UAMeal *meal = (UAMeal *)objects[0];
                    if(meal)
                    {
                        grams = [meal.grams doubleValue];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            __strong typeof(weakSelf) strongSelf = self;
                            [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        });
                    }
                }
            }];
        }
    }
    
    [super autocompleteBar:theAutocompleteBar didSelectSuggestion:suggestion];
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        name = textField.text;
    }
    else if(textField.tag == 1)
    {
        NSNumberFormatter *valueFormatter = [UAHelper standardNumberFormatter];
        
        grams = [[valueFormatter numberFromString:textField.text] doubleValue];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.tag == 2)
    {
        return NO;
    }
    else if(textField.tag == 0)
    {
        NSString *fullText = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        [self.keyboardShortcutAccessoryView showAutocompleteSuggestionsForInput:fullText];
    }
    
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        [self.keyboardShortcutAccessoryView setShowingAutocompleteBar:NO];
    }
    
    return YES;
}

@end
