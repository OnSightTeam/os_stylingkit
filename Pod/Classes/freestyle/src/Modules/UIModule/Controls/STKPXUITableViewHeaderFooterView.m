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
//  STKPXUITableViewHeaderFooterView.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 11/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUITableViewHeaderFooterView.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "STKPXVirtualStyleableControl.h"
#import "STKPXStyleUtils.h"

#import "STKPXOpacityStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXLayoutStyler.h"

#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXAnimationStyler.h"
#import "STKPXFontStyler.h"
#import "STKPXPaintStyler.h"
#import "STKPXTextContentStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXAttributedTextStyler.h"

static const char STYLE_CHILDREN;
static NSDictionary *LABEL_PSEUDOCLASS_MAP;

@implementation STKPXUITableViewHeaderFooterView

+ (void) load
{
    if (self != STKPXUITableViewHeaderFooterView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"table-view-headerfooter-view"];
    
    LABEL_PSEUDOCLASS_MAP = @{
                              @"normal"      : @(UIControlStateNormal),
                              @"highlighted" : @(UIControlStateHighlighted),
                              };

}

#pragma mark - Children

- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak STKPXUITableViewHeaderFooterView *weakSelf = self;
        
        //
        // background-view
        //
        STKPXVirtualStyleableControl *backgroundView = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"background-view" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            
            if(context.usesColorOnly && [context.color isEqual:[UIColor clearColor]])
            {
                [weakSelf px_setBackgroundView: nil];
            }
            else
            {
                [weakSelf px_setBackgroundView: [[UIImageView alloc] initWithImage:context.backgroundImage]];
            }
        }];
        
        backgroundView.viewStylers = @[
                                       STKPXOpacityStyler.sharedInstance,
                                       STKPXShapeStyler.sharedInstance,
                                       STKPXFillStyler.sharedInstance,
                                       STKPXBorderStyler.sharedInstance,
                                       STKPXBoxShadowStyler.sharedInstance,
                                       ];
        
        //
        // textLabel
        //
        STKPXVirtualStyleableControl *textLabel = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"text-label" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            
            if (context.usesColorOnly)
            {
//                objc_setAssociatedObject(weakSelf, &TEXT_LABEL_BACKGROUND_SET, context.color, OBJC_ASSOCIATION_COPY_NONATOMIC);
                
                weakSelf.textLabel.backgroundColor = context.color;
            }
            else if (context.usesImage)
            {
                UIColor *color = [UIColor colorWithPatternImage:context.backgroundImage];
//                objc_setAssociatedObject(weakSelf, &TEXT_LABEL_BACKGROUND_SET, color, OBJC_ASSOCIATION_COPY_NONATOMIC);
                
                weakSelf.textLabel.backgroundColor = color;
            }
        }];
        
        textLabel.supportedPseudoClasses = LABEL_PSEUDOCLASS_MAP.allKeys;
        textLabel.defaultPseudoClass = @"normal";
        textLabel.layer = weakSelf.textLabel.layer;

        textLabel.viewStylers = @[
                                  
                                  STKPXTransformStyler.sharedInstance,
                                  STKPXLayoutStyler.sharedInstance,
                                  STKPXOpacityStyler.sharedInstance,
                                  
                                  STKPXShapeStyler.sharedInstance,
                                  STKPXFillStyler.sharedInstance,
                                  STKPXBorderStyler.sharedInstance,
                                  
                                  [[STKPXBoxShadowStyler alloc] initWithCompletionBlock:^(id control, STKPXBoxShadowStyler *styler, STKPXStylerContext *context) {
                                      STKPXShadowGroup *group = context.outerShadow;
                                      UILabel *view = weakSelf.textLabel;
                                      
                                      if (group.shadows.count > 0)
                                      {
                                          STKPXShadow *shadow = group.shadows[0];
                                          
                                          view.shadowColor = shadow.color;
                                          view.shadowOffset = CGSizeMake(shadow.horizontalOffset, shadow.verticalOffset);
                                      }
                                      else
                                      {
                                          view.shadowColor = [UIColor clearColor];
                                          view.shadowOffset = CGSizeZero;
                                      }
                                  }],
                                  
                                  [[STKPXFontStyler alloc] initWithCompletionBlock:^(id control, STKPXFontStyler *styler, STKPXStylerContext *context) {
                                      UILabel *view = weakSelf.textLabel;
                                      view.font = context.font;
                                  }],
                                  
                                  [[STKPXPaintStyler alloc] initWithCompletionBlock:^(id control, STKPXPaintStyler *styler, STKPXStylerContext *context) {
                                      UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                                      UILabel *view = weakSelf.textLabel;
                                      
                                      if(color)
                                      {
                                          if([context stateFromStateNameMap:LABEL_PSEUDOCLASS_MAP] == UIControlStateHighlighted)
                                          {
                                              view.highlightedTextColor = color;
                                          }
                                          else
                                          {
                                              view.textColor = color;
                                          }
                                      }
                                  }],
                                  
                                  [[STKPXTextContentStyler alloc] initWithCompletionBlock:^(id control, STKPXTextContentStyler *styler, STKPXStylerContext *context) {
                                      UILabel *view = weakSelf.textLabel;
                                      view.text = context.text;
                                  }],
                                  
                                  [[STKPXGenericStyler alloc] initWithHandlers: @{
                                                                               
                                   @"text-align" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                                      UILabel *view = weakSelf.textLabel;
                                      view.textAlignment = declaration.textAlignmentValue;
                                  },
                                   @"text-transform" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                                      UILabel *view = weakSelf.textLabel;
                                      view.text = [STKPXStylerContext transformString:view.text usingAttribute:declaration.stringValue];
                                  },
                                   @"text-overflow" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                                      UILabel *view = weakSelf.textLabel;
                                      view.lineBreakMode = declaration.lineBreakModeValue;
                                  }
                                                                               }],
                                  STKPXAnimationStyler.sharedInstance
                                  ];

        
        // attributed text
        STKPXVirtualStyleableControl *attributedTextLabel =
        [[STKPXVirtualStyleableControl alloc] initWithParent:self
                                              elementName:@"attributed-text-label"
                                    viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
                                        // nothing for now
                                    }];
        
        attributedTextLabel.supportedPseudoClasses = LABEL_PSEUDOCLASS_MAP.allKeys;
        attributedTextLabel.defaultPseudoClass = @"normal";
        
        attributedTextLabel.viewStylers = @[
            [[STKPXAttributedTextStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable> styleable, STKPXAttributedTextStyler *styler, STKPXStylerContext *context) {

                UILabel *view = weakSelf.textLabel;
                UIControlState state = ([context stateFromStateNameMap:LABEL_PSEUDOCLASS_MAP]);
                
                UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                if(color)
                {
                    if(state == UIControlStateHighlighted)
                    {
                        view.highlightedTextColor = color;
                    }
                    else
                    {
                        view.textColor = color;
                    }
                }
                
                NSString *text = view.attributedText ? view.attributedText.string : view.text;
                
                NSMutableDictionary *dict = [context attributedTextAttributes:view withDefaultText:text andColor:color];
                
                NSMutableAttributedString *attrString = nil;
                if(context.transformedText)
                {
                    attrString = [[NSMutableAttributedString alloc] initWithString:context.transformedText attributes:dict];
                }
                
                view.attributedText = attrString;
            }]
        ];
        
        
        
        NSArray *styleChildren = @[ backgroundView, textLabel ];
        
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

            [[STKPXOpacityStyler alloc] initWithCompletionBlock:^(id<STKPXStyleable>view, STKPXOpacityStyler *styler, STKPXStylerContext *context) {
                ((STKPXUITableViewHeaderFooterView *)view).px_contentView.alpha = context.opacity;
            }],

            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,

            STKPXAnimationStyler.sharedInstance,
            
            STKPXPaintStyler.sharedInstanceForTintColor,
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
        (self.px_contentView).backgroundColor = context.color;
    }
    else if (context.usesImage)
    {
        (self.px_contentView).backgroundColor = [UIColor colorWithPatternImage:[context backgroundImageWithBounds:self.px_contentView.bounds]];
    }
}

//
// Overrides
//

// Invalidate outselves for styling when we get reused otherwise, we may not get restyled.
- (void)prepareForReuse
{
    callSuper0(SUPER_PREFIX, @selector(prepareForReuse));
    [STKPXStyleUtils invalidateStyleableAndDescendants:self];
}

- (id)pxStyleParent
{
    UIView *parent = self.superview;
    
    while([parent isKindOfClass:[UITableView class]] == false)
    {
        if(parent == nil)
        {
            break;
        }
        parent = parent.superview;
    }
    
    return parent;
    
}

//
// Wrappers
//

STKPX_WRAP_PROP(UIView, contentView);
STKPX_WRAP_1(setBackgroundView, view);
STKPX_WRAP_1(setBackgroundColor, color);

@end
