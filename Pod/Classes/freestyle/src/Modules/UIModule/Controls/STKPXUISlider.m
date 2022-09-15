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
//  STKPXUISlider.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUISlider.h"

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "STKPXVirtualStyleableControl.h"

#import "STKPXOpacityStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXAnimationStyler.h"

static const char STYLE_CHILDREN;
static NSDictionary *PSEUDOCLASS_MAP;

@implementation STKPXUISlider

#pragma mark - Static methods

+ (void) load
{
    if (self != STKPXUISlider.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"slider"];
    
    PSEUDOCLASS_MAP = @{
        @"normal"      : @(UIControlStateNormal),
        @"highlighted" : @(UIControlStateHighlighted),
        @"selected"    : @(UIControlStateSelected),
        @"disabled"    : @(UIControlStateDisabled)
    };
}

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak STKPXUISlider *weakSelf = self;
        
        // thumb
        STKPXVirtualStyleableControl *thumb = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"thumb" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            if (context.usesImage)
            {
                [weakSelf px_setThumbImage:context.backgroundImage
                              forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }
        }];

        thumb.viewStylers = @[
            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,
            [[STKPXGenericStyler alloc] initWithHandlers: @{
             @"color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                [weakSelf px_setThumbTintColor: declaration.colorValue];
            },
            }],
        ];
        thumb.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;
        thumb.defaultPseudoClass = @"normal";

        // min-track
        STKPXVirtualStyleableControl *minTrack = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"min-track" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            if (context.usesImage)
            {
                [weakSelf px_setMinimumTrackImage:context.backgroundImage
                                     forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }
        }];

        minTrack.viewStylers = @[
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            [[STKPXGenericStyler alloc] initWithHandlers: @{
             @"color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                [weakSelf px_setMinimumTrackTintColor: declaration.colorValue];
            },
            }],
        ];
        minTrack.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;
        minTrack.defaultPseudoClass = @"normal";

        // max-track
        STKPXVirtualStyleableControl *maxTrack = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"max-track" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            if (context.usesImage)
            {
                [weakSelf px_setMaximumTrackImage:context.backgroundImage forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }
        }];
        maxTrack.viewStylers = @[
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            [[STKPXGenericStyler alloc] initWithHandlers: @{
             @"color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                [weakSelf px_setMaximumTrackTintColor: declaration.colorValue];
            },
            }],
        ];
        maxTrack.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;
        maxTrack.defaultPseudoClass = @"normal";

        // min-value
        STKPXVirtualStyleableControl *minValue = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"min-value" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            if (context.usesImage)
            {
                [weakSelf px_setMinimumValueImage:context.backgroundImage];
            }

        }];
        minValue.viewStylers = @[
            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,
        ];
        
        // max-value
        STKPXVirtualStyleableControl *maxValue = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"max-value" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            if (context.usesImage)
            {
                [weakSelf px_setMaximumValueImage:context.backgroundImage];
            }
        }];
        maxValue.viewStylers = @[
            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,
        ];
        
        NSArray *styleChildren = @[ minTrack, maxTrack, thumb, minValue, maxValue ];

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
        [self px_setBackgroundColor: context.color];
    }
    else if (context.usesImage)
    {
        [self px_setBackgroundColor: [UIColor colorWithPatternImage:context.backgroundImage]];
    }
}

STKPX_WRAP_1(setBackgroundColor, color);
STKPX_WRAP_1(setMinimumValueImage, image);
STKPX_WRAP_1(setMaximumValueImage, image);
STKPX_WRAP_1(setMaximumTrackTintColor, color);
STKPX_WRAP_1(setMinimumTrackTintColor, color);
STKPX_WRAP_1(setThumbTintColor, color);

STKPX_WRAP_2v(setMaximumTrackImage, image, forState, UIControlState, state);
STKPX_WRAP_2v(setMinimumTrackImage, image, forState, UIControlState, state);
STKPX_WRAP_2v(setThumbImage, image, forState, UIControlState, state);

STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end
