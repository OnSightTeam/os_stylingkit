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
//  STKPXUITextField.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 10/10/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUITextField.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "STKPXStyleUtils.h"
#import "STKPXTransitionRuleSetInfo.h"
#import "STKPXNotificationManager.h"

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
#import "STKPXStyleInfo.h"
#import "STKPXTextShadowStyler.h"
#import "STKPXPaintStyler.h"
#import "STKPXVirtualStyleableControl.h"
#import "STKPXAttributedTextStyler.h"

// if on ARM64, then we can't/don't need to use 'objc_msgSendSuper_stret'
#if defined(__arm64__)
    #define objc_msgSendSuper_stret objc_msgSendSuper
#endif

static const char STYLE_CHILDREN;
static const char STATE_KEY;

// Private STKPX_PositionCursorDelegate class
@interface STKPX_PositionCursorDelegate : NSObject <CAAnimationDelegate>
- (instancetype)init NS_UNAVAILABLE;
- (instancetype) initWithTextField:(UITextField *)textField NS_DESIGNATED_INITIALIZER;
@end

@implementation STKPX_PositionCursorDelegate
{
    UITextField *textField_;
}

- (instancetype) initWithTextField:(UITextField *)textField
{
    if(self = [super init])
    {
        textField_ = textField;
    }

    return self;
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
    UITextRange *currentPos = textField_.selectedTextRange;

    textField_.selectedTextRange = [textField_ textRangeFromPosition:textField_.beginningOfDocument
                                                            toPosition:textField_.beginningOfDocument];
    textField_.selectedTextRange = currentPos;
}
@end
// End STKPX_PositionCursorDelegate Private class

static char PADDING;

@implementation STKPXUITextField

static NSDictionary *PSEUDOCLASS_MAP;

