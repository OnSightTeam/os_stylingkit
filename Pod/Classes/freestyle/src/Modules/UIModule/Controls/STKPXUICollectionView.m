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
//  STKPXUICollectionView.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXUICollectionView.h"
#import <QuartzCore/QuartzCore.h>

#import "UIView+STKPXStyling.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXStylingMacros.h"
#import "STKPXOpacityStyler.h"
#import "STKPXLayoutStyler.h"
#import "STKPXTransformStyler.h"
#import "STKPXVirtualStyleableControl.h"
#import "STKPXStyleUtils.h"

#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXAnimationStyler.h"
#import "STKPXGenericStyler.h"

#import "STKPXProxy.h"
#import "NSObject+STKPXSubclass.h"
#import "STKPXUICollectionViewDelegate.h"
#import "NSObject+STKPXSwizzle.h"

static const char STKPX_DELEGATE; // the new delegate (and datasource)
static const char STKPX_DELEGATE_PROXY; // the proxy for the old delegate
static const char STKPX_DATASOURCE_PROXY; // the proxy for the old datasource

@implementation UICollectionView (STKPXFreestyle)

+ (void) load
{
    if (self != UICollectionView.class)
        return;
    
    [self swizzleMethod:@selector(setDelegate:) withMethod:@selector(STKPX_setDelegate:)];
    [self swizzleMethod:@selector(setDataSource:) withMethod:@selector(STKPX_setDataSource:)];
}

-(void)px_setDelegate:(id<UICollectionViewDelegate>)delegate
{
    id proxy = [self stk_makeProxyFor:delegate withAssocObjectAddress:&STKPX_DELEGATE_PROXY];
    [self px_setDelegate:proxy];
}

-(void)px_setDataSource:(id<UICollectionViewDataSource>)dataSource
{
    id proxy = [self stk_makeProxyFor:dataSource withAssocObjectAddress:&STKPX_DATASOURCE_PROXY];
    [self px_setDataSource:proxy];
}

#pragma mark - Delegate and DataSource proxy methods

- (id <UICollectionViewDataSource>)stk_makeProxyFor:(id)dataSource withAssocObjectAddress:(const void *)variableAddress
{
    id proxy = dataSource ? [[STKPXProxy alloc] initWithBaseOject:dataSource overridingObject:[self pxDelegate]] : nil;
    if (proxy)
    {
        objc_setAssociatedObject(self, variableAddress, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return proxy;
}

- (STKPXUICollectionViewDelegate *)pxDelegate
{
    STKPXUICollectionViewDelegate *delegate = objc_getAssociatedObject(self, &STKPX_DELEGATE);

    if(delegate == nil)
    {
        delegate = [[STKPXUICollectionViewDelegate alloc] init];
        delegate.collectionView = self;
        objc_setAssociatedObject(self, &STKPX_DELEGATE, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return delegate;
}

@end

//
// STKPXUICollectionView
//

@implementation STKPXUICollectionView

#pragma mark - Static load

+ (void) load
{
    if (self != STKPXUICollectionView.class)
        return;
    
    [UIView registerDynamicSubclass:self withElementName:@"collection-view"];
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

            STKPXAnimationStyler.sharedInstance,
            
            [[STKPXGenericStyler alloc] initWithHandlers: @{
                @"cell-size" :  ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                    CGSize size = declaration.sizeValue;
                    STKPXUICollectionViewDelegate *delegate = [self pxDelegate];
                    delegate.itemSize.size = size;
                },
             
                @"cell-width" :  ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                    CGFloat width = declaration.floatValue;
                    STKPXUICollectionViewDelegate *delegate = [self pxDelegate];
                    delegate.itemSize.size = CGSizeMake(width, delegate.itemSize.size.height);
                },
                
                @"cell-height" :  ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                    CGFloat height = declaration.floatValue;
                    STKPXUICollectionViewDelegate *delegate = [self pxDelegate];
                    delegate.itemSize.size = CGSizeMake(delegate.itemSize.size.width, height);
                },
                
                @"selection-mode" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                    STKPXUICollectionView *view = (STKPXUICollectionView *)context.styleable;
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
            }]
            
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

#pragma mark - Update Styles

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


#pragma mark - Overrides

// None

#pragma mark - Wrappers

// Px Wrapped Only
STKPX_PXWRAP_PROP(CALayer, layer);

// Ti Wrapped
STKPX_WRAP_PROP(UIView, backgroundView);

STKPX_WRAP_1(setBackgroundColor, color);
STKPX_WRAP_1(setBackgroundView, view);

STKPX_LAYOUT_SUBVIEWS_OVERRIDE_RECURSIVE

@end
