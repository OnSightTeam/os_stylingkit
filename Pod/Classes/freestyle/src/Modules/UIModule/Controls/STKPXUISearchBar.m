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
//  STKPXUISearchBar.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUISearchBar.h"

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"

#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXTextContentStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXAnimationStyler.h"
#import "STKPXTextShadowStyler.h"
#import "STKPXUtils.h"

@implementation STKPXUISearchBar

+ (void)initialize
{
    if (self != STKPXUISearchBar.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"search-bar"];
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        stylers = @[
            STKPXTransformStyler.sharedInstance,
            STKPXLayoutStyler.sharedInstance,

            [[STKPXOpacityStyler alloc] initWithCompletionBlock:^(STKPXUISearchBar *view, STKPXOpacityStyler *styler, STKPXStylerContext *context) {
                [view px_setTranslucent:(context.opacity < 1.0) ? YES : NO];
            }],

            STKPXFillStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,

            [[STKPXTextShadowStyler alloc] initWithCompletionBlock:^(STKPXUISearchBar *view, STKPXTextShadowStyler *styler, STKPXStylerContext *context) {
                STKPXShadow *shadow = context.textShadow;
                NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:[view scopeBarButtonTitleTextAttributesForState:UIControlStateNormal]];

                NSShadow *nsShadow = [[NSShadow alloc] init];
                
                nsShadow.shadowColor = shadow.color;
                nsShadow.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);
                nsShadow.shadowBlurRadius = shadow.blurDistance;
                
                currentTextAttributes[NSShadowAttributeName] = nsShadow;

                [view px_setScopeBarButtonTitleTextAttributes:currentTextAttributes forState:UIControlStateNormal];
            }],

            [[STKPXTextContentStyler alloc] initWithCompletionBlock:^(STKPXUISearchBar *view, STKPXTextContentStyler *styler, STKPXStylerContext *context) {
                [view px_setText: context.text];
            }],

            [[STKPXGenericStyler alloc] initWithHandlers: @{

            @"-ios-tint-color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUISearchBar *view = (STKPXUISearchBar *)context.styleable;
                UIColor *color = declaration.colorValue;
                [view px_setTintColor:color];
            },

             @"color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUISearchBar *view = (STKPXUISearchBar *)context.styleable;
                UIColor *color = declaration.colorValue;
                [view px_setTintColor:color];
             },
                
             @"bar-style" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUISearchBar *view = (STKPXUISearchBar *)context.styleable;
                NSString *style = (declaration.stringValue).lowercaseString;

                if ([style isEqualToString:@"black"])
                {
                    [view px_setBarStyle: UIBarStyleBlack];
                }
                else //if([style isEqualToString:@"default"])
                {
                    [view px_setBarStyle: UIBarStyleDefault];
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
    // Background color setting
    if([STKPXUtils isIOS7OrGreater])
    {
        if (context.color)
        {
            [self px_setBarTintColor: context.color];
        }
        else if (context.usesImage)
        {
            [self px_setBarTintColor: [UIColor colorWithPatternImage:context.backgroundImage]];
        }
    }
    else
    {
        if (context.color)
        {
            [self px_setTintColor: context.color];
        }
        else if (context.usesImage)
        {
            [self px_setTintColor: [UIColor colorWithPatternImage:context.backgroundImage]];
        }
    }
}

STKPX_PXWRAP_1(setText, text);

STKPX_WRAP_1(setBarTintColor, color);
STKPX_WRAP_1(setTintColor, color);
STKPX_WRAP_1b(setTranslucent, flag);
STKPX_WRAP_1v(setBarStyle, UIBarStyle, style);
STKPX_WRAP_2v(setScopeBarButtonTitleTextAttributes, attrs, forState, UIControlState, state);

STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end
