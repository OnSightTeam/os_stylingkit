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
<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIButton.m
//  STKPXUIButton.m
========
//  STKUIButton.m
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIButton.m
//  Pixate
//
//  Created by Paul Colton on 9/13/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIButton.m
#import "STKPXUIButton.h"
========
#import "STKUIButton.h"
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIButton.m

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

<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIButton.m
@implementation STKPXUIButton
========
@implementation STKUIButton
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIButton.m

#pragma mark - Static methods

+ (void)initialize
{
<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIButton.m
    if (self != STKPXUIButton.class)
========
    if (self != STKUIButton.class)
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIButton.m
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
<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIButton.m
        __weak STKPXUIButton *weakSelf = self;
========
        __weak STKUIButton *weakSelf = self;
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIButton.m

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

<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIButton.m
            [[STKPXTextShadowStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXTextShadowStyler *styler, STKPXStylerContext *context) {
                STKPXShadow *shadow = context.textShadow;
========
            [[PXTextShadowStyler alloc] initWithCompletionBlock:^(STKUIButton *view, PXTextShadowStyler *styler, PXStylerContext *context) {
                PXShadow *shadow = context.textShadow;
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIButton.m

                if (shadow)
                {
                    [(STKPXUIButton *)view px_setTitleShadowColor: shadow.color forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
                    ((STKPXUIButton *)view).px_titleLabel.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);

                    /*
                    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] init];

                    [attrs setObject:shadow.color forKey:UITextAttributeTextShadowColor];
                    [attrs setObject:[NSValue valueWithCGSize:CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset)] forKey:UITextAttributeTextShadowOffset];

                    NSAttributedString *oldString = [view attributedTitleForState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
                    NSMutableAttributedString *attrString = (oldString)
                        ?   [[NSMutableAttributedString alloc] initWithAttributedString:oldString]
                        :   [[NSMutableAttributedString alloc] initWithString:[view titleForState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]]];

                    [attrString setAttributes:attrs range:NSMakeRange(0, attrString.length)];

                    [view px_setAttributedTitle:attrString forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
                    */
                }
            }],

<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIButton.m
            [[STKPXFontStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXFontStyler *styler, STKPXStylerContext *context) {
                ((STKPXUIButton *)view).px_titleLabel.font = context.font;
            }],

            [[STKPXPaintStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXPaintStyler *styler, STKPXStylerContext *context) {
========
            [[PXFontStyler alloc] initWithCompletionBlock:^(STKUIButton *view, PXFontStyler *styler, PXStylerContext *context) {
                view.px_titleLabel.font = context.font;
            }],

            [[PXPaintStyler alloc] initWithCompletionBlock:^(STKUIButton *view, PXPaintStyler *styler, PXStylerContext *context) {
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIButton.m
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

<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIButton.m
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
========
            [[PXInsetStyler alloc] initWithBaseName:@"content-edge" completionBlock:^(STKUIButton *view, PXInsetStyler *styler, PXStylerContext *context) {
                [view px_setContentEdgeInsets:styler.insets];
            }],
            [[PXInsetStyler alloc] initWithBaseName:@"title-edge" completionBlock:^(STKUIButton *view, PXInsetStyler *styler, PXStylerContext *context) {
                [view px_setTitleEdgeInsets:styler.insets];
            }],
            [[PXInsetStyler alloc] initWithBaseName:@"image-edge" completionBlock:^(STKUIButton *view, PXInsetStyler *styler, PXStylerContext *context) {
                [view px_setImageEdgeInsets:styler.insets];
            }],

            [[PXTextContentStyler alloc] initWithCompletionBlock:^(STKUIButton *view, PXTextContentStyler *styler, PXStylerContext *context) {
                [view px_setTitle:context.text forState:[context stateFromStateNameMap:PSEUDOCLASS_MAP]];
            }],

            [[PXGenericStyler alloc] initWithHandlers: @{
             @"text-transform" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                STKUIButton *view = (STKUIButton *)context.styleable;
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIButton.m
                NSString *newTitle = [declaration transformString:[view titleForState:UIControlStateNormal]];

                [view px_setTitle:newTitle forState:UIControlStateNormal];
            },
<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIButton.m
             @"text-overflow" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUIButton *view = (STKPXUIButton *)context.styleable;
========
             @"text-overflow" : ^(PXDeclaration *declaration, PXStylerContext *context) {
                STKUIButton *view = (STKUIButton *)context.styleable;
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIButton.m

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

//- (void)STKPX_UIControlEventTouchDown_Dummy {}

- (void)updateStyleWithRuleSet:(STKPXRuleSet *)ruleSet context:(STKPXStylerContext *)context
{
//    [self addTarget:self action:@selector(STKPX_UIControlEventTouchDown_Dummy) forControlEvents:UIControlEventTouchDown];
//    [self addTarget:self action:@selector(STKPX_UIControlEventTouchDown_Dummy) forControlEvents:UIControlEventTouchUpInside];

    //- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents

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
    
<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIButton.m
    if ([STKPXUtils isBeforeIOS7O])
========
    if ([PXUtils isBeforeIOS7O])
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIButton.m
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

/* HOLD
-(void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    //get the string indicating the action called
    NSString *actionString = NSStringFromSelector(action);

    //get the string for the action that you want to check for
    NSString *UIControlEventTouchDownName = [[self actionsForTarget:target forControlEvent:UIControlEventTouchDown] lastObject];

    if ([UIControlEventTouchDownName isEqualToString:actionString]){

        [UIView transitionWithView:self duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [super sendAction:action to:target forEvent:event];
        } completion:^(BOOL finished) {
        }];

    } else {
        //not an event we are interested in, allow it pass through with no additional action
        [super sendAction:action to:target forEvent:event];
    }
}
*/


@end
