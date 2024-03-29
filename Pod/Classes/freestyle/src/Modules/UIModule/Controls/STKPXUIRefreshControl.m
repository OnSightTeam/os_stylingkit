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
//  STKPXUIRefreshControl.m
//  Pixate
//
//  Created by Paul Colton on 12/12/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUIRefreshControl.h"
#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"

#import "STKPXOpacityStyler.h"
#import "STKPXPaintStyler.h"
#import "STKPXColorStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXAnimationStyler.h"

@implementation STKPXUIRefreshControl

+ (void) load
{
    if (self != STKPXUIRefreshControl.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"refresh-control"];
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        stylers = @[
            STKPXTransformStyler.sharedInstance,
            STKPXOpacityStyler.sharedInstance,

            
            [[STKPXPaintStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXPaintStyler *styler, STKPXStylerContext *context) {
                
                UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                
                if(color == nil)
                {
                    color = (UIColor *)[context propertyValueForName:@"-ios-tint-color"];
                }
                
                if(color)
                {
                    [(STKPXUIRefreshControl *)view px_setTintColor:color];
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

STKPX_WRAP_1(setTintColor, color);

// Overrides

STKPX_LAYOUT_SUBVIEWS_OVERRIDE_RECURSIVE

@end
