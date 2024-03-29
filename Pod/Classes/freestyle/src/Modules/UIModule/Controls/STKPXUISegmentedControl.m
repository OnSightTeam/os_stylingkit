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
//  STKPXUISegmentedControl.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUISegmentedControl.h"

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "STKPXVirtualStyleableControl.h"

#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXPaintStyler.h"
#import "STKPXFontStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXAnimationStyler.h"
#import "STKPXTextShadowStyler.h"

static NSDictionary *PSEUDOCLASS_MAP;
static char const STYLE_CHILDREN;

@implementation STKPXUISegmentedControl

+ (void) load
{
    if (self != STKPXUISegmentedControl.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"segmented-control"];

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
            if (context.backgroundImage)
            {
                [weakSelf px_setDividerImage:context.backgroundImage
                  forLeftSegmentState:UIControlStateNormal
                    rightSegmentState:UIControlStateNormal
                           barMetrics:UIBarMetricsDefault];
            }
        }];

        divider.viewStylers = @[
            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,
        ];

        NSArray *styleChildren = @[ divider ];

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

            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,

            [[STKPXTextShadowStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXTextShadowStyler *styler, STKPXStylerContext *context) {
                STKPXShadow *shadow = context.textShadow;
                NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:[(STKPXUISegmentedControl *)view titleTextAttributesForState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]]];

                NSShadow *nsShadow = [[NSShadow alloc] init];
                
                nsShadow.shadowColor = shadow.color;
                nsShadow.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);
                nsShadow.shadowBlurRadius = shadow.blurDistance;
                
                currentTextAttributes[NSShadowAttributeName] = nsShadow;

                [(STKPXUISegmentedControl *)view px_setTitleTextAttributes:currentTextAttributes forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }],

            [[STKPXFontStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXFontStyler *styler, STKPXStylerContext *context) {

                NSMutableDictionary *currentTextAttributes = [NSMutableDictionary
                                                              dictionaryWithDictionary:[(STKPXUISegmentedControl *)view titleTextAttributesForState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]]];

                currentTextAttributes[NSFontAttributeName] = context.font;

                [(STKPXUISegmentedControl *)view px_setTitleTextAttributes:currentTextAttributes
                                       forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }],

            [[STKPXPaintStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXPaintStyler *styler, STKPXStylerContext *context) {

                NSMutableDictionary *currentTextAttributes = [NSMutableDictionary
                                                              dictionaryWithDictionary:[(STKPXUISegmentedControl *)view titleTextAttributesForState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]]];
                UIColor *color = (UIColor *)[context propertyValueForName:@"color"];

                if(color)
                {
                    currentTextAttributes[NSForegroundColorAttributeName] = color;

                    [(STKPXUISegmentedControl *)view px_setTitleTextAttributes:currentTextAttributes
                                           forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
                }
                
                // Check for tint-color
                color = (UIColor *)[context propertyValueForName:@"-ios-tint-color"];
                if(color)
                {
                    [(STKPXUISegmentedControl *)view px_setTintColor:color];
                }
            }],

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
    if (context.usesColorOnly)
    {
        [self px_setTintColor: context.color];
    }
    else if (context.usesImage)
    {
        [self px_setTintColor: nil];
        [self px_setBackgroundImage:context.backgroundImage
                        forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]
                      barMetrics:UIBarMetricsDefault];
    }
}

STKPX_WRAP_1(setTintColor, color);

STKPX_WRAP_2v(setBackgroundImage, image, forState, UIControlState, state);
STKPX_WRAP_2v(setTitleTextAttributes, attribs, forState, UIControlState, state);

STKPX_WRAP_3v(setBackgroundImage, image, forState, UIControlState, state, barMetrics, UIBarMetrics, metrics);

STKPX_WRAP_4v(setDividerImage, image, forLeftSegmentState, UIControlState, lstate, rightSegmentState, UIControlState, rstate,barMetrics, UIBarMetrics, metrics);


STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end
