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
//  STKPXUICollectionViewCell.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUICollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXStyleUtils.h"
#import "STKPXVirtualStyleableControl.h"
#import "STKPXStyleUtils.h"

#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXAnimationStyler.h"

static NSDictionary *PSEUDOCLASS_MAP;
static const char STYLE_CHILDREN;

@interface STKPXUIImageViewWrapper_UICollectionViewCell : UIImageView @end
@implementation STKPXUIImageViewWrapper_UICollectionViewCell @end

@implementation STKPXUICollectionViewCell

+ (void) load
{
    if (self != STKPXUICollectionViewCell.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"collection-view-cell"];

    PSEUDOCLASS_MAP = @{
                        @"normal"   : @(UIControlStateNormal),
                        @"selected" : @(UIControlStateSelected)
                        };
}

#pragma mark - Children

- (NSArray *)pxStyleChildren
{
    NSArray *styleChildren;
    STKPXVirtualStyleableControl *contentView;
    
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak STKPXUICollectionViewCell *weakSelf = self;
        
        // content-view
        contentView = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"content-view" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            
            if (context.usesColorOnly)
            {
                (weakSelf.px_contentView).backgroundColor = context.color;
            }
            else if (context.usesImage)
            {
                (weakSelf.px_contentView).backgroundColor = [UIColor colorWithPatternImage:[context backgroundImageWithBounds:weakSelf.px_contentView.bounds]];
            }
            
        }];
        
        contentView.viewStylers = @[
                                    STKPXOpacityStyler.sharedInstance,
                                    STKPXShapeStyler.sharedInstance,
                                    STKPXFillStyler.sharedInstance,
                                    STKPXBorderStyler.sharedInstance,
                                    STKPXBoxShadowStyler.sharedInstance,
                                    ];
        
        styleChildren = @[ contentView ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    else
    {
        styleChildren = objc_getAssociatedObject(self, &STYLE_CHILDREN);
        contentView = styleChildren[0];
    }
    
    contentView.pxStyleChildren = self.contentView.subviews;

    return styleChildren;//return [styleChildren arrayByAddingObjectsFromArray:self.subviews];
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

            [[STKPXOpacityStyler alloc] initWithCompletionBlock: ^(id<STKPXStyleable> view, STKPXOpacityStyler *styler, STKPXStylerContext *context) {
                ((STKPXUICollectionViewCell*)view).px_contentView.alpha = context.opacity;
            }],

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
    if ([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateNormal)
    {
        if(context.usesColorOnly)
        {
            if([context.color isEqual:[UIColor clearColor]])
            {
                [self px_setBackgroundView: nil];
                [self px_setBackgroundColor: [UIColor clearColor]];
            }
            else
            {
                [self px_setBackgroundView: nil];
                [self px_setBackgroundColor: context.color];
            }
        }
        else if (context.usesImage)
        {
            [self px_setBackgroundColor: [UIColor clearColor]];
            
            if([self.px_backgroundView isKindOfClass:[STKPXUIImageViewWrapper_UICollectionViewCell class]] == NO)
            {
                [self px_setBackgroundView: [[STKPXUIImageViewWrapper_UICollectionViewCell alloc] initWithImage:context.backgroundImage]];
            }
            else
            {
                STKPXUIImageViewWrapper_UICollectionViewCell *view = (STKPXUIImageViewWrapper_UICollectionViewCell *) self.backgroundView;
                view.image = context.backgroundImage;
            }
        }
    }
    else if ([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateSelected)
    {
        if(context.usesColorOnly && [context.color isEqual:[UIColor clearColor]])
        {
            [self px_setSelectedBackgroundView: nil];
        }
        else if(context.usesImage)
        {
            if([self.px_selectedBackgroundView isKindOfClass:[STKPXUIImageViewWrapper_UICollectionViewCell class]] == NO)
            {
                [self px_setSelectedBackgroundView: [[STKPXUIImageViewWrapper_UICollectionViewCell alloc] initWithImage:context.backgroundImage]];
            }
            else
            {
                STKPXUIImageViewWrapper_UICollectionViewCell *view = (STKPXUIImageViewWrapper_UICollectionViewCell *) self.px_selectedBackgroundView;
                view.image = context.backgroundImage;
            }
        }
    }
}

//
// Overrides
//

STKPX_LAYOUT_SUBVIEWS_OVERRIDE

- (void)prepareForReuse
{
    callSuper0(SUPER_PREFIX, @selector(prepareForReuse));
    [STKPXStyleUtils invalidateStyleableAndDescendants:self];
}

//
// Wrappers
//

// Ti Wrapped
STKPX_WRAP_PROP(UIView, contentView);
STKPX_WRAP_PROP(UIView, backgroundView);
STKPX_WRAP_PROP(UIView, selectedBackgroundView);

STKPX_WRAP_1(setBackgroundColor, color);
STKPX_WRAP_1(setBackgroundView, view);
STKPX_WRAP_1(setSelectedBackgroundView, view);

@end
