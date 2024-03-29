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
//  STKPXUIButton.m
//  Pixate
//
//  Created by Paul Colton on 9/13/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUIButton.h"

#import "PixateFreestyle.h"
#import "STKPXStylingMacros.h"

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "NSDictionary+STKPXObject.h"
#import "NSMutableDictionary+STKPXObject.h"

#import "STKPXOpacityStyler.h"
#import "STKPXFontStyler.h"
#import "STKPXPaintStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXInsetStyler.h"
#import "STKPXTextContentStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXAnimationStyler.h"
#import "STKPXTextShadowStyler.h"

#import "STKPXDeclaration.h"
#import "STKPXRuleSet.h"
#import "STKPXVirtualStyleableControl.h"
#import <QuartzCore/QuartzCore.h>
#import "STKPXKeyframeAnimation.h"

#import "STKPXStyleUtils.h"
#import "STKPXUtils.h"
#import "NSMutableDictionary+STKPXObject.h"
#import "NSDictionary+STKPXObject.h"
#import "STKPXUIView.h"
#import "STKPXAnimationPropertyHandler.h"

#import "STKPXAttributedTextStyler.h"

static NSDictionary *PSEUDOCLASS_MAP;
static const char STYLE_CHILDREN;

@implementation STKPXUIButton

#pragma mark - Static methods

