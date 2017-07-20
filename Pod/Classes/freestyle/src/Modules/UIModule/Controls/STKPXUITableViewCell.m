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
//  PXUITableViewCell.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUITableViewCell.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+PXStyling.h"
#import "UIView+PXStyling-Private.h"
#import "PXStylingMacros.h"
#import "STKPXOpacityStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXVirtualStyleableControl.h"
#import "STKPXStyleUtils.h"
#import "STKPXRuntimeUtils.h"
#import "STKPXClassUtils.h"
#import "STKPXUtils.h"

#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXAnimationStyler.h"

#import "STKPXFontStyler.h"
#import "STKPXPaintStyler.h"
#import "STKPXDeclaration.h"
#import "STKPXRuleSet.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXTextContentStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXAttributedTextStyler.h"


#import "NSObject+PXSubclass.h"
#import "STKPXUILabel.h"

static NSDictionary *PSEUDOCLASS_MAP;
static NSDictionary *LABEL_PSEUDOCLASS_MAP;
static const char STYLE_CHILDREN;
static const NSUInteger UIControlStateMultiple = 1 << 15;
static const char CELL_BACKGROUND_SET;

static const char TEXT_LABEL_BACKGROUND_SET;
static const char DETAIL_TEXT_LABEL_BACKGROUND_SET;

@interface PXUIImageViewWrapper_UITableViewCell : UIImageView @end
@implementation PXUIImageViewWrapper_UITableViewCell @end

@implementation STKPXUITableViewCell

+ (void)initialize
{
    if (self != STKPXUITableViewCell.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"table-view-cell"];
    
    PSEUDOCLASS_MAP = @{
        @"normal"   : @(UIControlStateNormal),
        @"selected" : @(UIControlStateSelected),
        @"multiple" : @(UIControlStateMultiple),
    };
    
    LABEL_PSEUDOCLASS_MAP = @{
           @"normal"      : @(UIControlStateNormal),
           @"highlighted" : @(UIControlStateHighlighted),
           };

}

#pragma mark - Children

