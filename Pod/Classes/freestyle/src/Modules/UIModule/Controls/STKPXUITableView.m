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
//  STKPXUITableView.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUITableView.h"

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "STKPXVirtualStyleableControl.h"

#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXGenericStyler.h"
#import "STKPXAnimationStyler.h"

#import "STKPXProxy.h"
#import "STKPXUITableViewDelegate.h"
#import "NSObject+STKPXSwizzle.h"

// Optimization cached value
static Class uiPickerTableViewClass;

static const char STKPX_DELEGATE; // the new delegate (and datasource)
static const char STKPX_DELEGATE_PROXY; // the proxy for the old delegate
//static const char STKPX_DATASOURCE_PROXY; // the proxy for the old datasource

@implementation UITableView (STKPXFreestyle)

+ (void) load
{
    if (self != UITableView.class)
        return;
    
    [self swizzleMethod:@selector(setDelegate:) withMethod:@selector(STKPX_setDelegate:)];
    
    // Cache this value
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uiPickerTableViewClass = NSClassFromString(@"UIPickerTableView");
    });
}

-(void)px_setDelegate:(id<UITableViewDelegate>)delegate
{
    // Do not delegate tables embedded in a UIPickerTableView
    if(delegate
       && ([self class] == uiPickerTableViewClass) == NO
       )
    {
        id delegateProxy = [self pxDelegateProxy];
        if ([delegateProxy baseObject])
            [self px_setDelegate:nil];
        [delegateProxy setBaseObject:delegate];
        [self px_setDelegate:delegateProxy];
    }
    else
    {
        [self px_setDelegate:delegate];
    }
}

- (id)pxDelegate
{
    id delegate = objc_getAssociatedObject(self, &STKPX_DELEGATE);
    
    if(delegate == nil)
    {
        delegate = [[STKPXUITableViewDelegate alloc] init];
        objc_setAssociatedObject(self, &STKPX_DELEGATE, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return delegate;
}

- (id)pxDelegateProxy
{
    id proxy = objc_getAssociatedObject(self, &STKPX_DELEGATE_PROXY);
    
    if(proxy == nil)
    {
        proxy = [[STKPXProxy alloc] initWithBaseOject:nil overridingObject:[self pxDelegate]];
        objc_setAssociatedObject(self, &STKPX_DELEGATE_PROXY, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return proxy;
}

/* Don't use right now
 -(void)setDataSource:(id<UITableViewDataSource>)dataSource
 {
 if(dataSource)
 {
 NSLog(@"%@\n%@", dataSource, [NSThread callStackSymbols]);
 }
 
 id datasourceProxy = [self pxDatasourceProxy];
 [datasourceProxy setBaseObject:dataSource];
 callSuper1(SUPER_PREFIX, @selector(setDataSource:), datasourceProxy);
 }
 */


/*
 - (id)pxDatasourceProxy
 {
 id proxy = objc_getAssociatedObject(self, &STKPX_DATASOURCE_PROXY);
 
 if(proxy == nil)
 {
 proxy = [[STKPXProxy alloc] initWithBaseOject:nil overridingObject:[self pxDelegate]];
 objc_setAssociatedObject(self, &STKPX_DATASOURCE_PROXY, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
 }
 
 return proxy;
 }
 */

@end


@implementation STKPXUITableView

+ (void) load
{
    if (self != STKPXUITableView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"table-view"];
}

#pragma mark - Styler stuff

-(NSArray *)viewStylers
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

            [[STKPXGenericStyler alloc] initWithHandlers: @{
                                                         
             @"selection-mode" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITableView *view = (STKPXUITableView *)context.styleable;
                
                NSString *mode = (declaration.stringValue).lowercaseString;
                
                if([mode isEqualToString:@"single"])
                {
                    view.allowsMultipleSelection = NO;
                }
                else if([mode isEqualToString:@"multiple"])
                {
                    view.allowsMultipleSelection = YES;
                }
             },
             @"selection-mode-during-editing" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITableView *view = (STKPXUITableView *)context.styleable;
                
                NSString *mode = (declaration.stringValue).lowercaseString;
                
                if([mode isEqualToString:@"single"])
                {
                    view.allowsMultipleSelectionDuringEditing = NO;
                }
                else if([mode isEqualToString:@"multiple"])
                {
                    view.allowsMultipleSelectionDuringEditing = YES;
                }
             },
             @"row-height" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITableView *view = (STKPXUITableView *)context.styleable;

                view.rowHeight = declaration.floatValue;
             },
             @"header-height" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITableView *view = (STKPXUITableView *)context.styleable;
                
                view.sectionHeaderHeight = declaration.floatValue;
             },
             @"footer-height" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITableView *view = (STKPXUITableView *)context.styleable;
                
                view.sectionFooterHeight = declaration.floatValue;
             },
             @"separator-color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITableView *view = (STKPXUITableView *)context.styleable;
                
                [view px_setSeparatorColor: declaration.colorValue];
            },
             @"separator-style" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITableView *view = (STKPXUITableView *)context.styleable;
                NSString *style = (declaration.stringValue).lowercaseString;

                if ([style isEqualToString:@"none"])
                {
                    [view px_setSeparatorStyle: UITableViewCellSeparatorStyleNone];
                }
                else if ([style isEqualToString:@"single-line"])
                {
                    [view px_setSeparatorStyle: UITableViewCellSeparatorStyleSingleLine];
                }
                else if ([style isEqualToString:@"etched-line"])
                {
                    [view px_setSeparatorStyle: UITableViewCellSeparatorStyleSingleLineEtched];
                }
            },
             @"content-offset" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITableView *view = (STKPXUITableView *)context.styleable;
                CGSize point = declaration.sizeValue;
                
                [view px_setContentOffset: CGPointMake(point.width, point.height)];
            },
             @"content-size" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITableView *view = (STKPXUITableView *)context.styleable;
                CGSize size = declaration.sizeValue;
                
                [view px_setContentSize: size];
            },
             @"content-inset" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                STKPXUITableView *view = (STKPXUITableView *)context.styleable;
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
    if (context.usesColorOnly)
    {
        [self px_setBackgroundView: nil];
        [self px_setBackgroundColor: context.color];
    }
    else if (context.usesImage)
    {
        [self px_setBackgroundColor: [UIColor clearColor]];
        //[self px_setBackgroundColor: [UIColor colorWithPatternImage:context.backgroundImage]];
        [self px_setBackgroundView: [[UIImageView alloc] initWithImage:context.backgroundImage]];
    }
}

- (BOOL)preventStyling
{
    // We won't style this kind of table
    return ([self class] == uiPickerTableViewClass);
}

#pragma mark - Overrides

// None

#pragma mark - Wrappers

//
// Wrappers
//

STKPX_WRAP_1(setBackgroundColor, color);
STKPX_WRAP_1(setBackgroundView, view);
STKPX_WRAP_1(setSeparatorColor, color);
STKPX_WRAP_1v(setSeparatorStyle, UITableViewCellSeparatorStyle, style);

STKPX_WRAP_1s(setContentSize,   CGSize,       size);
STKPX_WRAP_1s(setContentOffset, CGPoint,      size);
STKPX_WRAP_1s(setContentInset,  UIEdgeInsets, insets);

STKPX_LAYOUT_SUBVIEWS_OVERRIDE_RECURSIVE

@end
