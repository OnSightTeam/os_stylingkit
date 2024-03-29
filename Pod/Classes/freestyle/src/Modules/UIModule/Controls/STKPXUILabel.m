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
//  STKPXUILabel.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 9/18/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUILabel.h"

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "STKPXViewUtils.h"
#import "STKPXStyleUtils.h"
#import "NSMutableDictionary+STKPXObject.h"
#import "NSDictionary+STKPXObject.h"
#import "STKPXUIView.h"

#import "STKPXOpacityStyler.h"
#import "STKPXFontStyler.h"
#import "STKPXPaintStyler.h"
#import "STKPXDeclaration.h"
#import "STKPXRuleSet.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXTextContentStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXAnimationStyler.h"
#import "STKPXTextShadowStyler.h"
#import "STKPXAttributedTextStyler.h"
#import "STKPXVirtualStyleableControl.h"

static NSDictionary *PSEUDOCLASS_MAP;
static const char STYLE_CHILDREN;

NSString *const kDefaultCacheLabelShadowColor = @"label.shadowColor";
NSString *const kDefaultCacheLabelShadowOffset = @"label.shadowOffset";
NSString *const kDefaultCacheLabelFont = @"label.font";
NSString *const kDefaultCacheLabelHighlightTextColor = @"label.highightTextColor";
NSString *const kDefaultCacheLabelTextColor = @"label.textColor";
NSString *const kDefaultCacheLabelText = @"label.text";
NSString *const kDefaultCacheLabelTextAlignment = @"label.textAlignment";
NSString *const kDefaultCacheLabelLineBreakMode = @"label.lineBreakMode";

@implementation STKPXUILabel

+ (void) load
{
    if (self != STKPXUILabel.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"label"];

    PSEUDOCLASS_MAP = @{
        @"normal"      : @(UIControlStateNormal),
        @"highlighted" : @(UIControlStateHighlighted),
    };
}

#pragma mark - Child support

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak STKPXUILabel *weakSelf = self;
        
        // attributed text
        STKPXVirtualStyleableControl *attributedText =
                [[STKPXVirtualStyleableControl alloc] initWithParent:self
                                                      elementName:@"attributed-text"
                                            viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
                // nothing for now
        }];
        
        attributedText.defaultPseudoClass = @"normal";
        attributedText.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;
        
        attributedText.viewStylers = @[
                                       
            [[STKPXAttributedTextStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>styleable, STKPXAttributedTextStyler *styler, STKPXStylerContext *context) {
                
                UIControlState state = ([context stateFromStateNameMap:PSEUDOCLASS_MAP]) ?
                    [context stateFromStateNameMap:PSEUDOCLASS_MAP] : UIControlStateNormal;
                
                NSString *text = weakSelf.text;
                UIColor *stateColor = state == UIControlStateHighlighted ? weakSelf.highlightedTextColor :weakSelf.textColor;
                
                NSMutableDictionary *dict = [context attributedTextAttributes:weakSelf withDefaultText:text andColor:stateColor];
                 
                 NSMutableAttributedString *attrString = nil;
                
                 if(context.transformedText)
                 {
                     attrString = [[NSMutableAttributedString alloc] initWithString:context.transformedText attributes:dict];
                 }

                [self setAttributedText:attrString
                     invalidateChildren:NO];
            }]
        ];
        
        NSArray *styleChildren = @[ attributedText ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return objc_getAssociatedObject(self, &STYLE_CHILDREN);
}

#pragma mark - Attributed text stuff

- (NSMutableDictionary *)getAttributedTextDictionary
{
    //NSString *text = self.text;
    //UIColor *color = self.textColor;
    //UIColor *backColor = self.backgroundColor;
    //const CGFloat fontSize = _testLabel.font.pointSize;
    //CTFontRef fontRef = (__bridge CTFontRef)_testLabel.font;
    //CTFontSymbolicTraits symbolicTraits = CTFontGetSymbolicTraits(fontRef);
    //BOOL isBold = (symbolicTraits & kCTFontBoldTrait);
    //BOOL isItalic = (symbolicTraits & kCTFontItalicTrait);
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  self.font, NSFontAttributeName,
                  self.textColor, NSForegroundColorAttributeName,
                  self.backgroundColor, NSBackgroundColorAttributeName,
                  @1, NSKernAttributeName,
                  nil];
    
    return attributes;
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