+ (void) load
{
    if (self != STKPXUIButton.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"button"];

    PSEUDOCLASS_MAP = @{
        @"normal"      : @(UIControlStateNormal),
        @"highlighted" : @(UIControlStateHighlighted),
        @"selected"    : @(UIControlStateSelected),
        @"disabled"    : @(UIControlStateDisabled)
    };
}

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak STKPXUIButton *weakSelf = self;

        //
        // icon child
        //
        STKPXVirtualStyleableControl *icon = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"icon" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            UIImage *image = context.backgroundImage;

            if (image)
            {
                [weakSelf px_setImage:image forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }
        }];

        icon.defaultPseudoClass = @"normal";
        icon.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;

        icon.viewStylers = @[
            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,
            ];
        
        //
        // attributed text child
        //
        STKPXVirtualStyleableControl *attributedText =
        [[STKPXVirtualStyleableControl alloc] initWithParent:self
                                              elementName:@"attributed-text"
                                    viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
                                        // nothing for now
                                    }];
        
        attributedText.defaultPseudoClass = @"normal";
        attributedText.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;
        
        attributedText.viewStylers =
        @[
            [[STKPXAttributedTextStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>styleable, STKPXAttributedTextStyler *styler, STKPXStylerContext *context) {

                UIControlState state = ([context stateFromStateNameMap:PSEUDOCLASS_MAP]);
                
                NSAttributedString *stateTextAttr = [weakSelf attributedTitleForState:state];
                NSString *stateText = stateTextAttr ? stateTextAttr.string : [weakSelf titleForState:state];
                
                UIColor *stateColor = [weakSelf titleColorForState:state];
                
                NSMutableDictionary *dict = [context attributedTextAttributes:weakSelf
                                                              withDefaultText:stateText
                                                                     andColor:stateColor];
               
                
               NSMutableAttributedString *attrString = nil;
               if(context.transformedText)
               {
                   attrString = [[NSMutableAttributedString alloc] initWithString:context.transformedText attributes:dict];
               }
               
               [weakSelf px_setAttributedTitle:attrString forState:state];
            }]
        ];

        NSArray *styleChildren = @[ icon, attributedText ];

        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return [objc_getAssociatedObject(self, &STYLE_CHILDREN) arrayByAddingObjectsFromArray:self.subviews];
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

            [[STKPXTextShadowStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXTextShadowStyler *styler, STKPXStylerContext *context) {
                STKPXShadow *shadow = context.textShadow;

                if (shadow)
                {
                    [(STKPXUIButton *)view px_setTitleShadowColor: shadow.color forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
                    ((STKPXUIButton *)view).px_titleLabel.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);
                }
            }],

            [[STKPXFontStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXFontStyler *styler, STKPXStylerContext *context) {
                ((STKPXUIButton *)view).px_titleLabel.font = context.font;
            }],

            [[STKPXPaintStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXPaintStyler *styler, STKPXStylerContext *context) {
                UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                if(color)
                {
                    [(STKPXUIButton *)view px_setTitleColor:color forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
                }
                
                color = (UIColor *)[context propertyValueForName:@"-ios-tint-color"];
                if(color)
                {
                    [(STKPXUIButton *)view px_setTintColor:color];
                }
            }],

            [[STKPXInsetStyler alloc] initWithBaseName:@"content-edge" completionBlock:^(id<STKPXStyleable>view, STKPXInsetStyler *styler, STKPXStylerContext *context) {
                [(STKPXUIButton *)view px_setContentEdgeInsets:styler.insets];
            }],
            [[STKPXInsetStyler alloc] initWithBaseName:@"title-edge" completionBlock:^(id<STKPXStyleable> view, STKPXInsetStyler *styler, STKPXStylerContext *context) {
                [(STKPXUIButton *)view px_setTitleEdgeInsets:styler.insets];
            }],
            [[STKPXInsetStyler alloc] initWithBaseName:@"image-edge" completionBlock:^(id<STKPXStyleable>view, STKPXInsetStyler *styler, STKPXStylerContext *context) {
                [(STKPXUIButton *)view px_setImageEdgeInsets:styler.insets];
            }],

            [[STKPXTextContentStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXTextContentStyler *styler, STKPXStylerContext *context) {
                [(STKPXUIButton *)view px_setTitle:context.text forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }],

            [[STKPXGenericStyler alloc] initWithHandlers: @{
             @"text-transform" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUIButton *view = (STKPXUIButton *)context.styleable;
                NSString *newTitle = [declaration transformString:[view titleForState:UIControlStateNormal]];

                [view px_setTitle:newTitle forState:UIControlStateNormal];
            },
             @"text-overflow" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUIButton *view = (STKPXUIButton *)context.styleable;

                view.px_titleLabel.lineBreakMode = declaration.lineBreakModeValue;
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
    // Solid colors are only supported for normal state, so we'll use images otherwise
    if (context.usesColorOnly)
    {
        if ([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateNormal && self.buttonType != UIButtonTypeRoundedRect)
        {
            [self px_setBackgroundColor:context.color];
        }
        else
        {
            //[self px_setBackgroundColor:[UIColor clearColor]];
            [self px_setBackgroundImage:context.backgroundImage
                               forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];

        }
    }
    else if (context.usesImage)
    {
        //[self px_setBackgroundColor:[UIColor clearColor]];
        [self px_setBackgroundImage:context.backgroundImage
                           forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
    }
}


- (CGSize) intrinsicContentSize
{
    struct objc_super superObj;
    superObj.receiver = self;
    superObj.super_class = [self pxClass];
        
    typedef CGSize(*callT)(struct objc_super*, SEL);
#if defined(__arm64__) || defined(__x86_64__) || defined(__i386__)
    callT sendSuper = (callT)objc_msgSendSuper;
#else
    callT sendSuper = (callT)objc_msgSendSuper_stret;
#endif
    
    CGSize result = sendSuper(&superObj, @selector(intrinsicContentSize));
    
    if ([STKPXUtils isBeforeIOS7O])
    {
        Class roundedButton = NSClassFromString(@"UIRoundedRectButton");

        if (roundedButton && [self isKindOfClass:roundedButton]) {
            result.width  -= 24;
            result.height -= 16;
        }
    }

    return result;
}


//
// Overrides
//

-(void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [self px_setTitle:title forState:state];
    [STKPXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

-(void)setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state
{
    [self px_setAttributedTitle:title forState:state];
    [STKPXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

// Px Wrapped Only
STKPX_PXWRAP_PROP(UILabel, titleLabel);
STKPX_PXWRAP_1s(setTransform, CGAffineTransform, transform);
STKPX_PXWRAP_1s(setAlpha, CGFloat, alpha);
STKPX_PXWRAP_1s(setBounds, CGRect, rect);
STKPX_PXWRAP_1s(setFrame,  CGRect, rect);
STKPX_PXWRAP_2v(setTitle, title, forState, UIControlState, state);
STKPX_PXWRAP_2v(setAttributedTitle, string, forState, UIControlState, state);

// Ti Wrapped as well
STKPX_WRAP_1(setTintColor, color);
STKPX_WRAP_1(setBackgroundColor, color);
STKPX_WRAP_1s(setContentEdgeInsets, UIEdgeInsets, insets);
STKPX_WRAP_1s(setTitleEdgeInsets,   UIEdgeInsets, insets);
STKPX_WRAP_1s(setImageEdgeInsets,   UIEdgeInsets, insets);
STKPX_WRAP_2v(setImage, image, forState, UIControlState, state);
STKPX_WRAP_2v(setBackgroundImage, image, forState, UIControlState, state);
STKPX_WRAP_2v(setTitleColor,      color, forState, UIControlState, state);
STKPX_WRAP_2v(setTitleShadowColor, color, forState, UIControlState, state);

// Styling overrides
STKPX_LAYOUT_SUBVIEWS_OVERRIDE


@end
