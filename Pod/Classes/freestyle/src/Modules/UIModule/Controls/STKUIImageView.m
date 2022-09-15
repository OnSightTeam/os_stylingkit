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
<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIImageView.m
//  STKPXUIImageView.m
========
//  STKUIImageView.m
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIImageView.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 9/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIImageView.m
#import "STKPXUIImageView.h"
========
#import "STKUIImageView.h"
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIImageView.m

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"

#import "STKPXOpacityStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXAnimationStyler.h"
#import "STKPXPaintStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXUtils.h"

static NSDictionary *PSEUDOCLASS_MAP;

<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIImageView.m
@implementation STKPXUIImageView

+ (void)initialize
{
    if (self != STKPXUIImageView.class)
========
@implementation STKUIImageView

+ (void)initialize
{
    if (self != STKUIImageView.class)
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIImageView.m
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"image-view"];

    PSEUDOCLASS_MAP = @{
        @"normal"      : @(UIControlStateNormal),
        @"highlighted" : @(UIControlStateHighlighted),
    };
}

#pragma mark - Pseudo-class State

- (NSArray *)supportedPseudoClasses
{
    return PSEUDOCLASS_MAP.allKeys;
}

- (NSString *)defaultPseudoClass
{
    return @"normal";
}

#pragma mark - Styling

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
            
            [[STKPXGenericStyler alloc] initWithHandlers: @{
                                                         
            @"-ios-rendering-mode" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                
                NSString *mode = (declaration.stringValue).lowercaseString;
                
                if([mode isEqualToString:@"original"])
                {
                    [context setPropertyValue:@"original" forName:@"rendering-mode"];
                }
                else if([mode isEqualToString:@"template"])
                {
                    [context setPropertyValue:@"template" forName:@"rendering-mode"];
                }
                else
                {
                    [context setPropertyValue:@"automatic" forName:@"rendering-mode"];
                }
            }}],
            
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
    UIImage *image = context.backgroundImage;
    
    if([STKPXUtils isIOS7OrGreater])
    {
        NSString *renderingMode = [context propertyValueForName:@"rendering-mode"];
        
        if(renderingMode)
        {
            if([renderingMode isEqualToString:@"original"])
            {
                image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            }
            else if([renderingMode isEqualToString:@"template"])
            {
                image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            else
            {
                image = [image imageWithRenderingMode:UIImageRenderingModeAutomatic];
            }
        }
    }

    if([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateHighlighted)
    {
        [self px_setHighlightedImage:image];
    }
    else if (context.usesImage)
    {
        [self px_setImage:image];
    }
    
    // TODO: support animated images
}

STKPX_WRAP_1(setImage, image);
STKPX_WRAP_1(setHighlightedImage, image);

STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end
