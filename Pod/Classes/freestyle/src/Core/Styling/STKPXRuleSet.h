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
//  STKPXRuleSet.h
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 7/3/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXSpecificity.h"
#import "STKPXTypeSelector.h"
#import "STKPXDeclarationContainer.h"
#import "STKPXDeclaration.h"
#import "STKPXStyleable.h"

/**
 *  A STKPXRuleSet represents a single CSS rule set. A rule set consists of selectors and declarations. A specificity is
 *  associated with each rule set to assist in the calculation of weights and cascading of declarations.
 */
@interface STKPXRuleSet : STKPXDeclarationContainer

/**
 *  A nonmutable array of selectors.
 *
 *  When a selector consists of a comma-delimited list, each item is added to this rule set
 */
@property (readonly, nonatomic) NSArray *selectors;

/**
 *  The specificity of this rule set as calculated based on the rule set's selectors
 */
@property (readonly, nonatomic) STKPXSpecificity *specificity;

/**
 *  Returns the final selector which determines what target types will be selected
 */
@property (readonly, nonatomic) STKPXTypeSelector *targetTypeSelector;

/**
 *  A class method used to merge multiple rule sets into a single rule set, taking specificity of each rule set into
 *  account. The resulting rule set's selectors and specificity properties are undefined.
 *
 *  @param ruleSets An array of rule sets to merge
 */
+ (instancetype)ruleSetWithMergedRuleSets:(NSArray *)ruleSets;

/**
 *  Add a selector to the list of selectors associated with this rule set
 *
 *  @param selector The selector to add
 */
- (void)addSelector:(id<STKPXSelector>)selector;

/**
 *  Determine if a given element matches the selector associated with this rule set
 *
 *  @param element The element to test
 */
- (BOOL)matches:(id<STKPXStyleable>)element;

@end
