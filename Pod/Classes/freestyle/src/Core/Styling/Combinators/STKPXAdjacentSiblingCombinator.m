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
//  STKPXAdjacentSiblingCombinator.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 9/25/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXAdjacentSiblingCombinator.h"
#import "STKPXStyleUtils.h"

@implementation STKPXAdjacentSiblingCombinator

STK_DEFINE_CLASS_LOG_LEVEL

#pragma mark - Getters

- (NSString *)displayName
{
    return @"ADJACENT_SIBLING_COMBINATOR";
}

#pragma mark - Methods

- (BOOL)matches:(id<STKPXStyleable>)element
{
    BOOL result = NO;

    if ([self.rhs matches:element])
    {
        id parent = element.pxStyleParent;

        if ([parent conformsToProtocol:@protocol(STKPXStyleable)])
        {
            id<STKPXStyleable> styleableParent = parent;
            NSArray *children = [STKPXStyleUtils elementChildrenOfStyleable:styleableParent];
            NSUInteger elementIndex = [children indexOfObject:element];

            if (elementIndex != NSNotFound && elementIndex > 0)
            {
                id previousSibling = children[elementIndex - 1];

                if ([previousSibling conformsToProtocol:@protocol(STKPXStyleable)])
                {
                    id<STKPXStyleable> styleablePreviousSibling = previousSibling;

                    result = [self.lhs matches:styleablePreviousSibling];
                }
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

#pragma mark - Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ + %@", self.lhs, self.rhs];
}

@end
