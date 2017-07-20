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
//  STKPXTransformTokenType.h
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 7/27/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  An enumeration of the STKPXTransform token types
 */
typedef NS_ENUM(int, STKPXTransformTokens)
{
    STKPXTransformToken_ERROR = -1,
    STKPXTransformToken_EOF,

    STKPXTransformToken_WHITESPACE,

    STKPXTransformToken_EMS,
    STKPXTransformToken_EXS,
    STKPXTransformToken_LENGTH,
    STKPXTransformToken_ANGLE,
    STKPXTransformToken_TIME,
    STKPXTransformToken_FREQUENCY,
    STKPXTransformToken_PERCENTAGE,
    STKPXTransformToken_DIMENSION,
    STKPXTransformToken_NUMBER,

    STKPXTransformToken_LPAREN,
    STKPXTransformToken_RPAREN,
    STKPXTransformToken_COMMA,

    STKPXTransformToken_TRANSLATE,
    STKPXTransformToken_TRANSLATEX,
    STKPXTransformToken_TRANSLATEY,
    STKPXTransformToken_SCALE,
    STKPXTransformToken_SCALEX,
    STKPXTransformToken_SCALEY,
    STKPXTransformToken_SKEW,
    STKPXTransformToken_SKEWX,
    STKPXTransformToken_SKEWY,
    STKPXTransformToken_ROTATE,
    STKPXTransformToken_MATRIX
};

/**
 *  A singleton class used to represent a STKPXTransform token type
 */
@interface STKPXTransformTokenType : NSObject

/**
 *  Convert the specified token type to a string suitable for testing, debugging, and error messages
 *
 *  @param type The value of the enumeration to convert to a string
 */
+ (NSString *)typeNameForInt:(STKPXTransformTokens)type;

@end
