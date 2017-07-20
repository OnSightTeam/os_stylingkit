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
//  STKPXStyleCache.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 10/2/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXStyleTreeInfo.h"
#import "STKPXStyleInfo.h"
#import "STKPXStyleUtils.h"

@implementation STKPXStyleTreeInfo
{
    NSString *styleKey_;
    STKPXStyleInfo *styleableStyleInfo_;
    NSMutableDictionary *childStyleInfo_;           // keyed by NSIndexPath
//    NSMutableDictionary *pseudoElementStyleInfo_;   // keyed by NSIndexPath
    NSUInteger descendantCount_;
}

#pragma mark - Initializers

- (instancetype)initWithStyleable:(id<STKPXStyleable>)styleable
{
    if (self = [super init])
    {
        styleKey_ = styleable.styleKey;
        NSNumber* checkPseudoClassFunction = @NO;
        styleableStyleInfo_ = [STKPXStyleInfo styleInfoForStyleable:styleable checkPseudoClassFunction:&checkPseudoClassFunction];
        _cached = !checkPseudoClassFunction.boolValue;
        styleableStyleInfo_.forceInvalidation = YES;
        childStyleInfo_ = [NSMutableDictionary dictionary];

        [self collectChildStyleInfoForStyleable:styleable];
    }

    return self;
}

#pragma mark - Getters

- (NSString *)styleKey
{
    return styleKey_;
}

#pragma mark - Methods

- (void)applyStylesToStyleable:(id<STKPXStyleable>)styleable
{
    if (styleableStyleInfo_ != nil)
    {
        [styleableStyleInfo_ applyToStyleable:styleable];
    }

    [childStyleInfo_ enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, STKPXStyleInfo *styleInfo, BOOL *stop)
    {
        id<STKPXStyleable> child = [self findDescendantOfStyleable:styleable
                                                  fromIndexPath:indexPath];

        if (child != nil)
        {
            if (styleInfo.changeable)
            {
                styleInfo = [STKPXStyleInfo styleInfoForStyleable:child];
            }

            [styleInfo applyToStyleable:child];
        }
    }];
}

- (id<STKPXStyleable>)findDescendantOfStyleable:(id<STKPXStyleable>)styleable
                               fromIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger indexes[indexPath.length];
    [indexPath getIndexes:indexes];
    id<STKPXStyleable> result = styleable;

    for (int i = 0; i < indexPath.length; i++)
    {
        NSUInteger index = indexes[i];
        NSArray *children = result.pxStyleChildren;

        if (index < children.count)
        {
            result = children[index];
        }
        else
        {
            result = nil;
            break;
        }
    }

    return result;
}

- (void)collectChildStyleInfoForStyleable:(id<STKPXStyleable>)styleable
{
    NSUInteger index = 0;

    descendantCount_ = 0;

    for (id<STKPXStyleable> child in styleable.pxStyleChildren)
    {
        NSIndexPath *childIndexPath = [NSIndexPath indexPathWithIndex:index++];

        [self setChildStyleInfoForStyleable:child withIndexPath:childIndexPath];
        descendantCount_++;
    }
}

- (void)setChildStyleInfoForStyleable:(id<STKPXStyleable>)styleable withIndexPath:(NSIndexPath *)indexPath
{
    // get style info for this child
    STKPXStyleInfo *styleInfo = [STKPXStyleInfo styleInfoForStyleable:styleable];


    if (styleInfo != nil)
    {
        // force invalidation of children
        styleInfo.forceInvalidation = YES;

        // save info for this index path
        childStyleInfo_[indexPath] = styleInfo;
    }

    // now process this child's children
    NSUInteger index = 0;

    for (id<STKPXStyleable> child in styleable.pxStyleChildren)
    {
        NSIndexPath *childIndexPath = [indexPath indexPathByAddingIndex:index++];

        [self setChildStyleInfoForStyleable:child withIndexPath:childIndexPath];
        descendantCount_++;
    }
}

#pragma mark - Overrides

- (void)dealloc
{
    styleableStyleInfo_ = nil;
    childStyleInfo_ = nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ Key=%@, StyledDescendants=%ld, TotalDescendants=%ld }", self.styleKey, (unsigned long) childStyleInfo_.count, (unsigned long) descendantCount_];
}

@end
