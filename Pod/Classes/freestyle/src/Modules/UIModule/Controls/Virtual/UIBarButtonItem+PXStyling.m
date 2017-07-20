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
//  UIBarButtonItem+PXStyling.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 12/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "UIBarButtonItem+PXStyling.h"
#import <objc/runtime.h>
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXTextContentStyler.h"
#import "PXStylingMacros.h"
#import "STKPXStyleUtils.h"
#import "STKPXShapeStyler.h"
#import "STKPXLayoutStyler.h"

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
#import "STKPXAttributedTextStyler.h"

#import "STKPXUtils.h"
#import "STKPXVirtualStyleableControl.h"

#import "UIBarItem+PXStyling.h"

static const char STYLE_CHILDREN;
static NSDictionary *BUTTONS_PSEUDOCLASS_MAP;

void PXForceLoadUIBarButtonItemPXStyling() {}

@implementation UIBarButtonItem (PXStyling)

@dynamic isVirtualControl;
@dynamic pxStyleParent;

+ (void)initialize
{
    if (self != UIBarButtonItem.class)
        return;
    
    BUTTONS_PSEUDOCLASS_MAP = @{
                                @"normal"      : @(UIControlStateNormal),
                                @"highlighted" : @(UIControlStateHighlighted),
                                @"disabled"    : @(UIControlStateDisabled)
                                };
    
}

- (NSString *)pxStyleElementName
{
    return self.styleElementName == nil ? @"bar-button-item" : self.styleElementName;
}

- (void)setPxStyleElementName:(NSString *)pxStyleElementName
{
    self.styleElementName = pxStyleElementName;
}
- (NSArray *)supportedPseudoClasses
{
    return BUTTONS_PSEUDOCLASS_MAP.allKeys;
}
    
- (NSString *)defaultPseudoClass
{
    return @"normal";
}
    
- (NSArray *)pxStyleChildren
{
    if (!objc_getAssociatedObject(self, &STYLE_CHILDREN))
    {
        // Weak ref to self
        __weak UIBarButtonItem *weakSelf = self;
        
        //
        // Child controls
        //
        
        // icon
        
        STKPXVirtualStyleableControl *icon = [[STKPXVirtualStyleableControl alloc] initWithParent:self elementName:@"icon" viewStyleUpdaterBlock:^(STKPXRuleSet *ruleSet, STKPXStylerContext *context) {
            
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
            
            weakSelf.image = image;
        }];

        icon.viewStylers = @[
            STKPXOpacityStyler.sharedInstance,
            STKPXShapeStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,
            STKPXAnimationStyler.sharedInstance,

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
                }
               }],
            ];
                
                
        
        //
        // all the children
        //
        
        NSArray *styleChildren = @[ icon ];
        
        objc_setAssociatedObject(self, &STYLE_CHILDREN, styleChildren, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    NSArray *styleChildren = objc_getAssociatedObject(self, &STYLE_CHILDREN);
    
    return styleChildren;
}


- (NSArray *)viewStylers
{
    static __strong NSArray *stylers = nil;
	static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        stylers = @[
            STKPXOpacityStyler.sharedInstance,
            STKPXFillStyler.sharedInstance,
            STKPXBorderStyler.sharedInstance,
            STKPXShapeStyler.sharedInstance,
            STKPXBoxShadowStyler.sharedInstance,

            [[STKPXAttributedTextStyler alloc] initWithCompletionBlock:^(UIBarButtonItem *view, STKPXAttributedTextStyler *styler, STKPXStylerContext *context) {
                
                UIControlState state = ([context stateFromStateNameMap:BUTTONS_PSEUDOCLASS_MAP]) ? [context stateFromStateNameMap:BUTTONS_PSEUDOCLASS_MAP] : UIControlStateNormal;
                
                NSDictionary *attribs = [view titleTextAttributesForState:state];
                
                NSDictionary *mergedAttribs = [context mergeTextAttributes:attribs];
                
                [view setTitleTextAttributes:mergedAttribs
                                    forState:state];
            }],
            
            [[STKPXTextContentStyler alloc] initWithCompletionBlock:^(UIBarButtonItem *view, STKPXTextContentStyler *styler, STKPXStylerContext *context) {
                view.title = context.text;
            }],
            

            [[STKPXGenericStyler alloc] initWithHandlers: @{
                @"-ios-tint-color" : [UIBarButtonItem TintColorDeclarationHandlerBlock:nil]
            }],
        ];
    });

	return stylers;
}

- (void)updateStyleWithRuleSet:(STKPXRuleSet *)ruleSet context:(STKPXStylerContext *)context
{
    [UIBarButtonItem UpdateStyleWithRuleSetHandler:ruleSet context:context target:self];
}
    
//
// Shared handlers and styler blocks to more easily support appearance api
//

+ (void) UpdateStyleWithRuleSetHandler:(STKPXRuleSet *)ruleSet context:(STKPXStylerContext *)context target:(UIBarButtonItem *)target
{
    if([STKPXUtils isBeforeIOS7O])
    {
        if (context.usesColorOnly)
        {
            target.tintColor = context.color;
            return;
        }
    }
    
    if(context.usesImage && context.backgroundImage)
    {
        [target setBackgroundImage:context.backgroundImage
                        forState:[context stateFromStateNameMap:BUTTONS_PSEUDOCLASS_MAP]
                      barMetrics:UIBarMetricsDefault];
    }
}
    
+ (PXDeclarationHandlerBlock) TintColorDeclarationHandlerBlock:(UIBarButtonItem *)target
{
    return ^(STKPXDeclaration *declaration, STKPXStylerContext *context)
    {
        UIBarButtonItem *view = (target == nil ? (UIBarButtonItem *)context.styleable : target);
        view.tintColor = declaration.colorValue;
    };
}
    
+ (PXStylerCompletionBlock) FontStylerCompletionBlock:(UIBarButtonItem *)target
{
    return ^(UIBarButtonItem *styleable, STKPXOpacityStyler *styler, STKPXStylerContext *context)
    {
        NSDictionary *attributes = [context propertyValueForName:[NSString stringWithFormat:@"textAttributes-%@", context.activeStateName]];
        NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        currentTextAttributes[NSFontAttributeName] = context.font;
        [context setPropertyValue:currentTextAttributes forName:[NSString stringWithFormat:@"textAttributes-%@", context.activeStateName]];
        
        [(target == nil ? styleable : target) setTitleTextAttributes:currentTextAttributes
                                 forState:[context stateFromStateNameMap:BUTTONS_PSEUDOCLASS_MAP]];
    };
}
    
+ (PXStylerCompletionBlock) PXPaintStylerCompletionBlock:(UIBarButtonItem *)target
{
    return ^(UIBarButtonItem *styleable, STKPXOpacityStyler *styler, STKPXStylerContext *context)
    {
        
        NSDictionary *attributes = [context propertyValueForName:[NSString stringWithFormat:@"textAttributes-%@", context.activeStateName]];
        NSMutableDictionary *currentTextAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        UIColor *color = (UIColor *)[context propertyValueForName:@"color"];
        if(color)
        {
            currentTextAttributes[NSForegroundColorAttributeName] = color;
            [context setPropertyValue:currentTextAttributes forName:[NSString stringWithFormat:@"textAttributes-%@", context.activeStateName]];
            [(target == nil ? styleable : target) setTitleTextAttributes:currentTextAttributes
                                     forState:[context stateFromStateNameMap:BUTTONS_PSEUDOCLASS_MAP]];
        }
    };
}



@end
