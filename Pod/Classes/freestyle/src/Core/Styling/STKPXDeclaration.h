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
//  STKPXDeclaration.h
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXPaint.h"
#import "STKPXShadow.h"
#import "STKPXDimension.h"
#import "STKPXOffsets.h"
#import "PixateFreestyleConfiguration.h"
#import "STKPXBorderInfo.h"

/**
 *  STKPXDeclaration represents a single property/value pair in a CSS rule set. A declaration consists of a property name
 *  and a property value. However, due to the nature of Pixate's 2-pass parsing, the property value in these instances
 *  is actually an array of lexemes. As such, a number of convenience methods are provided to convert the lexemes to a
 *  concrete value type.
 */
@interface STKPXDeclaration : NSObject

@property (nonatomic, strong) NSString *name;
@property (readonly, nonatomic, strong) NSArray *lexemes;
@property (nonatomic) BOOL important;

/**
 *  Initializes a newly allocated STKPXDeclaration using the specified property name
 *
 *  @param name The property name for this declaration
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Initializes a newly allocated STKPXDeclaration using the specified property name and value. The value will be tokenized
 *  to populate the lexemes property.
 *
 *  @param name The property name
 *  @param value The property value
 */
- (instancetype)initWithName:(NSString *)name value:(NSString *)value NS_DESIGNATED_INITIALIZER;

/**
 *  Set source, filename, and lexemes associated with this declaration
 *
 *  @param source The declaration's source
 *  @param filename The name of the file containing this declaration
 *  @param lexemes The value of this declaration as lexemes
 */
- (void)setSource:(NSString *)source filename:(NSString *)filename lexemes:(NSArray *)lexemes;

/**
 *  Convert the declaration value to a CGAffineTransformation using the SVG transform syntax
 */
@property (NS_NONATOMIC_IOSONLY, readonly) CGAffineTransform affineTransformValue;

/**
 *  Convert the declaration value to a list of animation infos, each delimited by a comma
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *animationInfoList;

/**
 *  Convert the declaration value to a list of transition infos, each delimited by a comma
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *transitionInfoList;

/**
 *  Convert the declaration value to a list of animation directions, each delimited by a comma
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *animationDirectionList;

/**
 *  Convert the declaration value to a list of animation file modes, each delimited by a comma
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *animationFillModeList;

/**
 *  Convert the declaration value to a list of animation play states, each delimited by a comma
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *animationPlayStateList;

/**
 *  Convert the declaration value to a list of animation timing functions, each delimited by a comma
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *animationTimingFunctionList;

/**
 *  Convert the declaration value to a boolean value
 */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL booleanValue;

/**
 *  Convert the delcaration value to border settings
 */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) STKPXBorderInfo *borderValue;

/**
 *  Convert the declaration value to a list of radii, each represented by a CGSize
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *borderRadiiList;

/**
 *  Convert the declaration value to a border style
 */
@property (NS_NONATOMIC_IOSONLY, readonly) STKPXBorderStyle borderStyleValue;

/**
 *  Convert the decalration value to a list of border styles. This allows 1 = 4 values, similar to padding
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *borderStyleList;

/**
 *  Convert the declaration value to a STKPXCacheStylesType value
 */
@property (NS_NONATOMIC_IOSONLY, readonly) STKPXCacheStylesType cacheStylesTypeValue;

/**
 *  Convert the declaration value to a color value
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) UIColor *colorValue;

/**
 *  Convert the declaration value to a float value
 */
@property (NS_NONATOMIC_IOSONLY, readonly) CGFloat floatValue;

/**
 *  Convert the declaration value to a list of floats, each delimited by a comma
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *floatListValue;

/**
 *  Convert the declaration value to a UIEdgeInsets value
 */
@property (NS_NONATOMIC_IOSONLY, readonly) UIEdgeInsets insetsValue;

/**
 *  Convert the declaration value to a STKPXDimension length value
 */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) STKPXDimension *lengthValue;

/**
 *  Convert the declaration value to a line break mode enumeration value
 */
@property (NS_NONATOMIC_IOSONLY, readonly) NSLineBreakMode lineBreakModeValue;

/**
 *  Convert the declaration value to a list of names, each delimited by a comma
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *nameListValue;

/**
 *  Convert the declaration value to a offsets value
 */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) STKPXOffsets *offsetsValue;

/**
 *  Convert the declaration value to a list of paints. This allows 1 - 4 paints, similar to padding
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *paintList;

/**
 *  Convert the declaration value to a paint value
 */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) id<STKPXPaint> paintValue;

/**
 *  Convert the declaration value to a parse error destination value
 */
@property (NS_NONATOMIC_IOSONLY, readonly) STKPXParseErrorDestination parseErrorDestinationValue;

/**
 *  Convert the declaration value to seconds
 */
@property (NS_NONATOMIC_IOSONLY, readonly) CGFloat secondsValue;

/**
 *  Convert the declaration value to a list of seconds, each delimited by a comma
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *secondsListValue;

/**
 *  Convert the declaration value to a size value
 */
@property (NS_NONATOMIC_IOSONLY, readonly) CGSize sizeValue;

/**
 *  Convert the declaration value to a shadow value
 */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) STKPXShadow *shadowValue;

/**
 *  Convert the declaration value to a string value
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringValue;

/**
 *  Convert the declaration value to a text alignment enumeration value
 */
@property (NS_NONATOMIC_IOSONLY, readonly) NSTextAlignment textAlignmentValue;

/**
 *  Convert the declaration value to a border style enumeration value
 */
@property (NS_NONATOMIC_IOSONLY, readonly) UITextBorderStyle textBorderStyleValue;

/**
  *  Treat the string value of this declaration as a text-transform value. Apply the text transform to the specified
  *  string and return the result
  *
  *  @param value The string to transform
  */
- (NSString *)transformString:(NSString *)value;

/**
 *  Convert the declaration value to a letter spacing value.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) STKPXDimension *letterSpacingValue;

/**
 *  Convert the declaration value to a URL
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *URLValue;

@end
