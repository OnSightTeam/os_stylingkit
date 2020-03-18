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
//  STKPXStylesheetParser.h
//  Pixate
//
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXParserBase.h"
#import "STKPXStylesheet.h"
#import "STKPXStylesheet-Private.h"
#import "STKPXStylesheetLexer.h"
#import "STKPXSelector.h"

/**
 *  STKPXStylesheetParser is responsible for making the first pass on CSS source. This pass generates expression trees for
 *  selectors. However, rule set bodies are mostly scanned only. The parser recognizes a declaration's name (property
 *  name), but simply collects its value lexemes in a array for future processing, if needed.
 *
 *  STKPXStylesheetParser uses some simple strategies for error recovery. All errors are captured and attached to the
 *  stylesheet generated by the parse methods.
 */
@interface STKPXStylesheetParser : STKPXParserBase <STKPXStylesheetLexerDelegate>

/**
 *  Make a first pass parse of the specified source and return the results in a new stylesheet instance.
 *
 *  @param source The CSS to parse
 *  @param origin The origin (specificity) to use for the generated stylesheet
 */
- (STKPXStylesheet *)parse:(NSString *)source withOrigin:(STKPXStylesheetOrigin)origin;

/**
 *  Make a first pass parse of the specified source and return the result in a new stylesheet instance. This parse
 *  method allows the file name to be specified which is used to prevent @import cycles.
 *
 *  @param source The CSS to parse
 *  @param origin The origin (specificity) to use for the generated stylesheet
 *  @param name The name of the file being processed
 */
- (STKPXStylesheet *)parse:(NSString *)source withOrigin:(STKPXStylesheetOrigin)origin filename:(NSString *)name;

/**
 *  Treat the specified source as inline CSS, as if it were coming from a style attribute.
 *
 *  @param css The inline CSS to parse
 */
- (STKPXStylesheet *)parseInlineCSS:(NSString *)css;

/**
 *  Parse the specified source as a CSS selector only.
 *
 *  @param source The selector source
 */
- (id<STKPXSelector>)parseSelectorString:(NSString *)source;

@end