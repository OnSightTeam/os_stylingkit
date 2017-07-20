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
//  STKPXAnnotationView.m
//  Pixate
//
//  Created by Paul Colton on 11/29/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXMKAnnotationView.h"
#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "objc.h"

#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXAnimationStyler.h"

@implementation STKPXMKAnnotationView

+ (void)initialize
{
    if (self != STKPXMKAnnotationView.class)
        return;
    
    [UIView registerDynamicSubclass:self
                           forClass:[STKPXMKAnnotationView targetSuperclass]
                    withElementName:@"annotation-view"];
}

+ (Class)targetSuperclass
{
	static Class targetSuperclass = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		targetSuperclass = NSClassFromString([[self description] substringFromIndex:2]);
	});

	return targetSuperclass;
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
    if (context.usesImage)
    {
        [self px_setImage:context.backgroundImage];
    }
}

STKPX_WRAP_1(setImage, image);

STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end


