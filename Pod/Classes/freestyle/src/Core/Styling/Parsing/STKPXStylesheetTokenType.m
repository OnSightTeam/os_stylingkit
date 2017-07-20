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
//  STKPXSSTokenType.m
//  Pixate
//
//  Created by Kevin Lindsey on 6/26/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXStylesheetTokenType.h"

@implementation STKPXStylesheetTokenType

+ (NSString *)typeNameForInt:(STKPXStylesheetTokens)type
{
    switch (type)
    {
        case STKPXSS_ERROR:                            return @"ERROR";
        case STKPXSS_EOF:                              return @"EOF";

        case STKPXSS_WHITESPACE:                       return @"WHITESPACE";

        case STKPXSS_NUMBER:                           return @"NUMBER";
        case STKPXSS_CLASS:                            return @"CLASS";
        case STKPXSS_ID:                               return @"ID";
        case STKPXSS_IDENTIFIER:                       return @"IDENTIFIER";

        case STKPXSS_LCURLY:                           return @"LCURLY";
        case STKPXSS_RCURLY:                           return @"RCURLY";
        case STKPXSS_LPAREN:                           return @"LPAREN";
        case STKPXSS_RPAREN:                           return @"RPAREN";
        case STKPXSS_LBRACKET:                         return @"LBRACKET";
        case STKPXSS_RBRACKET:                         return @"RBRACKET";

        case STKPXSS_SEMICOLON:                        return @"SEMICOLON";
        case STKPXSS_GREATER_THAN:                     return @"GREATER_THAN";
        case STKPXSS_PLUS:                             return @"PLUS";
        case STKPXSS_TILDE:                            return @"TILDE";
        case STKPXSS_STAR:                             return @"STAR";
        case STKPXSS_EQUAL:                            return @"EQUAL";
        case STKPXSS_COLON:                            return @"COLON";
        case STKPXSS_COMMA:                            return @"COMMA";
        case STKPXSS_PIPE:                             return @"PIPE";
        case STKPXSS_SLASH:                            return @"SLASH";

        case STKPXSS_DOUBLE_COLON:                     return @"DOUBLE_COLON";
        case STKPXSS_STARTS_WITH:                      return @"STARTS_WITH";
        case STKPXSS_ENDS_WITH:                        return @"ENDS_WITH";
        case STKPXSS_CONTAINS:                         return @"CONTAINS";
        case STKPXSS_LIST_CONTAINS:                    return @"LIST_CONTAINS";
        case STKPXSS_EQUALS_WITH_HYPHEN:               return @"HYPHEN_LIST_CONTAINS";

        case STKPXSS_STRING:                           return @"STRING";
        case STKPXSS_LINEAR_GRADIENT:                  return @"LINEAR_GRADIENT";
        case STKPXSS_RADIAL_GRADIENT:                  return @"RADIAL_GRADIENT";
        case STKPXSS_HSL:                              return @"HSL";
        case STKPXSS_HSLA:                             return @"HSLA";
        case STKPXSS_HSB:                              return @"HSB";
        case STKPXSS_HSBA:                             return @"HSBA";
        case STKPXSS_RGB:                              return @"RGB";
        case STKPXSS_RGBA:                             return @"RGBA";
        case STKPXSS_HEX_COLOR:                        return @"HEX_COLOR";
        case STKPXSS_URL:                              return @"URL";
        case STKPXSS_NAMESPACE:                        return @"NAMESPACE";

        case STKPXSS_NOT_PSEUDO_CLASS:                 return @"NOT";
        case STKPXSS_LINK_PSEUDO_CLASS:                return @"STKPXSS_LINK_PSEUDO_CLASS";
        case STKPXSS_VISITED_PSEUDO_CLASS:             return @"STKPXSS_VISITED_PSEUDO_CLASS";
        case STKPXSS_HOVER_PSEUDO_CLASS:               return @"STKPXSS_HOVER_PSEUDO_CLASS";
        case STKPXSS_ACTIVE_PSEUDO_CLASS:              return @"STKPXSS_ACTIVE_PSEUDO_CLASS";
        case STKPXSS_FOCUS_PSEUDO_CLASS:               return @"STKPXSS_FOCUS_PSEUDO_CLASS";
        case STKPXSS_TARGET_PSEUDO_CLASS:              return @"STKPXSS_TARGET_PSEUDO_CLASS";
        case STKPXSS_LANG_PSEUDO_CLASS:                return @"STKPXSS_LANG_PSEUDO_CLASS";
        case STKPXSS_ENABLED_PSEUDO_CLASS:             return @"STKPXSS_ENABLED_PSEUDO_CLASS";
        case STKPXSS_CHECKED_PSEUDO_CLASS:             return @"STKPXSS_CHECKED_PSEUDO_CLASS";
        case STKPXSS_INDETERMINATE_PSEUDO_CLASS:       return @"STKPXSS_INDETERMINATE_PSEUDO_CLASS";
        case STKPXSS_ROOT_PSEUDO_CLASS:                return @"STKPXSS_ROOT_PSEUDO_CLASS";
        case STKPXSS_NTH_CHILD_PSEUDO_CLASS:           return @"STKPXSS_NTH_CHILD_PSEUDO_CLASS";
        case STKPXSS_NTH_LAST_CHILD_PSEUDO_CLASS:      return @"STKPXSS_NTH_LAST_CHILD_PSEUDO_CLASS";
        case STKPXSS_NTH_OF_TYPE_PSEUDO_CLASS:         return @"STKPXSS_NTH_OF_TYPE_PSEUDO_CLASS";
        case STKPXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS:    return @"STKPXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS";
        case STKPXSS_FIRST_CHILD_PSEUDO_CLASS:         return @"STKPXSS_FIRST_CHILD_PSEUDO_CLASS";
        case STKPXSS_LAST_CHILD_PSEUDO_CLASS:          return @"STKPXSS_LAST_CHILD_PSEUDO_CLASS";
        case STKPXSS_FIRST_OF_TYPE_PSEUDO_CLASS:       return @"STKPXSS_FIRST_OF_TYPE_PSEUDO_CLASS";
        case STKPXSS_LAST_OF_TYPE_PSEUDO_CLASS:        return @"STKPXSS_LAST_OF_TYPE_PSEUDO_CLASS";
        case STKPXSS_ONLY_CHILD_PSEUDO_CLASS:          return @"STKPXSS_ONLY_CHILD_PSEUDO_CLASS";
        case STKPXSS_ONLY_OF_TYPE_PSEUDO_CLASS:        return @"STKPXSS_ONLY_OF_TYPE_PSEUDO_CLASS";
        case STKPXSS_EMPTY_PSEUDO_CLASS:               return @"STKPXSS_EMPTY_PSEUDO_CLASS";
        case STKPXSS_NTH:                              return @"STKPXSS_NTH";

        case STKPXSS_FIRST_LINE_PSEUDO_ELEMENT:        return @"STKPXSS_FIRST_LINE_PSEUDO_ELEMENT";
        case STKPXSS_FIRST_LETTER_PSEUDO_ELEMENT:      return @"STKPXSS_FIRST_LETTER_PSEUDO_ELEMENT";
        case STKPXSS_BEFORE_PSEUDO_ELEMENT:            return @"STKPXSS_BEFORE_PSEUDO_ELEMENT";
        case STKPXSS_AFTER_PSEUDO_ELEMENT:             return @"STKPXSS_AFTER_PSEUDO_ELEMENT";

        case STKPXSS_KEYFRAMES:                        return @"KEYFRAMES";
        case STKPXSS_IMPORTANT:                        return @"IMPORTANT";
        case STKPXSS_IMPORT:                           return @"IMPORT";
        case STKPXSS_MEDIA:                            return @"MEDIA";
        case STKPXSS_FONT_FACE:                        return @"FONT_FACE";
        case STKPXSS_AND:                              return @"AND";

        case STKPXSS_EMS:                              return @"EMS";
        case STKPXSS_EXS:                              return @"EXS";
        case STKPXSS_LENGTH:                           return @"LENGTH";
        case STKPXSS_ANGLE:                            return @"ANGLE";
        case STKPXSS_TIME:                             return @"TIME";
        case STKPXSS_FREQUENCY:                        return @"FREQUENCY";
        case STKPXSS_DIMENSION:                        return @"DIMENSION";
        case STKPXSS_PERCENTAGE:                       return @"PERCENTAGE";

        default:                        return @"<unknown>";
    }
}

@end
