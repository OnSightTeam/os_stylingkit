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
//  STKPXTransitionRuleSetInfo.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 2/28/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXTransitionRuleSetInfo.h"
#import "STKPXStylingMacros.h"
#import "STKPXStyleUtils.h"
#import "STKPXRuleSet.h"
#import "STKPXTransitionStyler.h"

@implementation STKPXTransitionRuleSetInfo

- (instancetype)initWithStyleable:(id<STKPXStyleable>)styleable withStateName:(NSString *)stateName
{
    if (self = [super init])
    {
        // find matching rule sets, regardless of any supported or specified pseudo-classes
        _allMatchingRuleSets = [STKPXStyleUtils matchingRuleSetsForStyleable:styleable];

        // filter the list of rule sets to only those that specify the current state
        _ruleSetsForState = [STKPXStyleUtils filterRuleSets:_allMatchingRuleSets
                                            forStyleable:styleable
                                                 byState:stateName];

        // merge rule sets for this state into a single rule set, taking specificity into account
        _mergedRuleSet = [STKPXRuleSet ruleSetWithMergedRuleSets:_ruleSetsForState];

        // extract any transition delcarations we might have
        STKPXTransitionStyler *styler = [[STKPXTransitionStyler alloc] init];
        NSSet *stylerProperties = [[NSSet alloc] initWithArray:styler.supportedProperties];
        STKPXStylerContext *context = [[STKPXStylerContext alloc] init];
        context.styleable = styleable;
        context.activeStateName = stateName;

        for (STKPXDeclaration *declaration in _mergedRuleSet.declarations)
        {
            if ([stylerProperties containsObject:declaration.name])
            {
                [styler processDeclaration:declaration withContext:context];
            }
        }

        _transitions = context.transitionInfos;
        NSMutableSet *animationProperties = [[NSMutableSet alloc] init];

        for (STKPXAnimationInfo *info in _transitions)
        {
            [animationProperties addObject:info.animationName];
        }

        NSMutableArray *nonAnimatedRuleSets = [[NSMutableArray alloc] init];
        NSMutableArray *animatedRuleSets = [[NSMutableArray alloc] init];

        [_ruleSetsForState enumerateObjectsUsingBlock:^(STKPXRuleSet *ruleSet, NSUInteger idx, BOOL *stop) {
            STKPXRuleSet *nonAnimatedRuleSet = [[STKPXRuleSet alloc] init];
            STKPXRuleSet *animatedRuleSet = [[STKPXRuleSet alloc] init];

            // copy selectors over, for debugging purposes only
            [ruleSet.selectors enumerateObjectsUsingBlock:^(id sel, NSUInteger idx, BOOL *stop) {
                [nonAnimatedRuleSet addSelector:sel];
                [animatedRuleSet addSelector:sel];
            }];

            // divide declarations into animated and non-animated lists
            [ruleSet.declarations enumerateObjectsUsingBlock:^(STKPXDeclaration *declaration, NSUInteger idx, BOOL *stop) {
                if ([animationProperties containsObject:declaration.name])
                {
                    [animatedRuleSet addDeclaration:declaration];
                }
                else if ([stylerProperties containsObject:declaration.name] == NO)
                {
                    [nonAnimatedRuleSet addDeclaration:declaration];
                }
            }];

            // add non-animated rule set, if we found any non-animated declarations
            if (nonAnimatedRuleSet.declarations.count > 0)
            {
                [nonAnimatedRuleSets addObject:nonAnimatedRuleSet];
            }

            // add animated rule set, if we found any animated declarations
            if (animatedRuleSet.declarations.count > 0)
            {
                [animatedRuleSets addObject:animatedRuleSet];
            }
        }];

        // save reference to non-animated rule sets, if we found any
        if (nonAnimatedRuleSets.count > 0)
        {
            _nonAnimatingRuleSets = nonAnimatedRuleSets;
        }

        // save reference to animated rule sets, if we found any
        if (animatedRuleSets.count > 0)
        {
            _animatingRuleSets = animatedRuleSets;
        }
    }

    return self;
}

@end
