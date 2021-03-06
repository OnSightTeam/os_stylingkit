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
//  STKPXTypeSelector.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 7/9/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXTypeSelector.h"
#import "STKPXPseudoClassSelector.h"
#import "STKPXStyleUtils.h"
#import "STKPXIdSelector.h"
#import "STKPXClassSelector.h"

@implementation STKPXTypeSelector
{
    NSMutableArray *attributeExpressions;
}

STK_DEFINE_CLASS_LOG_LEVEL

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithNamespaceURI:@"*" typeName:@"*"];
}

- (instancetype)initWithTypeName:(NSString *)type
{
    return [self initWithNamespaceURI:@"*" typeName:type];
}

- (instancetype)initWithNamespaceURI:(NSString *)uri typeName:(NSString *)type
{
    if (self = [super init])
    {
        _namespaceURI = uri;
        _typeName = type;
    }

    return self;
}

#pragma mark - Getters

- (BOOL)hasUniversalNamespace
{
    return [@"*" isEqualToString:_namespaceURI];
}

- (BOOL)hasUniversalType
{
    return [@"*" isEqualToString:_typeName];
}

- (NSArray *)attributeExpressions
{
    return attributeExpressions;
}

- (BOOL)hasPseudoClasses
{
    BOOL result = NO;

    for (id selector in attributeExpressions)
    {
        if ([selector isKindOfClass:[STKPXPseudoClassSelector class]])
        {
            result = YES;
            break;
        }
    }

    return result;
}

- (NSString *)styleId
{
    NSString *result = nil;

    for (id<STKPXSelector> expression in attributeExpressions)
    {
        if ([expression isKindOfClass:[STKPXIdSelector class]])
        {
            STKPXIdSelector *idSelector = (STKPXIdSelector *)expression;
            result = idSelector.idValue;
            break;
        }
    }

    return result;
}

- (NSSet *)styleClasses
{
    NSMutableSet *result = nil;

    for (id<STKPXSelector> expression in attributeExpressions)
    {
        if ([expression isKindOfClass:[STKPXClassSelector class]])
        {
            STKPXClassSelector *classSelector = (STKPXClassSelector *)expression;

            if (result == nil)
            {
                result = [NSMutableSet setWithCapacity:attributeExpressions.count];
            }

            [result addObject:classSelector.className];
        }
    }

    return (result != nil) ? result : nil;
}

#pragma mark - Methods

- (void)addAttributeExpression:(id<STKPXSelector>)expression
{
    if (expression)
    {
        if (!attributeExpressions)
        {
            attributeExpressions = [NSMutableArray array];
        }

        [attributeExpressions addObject:expression];
    }
}

- (void)incrementSpecificity:(STKPXSpecificity *)specificity
{
    if (!self.hasUniversalType)
    {
        [specificity incrementSpecifity:kSpecificityTypeElement];
    }

    if (self.pseudoElement.length > 0)
    {
        [specificity incrementSpecifity:kSpecificityTypeElement];
    }

    for (STKPXIdSelector *expr in attributeExpressions)
    {
        [expr incrementSpecificity:specificity];
    }
}

- (BOOL)matches:(id<STKPXStyleable>)element
{
    BOOL result = NO;

    // filter by namespace
    if (self.hasUniversalNamespace)
    {
        result = YES;
    }
    else
    {
        if ([element respondsToSelector:@selector(STKPXStyleNamespace)])
        {
            NSString *elementNamespace = element.pxStyleNamespace;

            if (_namespaceURI == nil)
            {
                // there should be namespace on the element
                result = (elementNamespace.length == 0);
            }
            else
            {
                // the URIs should match
                result = [_namespaceURI isEqualToString:element.pxStyleNamespace];
            }
        }
    }

    // filter by type name
    if (result)
    {
        if (!self.hasUniversalType)
        {
            result = ([_typeName isEqualToString:element.pxStyleElementName]);
        }
    }

    // filter by attribute expresssion
    if (result)
    {
        for (id<STKPXSelector> expression in attributeExpressions)
        {
            if (![expression matches:element])
            {
                result = NO;
                break;
            }
        }
    }

    // filter by pseudo-element
    if (result)
    {
        if (self.pseudoElement.length > 0)
        {
            if ([element respondsToSelector:@selector(supportedPseudoElements)])
            {
                result = ([element.supportedPseudoElements indexOfObject:self.pseudoElement] != NSNotFound);
            }
            else
            {
                result = NO;
            }
        }
    }

    if (result)
    {
        DDLogVerbose(@"%@ matched %@", self.description, [STKPXStyleUtils descriptionForStyleable:element]);
    }
    else
    {
        DDLogVerbose(@"%@ did not match %@", self.description, [STKPXStyleUtils descriptionForStyleable:element]);
    }

    return result;
}

- (BOOL)hasPseudoClass:(NSString *)className
{
    BOOL result = NO;

    for (id<STKPXSelector> selector in attributeExpressions)
    {
        if ([selector isKindOfClass:[STKPXPseudoClassSelector class]])
        {
            STKPXPseudoClassSelector *pseudoClass = selector;

            if ([pseudoClass.className isEqualToString:className])
            {
                result = YES;
                break;
            }
        }
    }

    return result;
}

#pragma mark - STKPXSourceEmitter Methods

- (NSString *)source
{
    STKPXSourceWriter *writer = [[STKPXSourceWriter alloc] init];

    [self sourceWithSourceWriter:writer];

    return writer.description;
}

- (void)sourceWithSourceWriter:(id)writer
{
    // TODO: support namespace
    [writer printIndent];
    [writer print:@"("];

    if (self.hasUniversalType)
    {
        [writer print:@"*"];
    }
    else
    {
        [writer print:self.typeName];
    }

    if (attributeExpressions.count > 0)
    {
        [writer increaseIndent];

        for (id<STKPXSelector> expr in attributeExpressions)
        {
            [writer printNewLine];
            [expr sourceWithSourceWriter:writer];
        }

        [writer decreaseIndent];
    }

    if (self.pseudoElement.length > 0)
    {
        [writer increaseIndent];

        [writer printNewLine];
        [writer printIndent];
        [writer print:@"(PSEUDO_ELEMENT "];
        [writer print:self.pseudoElement];
        [writer print:@")"];

        [writer decreaseIndent];
    }

    [writer print:@")"];
}

#pragma mark - Overrides

- (NSString *)description
{
    NSMutableArray *parts = [NSMutableArray array];

    if (self.hasUniversalNamespace)
    {
        [parts addObject:@"*"];
    }
    else
    {
        if (_namespaceURI)
        {
            [parts addObject:_namespaceURI];
        }
    }

    [parts addObject:@"|"];

    if (self.hasUniversalType)
    {
        [parts addObject:@"*"];
    }
    else
    {
        [parts addObject:_typeName];
    }

    for (id expr in attributeExpressions)
    {
        [parts addObject:[NSString stringWithFormat:@"%@", expr]];
    }

    if (self.pseudoElement.length > 0)
    {
        [parts addObject:[NSString stringWithFormat:@"::%@", self.pseudoElement]];
    }

    return [parts componentsJoinedByString:@""];
}

@end
