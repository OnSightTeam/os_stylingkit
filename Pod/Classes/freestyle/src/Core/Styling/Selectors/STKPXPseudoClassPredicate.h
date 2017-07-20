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
//  STKPXPseudoClassPredicate.h
//  Pixate
//
//  Created by Kevin Lindsey on 11/26/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXSelector.h"

/**
 *  The STKPXPseudoClassPredicateType enumeration specifies what test should be performed during a match operation
 */
typedef enum
{
    STKPXPseudoClassPredicateRoot,
    STKPXPseudoClassPredicateFirstChild,
    STKPXPseudoClassPredicateLastChild,
    STKPXPseudoClassPredicateFirstOfType,
    STKPXPseudoClassPredicateLastOfType,
    STKPXPseudoClassPredicateOnlyChild,
    STKPXPseudoClassPredicateOnlyOfType,
    STKPXPseudoClassPredicateEmpty
} STKPXPseudoClassPredicateType;

/**
 *  A STKPXPseudoClassPredicate is a selector that asks a true or false question of the styleable attempting to be matched.
 *  These questions, or predicates, determine position of the element among its siblings, whether this is the root
 *  view, or if it has no children
 */
@interface STKPXPseudoClassPredicate : NSObject <STKPXSelector>

/**
 *  This indicates what type of predicate will be performed during a match operation
 */
@property (nonatomic, readonly) STKPXPseudoClassPredicateType predicateType;

/**
 *  Initialize a newly allocated instance, setting its operation type
 *
 *  @param type The predicate type
 */
- (id)initWithPredicateType:(STKPXPseudoClassPredicateType)type;

@end
