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
//  STKPXUIToolbar.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUIToolbar.h"

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "STKPXVirtualStyleableControl.h"
#import "UIBarButtonItem+STKPXStyling.h"
#import "UIBarButtonItem+STKPXStyling-Private.h"
#import "STKPXUtils.h"

#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXBarShadowStyler.h"
#import "STKPXAnimationStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXImageUtils.h"
#import "STKPXFontStyler.h"
#import "STKPXPaintStyler.h"

static const char STYLE_CHILDREN;
static NSDictionary *BUTTONS_PSEUDOCLASS_MAP;

@implementation STKPXUIToolbar

+ (void)initialize
{
    if (self != STKPXUIToolbar.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"toolbar"];
    
    BUTTONS_PSEUDOCLASS_MAP = @{
                                @"normal"      : @(UIControlStateNormal),
                                @"highlighted" : @(UIControlStateHighlighted),
                                @"disabled"    : @(UIControlStateDisabled)
                                };

}

- (NSArray *)pxStyleChildren
{
    // Get the children array
    NSArray *children = objc_getAssociatedObject(self, &STYLE_CHILDREN);
    
    if (!children)
    {
        //
        // button-appearance
        //
        
        STKPXVirtualStyleableControl *barButtons =
        [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"button-appearance"
                                    viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context)
         {
             [UIBarButtonItem UpdateStyleWithRuleSetHandler:ruleSet
                                                    context:context
                                                     target:[UIBarButtonItem appearanceWhenContainedIn:[self class], nil]];
         }];
        
        barButtons.supportedPseudoClasses = BUTTONS_PSEUDOCLASS_MAP.allKeys;
        barButtons.defaultPseudoClass = @"normal";
        
        barButtons.viewStylers = @[
                                   STKPXOpacityStyler.sharedInstance,
                                   STKPXFillStyler.sharedInstance,
                                   STKPXBorderStyler.sharedInstance,
                                   STKPXShapeStyler.sharedInstance,
                                   STKPXBoxShadowStyler.sharedInstance,
                                   
                                   [[STKPXFontStyler alloc] initWithCompletionBlock:[UIBarButtonItem FontStylerCompletionBlock:[UIBarButtonItem appearanceWhenContainedIn:[self class], nil]]],
                                   
                                   [[STKPXPaintStyler alloc] initWithCompletionBlock:[UIBarButtonItem STKPXPaintStylerCompletionBlock:[UIBarButtonItem appearanceWhenContainedIn:[self class], nil]]],
                                   
                                   [[STKPXGenericStyler alloc] initWithHandlers: @{
                                        @"-ios-tint-color" : [UIBarButtonItem TintColorDeclarationHandlerBlock:[UIBarButtonItem appearanceWhenContainedIn:[self class], nil]]
                                        }],
                                   ];
        children = @[ barButtons ];

        objc_setAssociatedObject(self, &STYLE_CHILDREN, children, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }

    for (UIBarButtonItem *item in self.items)
    {
        item.pxStyleParent = self;
    }
    
    // Add toolbar items
    NSMutableArray *allChildren = [[NSMutableArray alloc] initWithArray:[children arrayByAddingObjectsFromArray:self.items]];

    // Add any other subviews
    [allChildren addObjectsFromArray:self.subviews];
    
    return allChildren;
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        stylers = @[
            STKPXLayoutStyler.sharedInstance,

            [[STKPXOpacityStyler alloc] initWithCompletionBlock:^(STKPXUIToolbar *view, STKPXOpacityStyler *styler, STKPXStylerContext *context) {
                [view px_setTranslucent: (context.opacity < 1.0) ? YES : NO];
            }],

            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,

            // shadow-* image properties
            [[STKPXBarShadowStyler alloc] initWithCompletionBlock:^(STKPXUIToolbar *view, STKPXBarShadowStyler *styler, STKPXStylerContext *context) {
                // iOS 6.x property
                if ([STKPXUtils isIOS6OrGreater])
                {
                    if (context.shadowImage)
                    {
                        [view px_setShadowImage:context.shadowImage forToolbarPosition:UIToolbarPositionAny];
                    }
                    else
                    {
                        // 'fill' with a clear pixel
                        [view px_setShadowImage:STKPXImageUtils.clearPixel forToolbarPosition:UIToolbarPositionAny];
                    }
                }
                
            }],

            STKPXAnimationStyler.sharedInstance,
            
            [[STKPXGenericStyler alloc] initWithHandlers: @{
              @"-ios-tint-color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUIToolbar *view = (STKPXUIToolbar *)context.styleable;
                UIColor *color = declaration.colorValue;
                [view px_setTintColor:color];
            },
                                                         
                 @"color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                    STKPXUIToolbar *view = (STKPXUIToolbar *)context.styleable;
                    UIColor *color = declaration.colorValue;
                    [view px_setTintColor:color];
                },
        }],
            
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
    if (context.color)
    {
        if([STKPXUtils isIOS7OrGreater])
        {
            [self px_setBarTintColor: context.color];
        }
        else
        {
            [self px_setTintColor: context.color];
        }
        
        [self px_setBackgroundImage:nil
                 forToolbarPosition:UIToolbarPositionAny
                         barMetrics:UIBarMetricsDefault];
    }
    
    if (context.usesImage)
    {
        [self px_setBackgroundColor: [UIColor clearColor]];
        [self px_setBackgroundImage:context.backgroundImage
                 forToolbarPosition:UIToolbarPositionAny
                         barMetrics:UIBarMetricsDefault];
    }
    
}

STKPX_LAYOUT_SUBVIEWS_OVERRIDE

STKPX_WRAP_1(setTintColor, color);
STKPX_WRAP_1(setBarTintColor, color);
STKPX_WRAP_1(setBackgroundColor, color);
STKPX_WRAP_1b(setTranslucent, flag);
STKPX_WRAP_2v(setShadowImage, image, forToolbarPosition, UIToolbarPosition, position);
STKPX_WRAP_3v(setBackgroundImage, image, forToolbarPosition, UIToolbarPosition, position, barMetrics, UIBarMetrics, metrics);

@end