#pragma mark - Stylers

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

                [(STKPXUILabel *)view px_setShadowColor: shadow.color];
                [(STKPXUILabel *)view px_setShadowOffset: CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset)];
            }],
            
            [[STKPXFontStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXFontStyler *styler, STKPXStylerContext *context) {
                [(STKPXUILabel *)view px_setFont:context.font];
            }],
            
            [[STKPXPaintStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXPaintStyler *styler, STKPXStylerContext *context) {
                UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                
                if(color)
                {
                    if([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateHighlighted)
                    {
                        [(STKPXUILabel *)view px_setHighlightedTextColor:color];
                    }
                    else
                    {
                        [(STKPXUILabel *)view px_setTextColor:color];
                    }
                }
            }],
            
            [[STKPXTextContentStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXTextContentStyler *styler, STKPXStylerContext *context) {
                [(STKPXUILabel *)view px_setText:context.text];
            }],
                
            [[STKPXGenericStyler alloc] initWithHandlers: @{
                 @"text-transform" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                    STKPXUILabel *view = (STKPXUILabel *)context.styleable;
                    
                    [view px_setText:[declaration transformString:view.text]];
                },
                 @"text-align" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                    STKPXUILabel *view = (STKPXUILabel *)context.styleable;

                    [view px_setTextAlignment:declaration.textAlignmentValue];
                },
                 @"text-overflow" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                    STKPXUILabel *view = (STKPXUILabel *)context.styleable;

                    [view px_setLineBreakMode:declaration.lineBreakModeValue];
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
    if (context.usesColorOnly)
    {
        [self px_setBackgroundColor:context.color];
    }
    else if (context.usesImage)
    {
        [self px_setBackgroundColor:[UIColor colorWithPatternImage:context.backgroundImage]];
    }
}

- (BOOL)preventStyling
{
    return [self.pxStyleParent isKindOfClass:[UIButton class]]
        || ([self.pxStyleParent class] == NSClassFromString(@"UINavigationItemButtonView"))
        ;
}

//
// Overrides
//

-(void)setText:(NSString *)text
{
    if (self.text != text ||
        ![self.text isEqualToString:text])
    {
        callSuper1(SUPER_PREFIX, @selector(setText:), text);

        // Setting plain text can change applicability of child selectors like :empty or :first-line
    }
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    [self setAttributedText:attributedText
         invalidateChildren:YES];
}

-(void)setAttributedText:(NSAttributedString *)attributedText
      invalidateChildren:(BOOL)invalidateChildren
{
    if (self.attributedText != attributedText ||
      ![self.attributedText isEqualToAttributedString:attributedText])
    {
        callSuper1(SUPER_PREFIX, @selector(setAttributedText:), attributedText);

        if(invalidateChildren && !self.preventStyling)
        {
            [STKPXStyleUtils invalidateStyleableAndDescendants:self];
            [self updateStylesNonRecursively];
        }
    }
}


// Px Wrapped Only
STKPX_PXWRAP_1(setText, text);

// Ti Wrapped Also
STKPX_WRAP_1(setShadowColor, color);
STKPX_WRAP_1(setFont, font);
STKPX_WRAP_1(setTextColor, color);
STKPX_WRAP_1(setHighlightedTextColor, color);
STKPX_WRAP_1(setBackgroundColor, color);
STKPX_WRAP_1s(setShadowOffset, CGSize, offset);
STKPX_WRAP_1v(setTextAlignment, NSTextAlignment, alignment);
STKPX_WRAP_1v(setLineBreakMode, NSLineBreakMode, mode);

STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end


