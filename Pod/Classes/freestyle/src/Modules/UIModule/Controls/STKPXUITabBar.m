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
//  STKPXUITabBar.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUITabBar.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "UITabBarItem+STKPXStyling.h"
#import "STKPXUtils.h"

#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXOpacityStyler.h"
#import "STKPXBarShadowStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXVirtualStyleableControl.h"
#import "STKPXGenericStyler.h"
#import "STKPXAnimationStyler.h"
#import "STKPXImageUtils.h"

@implementation STKPXUITabBar

+ (void)initialize
{
    if (self != STKPXUITabBar.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"tab-bar"];
}

- (NSArray *)pxStyleChildren
{
    __weak id weakSelf = self;

    // selection
    STKPXVirtualStyleableControl *selection = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"selection" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
        UIImage *image = context.backgroundImage;

        if (image)
        {
            [weakSelf px_setSelectionIndicatorImage: image];
        }
    }];

    selection.viewStylers = @[
        STKPXShapeStyler.sharedInstance,
        STKPXFillStyler.sharedInstance,
        STKPXBorderStyler.sharedInstance,
        STKPXBoxShadowStyler.sharedInstance,
    ];


    for (UITabBarItem *item in self.items)
    {
        item.pxStyleParent = self;
    }

    // Add all of the 'items' from the tabbar
    NSMutableArray *styleChildren = [[NSMutableArray alloc] initWithArray:self.items];
    
    // Add the virtual child
    [styleChildren addObject:selection];

    // Add any other subviews
    [styleChildren addObjectsFromArray:self.subviews];

    return styleChildren;
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

            // shadow-* image properties
            [[STKPXBarShadowStyler alloc] initWithCompletionBlock:^(STKPXUITabBar *view, STKPXBarShadowStyler *styler, STKPXStylerContext *context) {
                // iOS 6.x property
                if ([STKPXUtils isIOS6OrGreater])
                {
                    if (context.shadowImage)
                    {
                        [view px_setShadowImage:context.shadowImage];
                    }
                    else
                    {
                        // 'fill' with a clear pixel
                        [view px_setShadowImage:STKPXImageUtils.clearPixel];
                    }
                }
            }],

            [[STKPXGenericStyler alloc] initWithHandlers: @{
             @"-ios-tint-color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITabBar *view = (STKPXUITabBar *)context.styleable;
                
                [view px_setTintColor: declaration.colorValue];
            },
             @"color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITabBar *view = (STKPXUITabBar *)context.styleable;

                [view px_setTintColor: declaration.colorValue];
            },
             @"selected-color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITabBar *view = (STKPXUITabBar *)context.styleable;

                [view px_setSelectedImageTintColor: declaration.colorValue];
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
    if (context.usesColorOnly || context.usesImage)
    {
        if (context.usesColorOnly && [STKPXUtils isIOS7OrGreater])
        {
            [self px_setBarTintColor:context.color];
        }
        else
        {
            [self px_setBackgroundImage: context.backgroundImage];
        }
    }
    else
    {
        [self px_setBackgroundImage: nil];
    }
}

STKPX_WRAP_1(setBarTintColor, color);
STKPX_WRAP_1(setTintColor, color);
STKPX_WRAP_1(setSelectedImageTintColor, color);
STKPX_WRAP_1(setBackgroundImage, image);
STKPX_WRAP_1(setShadowImage, image);
STKPX_WRAP_1(setSelectionIndicatorImage, image);


STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end
