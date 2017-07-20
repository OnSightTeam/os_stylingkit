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
//  STKPXUIPageControl.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUIPageControl.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "STKPXUtils.h"

#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXAnimationStyler.h"

@implementation STKPXUIPageControl

+ (void)initialize
{
    if (self != STKPXUIPageControl.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"page-control"];
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

            [[STKPXGenericStyler alloc] initWithHandlers: @{
             @"color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUIPageControl *view = (STKPXUIPageControl *)context.styleable;

                if ([STKPXUtils isIOS6OrGreater])
                {
                    [view px_setPageIndicatorTintColor: declaration.colorValue];
                }
            },
             @"current-color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUIPageControl *view = (STKPXUIPageControl *)context.styleable;

                if ([STKPXUtils isIOS6OrGreater])
                {
                    [view px_setCurrentPageIndicatorTintColor: declaration.colorValue];
                }
            },
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
        [self px_setBackgroundColor: context.color];
    }
    else if (context.usesImage)
    {
        [self px_setBackgroundColor: [UIColor clearColor]];
        self.px_layer.contents = (__bridge id)(context.backgroundImage.CGImage);
    }
}

// Px Wrapped Only
STKPX_PXWRAP_PROP(CALayer, layer);

// Ti Wrapped
STKPX_WRAP_1(setBackgroundColor, color);
STKPX_WRAP_1(setPageIndicatorTintColor, color);
STKPX_WRAP_1(setCurrentPageIndicatorTintColor, color);

STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end
