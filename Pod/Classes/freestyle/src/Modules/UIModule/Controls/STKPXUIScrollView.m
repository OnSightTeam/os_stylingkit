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
//  STKPXUIScrollView.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUIScrollView.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"

#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXAnimationStyler.h"

@implementation STKPXUIScrollView

+ (void) load
{
    if (self != STKPXUIScrollView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"scroll-view"];
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
             @"content-offset" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUIScrollView *view = (STKPXUIScrollView *)context.styleable;
                CGSize point = declaration.sizeValue;

                [view px_setContentOffset: CGPointMake(point.width, point.height)];
            },
             @"content-size" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUIScrollView *view = (STKPXUIScrollView *)context.styleable;
                CGSize size = declaration.sizeValue;

                [view px_setContentSize: size];
            },
             @"content-inset" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUIScrollView *view = (STKPXUIScrollView *)context.styleable;
                UIEdgeInsets insets = declaration.insetsValue;

                [view px_setContentInset: insets];
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
        self.backgroundColor = context.color;
        self.px_layer.contents = nil;
    }
    else if (context.usesImage)
    {
        self.backgroundColor = [UIColor clearColor];
        self.px_layer.contents = (__bridge id)(context.backgroundImage.CGImage);
    }
}

// Px Wrapped Only
STKPX_PXWRAP_PROP(CALayer, layer);

// Ti Wrapped
STKPX_WRAP_1(setBackgroundColor, color);
STKPX_WRAP_1s(setContentSize,   CGSize,       size);
STKPX_WRAP_1s(setContentOffset, CGPoint,      size);
STKPX_WRAP_1s(setContentInset,  UIEdgeInsets, insets);

// Styling
STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end
