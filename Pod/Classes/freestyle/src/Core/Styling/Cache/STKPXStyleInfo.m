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
//  STKPXStyleInfo.m
//  Pixate
//
//  Modified by Anton Matosov
//  Created by Kevin Lindsey on 10/2/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXStyleInfo.h"
#import "STKPXDeclaration.h"

#import "STKPXStyleUtils.h"
#import "STKPXRuleSet.h"
#import "STKPXTypeSelector.h"
#import "STKPXStyler.h"
#import "NSObject+STKPXStyling.h"
#import "STKPXPseudoClassFunction.h"

@implementation STKPXStyleInfo
{
    NSMutableDictionary *declarationsByState_;
    NSMutableDictionary *stylersByState_;
}

STK_DEFINE_CLASS_LOG_LEVEL;

#pragma mark - Static Methods

+ (STKPXStyleInfo *)styleInfoForStyleable:(id<STKPXStyleable>)styleable
{
    return [self styleInfoForStyleable:styleable checkPseudoClassFunction:nil];
}

+ (STKPXStyleInfo *)styleInfoForStyleable:(id<STKPXStyleable>)styleable checkPseudoClassFunction:(NSNumber**)checkPseudoClassFunction
{
    STKPXStyleInfo *result = [[STKPXStyleInfo alloc] initWithStyleKey:styleable.styleKey];
    result.changeable = styleable.styleChangeable;
    
    // find all rule sets that apply to this styleable
    NSMutableArray *ruleSets = [STKPXStyleUtils matchingRuleSetsForStyleable:styleable];

    if (ruleSets.count > 0)
    {
        // style pseudo-elements
        // if ([styleable respondsToSelector:@selector(styleableForPseudoElement:)])
        // {
        //     // grab a list of supported pseudo-elements for this styleable object
        //     NSArray *pseudoElements = ([styleable respondsToSelector:@selector(supportedPseudoElements)])
        //         ? styleable.supportedPseudoElements
        //         : nil;

        //     for (NSString *pseudoElement in pseudoElements)
        //     {
        //         if (pseudoElement.length > 0)
        //         {
        //             NSArray *ruleSetsForPseudoElement = [STKPXStyleUtils filterRuleSets:ruleSets byPseudoElement:pseudoElement];

        //             if (ruleSetsForPseudoElement.count > 0)
        //             {
        //                 id<STKPXStyleable> pseudoElementStyleable = [styleable styleableForPseudoElement:pseudoElement];

        //                 if (pseudoElementStyleable != nil)
        //                 {
        //                     [self applyRuleSets:ruleSetsForPseudoElement toStyleable:pseudoElementStyleable forState:nil];
        //                 }
        //             }
        //         }
        //     }
        // }

        // remove pseudo-element rule sets
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];

        for (STKPXRuleSet *ruleSet in ruleSets)
        {
            STKPXTypeSelector *selector = ruleSet.targetTypeSelector;

            if (selector.pseudoElement.length > 0)
            {
                [toRemove addObject:ruleSet];
            }

            if (checkPseudoClassFunction) {
                if (!(*checkPseudoClassFunction).boolValue) {
                    for (id<STKPXSelector> attribute in selector.attributeExpressions) {
                        if ([attribute isKindOfClass:STKPXPseudoClassFunction.class]) {
                            *checkPseudoClassFunction = @YES;
                            break;
                        }
                    }
                }
            }
        }

        [ruleSets removeObjectsInArray:toRemove];
    }

    // process by state
    if (ruleSets.count > 0)
    {
        // grab a list of supported pseudo-classes for this styleable object
        NSArray *pseudoClasses = ([styleable respondsToSelector:@selector(supportedPseudoClasses)])
            ? styleable.supportedPseudoClasses
            : nil;

        // style pseudo-classes
        if (pseudoClasses.count > 0)
        {
            for (NSString *pseudoClass in pseudoClasses)
            {
                // filter the list of rule sets to only those that specify the current state
                NSArray *ruleSetsForState = [STKPXStyleUtils filterRuleSets:ruleSets forStyleable:styleable byState:pseudoClass];

                if (ruleSetsForState.count > 0)
                {
                    [self setStyleInfo:result withRuleSets:ruleSetsForState styleable:styleable stateName:pseudoClass];
                }
            }
        }
        else
        {
            [self setStyleInfo:result withRuleSets:ruleSets styleable:styleable stateName:@""];
        }
    }

    return (result.states.count > 0) ? result : nil;
}

+ (void)setStyleInfo:(STKPXStyleInfo *)styleInfo
        withRuleSets:(NSArray *)ruleSets
           styleable:(id<STKPXStyleable>)styleable
           stateName:(NSString *)stateName
{
    // merge all rule sets into a single rule set based on origin and weight/specificity
    STKPXRuleSet *mergedRuleSet = [STKPXRuleSet ruleSetWithMergedRuleSets:ruleSets];

    NSArray *stylers = ([styleable respondsToSelector:@selector(viewStylers)])
        ? ((NSObject *)styleable).viewStylers
        : nil;
    NSDictionary *stylersByProperty = ([styleable respondsToSelector:@selector(viewStylersByProperty)])
        ? ((NSObject *)styleable).viewStylersByProperty
        : nil;

    // build a set of stylers that are active based on the property names we have in the merged rule set
    NSMutableSet *activeStylers = [[NSMutableSet alloc] init];

    // keep track of active declarations
    NSMutableArray *activeDeclarations = [[NSMutableArray alloc] init];
    // NSMutableArray *inactiveDeclarations = [[NSMutableArray alloc] init];

    for (STKPXDeclaration *declaration in mergedRuleSet.declarations)
    {
        id<STKPXStyler> styler = stylersByProperty[declaration.name];

        if (styler)
        {
            [activeDeclarations addObject:declaration];
            [activeStylers addObject:NSStringFromClass(styler.class)];
        }
        else if (stylers == nil)
        {
            [activeDeclarations addObject:declaration];
        }
        // else
        // {
        //     [inactiveDeclarations addObject:declaration];
        // }
    }

    [styleInfo addDeclarations:activeDeclarations forState:stateName];
    [styleInfo addStylers:activeStylers forState:stateName];
}

