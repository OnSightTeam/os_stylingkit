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
//  STKPXUITextView.m
//  Pixate
//
//  Created by Kevin Lindsey on 10/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUITextView.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"

#import "STKPXOpacityStyler.h"
#import "STKPXFontStyler.h"
#import "STKPXColorStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXTextContentStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXAnimationStyler.h"
#import "STKPXVirtualStyleableControl.h"
#import "STKPXAttributedTextStyler.h"

static const char STYLE_CHILDREN;

@implementation STKPXUITextView

+ (void)initialize
{
    if (self != STKPXUITextView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"text-view"];
}

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak STKPXUITextView *weakSelf = self;
        
        // attributed text
        STKPXVirtualStyleableControl *attributedText =
        [[STKPXVirtualStyleableControl alloc] initWithParent:self
                                              elementName:@"attributed-text"
                                    viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
                                        // nothing for now
                                    }];
        
        attributedText.viewStylers = @[
                                       
                                       [[STKPXAttributedTextStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable> styleable, STKPXAttributedTextStyler *styler, STKPXStylerContext *context) {
                                           
                                           NSMutableDictionary *dict = [context attributedTextAttributes:weakSelf withDefaultText:weakSelf.text andColor:weakSelf.textColor];
                                           
                                           NSMutableAttributedString *attrString = nil;
                                           if(context.transformedText)
                                           {
                                               attrString = [[NSMutableAttributedString alloc] initWithString:context.transformedText attributes:dict];
                                           }
                                           
                                           [weakSelf px_setAttributedText:attrString];
                                       }]
                                       ];
        
        NSArray *styleChildren = @[ attributedText ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return objc_getAssociatedObject(self, &STYLE_CHILDREN);
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

            [[STKPXFontStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable> view, STKPXFontStyler *styler, STKPXStylerContext *context) {
                [(STKPXUITextView *)view px_setFont: context.font];
            }],

            [[STKPXColorStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable> view, STKPXColorStyler *styler, STKPXStylerContext *context) {
                [(STKPXUITextView *)view px_setTextColor: (UIColor *) [context propertyValueForName:@"color"]];
            }],

            [[STKPXTextContentStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable> view, STKPXTextContentStyler *styler, STKPXStylerContext *context) {
                [(STKPXUITextView *)view px_setText: context.text];
            }],

            [[STKPXGenericStyler alloc] initWithHandlers: @{
             @"text-align" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITextView *view = (STKPXUITextView *)context.styleable;

                [view px_setTextAlignment: declaration.textAlignmentValue];
            },
             @"content-offset" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITextView *view = (STKPXUITextView *)context.styleable;
                CGSize point = declaration.sizeValue;
                
                [view px_setContentOffset: CGPointMake(point.width, point.height)];
            },
             @"content-size" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITextView *view = (STKPXUITextView *)context.styleable;
                CGSize size = declaration.sizeValue;
                
                [view px_setContentSize: size];
            },
             @"content-inset" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITextView *view = (STKPXUITextView *)context.styleable;
                UIEdgeInsets insets = declaration.insetsValue;
                
                [view px_setContentInset: insets];
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
    if (context.color)
    {
        [self px_setBackgroundColor: context.color];
    }
    else if (context.usesImage)
    {
        //[self px_setBackgroundColor: [UIColor colorWithPatternImage:context.backgroundImage]];
        self.px_layer.contents = (__bridge id)(context.backgroundImage.CGImage);
    }
}

//
// Overrides
//

-(void)setText:(NSString *)text
{
    [self px_setText:text];
    [STKPXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    [self px_setAttributedText:attributedText];
    [STKPXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

// Px Wrapped Only
STKPX_PXWRAP_PROP(CALayer, layer);
STKPX_PXWRAP_1(setText, text);
STKPX_PXWRAP_1(setAttributedText, text);

// Ti Wrapped
STKPX_WRAP_1(setTextColor, color);
STKPX_WRAP_1(setFont, font);
STKPX_WRAP_1(setBackgroundColor, color);
STKPX_WRAP_1v(setTextAlignment, NSTextAlignment, alignment);

STKPX_WRAP_1s(setContentSize,   CGSize,       size);
STKPX_WRAP_1s(setContentOffset, CGPoint,      size);
STKPX_WRAP_1s(setContentInset,  UIEdgeInsets, insets);

@end
