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
//  STKPXTransformTokenType.m
//  Pixate
//
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXTransformTokenType.h"

@implementation STKPXTransformTokenType

+ (NSString *)typeNameForInt:(STKPXTransformTokens)type
{
    switch (type)
    {
        case STKPXTransformToken_ERROR:        return @"ERROR";
        case STKPXTransformToken_EOF:          return @"EOF";

        case STKPXTransformToken_WHITESPACE:   return @"WHITESPACE";

        case STKPXTransformToken_EMS:          return @"EMS";
        case STKPXTransformToken_EXS:          return @"EXS";
        case STKPXTransformToken_LENGTH:       return @"LENGTH";
        case STKPXTransformToken_ANGLE:        return @"ANGLE";
        case STKPXTransformToken_TIME:         return @"TIME";
        case STKPXTransformToken_FREQUENCY:    return @"FREQUENCY";
        case STKPXTransformToken_PERCENTAGE:   return @"PERCENTAGE";
        case STKPXTransformToken_DIMENSION:    return @"DIMENSION";
        case STKPXTransformToken_NUMBER:       return @"NUMBER";

        case STKPXTransformToken_LPAREN:       return @"LPAREN";
        case STKPXTransformToken_RPAREN:       return @"RPAREN";
        case STKPXTransformToken_COMMA:        return @"COMMA";

        case STKPXTransformToken_TRANSLATE:    return @"TRANSLATE";
        case STKPXTransformToken_TRANSLATEX:   return @"TRANSLATEX";
        case STKPXTransformToken_TRANSLATEY:   return @"TRANSLATEY";
        case STKPXTransformToken_SCALE:        return @"SCALE";
        case STKPXTransformToken_SCALEX:       return @"SCALEX";
        case STKPXTransformToken_SCALEY:       return @"SCALEY";
        case STKPXTransformToken_SKEW:         return @"SKEW";
        case STKPXTransformToken_SKEWX:        return @"SKEWX";
        case STKPXTransformToken_SKEWY:        return @"SKEWY";
        case STKPXTransformToken_ROTATE:       return @"ROTATE";
        case STKPXTransformToken_MATRIX:       return @"MATRIX";

        default:                        return @"<unknown>";
    }
}

@end
