/*
 * Copyright 2012-present Pixate, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  STKPXUIPickerViewDelegate.m
//  Pixate
//
//  Created by Paul Colton on 12/18/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXUIPickerViewDelegate.h"
#import "UIView+STKPXStyling.h"
#import "STKPXProxy.h"

@implementation STKPXUIPickerViewDelegate

/* NOT USED YET
 
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if([pickerView.delegate isProxy] == NO)
    {
        NSLog(@"STKPXUIPickerView: delegate is not a Pixate proxy class.");
        return nil;
    }
    
    UIView *returnedView = [[((STKPXProxy *) pickerView.delegate) baseObject] pickerView:pickerView viewForRow:row forComponent:component reusingView:view];
    
    [pickerView updateStyles];
    
    return view;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if([pickerView.dataSource isProxy] == NO)
    {
        NSLog(@"STKPXUIPickerView: dataSource is not a Pixate proxy class.");
        return nil;
    }

    NSString *title = [[((STKPXProxy *) pickerView.dataSource) baseObject] pickerView:pickerView titleForRow:row forComponent:component];
    
    [pickerView updateStyles];

    return title;
}

*/

@end
