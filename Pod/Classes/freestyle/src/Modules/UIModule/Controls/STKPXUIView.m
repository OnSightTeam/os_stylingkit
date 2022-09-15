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
//  STKPXUIView.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 9/13/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUIView.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "STKPXStyleUtils.h"
#import "NSMutableDictionary+STKPXObject.h"
#import "NSDictionary+STKPXObject.h"
#import "STKPXVirtualStyleableControl.h"

#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXAnimationStyler.h"
#import "STKPXPaintStyler.h"

static const char STYLE_CHILDREN;

@implementation STKPXUIView

+ (void) load
{
    if (self != STKPXUIView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"view"];
}

- (NSArray *)pxStyleChildren
{
    NSArray *styleChildren;
    
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak STKPXUIView* weakSelf = self;

        //
        // layer
        //
        STKPXVirtualStyleableControl *layer = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"layer" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            if (context.usesColorOnly)
            {
                weakSelf.px_layer.backgroundColor = context.color.CGColor;
            }
            else if (context.usesImage)
            {
                weakSelf.px_layer.contents = (__bridge id)(context.backgroundImage.CGImage);
            }
        }];

        layer.viewStylers = @[
                              STKPXShapeStyler.sharedInstance,
                              STKPXFillStyler.sharedInstance,
                              STKPXBorderStyler.sharedInstance,
                              STKPXBoxShadowStyler.sharedInstance
                              ];

        styleChildren = @[ layer ];
        
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
            
            STKPXPaintStyler.sharedInstanceForTintColor,
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

- (BOOL)preventStyling
{
    return [self.superview isKindOfClass:[UITextView class]];
}

// Px Wrapped Only
STKPX_PXWRAP_PROP(CALayer, layer);

// Ti Wrapped
STKPX_WRAP_1(setBackgroundColor, color);
STKPX_WRAP_1(setTintColor, color);

// Styling
STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end
