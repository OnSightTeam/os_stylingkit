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
//  PXUIStepper.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUIStepper.h"

#import "STKPXUtils.h"
#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "STKPXVirtualStyleableControl.h"

#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXPaintStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXAnimationStyler.h"

static NSDictionary *PSEUDOCLASS_MAP;
static char const STYLE_CHILDREN;

@implementation STKPXUIStepper

+ (void)initialize
{
    if (self != STKPXUIStepper.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"stepper"];
    
    PSEUDOCLASS_MAP = @{
        @"normal"      : @(UIControlStateNormal),
        @"highlighted" : @(UIControlStateHighlighted),
        @"selected"    : @(UIControlStateSelected),
        @"disabled"    : @(UIControlStateDisabled)
    };
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

#pragma mark - Styling

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak id weakSelf = self;

        // divider
        STKPXVirtualStyleableControl *divider = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"divider" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {

            if ([STKPXUtils isIOS6OrGreater] && context.backgroundImage)
            {
                [weakSelf px_setDividerImage:context.backgroundImage
                  forLeftSegmentState:UIControlStateNormal
                    rightSegmentState:UIControlStateNormal];
            }
        }];
        
        divider.viewStylers = @[
            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,
        ];
        
        // increment
        STKPXVirtualStyleableControl *increment = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"increment" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            
            if ([STKPXUtils isIOS6OrGreater] && context.backgroundImage)
            {
                [weakSelf px_setIncrementImage:context.backgroundImage
                               forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }
        }];
        
        increment.viewStylers = @[
            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,
        ];

        
        // decrement
        STKPXVirtualStyleableControl *decrement = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"decrement" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            
            if ([STKPXUtils isIOS6OrGreater] && context.backgroundImage)
            {
                [weakSelf px_setDecrementImage:context.backgroundImage
                               forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }
        }];
        
        decrement.viewStylers = @[
            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,
        ];

        NSArray *styleChildren = @[ divider, increment, decrement ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return [objc_getAssociatedObject(self, &STYLE_CHILDREN) arrayByAddingObjectsFromArray:self.subviews];
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        stylers = @[
            STKPXTransformStyler.sharedInstance,
            STKPXLayoutStyler.sharedInstance,
            STKPXOpacityStyler.sharedInstance,

            [[STKPXPaintStyler alloc] initWithCompletionBlock:^(STKPXUIStepper *view, STKPXPaintStyler *styler, STKPXStylerContext *context) {
                
                if ([STKPXUtils isIOS6OrGreater])
                {
                    UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                    
                    if(color == nil)
                    {
                        color = (UIColor *)[context propertyValueForName:@"-ios-tint-color"];
                    }
                    
                    if(color)
                    {
                        [view px_setTintColor:color];
                    }
                }
            }],

            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,

            STKPXAnimationStyler.sharedInstance,
        ];
    });

	return stylers;
}

- (NSDictionary *)viewStylersByProperty
{
    static NSDictionary *map = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        map = [STKPXStyleUtils viewStylerPropertyMapForStyleable:self];
    });

    return map;
}

- (void)updateStyleWithRuleSet:(STKPXRuleSet *)ruleSet context:(STKPXStylerContext *)context
{
    if ([STKPXUtils isIOS6OrGreater])
    {
        if(context.usesColorOnly || context.usesImage)
        {
            [self px_setTintColor: nil];
            [self px_setBackgroundImage:context.backgroundImage
                            forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
        }
    }

}

PX_WRAP_1(setTintColor, color);

PX_WRAP_2v(setIncrementImage, image, forState, UIControlState, state);
PX_WRAP_2v(setDecrementImage, image, forState, UIControlState, state);
PX_WRAP_2v(setBackgroundImage, image, forState, UIControlState, state);

PX_WRAP_3v(setDividerImage, image, forLeftSegmentState, UIControlState, lstate, rightSegmentState, UIControlState, rstate);


PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