+ (void)initialize
{
    if (self != STKPXUITextField.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"text-field"];

    PSEUDOCLASS_MAP = @{
                        @"normal"      : UITextFieldTextDidEndEditingNotification,
                        @"highlighted" : UITextFieldTextDidBeginEditingNotification,
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

- (BOOL)canStylePseudoClass:(NSString *)pseudoClass
{
    return [[self pxState] isEqualToString:pseudoClass];
}

- (void)registerNotifications
{
    __weak STKPXUITextField *weakSelf = self;

    [STKPXNotificationManager.sharedInstance registerObserver:self forNotification:UITextFieldTextDidBeginEditingNotification withBlock:^{
        [weakSelf px_TransitionTextField:weakSelf forState:@"highlighted"];
    }];
    [STKPXNotificationManager.sharedInstance registerObserver:self forNotification:UITextFieldTextDidEndEditingNotification withBlock:^{
        [weakSelf px_TransitionTextField:weakSelf forState:@"normal"];
    }];
}

- (void)dealloc
{
    [STKPXNotificationManager.sharedInstance unregisterObserver:self forNotification:UITextFieldTextDidBeginEditingNotification];
    [STKPXNotificationManager.sharedInstance unregisterObserver:self forNotification:UITextFieldTextDidEndEditingNotification];
}

- (void)setPxState:(NSString *)stateName
{
    objc_setAssociatedObject(self, &STATE_KEY, stateName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)pxState
{
    NSString *result = objc_getAssociatedObject(self, &STATE_KEY);

    return result ? result : self.defaultPseudoClass;
}

#pragma mark - Stylers

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak STKPXUITextField *weakSelf = self;
        
        // placeholder
        STKPXVirtualStyleableControl *placeholder = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"placeholder" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {

            // Style placeholder
            NSMutableDictionary *currentPlaceholderTextAttributes = [context propertyValueForName:@"text-attributes"];
            if(currentPlaceholderTextAttributes)
            {
                NSString *placeholderText = [context propertyValueForName:@"text-value"];
                
                if(!placeholderText)
                {
                    if(weakSelf.placeholder)
                    {
                        placeholderText = weakSelf.placeholder;
                    }
                    else
                    {
                        placeholderText = @"";
                    }
                }
                
                [weakSelf px_setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholderText
                                                                                      attributes:currentPlaceholderTextAttributes]];
            }
        }];
        
        placeholder.viewStylers = @[
             [[STKPXTextShadowStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable> view, STKPXTextShadowStyler *styler, STKPXStylerContext *context) {
                 STKPXShadow *shadow = context.textShadow;
                 
                 // Get attributes from context, if any
                 NSMutableDictionary *currentTextAttributes = [context propertyValueForName:@"text-attributes"];
                 if(!currentTextAttributes)
                 {
                     currentTextAttributes = [[NSMutableDictionary alloc] initWithCapacity:5];
                     [context setPropertyValue:currentTextAttributes forName:@"text-attributes"];
                 }
                 
                 NSShadow *nsShadow = [[NSShadow alloc] init];
                 
                 nsShadow.shadowColor = shadow.color;
                 nsShadow.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);
                 nsShadow.shadowBlurRadius = shadow.blurDistance;
                 
                 currentTextAttributes[NSShadowAttributeName] = nsShadow;
             }],
             
             [[STKPXFontStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXFontStyler *styler, STKPXStylerContext *context) {
                 
                 // Get attributes from context, if any
                 NSMutableDictionary *currentTextAttributes = [context propertyValueForName:@"text-attributes"];
                 if(!currentTextAttributes)
                 {
                     currentTextAttributes = [[NSMutableDictionary alloc] initWithCapacity:5];
                     [context setPropertyValue:currentTextAttributes forName:@"text-attributes"];
                 }
                 
                 currentTextAttributes[NSFontAttributeName] = context.font;
                 
             }],
             
             [[STKPXPaintStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXPaintStyler *styler, STKPXStylerContext *context) {
                 
                 // Get attributes from context, if any
                 NSMutableDictionary *currentTextAttributes = [context propertyValueForName:@"text-attributes"];
                 if(!currentTextAttributes)
                 {
                     currentTextAttributes = [[NSMutableDictionary alloc] initWithCapacity:5];
                     [context setPropertyValue:currentTextAttributes forName:@"text-attributes"];
                 }
                 
                 UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                 
                 if(color)
                 {
                     currentTextAttributes[NSForegroundColorAttributeName] = color;
                 }
             }],
             
             [[STKPXTextContentStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXTextContentStyler *styler, STKPXStylerContext *context) {

                 [context setPropertyValue:context.text forName:@"text-value"];
             }],
             
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
        
        attributedText.viewStylers =
        @[
          [[STKPXAttributedTextStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>styleable, STKPXAttributedTextStyler *styler, STKPXStylerContext *context) {
              
              NSMutableDictionary *dict = [context attributedTextAttributes:weakSelf
                                                            withDefaultText:weakSelf.text
                                                                   andColor:weakSelf.textColor];
              
              NSMutableAttributedString *attrString = nil;
              if(context.transformedText)
              {
                  attrString = [[NSMutableAttributedString alloc] initWithString:context.transformedText attributes:dict];
              }
              
              [weakSelf px_setAttributedText:attrString];
          }]
          ];
        
        NSArray *styleChildren = @[ placeholder, attributedText ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

            [[STKPXFontStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXFontStyler *styler, STKPXStylerContext *context) {
                UIFont *font = context.font;

                if (font)
                {
                    [(STKPXUITextField *)view px_setFont: font];
                }

            }],

            [[STKPXColorStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXColorStyler *styler, STKPXStylerContext *context) {
                UIColor *color = (UIColor *) [context propertyValueForName:@"color"];
                
                if(color)
                {
                    [(STKPXUITextField *)view px_setTextColor: color];
                }
            }],

            [[STKPXTextContentStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXTextContentStyler *styler, STKPXStylerContext *context) {
                [(STKPXUITextField *)view px_setText: context.text];
            }],

            [[STKPXGenericStyler alloc] initWithHandlers: @{
             @"text-align" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITextField *view = (STKPXUITextField *)context.styleable;

                [view px_setTextAlignment: declaration.textAlignmentValue];
             },
             @"-ios-border-style" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITextField *view = (STKPXUITextField *)context.styleable;

                [view px_setBorderStyle:declaration.textBorderStyleValue];
            },
             @"padding" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITextField *view = (STKPXUITextField *)context.styleable;

                view.padding = declaration.offsetsValue;
            },
             @"padding-top" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITextField *view = (STKPXUITextField *)context.styleable;
                STKPXOffsets *padding = view.padding;
                CGFloat value = declaration.floatValue;

                view.padding = [[STKPXOffsets alloc] initWithTop:value right:padding.right bottom:padding.bottom left:padding.left];
            },
             @"padding-right" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITextField *view = (STKPXUITextField *)context.styleable;
                STKPXOffsets *padding = view.padding;
                CGFloat value = declaration.floatValue;

                view.padding = [[STKPXOffsets alloc] initWithTop:padding.top right:value bottom:padding.bottom left:padding.left];
            },
             @"padding-bottom" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITextField *view = (STKPXUITextField *)context.styleable;
                STKPXOffsets *padding = view.padding;
                CGFloat value = declaration.floatValue;

                view.padding = [[STKPXOffsets alloc] initWithTop:padding.top right:padding.right bottom:value left:padding.left];
            },
             @"padding-left" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITextField *view = (STKPXUITextField *)context.styleable;
                STKPXOffsets *padding = view.padding;
                CGFloat value = declaration.floatValue;

                view.padding = [[STKPXOffsets alloc] initWithTop:padding.top right:padding.right bottom:padding.bottom left:value];
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
    if (context.usesColorOnly)
    {
        [self px_setBackgroundColor: context.color];
    }
    else if (context.usesImage)
    {
        [self px_setBackgroundColor: [UIColor colorWithPatternImage:context.backgroundImage]];
    }
}

