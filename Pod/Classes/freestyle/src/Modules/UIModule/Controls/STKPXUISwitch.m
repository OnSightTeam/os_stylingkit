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
//  STKPXUISwitch.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUISwitch.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "STKPXDeclaration.h"
#import "STKPXVirtualStyleableControl.h"
#import "STKPXUtils.h"
#import "STKPXRuleSet.h"

#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXAnimationStyler.h"

static char const STYLE_CHILDREN;

@implementation STKPXUISwitch

+ (void) load
{
    if (self != STKPXUISwitch.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"switch"];
}

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak id weakSelf = self;

        // thumb
        STKPXVirtualStyleableControl *thumb = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"thumb"];
        thumb.viewStylers = @[
            [[STKPXGenericStyler alloc] initWithHandlers: @{
             @"color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                if ([STKPXUtils isIOS6OrGreater])
                {
                    [weakSelf px_setThumbTintColor: declaration.colorValue];
                }
            },
            }],
        ];

        // on
        STKPXVirtualStyleableControl *on = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"on" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {

            if ([STKPXUtils isIOS6OrGreater] && context.backgroundImage)
            {
                [weakSelf px_setOnImage: context.backgroundImage];
            }
        }];
        on.viewStylers = @[
            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,
        ];

        // off
        STKPXVirtualStyleableControl *off = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"off" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {

            if ([STKPXUtils isIOS6OrGreater] && context.backgroundImage)
            {
                [weakSelf px_setOffImage: context.backgroundImage];
            }
        }];
        off.viewStylers = @[
            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,
        ];

        NSArray *styleChildren = @[ thumb, on, off ];

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

            [[STKPXGenericStyler alloc] initWithHandlers: @{
             @"-ios-tint-color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUISwitch *view = (STKPXUISwitch *)context.styleable;
                
                [view px_setTintColor: declaration.colorValue];
            },
             @"color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUISwitch *view = (STKPXUISwitch *)context.styleable;

                [view px_setOnTintColor: declaration.colorValue];
            },
             @"off-color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUISwitch *view = (STKPXUISwitch *)context.styleable;

                // iOS 6+
                if ([STKPXUtils isIOS6OrGreater])
                {
                    [view px_setTintColor: declaration.colorValue];
                }
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
        [self px_setBackgroundColor: context.color];
    }
    else if (context.usesImage)
    {
        //self.backgroundColor = [UIColor colorWithPatternImage:context.backgroundImage];
        self.px_layer.contents = (__bridge id)(context.backgroundImage.CGImage);
    }
}

// Px Wrapped Only
STKPX_PXWRAP_PROP(CALayer, layer);

// Ti Wrapped
STKPX_WRAP_1(setOnImage, image);
STKPX_WRAP_1(setOffImage, image);
STKPX_WRAP_1(setTintColor, color);
STKPX_WRAP_1(setThumbTintColor, color);
STKPX_WRAP_1(setOnTintColor, color);
STKPX_WRAP_1(setBackgroundColor, color);

// Styling
STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end