- (NSArray *)pxStyleChildren
{
    NSArray *styleChildren;
    STKPXVirtualStyleableControl *contentView;
    STKPXVirtualStyleableControl *textLabel;
    STKPXVirtualStyleableControl *detailTextLabel;
    
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        __weak STKPXUITableViewCell *weakSelf = self;

        //
        // content-view
        //
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

        
        //
        // textLabel
        //
        textLabel = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"text-label" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            
            if (context.usesColorOnly)
            {
                if ([STKPXUtils isIOS7OrGreater] == NO)
                {
                    objc_setAssociatedObject(weakSelf, &TEXT_LABEL_BACKGROUND_SET, context.color, OBJC_ASSOCIATION_COPY_NONATOMIC);
                }
                
                weakSelf.textLabel.backgroundColor = context.color;
            }
            else if (context.usesImage)
            {
                UIColor *color = [UIColor colorWithPatternImage:context.backgroundImage];
                
                if ([STKPXUtils isIOS7OrGreater] == NO)
                {
                    objc_setAssociatedObject(weakSelf, &TEXT_LABEL_BACKGROUND_SET, color, OBJC_ASSOCIATION_COPY_NONATOMIC);
                }
                
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
                  view.text = [declaration transformString:view.text];
              },
               @"text-overflow" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                  UILabel *view = weakSelf.textLabel;
                  view.lineBreakMode = declaration.lineBreakModeValue;
              }
               }],
              STKPXAnimationStyler.sharedInstance
        ];


        //
        // detailTextLabel
        //
        detailTextLabel = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"detail-text-label" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            
            if (context.usesColorOnly)
            {
                
                if ([STKPXUtils isIOS7OrGreater] == NO)
                {
                    objc_setAssociatedObject(weakSelf, &DETAIL_TEXT_LABEL_BACKGROUND_SET, context.color, OBJC_ASSOCIATION_COPY_NONATOMIC);
                }
                
                weakSelf.detailTextLabel.backgroundColor = context.color;

            }
            else if (context.usesImage)
            {
                UIColor *color = [UIColor colorWithPatternImage:context.backgroundImage];
                
                if ([STKPXUtils isIOS7OrGreater] == NO)
                {
                    objc_setAssociatedObject(weakSelf, &DETAIL_TEXT_LABEL_BACKGROUND_SET, color, OBJC_ASSOCIATION_COPY_NONATOMIC);
                }
                weakSelf.detailTextLabel.backgroundColor = color;
            }
        }];

        detailTextLabel.supportedPseudoClasses = LABEL_PSEUDOCLASS_MAP.allKeys;
        detailTextLabel.defaultPseudoClass = @"normal";
        detailTextLabel.layer = weakSelf.detailTextLabel.layer;

        detailTextLabel.viewStylers = @[
                                  
              STKPXTransformStyler.sharedInstance,
              STKPXLayoutStyler.sharedInstance,
              STKPXOpacityStyler.sharedInstance,
              
              STKPXShapeStyler.sharedInstance,
              STKPXFillStyler.sharedInstance,
              STKPXBorderStyler.sharedInstance,
              
              [[STKPXBoxShadowStyler alloc] initWithCompletionBlock:^(id control, STKPXBoxShadowStyler *styler, STKPXStylerContext *context) {
                  STKPXShadowGroup *group = context.outerShadow;
                  UILabel *view = weakSelf.detailTextLabel;
                  
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
                  UILabel *view = weakSelf.detailTextLabel;
                  view.font = context.font;
              }],
              
              [[STKPXPaintStyler alloc] initWithCompletionBlock:^(id control, STKPXPaintStyler *styler, STKPXStylerContext *context) {
                  UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
                  UILabel *view = weakSelf.detailTextLabel;
                  
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
                  UILabel *view = weakSelf.detailTextLabel;
                  view.text = context.text;
              }],
              
              [[STKPXGenericStyler alloc] initWithHandlers: @{
               
               @"text-align" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                  UILabel *view = weakSelf.detailTextLabel;
                  view.textAlignment = declaration.textAlignmentValue;
              },
               @"text-transform" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                  UILabel *view = weakSelf.detailTextLabel;
                  view.text = [declaration transformString:view.text];
              },
               @"text-overflow" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                  UILabel *view = weakSelf.detailTextLabel;
                  view.lineBreakMode = declaration.lineBreakModeValue;
              }
               }],
              STKPXAnimationStyler.sharedInstance
        ];
        
        
        // attributed text
        
        STKPXVirtualStyleableControl *attributedTextLabel =
        [[STKPXVirtualStyleableControl alloc] initWithParent:textLabel
                                              elementName:@"attributed-text"
                                    viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
                                        // nothing for now
                                    }];
        
        attributedTextLabel.defaultPseudoClass = @"normal";
        attributedTextLabel.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;
        
        attributedTextLabel.viewStylers = @[
            [[STKPXAttributedTextStyler alloc] initWithCompletionBlock:^(STKPXVirtualStyleableControl *styleable, STKPXAttributedTextStyler *styler, STKPXStylerContext *context) {
                
                UILabel *view = weakSelf.textLabel;
                UIControlState state = ([context stateFromStateNameMap:PSEUDOCLASS_MAP]);
                
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
        
        
        // attributed detail text
        STKPXVirtualStyleableControl *attributedDetailTextLabel =
        [[STKPXVirtualStyleableControl alloc] initWithParent:detailTextLabel
                                              elementName:@"attributed-text"
                                    viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
                                        // nothing for now
                                    }];
        
        attributedDetailTextLabel.defaultPseudoClass = @"normal";
        attributedDetailTextLabel.supportedPseudoClasses = PSEUDOCLASS_MAP.allKeys;
        
        attributedDetailTextLabel.viewStylers = @[
            [[STKPXAttributedTextStyler alloc] initWithCompletionBlock:^(STKPXVirtualStyleableControl *styleable, STKPXAttributedTextStyler *styler, STKPXStylerContext *context) {
                
                UILabel *view = weakSelf.detailTextLabel;
                UIControlState state = ([context stateFromStateNameMap:PSEUDOCLASS_MAP]);
                
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
        
        textLabel.pxStyleChildren = @[attributedTextLabel];
        detailTextLabel.pxStyleChildren = @[attributedDetailTextLabel];

        // contentView should remain the first child
        styleChildren = @[ contentView, textLabel, detailTextLabel ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    else
    {
        styleChildren = objc_getAssociatedObject(self, &STYLE_CHILDREN);
        if(styleChildren)
        {
            for (STKPXVirtualStyleableControl *item in styleChildren) {
                if([item.pxStyleElementName isEqualToString:@"content-view"])
                {
                    contentView = item;
                    break;
                }
            }
        }
    }
    
    // Add any contentView subviews
    contentView.pxStyleChildren = self.contentView.subviews;

    // Add any subviews and return the child list
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
            
            [[STKPXOpacityStyler alloc] initWithCompletionBlock:^(STKPXUITableViewCell *view, STKPXOpacityStyler *styler, STKPXStylerContext *context) {
                view.px_contentView.alpha = context.opacity;
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
//    NSLog(@"updateStyleWithRuleSet %@", self);
    
//    NSLog(@"%f,%f %f,%f", self.bounds.size.width, self.bounds.size.height,
//          self.contentView.bounds.size.width,self.contentView.bounds.size.height);

    // For grouped table cells, we need to use contentView's bounds, not the cell's bounds
    UITableView *parent = self.pxStyleParent; //(UITableView *) self.superview;
    if([parent isKindOfClass:[UITableView class]] && parent.style == UITableViewStyleGrouped)
    {
        context.bounds = self.px_contentView.bounds;
    }
    
    if ([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateNormal)
    {
        if(context.usesColorOnly)
        {
            if([context.color isEqual:[UIColor clearColor]])
            {
                [self px_setBackgroundView: nil];
                [self px_setBackgroundColor: [UIColor clearColor]];
                if ([STKPXUtils isIOS7OrGreater] == NO)
                {
                    objc_setAssociatedObject(self, &CELL_BACKGROUND_SET, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
                }
            }
            else
            {
                [self px_setBackgroundColor: context.color];
                if ([STKPXUtils isIOS7OrGreater] == NO)
                {
                    objc_setAssociatedObject(self, &CELL_BACKGROUND_SET, context.color, OBJC_ASSOCIATION_COPY_NONATOMIC);
                }
            }
        }
        else if(context.usesImage)
        {
            [self px_setBackgroundColor: [UIColor clearColor]];
            
            if([self.px_backgroundView isKindOfClass:[PXUIImageViewWrapper_UITableViewCell class]] == NO)
            {
                [self px_setBackgroundView: [[PXUIImageViewWrapper_UITableViewCell alloc] initWithImage:context.backgroundImage]];

                if([parent isKindOfClass:[UITableView class]] && parent.style == UITableViewStyleGrouped)
                {
                    // This _shouldn't_ cause a recursive loop as we only ever do it on first
                    // creation of the PXViewWrapper for the background view. Subsequent stylings
                    // should use the cached version and therefore not reach this call.
                    [self setNeedsLayout];
                }
            }
            else
            {
                PXUIImageViewWrapper_UITableViewCell *view = (PXUIImageViewWrapper_UITableViewCell *) self.backgroundView;
                view.image = context.backgroundImage;
            }
            
            if ([STKPXUtils isIOS7OrGreater] == NO)
            {
                objc_setAssociatedObject(self, &CELL_BACKGROUND_SET, [UIColor clearColor], OBJC_ASSOCIATION_COPY_NONATOMIC);
            }

        }
    }
    else if ([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateSelected)
    {
        if(context.usesColorOnly && [context.color isEqual:[UIColor clearColor]])
        {
            [self px_setSelectedBackgroundView: nil];
        }
        else
        {
            if([self.px_selectedBackgroundView isKindOfClass:[PXUIImageViewWrapper_UITableViewCell class]] == NO)
            {
                [self px_setSelectedBackgroundView: [[PXUIImageViewWrapper_UITableViewCell alloc] initWithImage:context.backgroundImage]];
            }
            else
            {
                PXUIImageViewWrapper_UITableViewCell *view = (PXUIImageViewWrapper_UITableViewCell *) self.px_selectedBackgroundView;
                view.image = context.backgroundImage;
            }
        }
    }
    else if ([context stateFromStateNameMap:PSEUDOCLASS_MAP] == UIControlStateMultiple)
    {
        if(context.usesColorOnly && [context.color isEqual:[UIColor clearColor]])
        {
            [self px_setMultipleSelectionBackgroundView: nil];
        }
        else
        {
            if([self.px_multipleSelectionBackgroundView isKindOfClass:[PXUIImageViewWrapper_UITableViewCell class]] == NO)
            {
                [self px_setMultipleSelectionBackgroundView: [[UIImageView alloc] initWithImage:context.backgroundImage]];
            }
            else
            {
                PXUIImageViewWrapper_UITableViewCell *view = (PXUIImageViewWrapper_UITableViewCell *) self.px_multipleSelectionBackgroundView;
                view.image = context.backgroundImage;
            }
        }
    }
    
}

//
// Overrides
//

- (void)prepareForReuse
{
    callSuper0(SUPER_PREFIX, @selector(prepareForReuse));
    [STKPXStyleUtils invalidateStyleableAndDescendants:self];
}

//
// Weappers
//

PX_WRAP_PROP(UIView, contentView);
PX_WRAP_PROP(UIView, backgroundView);
PX_WRAP_PROP(UIView, selectedBackgroundView);
PX_WRAP_PROP(UIView, multipleSelectionBackgroundView);

PX_WRAP_1(setBackgroundColor, color);
PX_WRAP_1(setBackgroundView, view);
PX_WRAP_1(setSelectedBackgroundView, view);
PX_WRAP_1(setMultipleSelectionBackgroundView, view);


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

@end
