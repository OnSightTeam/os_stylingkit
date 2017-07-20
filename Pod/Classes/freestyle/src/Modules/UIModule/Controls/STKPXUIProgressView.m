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
//  PXUIProgressView.m
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUIProgressView.h"

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"

#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXVirtualStyleableControl.h"
#import "STKPXTransformStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXAnimationStyler.h"

static char const STYLE_CHILDREN;

@implementation STKPXUIProgressView

+ (void)initialize
{
    if (self != STKPXUIProgressView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"progress-view"];
}

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak id weakSelf = self;

        // thumb
        STKPXVirtualStyleableControl *track = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"track" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            if (context.usesColorOnly)
            {
                [weakSelf px_setProgressTintColor: context.color];
                [weakSelf px_setProgressImage: nil];
            }
            else if (context.backgroundImage)
            {
                // TODO: can we remove tints?
                [weakSelf px_setProgressImage: [context.backgroundImage resizableImageWithCapInsets:UIEdgeInsetsZero]];
            }
        }];

        track.viewStylers = @[
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
        ];

        NSArray *styleChildren = @[ track ];

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
        [self px_setTrackTintColor: context.color];
        [self px_setTrackImage: nil];
    }
    else if (context.usesImage)
    {
        if (UIEdgeInsetsEqualToEdgeInsets(context.insets, UIEdgeInsetsZero))
        {
            [self px_setTrackImage: [context.backgroundImage resizableImageWithCapInsets:UIEdgeInsetsZero]];
        }
        else
        {
            [self px_setTrackImage: context.backgroundImage];
        }
    }
}

PX_WRAP_1(setProgressTintColor, color);
PX_WRAP_1(setProgressImage, image);
PX_WRAP_1(setTrackTintColor, color);
PX_WRAP_1(setTrackImage, image);

PX_LAYOUT_SUBVIEWS_OVERRIDE

@end