#pragma mark - Initializers

- (instancetype)initWithStyleKey:(NSString *)styleKey
{
    if (self = [super init])
    {
        _styleKey = styleKey;
    }

    return self;
}

#pragma mark - Getters

- (NSArray *)states
{
    return (declarationsByState_ != nil) ? declarationsByState_.allKeys : nil;
}

#pragma mark - Methods

- (void)addDeclarations:(NSArray *)declarations forState:(NSString *)stateName
{
    if (declarations.count > 0 && stateName != nil)
    {
        if (declarationsByState_ == nil)
        {
            declarationsByState_ = [NSMutableDictionary dictionary];
        }

        // TODO: check for pre-existing?

        declarationsByState_[stateName] = declarations;
    }
}

- (void)addStylers:(NSSet *)stylers forState:(NSString *)stateName
{
    if (stylers.count > 0 && stateName != nil)
    {
        if (stylersByState_ == nil)
        {
            stylersByState_ = [NSMutableDictionary dictionary];
        }

        stylersByState_[stateName] = stylers;
    }
}

- (NSArray *)declarationsForState:(NSString *)stateName
{
    return (declarationsByState_ != nil) ? declarationsByState_[stateName] : nil;
}

- (NSSet *)stylersForState:(NSString *)stateName
{
    return (stylersByState_ != nil) ? stylersByState_[stateName] : nil;
}

- (void)applyToStyleable:(id<STKPXStyleable>)styleable
{
    // abort application of style info if the styleable's style key does not match the info's style key
    if ([self.styleKey isEqualToString:styleable.styleKey] == NO)
    {
        DDLogError(@"StyleKey mismatch ('%@' != '%@'). Aborted applyStyleInfo for %@", self.styleKey, styleable.styleKey, [STKPXStyleUtils descriptionForStyleable:styleable]);
        return;
    }

    NSArray *stylers = ([styleable respondsToSelector:@selector(viewStylers)])
        ? ((NSObject *)styleable).viewStylers
        : nil;
    NSDictionary *stylersByProperty = ([styleable respondsToSelector:@selector(viewStylersByProperty)])
        ? ((NSObject *)styleable).viewStylersByProperty
        : nil;

    for (NSString *stateName in self.states)
    {
        // NOTE: if a styleable does not contain canStylePseudoClass, we assume that if it did, the method would return YES
        if ([styleable respondsToSelector:@selector(canStylePseudoClass:)]
            && ![styleable canStylePseudoClass:stateName])
        {
            //NSLog(@"skipping state '%@' for styleable: %@", stateName, [STKPXStyleUtils descriptionForStyleable:styleable]);

            // styleable says we can't style this pseudoclass right now, so skip it
            continue;
        }

        NSArray *activeDeclarations = [self declarationsForState:stateName];

        if (self.forceInvalidation)
        {
            [STKPXStyleUtils invalidateStyleable:styleable];
        }

        if (![STKPXStyleUtils stylesOfStyleable:styleable
                           matchDeclarations:activeDeclarations
                                       state:stateName])
        {
            NSSet *activeStylers = [self stylersForState:stateName];

            // create context and store styleable and state name there
            STKPXStylerContext *context = [[STKPXStylerContext alloc] init];

            context.styleable = styleable;
            context.activeStateName = stateName;
            context.styleHash = [STKPXStyleUtils hashValueForStyleable:styleable state:stateName];

            // process declarations in styler order
            for (id<STKPXStyler> currentStyler in stylers)
            {
                if ([activeStylers containsObject:NSStringFromClass(currentStyler.class)])
                {
                    // process the declarations, in order
                    for (STKPXDeclaration *declaration in activeDeclarations)
                    {
                        id<STKPXStyler> styler = stylersByProperty[declaration.name];

                        if (styler == currentStyler)
                        {
                            [styler processDeclaration:declaration withContext:context];
                        }
                    }

                    // apply styler completion block
                    [currentStyler applyStylesWithContext:context];
                }
            }

            // see if there's a catch-all 'updateStyleWithRuleSet:context:' method to call
            if ([styleable respondsToSelector:@selector(updateStyleWithRuleSet:context:)])
            {
                STKPXRuleSet *ruleSet = [[STKPXRuleSet alloc] init];

                for (STKPXDeclaration *declaration in activeDeclarations)
                {
                    [ruleSet addDeclaration:declaration];
                }

                [(NSObject *)styleable updateStyleWithRuleSet:ruleSet context:context];
            }
            
            // If the frame of the view has potentially changed, let's recompute the style hash
            if([context propertyValueForName:@"frame"])
            {
                [STKPXStyleUtils stylesOfStyleable:styleable matchDeclarations:activeDeclarations state:stateName];
            }
        }
    }
}

#pragma mark - Overrides

- (NSString *)description
{
    NSMutableArray *parts = [NSMutableArray array];

    for (NSString *state in self.states)
    {
        NSString *stateName = (state.length > 0) ? state : @"default";

        // emit state
        [parts addObject:[NSString stringWithFormat:@"%@ {", stateName]];

        // emit declaration
        for (STKPXDeclaration *declaration in declarationsByState_[state])
        {
            [parts addObject:[NSString stringWithFormat:@"  %@", declaration.description]];
        }

        // close
        [parts addObject:@"}"];
    }

    return [parts componentsJoinedByString:@"\n"];
}

@end
