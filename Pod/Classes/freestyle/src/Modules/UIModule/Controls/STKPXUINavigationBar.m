/*
 * Copyright 2015-present StylingKit Development Team
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
//  PXUINavigationBar.m
//  Pixate
//
//  Modified by Anton Matosov
//  Created by Paul Colton on 10/8/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUINavigationBar.h"

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "STKPXVirtualStyleableControl.h"
#import "NSObject+PXSubclass.h"
#import "STKPXUtils.h"
#import "STKPXImageUtils.h"

#import "STKPXBarMetricsAdjustmentStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXOpacityStyler.h"
#import "STKPXFontStyler.h"
#import "STKPXPaintStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXBarShadowStyler.h"
#import "STKPXAnimationStyler.h"
#import "STKPXTextShadowStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXTextContentStyler.h"
#import "UINavigationItem+PXStyling.h"
#import "UIBarButtonItem+PXStyling-Private.h"

static const char STYLE_CHILDREN;
static NSDictionary *PSEUDOCLASS_MAP;
static NSDictionary *BUTTONS_PSEUDOCLASS_MAP;

@implementation STKPXUINavigationBar

#pragma mark - Static methods

+ (void)initialize
{
    if (self != STKPXUINavigationBar.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"navigation-bar"];

    PSEUDOCLASS_MAP = @{
        @"default" : @(UIBarMetricsDefault),
        @"landscape-iphone" : @(UIBarMetricsCompact)
    };
    
    BUTTONS_PSEUDOCLASS_MAP = @{
                        @"normal"      : @(UIControlStateNormal),
                        @"highlighted" : @(UIControlStateHighlighted),
                        @"disabled"    : @(UIControlStateDisabled)
                        };

}

#pragma mark - Pseudo-class State

- (NSArray *)supportedPseudoClasses
{
    if (STKPXUtils.isIPhone)
    {
        return PSEUDOCLASS_MAP.allKeys;
    }
    else
    {
        return @[ @"default" ];
    }
}

- (NSString *)defaultPseudoClass
{
    if (STKPXUtils.isIPhone)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

        switch (orientation) {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                return @"landscape-iphone";

            default:
                return @"default";
        }
    }
    else
    {
        return @"default";
    }
}

#pragma mark - Styling

- (NSArray *)pxStyleChildren
{
    // Get the children array
    NSArray *children = objc_getAssociatedObject(self, &STYLE_CHILDREN);

    if (!children)
    {
        // Weak ref to self
        __weak STKPXUINavigationBar *weakSelf = self;

        //
        // Child controls
        //
        
        /// back-indicator
        
        STKPXVirtualStyleableControl *backIndicator = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"back-indicator" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            
            if([STKPXUtils isIOS7OrGreater])
            {
                UIImage *image = context.backgroundImage;
            
                weakSelf.backIndicatorImage = image;
                
                if(weakSelf.backIndicatorTransitionMaskImage == nil)
                {
                    weakSelf.backIndicatorTransitionMaskImage = image;
                }
            }
        }];

        backIndicator.viewStylers = @[
                                      STKPXOpacityStyler.sharedInstance,
                                      STKPXShapeStyler.sharedInstance,
                                      STKPXFillStyler.sharedInstance,
                                      STKPXBorderStyler.sharedInstance,
                                      STKPXBoxShadowStyler.sharedInstance
                                      ];
        
        /// back-indicator-mask
        
        STKPXVirtualStyleableControl *backIndicatorMask = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"back-indicator-mask" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            
            if([STKPXUtils isIOS7OrGreater])
            {
                UIImage *image = context.backgroundImage;
                
                weakSelf.backIndicatorTransitionMaskImage = image;
            }
        }];
        
        backIndicatorMask.viewStylers = @[
                             STKPXOpacityStyler.sharedInstance,
                             STKPXShapeStyler.sharedInstance,
                             STKPXFillStyler.sharedInstance,
                             STKPXBorderStyler.sharedInstance,
                             STKPXBoxShadowStyler.sharedInstance
                             ];

        /// title

        STKPXVirtualStyleableControl *title = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"title"];

        title.viewStylers = @[
            [[STKPXGenericStyler alloc] initWithHandlers:@{
                @"text-transform" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context)
                {

                    NSString *newTitle = [declaration transformString:weakSelf.topItem.title];

                    if (![newTitle isEqualToString:weakSelf.topItem.title])
                    {
                        weakSelf.topItem.title = newTitle;
                    }
                }
            }],

            [[STKPXTextShadowStyler alloc] initWithCompletionBlock:^(STKPXVirtualStyleableControl *view, STKPXTextShadowStyler *styler, STKPXStylerContext *context) {
               STKPXShadow *shadow = context.textShadow;
               NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:weakSelf.titleTextAttributes];
               
                NSShadow *nsShadow = [[NSShadow alloc] init];
                
                nsShadow.shadowColor = shadow.color;
                nsShadow.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);
                nsShadow.shadowBlurRadius = shadow.blurDistance;
                
                currentTextAttributes[NSShadowAttributeName] = nsShadow;
               
               [weakSelf px_setTitleTextAttributes:currentTextAttributes];
            }],

            [[STKPXFontStyler alloc] initWithCompletionBlock:^(STKPXVirtualStyleableControl *view, STKPXFontStyler *styler, STKPXStylerContext *context) {
               NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:weakSelf.titleTextAttributes];
               
               currentTextAttributes[NSFontAttributeName] = context.font;
               
               [weakSelf px_setTitleTextAttributes:currentTextAttributes];
                
                if([STKPXUtils isBeforeIOS7O])
                {
                    [weakSelf setNeedsLayout];
                }
            }],

            [[STKPXPaintStyler alloc] initWithCompletionBlock:^(STKPXVirtualStyleableControl *view, STKPXPaintStyler *styler, STKPXStylerContext *context) {
                
               NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:weakSelf.titleTextAttributes];
               
               UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
               
                if(color)
                {
                   currentTextAttributes[NSForegroundColorAttributeName] = color;
                   
                   [weakSelf px_setTitleTextAttributes:currentTextAttributes];
                }
            }],
            
        ];
        
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
            
            [[STKPXPaintStyler alloc] initWithCompletionBlock:[UIBarButtonItem PXPaintStylerCompletionBlock:[UIBarButtonItem appearanceWhenContainedIn:[self class], nil]]],

            [[STKPXGenericStyler alloc] initWithHandlers: @{
                @"-ios-tint-color" : [UIBarButtonItem TintColorDeclarationHandlerBlock:[UIBarButtonItem appearanceWhenContainedIn:[self class], nil]]
                }],
            ];
        
        
        //
        // back-button-appearance
        //
        
        STKPXVirtualStyleableControl *backBarButtons =
        [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"back-button-appearance"
                                    viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context)
         {
             if (context.usesImage && context.backgroundImage)
             {
                 UIImage *image = context.backgroundImage;
                 
                 [[UIBarButtonItem appearanceWhenContainedIn:[self class], nil]
                      setBackButtonBackgroundImage:image
                      forState:[context stateFromStateNameMap:BUTTONS_PSEUDOCLASS_MAP]
                      barMetrics:UIBarMetricsDefault];
             }
         }];
        
        backBarButtons.supportedPseudoClasses = BUTTONS_PSEUDOCLASS_MAP.allKeys;
        backBarButtons.defaultPseudoClass = @"normal";
        
        backBarButtons.viewStylers = @[
                                       STKPXOpacityStyler.sharedInstance,
                                       STKPXShapeStyler.sharedInstance,
                                       STKPXFillStyler.sharedInstance,
                                       STKPXBorderStyler.sharedInstance,
                                       STKPXBoxShadowStyler.sharedInstance
                                       ];
        
        children = @[ title, backIndicator, backIndicatorMask, barButtons, backBarButtons ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, children, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    //
    // Collect all of this views children, real and virtual
    //

    // Add the subviews
    NSMutableArray *allChildren = [[NSMutableArray alloc]
                                   initWithArray:[children arrayByAddingObjectsFromArray:self.subviews]];

    // Add the top navigation item
    if(self.topItem)
    {
        self.topItem.pxStyleParent = self;
        [allChildren addObject:self.topItem];
    }

    return allChildren;
}

- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        
        stylers = @[
            STKPXTransformStyler.sharedInstance,
            STKPXLayoutStyler.sharedInstance,

            [[STKPXOpacityStyler alloc] initWithCompletionBlock:^(STKPXUINavigationBar *view, STKPXOpacityStyler *styler, STKPXStylerContext *context) {
                [view px_setTranslucent:(context.opacity < 1.0) ? YES : NO];
            }],

            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,
            
            [[STKPXBarMetricsAdjustmentStyler alloc] initWithCompletionBlock:^(STKPXUINavigationBar *view, STKPXBarMetricsAdjustmentStyler *styler, STKPXStylerContext *context) {
                STKPXDimension *offset = context.barMetricsVerticalOffset;
                CGFloat value = (offset) ? offset.points.number : 0.0f;
                
                [view px_setTitleVerticalPositionAdjustment:value forBarMetrics:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }],

            [[STKPXPaintStyler alloc] initWithCompletionBlock:^(STKPXUINavigationBar *view, STKPXPaintStyler *styler, STKPXStylerContext *context) {
                
                if([STKPXUtils isIOS7OrGreater])
                {
                    UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                    if(color)
                    {
                        [view px_setTintColor:color];
                    }
                }
                else // @deprecated in 1.1 (this else statement only)
                {
                    NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:view.titleTextAttributes];
                    
                    UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                    
                    if(color)
                    {
                        currentTextAttributes[NSForegroundColorAttributeName] = color;
                        
                        [view px_setTitleTextAttributes:currentTextAttributes];
                    }
                }
                
                // check for tint-color
                UIColor *color = (UIColor *)[context propertyValueForName:@"-ios-tint-color"];
                if(color)
                {
                    [view px_setTintColor:color];
                }
            }],
            
            // @deprecated in 1.1
            [[STKPXTextShadowStyler alloc] initWithCompletionBlock:^(STKPXUINavigationBar *view, STKPXTextShadowStyler *styler, STKPXStylerContext *context) {
                STKPXShadow *shadow = context.textShadow;
                NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:view.titleTextAttributes];
                
                NSShadow *nsShadow = [[NSShadow alloc] init];
                
                nsShadow.shadowColor = shadow.color;
                nsShadow.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);
                nsShadow.shadowBlurRadius = shadow.blurDistance;
                
                currentTextAttributes[NSShadowAttributeName] = nsShadow;
                
                [view px_setTitleTextAttributes:currentTextAttributes];
            }],
            
            // @deprecated in 1.1
            [[STKPXFontStyler alloc] initWithCompletionBlock:^(STKPXUINavigationBar *view, STKPXFontStyler *styler, STKPXStylerContext *context) {
                NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:view.titleTextAttributes];
                
                currentTextAttributes[NSFontAttributeName] = context.font;
                
                [view px_setTitleTextAttributes:currentTextAttributes];
                
                if([STKPXUtils isBeforeIOS7O])
                {
                    [view setNeedsLayout];
                }
            }],

            // shadow-* image properties
            [[STKPXBarShadowStyler alloc] initWithCompletionBlock:^(STKPXUINavigationBar *view, STKPXBarShadowStyler *styler, STKPXStylerContext *context) {
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

            STKPXAnimationStyler.sharedInstance,
            
            /*
             *  - background-position: any | bottom | top | top-attached;
             *
            [[PXGenericStyler alloc] initWithHandlers: @{
                @"background-position" : ^(PXDeclaration *declaration, PXStylerContext *context)
                {
                    NSString *position = [declaration.stringValue lowercaseString];
                    [context setPropertyValue:position forName:@"background-position"];
                }
            }],
             */
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
    //
    // Set the background-color....
    //
    if (context.usesColorOnly)
    {
        if([STKPXUtils isIOS7OrGreater])
        {
            [self px_setBarTintColor:context.color];
        }
        else
        {
            [self px_setTintColor:context.color];
        }
        
        [self px_setBackgroundImage:nil
                      forBarMetrics:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
    }
    else if (context.usesImage)
    {
        /*
        if([PXUtils isIOS7OrGreater])
        {
            UIBarPosition position = UIBarPositionAny;
            NSString *backgroundPosition = [context propertyValueForName:@"background-position"];
            
            if([backgroundPosition isEqualToString:@"bottom"])
            {
                position = UIBarPositionBottom;
            }
            else if([backgroundPosition isEqualToString:@"top"])
            {
                position = UIBarPositionTop;
            }
            else if([backgroundPosition isEqualToString:@"top-attached"])
            {
                position = UIBarPositionTopAttached;
            }
            
            // TODO: use a macro here
            [self setBackgroundImage:context.backgroundImage
                      forBarPosition:position
                          barMetrics:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            
            
        }
        else
        {
         */
        [self px_setBackgroundColor:[UIColor clearColor]];
        [self px_setBackgroundImage:context.backgroundImage
                      forBarMetrics:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
//        }
    }

}

// Overrides
PX_LAYOUT_SUBVIEWS_OVERRIDE

// This will allow for the dynamically added content to style, like the UINavigationItems
-(void)addSubview:(UIView *)view
{
    callSuper1(SUPER_PREFIX, @selector(addSubview:), view);
    
    // invalidate the navbar when new views get added (primarily to catch new top level views sliding in)
    [STKPXStyleUtils invalidateStyleableAndDescendants:self];
    
    // update styles for this newly added view
    [self updateStyles];
}

// Ti Wrapped
PX_WRAP_1(setTintColor, color);
PX_WRAP_1(setBarTintColor, color);
PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1(setShadowImage, image);
PX_WRAP_1(setTitleTextAttributes, attribs);
PX_WRAP_1b(setTranslucent, flag);
//BUSTED:PX_WRAP_3v(setBackgroundImage, image, forBarPosition, UIBarPosition, position, barMetrics, UIBarMetrics, metrics);
PX_WRAP_2v(setBackgroundImage, image, forBarMetrics, UIBarMetrics, metrics);
PX_WRAP_2vv(setTitleVerticalPositionAdjustment, CGFloat, adjustment, forBarMetrics, UIBarMetrics, metrics);

@end

