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
//  STKPXPseudoClassPredicate.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 11/26/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXPseudoClassPredicate.h"
#import "STKPXStyleUtils.h"

@implementation STKPXPseudoClassPredicate

STK_DEFINE_CLASS_LOG_LEVEL

#pragma mark - Initializers

- (instancetype)initWithPredicateType:(STKPXPseudoClassPredicateType)type
{
    if (self = [super init])
    {
        _predicateType = type;
    }

    return self;
}

#pragma mark - STKPXSelector Implementation

- (BOOL)matches:(id<STKPXStyleable>)element
{
    BOOL result = NO;
    STKPXStyleableChildrenInfo *info = [STKPXStyleUtils childrenInfoForStyleable:element];

    switch (_predicateType)
    {
        case STKPXPseudoClassPredicateRoot:
            // TODO: not sure how robust this test is
            result = (element.pxStyleParent == nil);
            break;

        case STKPXPseudoClassPredicateFirstChild:
        {
            result = (info->childrenIndex == 1);
            break;
        }

        case STKPXPseudoClassPredicateLastChild:
        {
            result = (info->childrenIndex == info->childrenCount);
            break;
        }

        case STKPXPseudoClassPredicateFirstOfType:
        {
            result = (info->childrenOfTypeIndex == 1);
            break;
        }

        case STKPXPseudoClassPredicateLastOfType:
        {
            result = (info->childrenOfTypeIndex == info->childrenOfTypeCount);
            break;
        }

        case STKPXPseudoClassPredicateOnlyChild:
        {
            result = (info->childrenCount == 1 && info->childrenIndex == 1);
            break;
        }

        case STKPXPseudoClassPredicateOnlyOfType:
        {
            result = (info->childrenOfTypeCount == 1 && info->childrenOfTypeIndex == 1);
            break;
        }

        case STKPXPseudoClassPredicateEmpty:
        {
            result = ([STKPXStyleUtils childCountForStyleable:element] == 0);
            break;
        }
    }

    free(info);

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

- (void)incrementSpecificity:(STKPXSpecificity *)specificity
{
    [specificity incrementSpecifity:kSpecificityTypeClassOrAttribute];
}

#pragma mark - Overrides

- (NSString *)description
{
    switch (_predicateType)
    {
        case STKPXPseudoClassPredicateRoot: return @":root";
        case STKPXPseudoClassPredicateFirstChild: return @":first-child";
        case STKPXPseudoClassPredicateLastChild: return @":list-child";
        case STKPXPseudoClassPredicateFirstOfType: return @":first-of-type";
        case STKPXPseudoClassPredicateLastOfType: return @":last-of-type";
        case STKPXPseudoClassPredicateOnlyChild: return @":only-child";
        case STKPXPseudoClassPredicateOnlyOfType: return @":only-of-type";
        case STKPXPseudoClassPredicateEmpty: return @":empty";
        default: return @"<uknown-pseudo-class-predicate";
    }
}

- (void)sourceWithSourceWriter:(STKPXSourceWriter *)writer
{
    [writer printIndent];
    [writer print:@"(PSEUDO_CLASS_PREDICATE "];
    [writer print:self.description];
    [writer print:@")"];
}

@end
