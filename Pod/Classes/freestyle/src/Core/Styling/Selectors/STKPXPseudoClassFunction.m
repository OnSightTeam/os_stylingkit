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
//  STKPXPseudoClassFunction.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 11/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXPseudoClassFunction.h"
#import "STKPXStyleUtils.h"
#import "STKPXLog.h"

@implementation STKPXPseudoClassFunction

STK_DEFINE_CLASS_LOG_LEVEL

#pragma mark - Initializers

- (instancetype)initWithFunctionType:(STKPXPseudoClassFunctionType)type modulus:(NSInteger)modulus remainder:(NSInteger)remainder
{
    if (self = [super init])
    {
        _functionType = type;
        _modulus = modulus;
        _remainder = remainder;
    }

    return self;
}

#pragma mark - STKPXSelector Implementation

- (BOOL)matches:(id<STKPXStyleable>)element
{
    BOOL result = NO;
    STKPXStyleableChildrenInfo *info = [STKPXStyleUtils childrenInfoForStyleable:element];

    if (_modulus != 0 || _remainder != 0)
    {
        switch (_functionType)
        {
            case STKPXPseudoClassFunctionNthLastChild:
                info->childrenIndex = info->childrenCount - info->childrenIndex + 1;
                // fall through

            case STKPXPseudoClassFunctionNthChild:
            {
                if (_modulus == 1)
                {
                    result = (info->childrenIndex == _remainder);
                }
                else
                {
                    NSInteger diff = info->childrenIndex - _remainder;
                    NSInteger diffMod = (_modulus != 0) ? diff % _modulus : diff;

                    if ((diff <= 0 && _modulus < 0) || (diff >= 0 && _modulus > 0))
                    {
                        result = (diffMod == 0);
                    }
                }
                break;
            }

            case STKPXPseudoClassFunctionNthLastOfType:
                info->childrenOfTypeIndex = info->childrenOfTypeCount - info->childrenOfTypeIndex + 1;
                // fall through

            case STKPXPseudoClassFunctionNthOfType:
            {
                if (_modulus == 1)
                {
                    result = (info->childrenOfTypeIndex == _remainder);
                }
                else
                {
                    NSInteger diff = info->childrenOfTypeIndex - _remainder;
                    NSInteger diffMod = (_modulus != 0) ? diff % _modulus : diff;

                    if ((diff <= 0 && _modulus < 0) || (diff >= 0 && _modulus > 0))
                    {
                        result = (diffMod == 0);
                    }
                }
                break;
            }
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
    NSMutableArray *parts = [[NSMutableArray alloc] init];

    switch (_functionType)
    {
        case STKPXPseudoClassFunctionNthChild:
            [parts addObject:@":nth-child("];
            break;

        case STKPXPseudoClassFunctionNthLastChild:
            [parts addObject:@":nth-last-child("];
            break;

        case STKPXPseudoClassFunctionNthOfType:
            [parts addObject:@":nth-of-type("];
            break;

        case STKPXPseudoClassFunctionNthLastOfType:
            [parts addObject:@":nth-last-of-type("];
            break;
    }

    if (_modulus == 0)
    {
        [parts addObject:[NSString stringWithFormat:@"%ld", (long) _remainder]];
    }
    else if (_remainder == 0)
    {
        [parts addObject:[NSString stringWithFormat:@"%ldn", (long) _modulus]];
    }
    else
    {
        [parts addObject:[NSString stringWithFormat:@"%ldn+%ld", (long) _modulus, (long) _remainder]];
    }

    [parts addObject:@")"];

    return [parts componentsJoinedByString:@""];
}

@end
