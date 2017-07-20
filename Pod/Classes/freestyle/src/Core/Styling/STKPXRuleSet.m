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
//  STKPXRuleSet.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 7/3/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXRuleSet.h"
#import "STKPXSourceWriter.h"
#import "STKPXShapeView.h"
#import "STKPXFontRegistry.h"
#import "STKPXCombinator.h"

@implementation STKPXRuleSet
{
    NSMutableArray *selectors;
}

#pragma mark - Static initializers

+ (instancetype)ruleSetWithMergedRuleSets:(NSArray *)ruleSets
{
    STKPXRuleSet *result = [[STKPXRuleSet alloc] init];

    if (ruleSets.count > 0)
    {
        // order rules by specificity
        NSArray *sortedRuleSets =
            [ruleSets sortedArrayUsingComparator:^NSComparisonResult(STKPXRuleSet *a, STKPXRuleSet *b)
             {
                 return [a.specificity compareSpecificity:b.specificity];
             }];

        for (STKPXRuleSet *ruleSet in [sortedRuleSets reverseObjectEnumerator])
        {
            // add selectors
            for (id<STKPXSelector> selector in ruleSet.selectors)
            {
                [result addSelector:selector];
            }

            // add declarations
            for (STKPXDeclaration *declaration in ruleSet.declarations)
            {
                if ([result hasDeclarationForName:declaration.name])
                {
                    if (declaration.important)
                    {
                        STKPXDeclaration *addedDeclaration = [result declarationForName:declaration.name];

                        if (addedDeclaration.important == NO)
                        {
                            // replace old with this !important one
                            [result removeDeclaration:addedDeclaration];
                            [result addDeclaration:declaration];
                        }
                    }
                }
                else
                {
                    [result addDeclaration:declaration];
                }
            }
        }
    }

    return result;
}

#pragma mark - Initializers

- (instancetype)init
{
    if (self = [super init])
    {
        _specificity = [[STKPXSpecificity alloc] init];
    }

    return self;
}

#pragma mark - Getters

- (NSArray *)selectors
{
    return selectors;
}

- (STKPXTypeSelector *)targetTypeSelector
{
    STKPXTypeSelector *result = nil;

    if (selectors.count > 0)
    {
        id candidate = selectors[0];

        if (candidate)
        {
            if ([candidate conformsToProtocol:@protocol(STKPXCombinator)])
            {
                id<STKPXCombinator> combinator = candidate;

                // NOTE: STKPXStylesheetParser grows expressions down and to the left. This guarantees that the top-most nodes
                // RHS will be a type selector, and will be the last in the expression
                result = combinator.rhs;
            }
            else if ([candidate isKindOfClass:[STKPXTypeSelector class]])
            {
                result = candidate;
            }
        }
    }

    return result;
}

#pragma mark - Methods

- (void)addSelector:(id<STKPXSelector>)selector
{
    if (selector)
    {
        if (!selectors)
        {
            selectors = [NSMutableArray array];
        }

        [selectors addObject:selector];

        [selector incrementSpecificity:_specificity];
    }
}

- (BOOL)matches:(id<STKPXStyleable>)element
{
    BOOL result = NO;

    if (element && selectors.count > 0)
    {
        result = YES;

        for (STKPXTypeSelector *selector in selectors)
        {
            if (![selector matches:element])
            {
                result = NO;
                break;
            }
        }
    }

    return result;
}

#pragma mark - Overrides

- (void)dealloc
{
    self->selectors = nil;
}

- (NSString *)description
{
    STKPXSourceWriter *writer = [[STKPXSourceWriter alloc] init];

    if (selectors)
    {
        for (id selector in selectors)
        {
            [writer print:[NSString stringWithFormat:@"%@ ", selector]];
        }
    }

    [writer printWithNewLine:@"{"];
    [writer increaseIndent];

    [writer printIndent];
    [writer print:@"// specificity = "];
    [writer printWithNewLine:_specificity.description];

    for (STKPXDeclaration *declaration in self.declarations)
    {
        [writer printIndent];
        [writer printWithNewLine:declaration.description];
    }

    [writer decreaseIndent];
    [writer print:@"}"];

    return writer.description;
}

@end