//
// Wrappers
//

STKPX_PXWRAP_1(setText, text);
STKPX_PXWRAP_1(setPlaceholder, text);
STKPX_PXWRAP_1(setAttributedText, text);
STKPX_PXWRAP_1(setAttributedPlaceholder, text);

STKPX_WRAP_1(setTextColor, color);
STKPX_WRAP_1(setFont, font);
STKPX_WRAP_1(setBackgroundColor, color);

STKPX_WRAP_1v(setTextAlignment, NSTextAlignment, alignment);
STKPX_WRAP_1v(setBorderStyle, UITextBorderStyle, style);

#pragma mark - Getters

- (STKPXOffsets *)padding
{
    return objc_getAssociatedObject(self, &PADDING);
}

#pragma mark - Setters

- (void)setPadding:(STKPXOffsets *)padding
{
    objc_setAssociatedObject(self, &PADDING, padding, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//
// Overrides
//

STKPX_LAYOUT_SUBVIEWS_OVERRIDE

-(void)setText:(NSString *)text
{
    callSuper1(SUPER_PREFIX, @selector(setText:), text);
    [STKPXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    callSuper1(SUPER_PREFIX, @selector(setAttributedText:), attributedText);
    [STKPXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

-(void)setPlaceholder:(NSString *)placeholder
{
    callSuper1(SUPER_PREFIX, @selector(setPlaceholder:), placeholder);
    [STKPXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

-(void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    callSuper1(SUPER_PREFIX, @selector(setAttributedPlaceholder:), attributedPlaceholder);
    [STKPXStyleUtils invalidateStyleableAndDescendants:self];
    [self updateStylesNonRecursively];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    Class _superClass = self.pxClass;
    struct objc_super mysuper;
    mysuper.receiver = self;
    mysuper.super_class = _superClass;

    CGRect result = ((CGRect(*)(struct objc_super*, SEL, CGRect))objc_msgSendSuper_stret)(&mysuper, @selector(textRectForBounds:), bounds);

    STKPXOffsets *padding = self.padding;
    result.origin.x = result.origin.x + padding.left;
    result.origin.y = result.origin.y + padding.top;
    result.size.width = result.size.width - (padding.left + padding.right);
    result.size.height = result.size.height - (padding.top + padding.bottom);
    
    return result;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    Class _superClass = self.pxClass;
    struct objc_super mysuper;
    mysuper.receiver = self;
    mysuper.super_class = _superClass;
    
    CGRect result = ((CGRect(*)(struct objc_super*, SEL, CGRect))objc_msgSendSuper_stret)(&mysuper, @selector(editingRectForBounds:), bounds);

    STKPXOffsets *padding = self.padding;
    result.origin.x = result.origin.x + padding.left;
    result.origin.y = result.origin.y + padding.top;
    result.size.width = result.size.width - (padding.left + padding.right);
    result.size.height = result.size.height - (padding.top + padding.bottom);
    
    return result;
}

// Notification handlers

- (void)px_TransitionTextField:(UITextField *)textField forState:(NSString *)stateName
{
    [self setPxState:stateName];

    STKPXTransitionRuleSetInfo *ruleSetInfo = [[STKPXTransitionRuleSetInfo alloc] initWithStyleable:textField
                                                                             withStateName:stateName];

    if (ruleSetInfo.nonAnimatingRuleSets.count > 0)
    {
        STKPXStyleInfo *styleInfo = [[STKPXStyleInfo alloc] initWithStyleKey:textField.styleKey];
        [STKPXStyleInfo setStyleInfo:styleInfo withRuleSets:ruleSetInfo.nonAnimatingRuleSets styleable:textField stateName:stateName];
        styleInfo.forceInvalidation = YES;
        [styleInfo applyToStyleable:textField];
    }

    if (ruleSetInfo.animatingRuleSets.count > 0)
    {
        STKPXAnimationInfo *info = (ruleSetInfo.transitions.count > 0) ? (ruleSetInfo.transitions)[0] : nil;

        if (info != nil)
        {
            CATransition* trans = [CATransition animation];

            trans.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            trans.duration = info.animationDuration;
            trans.type = kCATransitionFade;
            trans.subtype = kCATransitionFromTop;
            trans.removedOnCompletion = YES;
            trans.delegate = [[STKPX_PositionCursorDelegate alloc] initWithTextField:textField];

            [textField.layer removeAllAnimations];
            [textField.layer addAnimation:trans forKey:@"transition"];

            STKPXStyleInfo *styleInfo = [[STKPXStyleInfo alloc] initWithStyleKey:textField.styleKey];
            [STKPXStyleInfo setStyleInfo:styleInfo withRuleSets:ruleSetInfo.ruleSetsForState styleable:textField stateName:stateName];
            [styleInfo applyToStyleable:textField];
        }
    }
}

@end

