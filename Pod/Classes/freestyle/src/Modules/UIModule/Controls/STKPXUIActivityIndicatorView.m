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
//  PXUIActivityIndicatorView.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUIActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "STKPXOpacityStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXAnimationStyler.h"

@implementation STKPXUIActivityIndicatorView

+ (void)initialize
{
    if (self != STKPXUIActivityIndicatorView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"activity-indicator-view"];
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        stylers = @[
            STKPXTransformStyler.sharedInstance,
            STKPXOpacityStyler.sharedInstance,
            STKPXLayoutStyler.sharedInstance,

            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,

            [[STKPXGenericStyler alloc] initWithHandlers: @{
             @"color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUIActivityIndicatorView *view = (STKPXUIActivityIndicatorView *)context.styleable;

                [view px_setColor:declaration.colorValue];
            },
             @"style" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUIActivityIndicatorView *view = (STKPXUIActivityIndicatorView *)context.styleable;
                NSString *style = (declaration.stringValue).lowercaseString;

                if ([style isEqualToString:@"large"])
                {
                    [view px_setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
                }
                else if ([style isEqualToString:@"small-gray"])
                {
                    [view px_setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                }
                else //default: if([style isEqualToString:@"small"])
                {
                    [view px_setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
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
        [self px_setBackgroundColor:context.color];
        self.px_layer.contents = nil;
    }
    else if (context.usesImage)
    {
        [self px_setBackgroundColor:[UIColor clearColor]];
        self.px_layer.contents = (__bridge id)(context.backgroundImage.CGImage);
    }
}


// Px Wrapped Only
PX_PXWRAP_PROP(CALayer, layer);

// Ti Wrapped
PX_WRAP_1(setColor, color);
PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1v(setActivityIndicatorViewStyle, UIActivityIndicatorViewStyle, style);

PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
