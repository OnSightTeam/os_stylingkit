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
//  STKPXForceLoadControls.m
//  Pixate
//
//  Created by Paul Colton on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXForceLoadControls.h"

#import "STKPXMKAnnotationView.h"
#import "STKPXMKMapView.h"
#import "STKPXUICollectionView.h"
#import "STKPXUICollectionViewCell.h"
#import "STKPXUINavigationBar.h"
#import "STKPXUITableView.h"
#import "STKPXUITableViewCell.h"
#import "STKPXUITableViewHeaderFooterView.h"
#import "STKPXMPVolumeView.h"
#import "STKPXUIActionSheet.h"
#import "STKPXUIActivityIndicatorView.h"
#import "STKPXUIButton.h"
#import "STKPXUIDatePicker.h"
#import "STKPXUIImageView.h"  
#import "STKPXUILabel.h"
#import "STKPXUIPageControl.h"
#import "STKPXUIPickerView.h"
#import "STKPXUIProgressView.h"
#import "STKPXUIRefreshControl.h"
#import "STKPXUIScrollView.h"
#import "STKPXUISearchBar.h"
#import "STKPXUISegmentedControl.h"
#import "STKPXUISlider.h"
#import "STKPXUIStepper.h"
#import "STKPXUISwitch.h"
#import "STKPXUITabBar.h"
#import "STKPXUITextField.h"
#import "STKPXUITextView.h"
#import "STKPXUIToolbar.h"
#import "STKPXUIView.h"
#import "STKPXUIWebView.h"
#import "STKPXUIWindow.h"
#import "STK_UIAlertControllerView.h"

@implementation STKPXForceLoadControls

+(void)forceLoad
{
    [STKPXMKAnnotationView class];
    [STKPXMKMapView class];
    [STKPXUICollectionView class];
    [STKPXUICollectionViewCell class];
    [STKPXUINavigationBar class];
    [STKPXUITableView class];
    [STKPXUITableViewCell class];
    [STKPXUITableViewHeaderFooterView class];
    [STKPXMPVolumeView class];
    [STKPXUIActionSheet class];
    [STKPXUIActivityIndicatorView class];
    [STKPXUIButton class];
    [STKPXUIDatePicker class];
    [STKPXUIImageView class];
    [STKPXUILabel class];
    [STKPXUIPageControl class];
    [STKPXUIPickerView class];
    [STKPXUIProgressView class];
    [STKPXUIRefreshControl class];
    [STKPXUIScrollView class];
    [STKPXUISearchBar class];
    [STKPXUISegmentedControl class];
    [STKPXUISlider class];
    [STKPXUIStepper class];
    [STKPXUISwitch class];
    [STKPXUITabBar class];
    [STKPXUITextField class];
    [STKPXUITextView class];
    [STKPXUIToolbar class];
    [STKPXUIView class];
    [STKPXUIWebView class];
    [STKPXUIWindow class];
    [STK_UIAlertControllerView class];
}

@end
