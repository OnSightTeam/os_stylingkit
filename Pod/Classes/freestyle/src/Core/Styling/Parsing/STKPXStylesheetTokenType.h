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
//  STKPXSSTokenType.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/23/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A list of iCSS token types
 */
typedef enum _PXStylesheetTokens : NSInteger
{
    STKPXSS_ERROR = -1,
    STKPXSS_EOF,

    STKPXSS_WHITESPACE,

    STKPXSS_NUMBER,
    STKPXSS_CLASS,
    STKPXSS_ID,
    STKPXSS_IDENTIFIER,

    STKPXSS_LCURLY,
    STKPXSS_RCURLY,
    STKPXSS_LPAREN,
    STKPXSS_RPAREN,
    STKPXSS_LBRACKET,
    STKPXSS_RBRACKET,

    STKPXSS_SEMICOLON,
    STKPXSS_GREATER_THAN,
    STKPXSS_PLUS,
    STKPXSS_TILDE,
    STKPXSS_STAR,
    STKPXSS_EQUAL,
    STKPXSS_COLON,
    STKPXSS_COMMA,
    STKPXSS_PIPE,
    STKPXSS_SLASH,

    STKPXSS_DOUBLE_COLON,
    STKPXSS_STARTS_WITH,
    STKPXSS_ENDS_WITH,
    STKPXSS_CONTAINS,
    STKPXSS_LIST_CONTAINS,
    STKPXSS_EQUALS_WITH_HYPHEN,

    STKPXSS_STRING,
    STKPXSS_LINEAR_GRADIENT,
    STKPXSS_RADIAL_GRADIENT,
    STKPXSS_HSL,
    STKPXSS_HSLA,
    STKPXSS_HSB,
    STKPXSS_HSBA,
    STKPXSS_RGB,
    STKPXSS_RGBA,
    STKPXSS_HEX_COLOR,
    STKPXSS_URL,
    STKPXSS_NAMESPACE,

    STKPXSS_NOT_PSEUDO_CLASS,
    STKPXSS_LINK_PSEUDO_CLASS,
    STKPXSS_VISITED_PSEUDO_CLASS,
    STKPXSS_HOVER_PSEUDO_CLASS,
    STKPXSS_ACTIVE_PSEUDO_CLASS,
    STKPXSS_FOCUS_PSEUDO_CLASS,
    STKPXSS_TARGET_PSEUDO_CLASS,
    STKPXSS_LANG_PSEUDO_CLASS,
    STKPXSS_ENABLED_PSEUDO_CLASS,
    STKPXSS_CHECKED_PSEUDO_CLASS,
    STKPXSS_INDETERMINATE_PSEUDO_CLASS,
    STKPXSS_ROOT_PSEUDO_CLASS,
    STKPXSS_NTH_CHILD_PSEUDO_CLASS,
    STKPXSS_NTH_LAST_CHILD_PSEUDO_CLASS,
    STKPXSS_NTH_OF_TYPE_PSEUDO_CLASS,
    STKPXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS,
    STKPXSS_FIRST_CHILD_PSEUDO_CLASS,
    STKPXSS_LAST_CHILD_PSEUDO_CLASS,
    STKPXSS_FIRST_OF_TYPE_PSEUDO_CLASS,
    STKPXSS_LAST_OF_TYPE_PSEUDO_CLASS,
    STKPXSS_ONLY_CHILD_PSEUDO_CLASS,
    STKPXSS_ONLY_OF_TYPE_PSEUDO_CLASS,
    STKPXSS_EMPTY_PSEUDO_CLASS,
    STKPXSS_NTH,

    STKPXSS_FIRST_LINE_PSEUDO_ELEMENT,
    STKPXSS_FIRST_LETTER_PSEUDO_ELEMENT,
    STKPXSS_BEFORE_PSEUDO_ELEMENT,
    STKPXSS_AFTER_PSEUDO_ELEMENT,

    STKPXSS_KEYFRAMES,
    STKPXSS_IMPORTANT,
    STKPXSS_IMPORT,
    STKPXSS_MEDIA,
    STKPXSS_FONT_FACE,
    STKPXSS_AND,

    STKPXSS_EMS,
    STKPXSS_EXS,
    STKPXSS_LENGTH,
    STKPXSS_ANGLE,
    STKPXSS_TIME,
    STKPXSS_FREQUENCY,
    STKPXSS_DIMENSION,
    STKPXSS_PERCENTAGE

} STKPXStylesheetTokens;

/**
 *  A singleton used to indicate the type of a given lexeme
 */
@interface STKPXStylesheetTokenType : NSObject

/**
 *  Return a display name for the specified token type. This is used for debugging and error reporting.
 *
 *  @param type The value of the enumeration to convert to a string
 */
+ (NSString *)typeNameForInt:(STKPXStylesheetTokens)type;

@end
