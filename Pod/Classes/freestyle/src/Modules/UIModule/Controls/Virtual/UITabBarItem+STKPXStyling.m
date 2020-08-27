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
//  UITabBarItem+STKPXStyling.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 10/31/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "UITabBarItem+STKPXStyling.h"
#import <objc/runtime.h>
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXFontStyler.h"
#import "STKPXColorStyler.h"
#import "STKPXTextContentStyler.h"
#import "STKPXStyleUtils.h"
#import "STKPXStylingMacros.h"
#import "UIBarItem+STKPXStyling.h"
#import "STKPXAttributedTextStyler.h"

void STKPXForceLoadUITabBarItemPXStyling() {}

@implementation UITabBarItem (STKPXStyling)

@dynamic isVirtualControl;
@dynamic pxStyleParent;

static NSDictionary *PSEUDOCLASS_MAP;

+ (void)initialize
{
    if (self != UITabBarItem.class)
        return;
    
    PSEUDOCLASS_MAP = @{
        @"normal" : @(UIControlStateNormal),
        @"selected" : @(UIControlStateSelected),
        @"unselected" : @(UIControlStateNormal)
    };
}

- (NSString *)pxStyleElementName
{
    return self.styleElementName == nil ? @"tab-bar-item" : self.styleElementName;
}
    
- (void)setPxStyleElementName:(NSString *)pxStyleElementName
{
    self.styleElementName = pxStyleElementName;
}
    
- (NSArray *)pxStyleChildren
{
    return nil;
}

#pragma mark - Pseudo-class State

- (NSArray *)supportedPseudoClasses
{
    return PSEUDOCLASS_MAP.allKeys;
}

- (NSString *)defaultPseudoClass
{
    return @"normal";
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        stylers = @[

            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,

            [[STKPXAttributedTextStyler alloc] initWithCompletionBlock: ^(id<STKPXStyleable> view, id<STKPXStyler> styler, STKPXStylerContext *context) {
  
                UIControlState state = ([context stateFromStateNameMap:PSEUDOCLASS_MAP]) ? [context stateFromStateNameMap:PSEUDOCLASS_MAP] : UIControlStateNormal;
                
                NSDictionary *attribs = [(UIBarButtonItem*)view titleTextAttributesForState:state];
                
                NSDictionary *mergedAttribs = [context mergeTextAttributes:attribs];
                
                [(UIBarButtonItem*)view setTitleTextAttributes:mergedAttribs
                                                      forState:state];
            }],
            
            [[STKPXTextContentStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable> view, id<STKPXStyler> styler, STKPXStylerContext *context) {
                ((UIBarButtonItem*)view).title = context.text;
            }],
        ];
    });

    return stylers;
}

- (void)updateStyleWithRuleSet:(STKPXRuleSet *)ruleSet context:(STKPXStylerContext *)context
{
    if([context.activeStateName isEqualToString:@"normal"])
    {
        if (context.usesImage)
        {
            self.image = context.backgroundImage;
        }
    }
    else if([context.activeStateName isEqualToString:@"selected"])
    {
        if (context.usesImage)
        {
            self.selectedImage = context.backgroundImage;
        }
    }
    else if([context.activeStateName isEqualToString:@"unselected"])
    {
        if (context.usesImage)
        {
            self.image = context.backgroundImage;
        }
    }
}

@end
