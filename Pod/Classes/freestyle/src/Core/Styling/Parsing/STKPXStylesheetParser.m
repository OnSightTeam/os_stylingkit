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
//  STKPXStylesheetParser.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 9/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXStylesheetParser.h"
#import "STKPXStylesheetTokenType.h"
#import "STKPXDeclaration.h"
#import "STKPXIdSelector.h"
#import "STKPXClassSelector.h"
#import "STKPXNotPseudoClass.h"
#import "STKPXPseudoClassSelector.h"
#import "STKPXAttributeSelectorOperator.h"
#import "STKPXAttributeSelector.h"
#import "NSMutableArray+StackAdditions.h"
#import "STKPXCombinator.h"
#import "STKPXAdjacentSiblingCombinator.h"
#import "STKPXChildCombinator.h"
#import "STKPXDescendantCombinator.h"
#import "STKPXSiblingCombinator.h"
#import "STKPXPseudoClassPredicate.h"
#import "STKPXPseudoClassFunction.h"
#import "STKPXFileUtils.h"
#import "STKPXNamedMediaExpression.h"
#import "STKPXMediaExpressionGroup.h"
#import "PixateFreestyle.h"
#import "STKPXKeyframeBlock.h"
#import "STKPXFontRegistry.h"

@implementation STKPXStylesheetParser
{
    STKPXStylesheetLexer *lexer_;
    STKPXStylesheet *currentStyleSheet_;
    STKPXTypeSelector *currentSelector_;
    NSMutableArray *activeImports_;
}

STK_DEFINE_CLASS_LOG_LEVEL

#pragma mark - Statics

static NSIndexSet *SELECTOR_SEQUENCE_SET;
static NSIndexSet *SELECTOR_OPERATOR_SET;
static NSIndexSet *SELECTOR_SET;
static NSIndexSet *TYPE_SELECTOR_SET;
static NSIndexSet *SELECTOR_EXPRESSION_SET;
static NSIndexSet *TYPE_NAME_SET;
static NSIndexSet *ATTRIBUTE_OPERATOR_SET;
static NSIndexSet *DECLARATION_DELIMITER_SET;
static NSIndexSet *KEYFRAME_SELECTOR_SET;
static NSIndexSet *NAMESPACE_SET;
static NSIndexSet *IMPORT_SET;
static NSIndexSet *QUERY_VALUE_SET;
static NSIndexSet *ARCHAIC_PSEUDO_ELEMENTS_SET;

+ (void)initialize
{
    if (!TYPE_NAME_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:STKPXSS_IDENTIFIER];
        [set addIndex:STKPXSS_STAR];
        TYPE_NAME_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!TYPE_SELECTOR_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndexes:TYPE_NAME_SET];
        [set addIndex:STKPXSS_PIPE]; // namespace operator
        TYPE_SELECTOR_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!SELECTOR_EXPRESSION_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:STKPXSS_ID];
        [set addIndex:STKPXSS_CLASS];
        [set addIndex:STKPXSS_LBRACKET];
        [set addIndex:STKPXSS_COLON];
        [set addIndex:STKPXSS_NOT_PSEUDO_CLASS];
        [set addIndex:STKPXSS_LINK_PSEUDO_CLASS];
        [set addIndex:STKPXSS_VISITED_PSEUDO_CLASS];
        [set addIndex:STKPXSS_HOVER_PSEUDO_CLASS];
        [set addIndex:STKPXSS_ACTIVE_PSEUDO_CLASS];
        [set addIndex:STKPXSS_FOCUS_PSEUDO_CLASS];
        [set addIndex:STKPXSS_TARGET_PSEUDO_CLASS];
        [set addIndex:STKPXSS_LANG_PSEUDO_CLASS];
        [set addIndex:STKPXSS_ENABLED_PSEUDO_CLASS];
        [set addIndex:STKPXSS_CHECKED_PSEUDO_CLASS];
        [set addIndex:STKPXSS_INDETERMINATE_PSEUDO_CLASS];
        [set addIndex:STKPXSS_ROOT_PSEUDO_CLASS];
        [set addIndex:STKPXSS_NTH_CHILD_PSEUDO_CLASS];
        [set addIndex:STKPXSS_NTH_LAST_CHILD_PSEUDO_CLASS];
        [set addIndex:STKPXSS_NTH_OF_TYPE_PSEUDO_CLASS];
        [set addIndex:STKPXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS];
        [set addIndex:STKPXSS_FIRST_CHILD_PSEUDO_CLASS];
        [set addIndex:STKPXSS_LAST_CHILD_PSEUDO_CLASS];
        [set addIndex:STKPXSS_FIRST_OF_TYPE_PSEUDO_CLASS];
        [set addIndex:STKPXSS_LAST_OF_TYPE_PSEUDO_CLASS];
        [set addIndex:STKPXSS_ONLY_CHILD_PSEUDO_CLASS];
        [set addIndex:STKPXSS_ONLY_OF_TYPE_PSEUDO_CLASS];
        [set addIndex:STKPXSS_EMPTY_PSEUDO_CLASS];
        SELECTOR_EXPRESSION_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!SELECTOR_OPERATOR_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:STKPXSS_PLUS];
        [set addIndex:STKPXSS_GREATER_THAN];
        [set addIndex:STKPXSS_TILDE];
        SELECTOR_OPERATOR_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!SELECTOR_SEQUENCE_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndexes:TYPE_SELECTOR_SET];
        [set addIndexes:SELECTOR_EXPRESSION_SET];
        [set addIndexes:SELECTOR_OPERATOR_SET];
        SELECTOR_SEQUENCE_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!SELECTOR_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndexes:TYPE_SELECTOR_SET];
        [set addIndexes:SELECTOR_EXPRESSION_SET];
        SELECTOR_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!ATTRIBUTE_OPERATOR_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:STKPXSS_STARTS_WITH];
        [set addIndex:STKPXSS_ENDS_WITH];
        [set addIndex:STKPXSS_CONTAINS];
        [set addIndex:STKPXSS_EQUAL];
        [set addIndex:STKPXSS_LIST_CONTAINS];
        [set addIndex:STKPXSS_EQUALS_WITH_HYPHEN];
        ATTRIBUTE_OPERATOR_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!DECLARATION_DELIMITER_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:STKPXSS_SEMICOLON];
        [set addIndex:STKPXSS_RCURLY];
        DECLARATION_DELIMITER_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!KEYFRAME_SELECTOR_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:STKPXSS_IDENTIFIER];
        [set addIndex:STKPXSS_PERCENTAGE];
        KEYFRAME_SELECTOR_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!NAMESPACE_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:STKPXSS_STRING];
        [set addIndex:STKPXSS_URL];
        NAMESPACE_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!IMPORT_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:STKPXSS_STRING];
        [set addIndex:STKPXSS_URL];
        IMPORT_SET = [[NSIndexSet alloc] initWithIndexSet:set];
    }

    if (!QUERY_VALUE_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:STKPXSS_IDENTIFIER];
        [set addIndex:STKPXSS_NUMBER];
        [set addIndex:STKPXSS_LENGTH];
        [set addIndex:STKPXSS_STRING];
        QUERY_VALUE_SET = set;
    }

    if (!ARCHAIC_PSEUDO_ELEMENTS_SET)
    {
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        [set addIndex:STKPXSS_FIRST_LINE_PSEUDO_ELEMENT];
        [set addIndex:STKPXSS_FIRST_LETTER_PSEUDO_ELEMENT];
        [set addIndex:STKPXSS_BEFORE_PSEUDO_ELEMENT];
        [set addIndex:STKPXSS_AFTER_PSEUDO_ELEMENT];
        ARCHAIC_PSEUDO_ELEMENTS_SET = set;
    }
}

#pragma mark - Initializers

- (instancetype)init
{
    if (self = [super init])
    {
        lexer_ = [[STKPXStylesheetLexer alloc] init];
        lexer_.delegate = self;
    }

    return self;
}

#pragma mark - Methods

// level 0

- (STKPXStylesheet *)parse:(NSString *)source withOrigin:(STKPXStylesheetOrigin)origin filename:(NSString *)name
{
    // add the source file name to prevent @imports from importing it as well
    [self addImportName:name];

    // parse
    STKPXStylesheet *result = [self parse:source withOrigin:origin];

    // associate file path on resulting stylesheet
    result.filePath = name;

    return result;
}

- (STKPXStylesheet *)parse:(NSString *)source withOrigin:(STKPXStylesheetOrigin)origin
{
    // clear errors
    [self clearErrors];

    // create stylesheet
    currentStyleSheet_ = [[STKPXStylesheet alloc] initWithOrigin:origin];

    // setup lexer and prime it
    lexer_.source = source;
    [self advance];

    @try
    {
        while (currentLexeme)
        {
            switch (currentLexeme.type)
            {
                case STKPXSS_IMPORT:
                    [self parseImport];
                    break;

                case STKPXSS_NAMESPACE:
                    [self parseNamespace];
                    break;

                case STKPXSS_KEYFRAMES:
                    [self parseKeyframes];
                    break;

                case STKPXSS_MEDIA:
                    [self parseMedia];
                    break;

                case STKPXSS_FONT_FACE:
                    [self parseFontFace];
                    break;

                default:
                    // TODO: check for valid tokens to error out sooner?
                    [self parseRuleSet];
                    break;
            }
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    // clear out any import refs
    activeImports_ = nil;

    return currentStyleSheet_;
}

- (STKPXStylesheet *)parseInlineCSS:(NSString *)css
{
    // clear errors
    [self clearErrors];

    // create stylesheet
    self->currentStyleSheet_ = [[STKPXStylesheet alloc] initWithOrigin:STKPXStylesheetOriginInline];

    // setup lexer and prime it
    lexer_.source = css;
    [lexer_ increaseNesting];
    [self advance];

    @try
    {
        // build placeholder rule set
        STKPXRuleSet *ruleSet = [[STKPXRuleSet alloc] init];

        // parse declarations
        NSArray *declarations = [self parseDeclarations];

        // add declarations to rule set
        for (STKPXDeclaration *declaration in declarations)
        {
            [ruleSet addDeclaration:declaration];
        }

        // save rule set
        [currentStyleSheet_ addRuleSet:ruleSet];
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
    }

    return self->currentStyleSheet_;
}

- (id<STKPXSelector>)parseSelectorString:(NSString *)source
{
    id<STKPXSelector> result = nil;

    // clear errors
    [self clearErrors];

    // setup lexer and prime it
    lexer_.source = source;
    [self advance];

    @try
    {
        result = [self parseSelector];
    }
    @catch (NSException *e) {
        [self addError:e.description];
    }

    return result;
}

// level 1

- (void)parseFontFace
{
    [self assertTypeAndAdvance:STKPXSS_FONT_FACE];

    // process declaration block
    if ([self isType:STKPXSS_LCURLY])
    {
        NSArray *declarations = [self parseDeclarationBlock];

        // TODO: we probably shouldn't load font right here
        for (STKPXDeclaration *declaration in declarations)
        {
            if ([@"src" isEqualToString:declaration.name])
            {
                [STKPXFontRegistry loadFontFromURL:declaration.URLValue];
            }
        }
    }
}

- (void)parseImport
{
    [self assertTypeAndAdvance:STKPXSS_IMPORT];
    [self assertTypeInSet:IMPORT_SET];

    NSString *path = nil;

    switch (currentLexeme.type)
    {
        case STKPXSS_STRING:
        {
            NSString *string = currentLexeme.value;

            if (string.length > 2)
            {
                path = [string substringWithRange:NSMakeRange(1, string.length - 2)];
            }

            break;
        }

        case STKPXSS_URL:
            path = currentLexeme.value;
            break;
    }

    if (path)
    {
        // advance over @import argument
        [self advance];

        // calculate resource name and file extension
        NSString *pathMinusExtension = path.stringByDeletingPathExtension;
        NSString *extension = path.pathExtension.lowercaseString;
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:pathMinusExtension ofType:extension];

        if (![activeImports_ containsObject:bundlePath])
        {
            // we need to go ahead and process the trailing semicolon so we have the corrent lexeme in case we push it
            // below
            [self advance];

            [self addImportName:bundlePath];

            NSString *source = [STKPXFileUtils sourceFromResource:pathMinusExtension ofType:extension];

            if (source.length > 0)
            {
                [lexer_ pushLexeme:currentLexeme];
                [lexer_ pushSource:source];
                [self advance];
            }
        }
        else
        {
            NSString *message
                = [NSString stringWithFormat:@"@import cycle detected trying to import '%@':\n%@ ->\n%@", path, [activeImports_ componentsJoinedByString:@" ->\n"], bundlePath];

            [self addError:message];

            // NOTE: we do this here so we'll still have the current file on the active imports stack. This handles the
            // case of a file ending with an @import statement, causing advance to pop it from the active imports stack
            [self advance];
        }
    }
}

- (void)parseMedia
{
    [self assertTypeAndAdvance:STKPXSS_MEDIA];

    // TODO: support media types, NOT, and ONLY. Skipping for now
    while ([self isType:STKPXSS_IDENTIFIER])
    {
        [self advance];
    }

    // 'and' may appear here
    [self advanceIfIsType:STKPXSS_AND];

    // parse optional expressions
    if ([self isType:STKPXSS_LPAREN])
    {
        [self parseMediaExpressions];
    }

    // parse body
    if ([self isType:STKPXSS_LCURLY])
    {
        @try
        {
            [self advance];

            while (currentLexeme && ![self isType:STKPXSS_RCURLY])
            {
                [self parseRuleSet];
            }

            [self advanceIfIsType:STKPXSS_RCURLY withWarning:@"Expected @media body closing curly brace"];
        }
        @finally
        {
            // reset active media query to none
            currentStyleSheet_.activeMediaQuery = nil;
        }
    }
}

- (void)parseRuleSet
{
    NSArray *selectors;

    // parse selectors
    @try
    {
        selectors = [self parseSelectorGroup];
    }
    @catch (NSException *e)
    {
        // emit error
        [self addError:e.description];

        // use flag to indicate we have no selectors
        selectors = @[ [NSNull null] ];

        // advance to '{'
        [self advanceToType:STKPXSS_LCURLY];
    }

    // here for error recovery
    if (![self isType:STKPXSS_LCURLY])
    {
        [self addError:@"Expected a left curly brace to begin a declaration block"];

        // advance to '{'
        [self advanceToType:STKPXSS_LCURLY];
    }

    // parse declaration block
    if ([self isType:STKPXSS_LCURLY])
    {
        NSArray *declarations = [self parseDeclarationBlock];

        for (id selector in selectors)
        {
            // build rule set
            STKPXRuleSet *ruleSet = [[STKPXRuleSet alloc] init];

            // add selector
            if (selector != [NSNull null])
            {
                [ruleSet addSelector:selector];
            }

            for (STKPXDeclaration *declaration in declarations)
            {
                [ruleSet addDeclaration:declaration];
            }

            // save rule set
            [currentStyleSheet_ addRuleSet:ruleSet];
        }
    }
}

- (void)parseKeyframes
{
    // advance over '@keyframes'
    [self assertTypeAndAdvance:STKPXSS_KEYFRAMES];

    // grab keyframe name
    [self assertType:STKPXSS_IDENTIFIER];
    STKPXKeyframe *keyframe = [[STKPXKeyframe alloc] initWithName:currentLexeme.value];
    [self advance];

    // advance over '{'
    [self assertTypeAndAdvance:STKPXSS_LCURLY];

    // process each block
    while ([self isInTypeSet:KEYFRAME_SELECTOR_SET])
    {
        // grab all offsets
        NSMutableArray *offsets = [[NSMutableArray alloc] init];

        [offsets addObject:@([self parseOffset])];

        while ([self isType:STKPXSS_COMMA])
        {
            // advance over ','
            [self advance];

            [offsets addObject:@([self parseOffset])];
        }

        // grab declarations
        NSArray *declarations = [self parseDeclarationBlock];

        // create blocks, one for each offset, using the same declarations for each
        for (NSNumber *number in offsets)
        {
            CGFloat offset = number.floatValue;

            // create keyframe block
            STKPXKeyframeBlock *block = [[STKPXKeyframeBlock alloc] initWithOffset:offset];

            // add declarations to it
            for (STKPXDeclaration *declaration in declarations)
            {
                [block addDeclaration:declaration];
            }

            [keyframe addKeyframeBlock:block];
        }
    }

    // add keyframe to current stylesheet
    [currentStyleSheet_ addKeyframe:keyframe];

    // advance over '}'
    [self assertTypeAndAdvance:STKPXSS_RCURLY];
}

- (CGFloat)parseOffset
{
    CGFloat offset = 0.0f;

    [self assertTypeInSet:KEYFRAME_SELECTOR_SET];

    switch (currentLexeme.type)
    {
        case STKPXSS_IDENTIFIER:
            // NOTE: we only check for 'to' since 'from' and unrecognized values will use the default value of 0.0f
            if ([@"to" isEqualToString:currentLexeme.value])
            {
                offset = 1.0f;
            }
            [self advance];
            break;

        case STKPXSS_PERCENTAGE:
        {
            STKPXDimension *percentage = currentLexeme.value;
            offset = percentage.number / 100.0f;
            offset = MIN(1.0f, offset);
            offset = MAX(0.0f, offset);
            [self advance];
            break;
        }

        default:
        {
            NSString *message = [NSString stringWithFormat:@"Unrecognized keyframe selector type: %@", currentLexeme];
            [self errorWithMessage:message];
            break;
        }
    }

    return offset;
}

- (void)parseNamespace
{
    [self assertTypeAndAdvance:STKPXSS_NAMESPACE];

    NSString *identifier = nil;
    NSString *uri;

    if ([self isType:STKPXSS_IDENTIFIER])
    {
        identifier = currentLexeme.value;
        [self advance];
    }

    [self assertTypeInSet:NAMESPACE_SET];

    // grab value
    uri = currentLexeme.value;

    // trim string
    if ([self isType:STKPXSS_STRING])
    {
        uri = [uri substringWithRange:NSMakeRange(1, uri.length - 2)];
    }

    [self advance];

    // set namespace on stylesheet
    [currentStyleSheet_ setURI:uri forNamespacePrefix:identifier];

    [self assertTypeAndAdvance:STKPXSS_SEMICOLON];
}

// level 2

- (NSArray *)parseSelectorGroup
{
    NSMutableArray *selectors = [[NSMutableArray alloc] init];

    id<STKPXSelector> selectorSequence = [self parseSelectorSequence];

    if (selectorSequence)
    {
        [selectors addObject:selectorSequence];
    }

    while (currentLexeme.type == STKPXSS_COMMA)
    {
        // advance over ','
        [self advance];

        // grab next selector
        [selectors addObject:[self parseSelectorSequence]];
    }

    if (selectors.count == 0)
    {
        [self errorWithMessage:@"Expected a Selector or Pseudo-element"];
    }

    return selectors;
}

- (NSArray *)parseDeclarationBlock
{
    [self assertTypeAndAdvance:STKPXSS_LCURLY];

    NSArray *declarations = [self parseDeclarations];

    [self assertTypeAndAdvance:STKPXSS_RCURLY];

    return declarations;
}

- (void)parseMediaExpressions
{
    @try
    {
        // create container for zero-or-more expressions
        NSMutableArray *expressions = [NSMutableArray array];

        // add at least one expression
        [expressions addObject:[self parseMediaExpression]];

        // and any others
        while ([self isType:STKPXSS_AND])
        {
            [self advance];

            [expressions addObject:[self parseMediaExpression]];
        }

        // create expression group or use single entry
        if (expressions.count == 1)
        {
            currentStyleSheet_.activeMediaQuery = expressions[0];
        }
        else
        {
            STKPXMediaExpressionGroup *group = [[STKPXMediaExpressionGroup alloc] init];

            for (id<STKPXMediaExpression> expression in expressions)
            {
                [group addExpression: expression];
            }

            currentStyleSheet_.activeMediaQuery = group;
        }
    }
    @catch (NSException *e)
    {
        [self addError:e.description];
        // TODO: error recovery
    }
}

// level 3

- (id<STKPXSelector>)parseSelectorSequence
{
    id<STKPXSelector> root = [self parseSelector];

    while ([self isInTypeSet:SELECTOR_SEQUENCE_SET])
    {
        STKPXStylesheetLexeme *operator = nil;

        if ([self isInTypeSet:SELECTOR_OPERATOR_SET])
        {
            operator = currentLexeme;
            [self advance];
        }

        id<STKPXSelector> rhs = [self parseSelector];

        if (operator)
        {
            switch (operator.type)
            {
                case STKPXSS_PLUS:
                    root = [[STKPXAdjacentSiblingCombinator alloc] initWithLHS:root RHS:rhs];
                    break;

                case STKPXSS_GREATER_THAN:
                    root = [[STKPXChildCombinator alloc] initWithLHS:root RHS:rhs];
                    break;

                case STKPXSS_TILDE:
                    root = [[STKPXSiblingCombinator alloc] initWithLHS:root RHS:rhs];
                    break;

                default:
                    [self errorWithMessage:@"Unsupported selector operator (combinator)"];
            }
        }
        else
        {
            root = [[STKPXDescendantCombinator alloc] initWithLHS:root RHS:rhs];
        }
    }

    NSString *pseudoElement = nil;

    // grab possible pseudo-element in new and old formats
    if ([self isType:STKPXSS_DOUBLE_COLON])
    {
        [self advance];

        [self assertType:STKPXSS_IDENTIFIER];
        pseudoElement = currentLexeme.value;
        [self advance];
    }
    else if ([self isInTypeSet:ARCHAIC_PSEUDO_ELEMENTS_SET])
    {
        NSString *stringValue = currentLexeme.value;

        pseudoElement = [stringValue substringFromIndex:1];

        [self advance];
    }

    if (pseudoElement.length > 0)
    {
        if (root == nil)
        {
            STKPXTypeSelector *selector = [[STKPXTypeSelector alloc] init];

            selector.pseudoElement = pseudoElement;

            root = selector;
        }
        else
        {
            if ([root isKindOfClass:[STKPXTypeSelector class]])
            {
                STKPXTypeSelector *selector = root;

                selector.pseudoElement = pseudoElement;
            }
            else if ([root isKindOfClass:[STKPXCombinatorBase class]])
            {
                STKPXCombinatorBase *combinator = (STKPXCombinatorBase *)root;
                STKPXTypeSelector *selector = combinator.rhs;

                selector.pseudoElement = pseudoElement;
            }
        }
    }

    return root;
}

- (NSArray *)parseDeclarations
{
    NSMutableArray *declarations = [NSMutableArray array];

    // parse properties
    while (currentLexeme && currentLexeme.type != STKPXSS_RCURLY)
    {
        @try
        {
            STKPXDeclaration *declaration = [self parseDeclaration];

            [declarations addObject:declaration];
        }
        @catch (NSException *e)
        {
            [self addError:e.description];

            // TODO: parseDeclaration could do error recovery. If not, this should probably do the same recovery
            while (currentLexeme && ![self isInTypeSet:DECLARATION_DELIMITER_SET])
            {
                [self advance];
            }

            [self advanceIfIsType:STKPXSS_SEMICOLON];
        }
    }

    return declarations;
}

- (id<STKPXMediaExpression>)parseMediaExpression
{
    [self assertTypeAndAdvance:STKPXSS_LPAREN];

    // grab name
    [self assertType:STKPXSS_IDENTIFIER];
    NSString *name = [currentLexeme.value lowercaseString];
    [self advance];

    id value = nil;

    // parse optional value
    if ([self isType:STKPXSS_COLON])
    {
        // advance over ':'
        [self assertTypeAndAdvance:STKPXSS_COLON];

        // grab value
        [self assertTypeInSet:QUERY_VALUE_SET];
        value = currentLexeme.value;
        [self advance];

        // make string values lowercase to avoid doing it later
        if ([value isKindOfClass:[NSString class]])
        {
            value = [value lowercaseString];
        }
        // check for possible ratio syntax
        else if ([value isKindOfClass:[NSNumber class]] && [self isType:STKPXSS_SLASH]) {
            
            NSNumber *numerator = (NSNumber *) value;
            
            // advance over '/'
            [self advance];

            // grab denominator
            [self assertType:STKPXSS_NUMBER];
            NSNumber *denom = currentLexeme.value;
            [self advance];

            if (numerator.floatValue == 0.0)
            {
                // do nothing, leave result as 0.0
            }
            else if (denom.floatValue == 0.0)
            {
                value = @(NAN);
            }
            else
            {
                value = @(numerator.floatValue / denom.floatValue);
            }
        }
    }

    [self advanceIfIsType:STKPXSS_RPAREN withWarning:@"Expected closing parenthesis in media query"];

    // create query expression and activate it in current stylesheet
    return [[STKPXNamedMediaExpression alloc] initWithName:name value:value];
}

// level 4

- (id<STKPXSelector>)parseSelector
{
    STKPXTypeSelector *result = nil;

    if ([self isInTypeSet:SELECTOR_SET])
    {
        if ([self isInTypeSet:TYPE_SELECTOR_SET])
        {
            result = [self parseTypeSelector];
        }
        else
        {
            // match any element
            result = [[STKPXTypeSelector alloc] init];

            // clear whitespace flag, so first expression will not fail in this case
            [currentLexeme clearFlag:STKPXLexemeFlagFollowsWhitespace];
        }

        if ([self isInTypeSet:SELECTOR_EXPRESSION_SET])
        {
            for (id<STKPXSelector> expression in [self parseSelectorExpressions])
            {
                [result addAttributeExpression:expression];
            }
        }
    }
    // else, fail silently in case a pseudo-element follows

    return result;
}

- (STKPXDeclaration *)parseDeclaration
{
    // process property name
    [self assertType:STKPXSS_IDENTIFIER];
    STKPXDeclaration *declaration = [[STKPXDeclaration alloc] initWithName:currentLexeme.value];
    [self advance];

    // colon
    [self assertTypeAndAdvance:STKPXSS_COLON];

    // collect values
    NSMutableArray *lexemes = [NSMutableArray array];

    while (currentLexeme && ![self isInTypeSet:DECLARATION_DELIMITER_SET])
    {
        if (currentLexeme.type == STKPXSS_COLON && ((STKPXStylesheetLexeme *)lexemes.lastObject).type == STKPXSS_IDENTIFIER)
        {
            // assume we've moved into a new declaration, so push last lexeme back into the lexeme stream
            STKPXStylesheetLexeme *propertyName = [lexemes pop];

            // this pushes the colon back to the lexer and makes the property name the current lexeme
            [self pushLexeme:propertyName];

            // signal end of this declaration
            break;
        }
        else
        {
            [lexemes addObject:currentLexeme];
            [self advance];
        }
    }

    // let semicolons be optional
    [self advanceIfIsType:STKPXSS_SEMICOLON];

    // grab original source, for error messages and hashing
    NSString *source;

    if (lexemes.count > 0)
    {
        STKPXStylesheetLexeme *firstLexeme = lexemes[0];
        STKPXStylesheetLexeme *lastLexeme = lexemes.lastObject;
        NSUInteger start = firstLexeme.range.location;
        NSUInteger end = lastLexeme.range.location + lastLexeme.range.length;
        NSUInteger length = end - start;
        NSRange sourceRange = NSMakeRange(start, length);

        source = [lexer_.source substringWithRange:sourceRange];
    }
    else
    {
        source = @"";
    }

    // check for !important
    STKPXStylesheetLexeme *lastLexeme = lexemes.lastObject;

    if (lastLexeme.type == STKPXSS_IMPORTANT)
    {
        // drop !important and tag declaration as important
        [lexemes removeLastObject];
        declaration.important = YES;
    }

    // associate lexemes with declaration
    [declaration setSource:source filename:[self currentFilename] lexemes:lexemes];

    return declaration;
}

// level 5

- (STKPXTypeSelector *)parseTypeSelector
{
    STKPXTypeSelector *result = nil;

    if ([self isInTypeSet:TYPE_SELECTOR_SET])
    {
        NSString *namespace = nil;
        NSString *name = nil;

        // namespace or type
        if ([self isInTypeSet:TYPE_NAME_SET])
        {
            // assume we have a name only
            name = currentLexeme.value;
            [self advance];
        }

        // if pipe, then we had a namespace, now process type
        if ([self isType:STKPXSS_PIPE])
        {
            namespace = name;

            // advance over '|'
            [self advance];

            if ([self isInTypeSet:TYPE_NAME_SET])
            {
                // set name
                name = currentLexeme.value;
                [self advance];
            }
            else
            {
                [self errorWithMessage:@"Expected IDENTIFIER or STAR"];
            }
        }
        else
        {
            namespace = @"*";
        }

        // find namespace URI from namespace prefix

        NSString *namespaceURI = nil;

        if (namespace)
        {
            if ([namespace isEqualToString:@"*"])
            {
                namespaceURI = namespace;
            }
            else
            {
                namespaceURI = [currentStyleSheet_ namespaceForPrefix:namespace];
            }
        }

        result = [[STKPXTypeSelector alloc] initWithNamespaceURI:namespaceURI typeName:name];
    }
    else
    {
        [self errorWithMessage:@"Expected IDENTIFIER, STAR, or PIPE"];
    }

    return result;
}

- (NSArray *)parseSelectorExpressions
{
    NSMutableArray *expressions = [NSMutableArray array];

    while (![currentLexeme flagIsSet:STKPXLexemeFlagFollowsWhitespace] && [self isInTypeSet:SELECTOR_EXPRESSION_SET])
    {
        switch (currentLexeme.type)
        {
            case STKPXSS_ID:
            {
                NSString *name = [(NSString *) currentLexeme.value substringFromIndex:1];
                [expressions addObject:[[STKPXIdSelector alloc] initWithIdValue:name]];
                [self advance];
                break;
            }

            case STKPXSS_CLASS:
            {
                NSString *name = [(NSString *) currentLexeme.value substringFromIndex:1];
                [expressions addObject:[[STKPXClassSelector alloc] initWithClassName:name]];
                [self advance];
                break;
            }

            case STKPXSS_LBRACKET:
                [expressions addObject:[self parseAttributeSelector]];
                break;

            case STKPXSS_COLON:
                [expressions addObject:[self parsePseudoClass]];
                break;

            case STKPXSS_NOT_PSEUDO_CLASS:
                [expressions addObject:[self parseNotSelector]];
                break;

            case STKPXSS_ROOT_PSEUDO_CLASS:
                [expressions addObject:[[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateRoot]];
                [self advance];
                break;

            case STKPXSS_FIRST_CHILD_PSEUDO_CLASS:
                [expressions addObject:[[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateFirstChild]];
                [self advance];
                break;

            case STKPXSS_LAST_CHILD_PSEUDO_CLASS:
                [expressions addObject:[[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateLastChild]];
                [self advance];
                break;

            case STKPXSS_FIRST_OF_TYPE_PSEUDO_CLASS:
                [expressions addObject:[[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateFirstOfType]];
                [self advance];
                break;

            case STKPXSS_LAST_OF_TYPE_PSEUDO_CLASS:
                [expressions addObject:[[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateLastOfType]];
                [self advance];
                break;

            case STKPXSS_ONLY_CHILD_PSEUDO_CLASS:
                [expressions addObject:[[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateOnlyChild]];
                [self advance];
                break;

            case STKPXSS_ONLY_OF_TYPE_PSEUDO_CLASS:
                [expressions addObject:[[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateOnlyOfType]];
                [self advance];
                break;

            case STKPXSS_EMPTY_PSEUDO_CLASS:
                [expressions addObject:[[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateEmpty]];
                [self advance];
                break;

            case STKPXSS_NTH_CHILD_PSEUDO_CLASS:
            case STKPXSS_NTH_LAST_CHILD_PSEUDO_CLASS:
            case STKPXSS_NTH_OF_TYPE_PSEUDO_CLASS:
            case STKPXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS:
                [expressions addObject:[self parsePseudoClassFunction]];
                [self assertTypeAndAdvance:STKPXSS_RPAREN];
                break;

            // TODO: implement
            case STKPXSS_LINK_PSEUDO_CLASS:
            case STKPXSS_VISITED_PSEUDO_CLASS:
            case STKPXSS_HOVER_PSEUDO_CLASS:
            case STKPXSS_ACTIVE_PSEUDO_CLASS:
            case STKPXSS_FOCUS_PSEUDO_CLASS:
            case STKPXSS_TARGET_PSEUDO_CLASS:
            case STKPXSS_ENABLED_PSEUDO_CLASS:
            case STKPXSS_CHECKED_PSEUDO_CLASS:
            case STKPXSS_INDETERMINATE_PSEUDO_CLASS:
                [expressions addObject:[[STKPXPseudoClassSelector alloc] initWithClassName:currentLexeme.value]];
                [self advance];
                break;

            // TODO: implement
            case STKPXSS_LANG_PSEUDO_CLASS:
                [expressions addObject:[[STKPXPseudoClassSelector alloc] initWithClassName:currentLexeme.value]];
                [self advanceToType:STKPXSS_RPAREN];
                [self advance];
                break;

            default:
                break;
        }
    }

    if (expressions.count == 0 && ![currentLexeme flagIsSet:STKPXLexemeFlagFollowsWhitespace])
    {
        [self errorWithMessage:@"Expected ID, CLASS, LBRACKET, or PseudoClass"];
    }

    return expressions;
}

// level 6

- (STKPXPseudoClassFunction *)parsePseudoClassFunction
{
    // initialize to something to remove analyzer warnings, but the switch below has to cover all cases to prevent a
    // bug here
    STKPXPseudoClassFunctionType type = STKPXPseudoClassFunctionNthChild;

    switch (currentLexeme.type)
    {
        case STKPXSS_NTH_CHILD_PSEUDO_CLASS:
            type = STKPXPseudoClassFunctionNthChild;
            break;

        case STKPXSS_NTH_LAST_CHILD_PSEUDO_CLASS:
            type = STKPXPseudoClassFunctionNthLastChild;
            break;

        case STKPXSS_NTH_OF_TYPE_PSEUDO_CLASS:
            type = STKPXPseudoClassFunctionNthOfType;
            break;

        case STKPXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS:
            type = STKPXPseudoClassFunctionNthLastOfType;
            break;
    }

    // advance over function name and left paren
    [self advance];

    NSInteger modulus = 0;
    NSInteger remainder = 0;

    // parse modulus
    if ([self isType:STKPXSS_NTH])
    {
        NSString *numberString = currentLexeme.value;
        NSUInteger length = numberString.length;

        // extract modulus
        if (length == 1)
        {
            // we have 'n'
            modulus = 1;
        }
        else if (length == 2 && [numberString hasPrefix:@"-"])
        {
            // we have '-n'
            modulus = -1;
        }
        else if (length == 2 && [numberString hasPrefix:@"+"])
        {
            // we have '+n'
            modulus = 1;
        }
        else
        {
            // a number precedes 'n'
            modulus = [numberString substringWithRange:NSMakeRange(0, numberString.length - 1)].intValue;
        }

        [self advance];

        if ([self isType:STKPXSS_PLUS])
        {
            [self advance];

            // grab remainder
            [self assertType:STKPXSS_NUMBER];
            NSNumber *remainderNumber = currentLexeme.value;
            remainder = remainderNumber.intValue;
            [self advance];
        }
        else if ([self isType:STKPXSS_NUMBER])
        {
            NSString *numberString = [lexer_.source substringWithRange:currentLexeme.range];

            if ([numberString hasPrefix:@"-"] || [numberString hasPrefix:@"+"])
            {
                NSNumber *remainderNumber = currentLexeme.value;
                remainder = remainderNumber.intValue;
                [self advance];
            }
            else
            {
                [self errorWithMessage:@"Expected NUMBER with leading '-' or '+'"];
            }
        }
    }
    else if ([self isType:STKPXSS_IDENTIFIER])
    {
        NSString *stringValue = currentLexeme.value;

        if ([@"odd" isEqualToString:stringValue])
        {
            modulus = 2;
            remainder = 1;
        }
        else if ([@"even" isEqualToString:stringValue])
        {
            modulus = 2;
        }
        else
        {
            [self errorWithMessage:[NSString stringWithFormat:@"Unrecognized identifier '%@'. Expected 'odd' or 'even'", stringValue]];
        }

        [self advance];
    }
    else if ([self isType:STKPXSS_NUMBER])
    {
        modulus = 1;
        NSNumber *remainderNumber = currentLexeme.value;
        remainder = remainderNumber.intValue;

        [self advance];
    }
    else
    {
        [self errorWithMessage:@"Expected NTH, NUMBER, 'odd', or 'even'"];
    }

    return [[STKPXPseudoClassFunction alloc] initWithFunctionType:type modulus:modulus remainder:remainder];
}

- (id<STKPXSelector>)parseAttributeSelector
{
    id<STKPXSelector> result = nil;

    [self assertTypeAndAdvance:STKPXSS_LBRACKET];

    result = [self parseAttributeTypeSelector];

    if ([self isInTypeSet:ATTRIBUTE_OPERATOR_SET])
    {
        STKPXAttributeSelectorOperatorType operatorType = kAttributeSelectorOperatorEqual; // make anaylzer happy

        switch (currentLexeme.type)
        {
            case STKPXSS_STARTS_WITH:          operatorType = kAttributeSelectorOperatorStartsWith; break;
            case STKPXSS_ENDS_WITH:            operatorType = kAttributeSelectorOperatorEndsWith; break;
            case STKPXSS_CONTAINS:             operatorType = kAttributeSelectorOperatorContains; break;
            case STKPXSS_EQUAL:                operatorType = kAttributeSelectorOperatorEqual; break;
            case STKPXSS_LIST_CONTAINS:        operatorType = kAttributeSelectorOperatorListContains; break;
            case STKPXSS_EQUALS_WITH_HYPHEN:   operatorType = kAttributeSelectorOperatorEqualWithHyphen; break;

            default:
                [self errorWithMessage:@"Unsupported attribute operator type"];
                break;
        }

        [self advance];

        if ([self isType:STKPXSS_STRING])
        {
            NSString *value = currentLexeme.value;

            // process string
            result = [[STKPXAttributeSelectorOperator alloc] initWithOperatorType:operatorType
                                                             attributeSelector:result
                                                                   stringValue:[value substringWithRange:NSMakeRange(1, value.length - 2)]];

            [self advance];
        }
        else if ([self isType:STKPXSS_IDENTIFIER])
        {
            // process string
            result = [[STKPXAttributeSelectorOperator alloc] initWithOperatorType:operatorType
                                                             attributeSelector:result
                                                                   stringValue:currentLexeme.value];

            [self advance];
        }
        else
        {
            [self errorWithMessage:@"Expected STRING or IDENTIFIER"];
        }
    }

    [self assertTypeAndAdvance:STKPXSS_RBRACKET];

    return result;
}

- (id<STKPXSelector>)parsePseudoClass
{
    id<STKPXSelector> result = nil;

    [self assertType:STKPXSS_COLON];
    [self advance];

    if ([self isType:STKPXSS_IDENTIFIER])
    {
        // process identifier
        result = [[STKPXPseudoClassSelector alloc] initWithClassName:currentLexeme.value];
        [self advance];
    }
    else
    {
        [self errorWithMessage:@"Expected IDENTIFIER"];
    }

    // TODO: support an+b notation

    return result;
}

- (id<STKPXSelector>)parseNotSelector
{
    // advance over 'not'
    [self assertType:STKPXSS_NOT_PSEUDO_CLASS];
    [self advance];

    id<STKPXSelector> result = [[STKPXNotPseudoClass alloc] initWithExpression:[self parseNegationArgument]];

    // advance over ')'
    [self assertTypeAndAdvance:STKPXSS_RPAREN];

    return result;
}

// level 7

- (id<STKPXSelector>)parseAttributeTypeSelector
{
    STKPXAttributeSelector *result = nil;

    if ([self isInTypeSet:TYPE_SELECTOR_SET])
    {
        NSString *namespace = nil;
        NSString *name = nil;

        // namespace or type
        if ([self isInTypeSet:TYPE_NAME_SET])
        {
            // assume we have a name only
            name = currentLexeme.value;
            [self advance];
        }

        // if pipe, then we had a namespace, now process type
        if ([self isType:STKPXSS_PIPE])
        {
            namespace = name;

            // advance over '|'
            [self advance];

            if ([self isInTypeSet:TYPE_NAME_SET])
            {
                // set name
                name = currentLexeme.value;
                [self advance];
            }
            else
            {
                [self errorWithMessage:@"Expected IDENTIFIER or STAR"];
            }
        }
        // NOTE: default namepace is nil indicating no namespace should exist when matching with this selector. This
        // differs from the interpretation used on type selectors

        // find namespace URI from namespace prefix

        NSString *namespaceURI = nil;

        if (namespace)
        {
            if ([namespace isEqualToString:@"*"])
            {
                namespaceURI = namespace;
            }
            else
            {
                namespaceURI = [currentStyleSheet_ namespaceForPrefix:namespace];
            }
        }

        result = [[STKPXAttributeSelector alloc] initWithNamespaceURI:namespaceURI attributeName:name];
    }
    else
    {
        [self errorWithMessage:@"Expected IDENTIFIER, STAR, or PIPE"];
    }

    return result;
}

- (id<STKPXSelector>)parseNegationArgument
{
    id<STKPXSelector> result = nil;

    switch (currentLexeme.type)
    {
        case STKPXSS_ID:
        {
            NSString *name = [(NSString *) currentLexeme.value substringFromIndex:1];
            result = [[STKPXIdSelector alloc] initWithIdValue:name];
            [self advance];
            break;
        }

        case STKPXSS_CLASS:
        {
            NSString *name = [(NSString *) currentLexeme.value substringFromIndex:1];
            result = [[STKPXClassSelector alloc] initWithClassName:name];
            [self advance];
            break;
        }

        case STKPXSS_LBRACKET:
            result = [self parseAttributeSelector];
            break;

        case STKPXSS_COLON:
            result = [self parsePseudoClass];
            break;

        case STKPXSS_ROOT_PSEUDO_CLASS:
            result = [[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateRoot];
            [self advance];
            break;

        case STKPXSS_FIRST_CHILD_PSEUDO_CLASS:
            result = [[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateFirstChild];
            [self advance];
            break;

        case STKPXSS_LAST_CHILD_PSEUDO_CLASS:
            result = [[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateLastChild];
            [self advance];
            break;

        case STKPXSS_FIRST_OF_TYPE_PSEUDO_CLASS:
            result = [[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateFirstOfType];
            [self advance];
            break;

        case STKPXSS_LAST_OF_TYPE_PSEUDO_CLASS:
            result = [[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateLastOfType];
            [self advance];
            break;

        case STKPXSS_ONLY_CHILD_PSEUDO_CLASS:
            result = [[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateOnlyChild];
            [self advance];
            break;

        case STKPXSS_ONLY_OF_TYPE_PSEUDO_CLASS:
            result = [[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateOnlyOfType];
            [self advance];
            break;

        case STKPXSS_EMPTY_PSEUDO_CLASS:
            result = [[STKPXPseudoClassPredicate alloc] initWithPredicateType:STKPXPseudoClassPredicateEmpty];
            [self advance];
            break;

        case STKPXSS_NTH_CHILD_PSEUDO_CLASS:
        case STKPXSS_NTH_LAST_CHILD_PSEUDO_CLASS:
        case STKPXSS_NTH_OF_TYPE_PSEUDO_CLASS:
        case STKPXSS_NTH_LAST_OF_TYPE_PSEUDO_CLASS:
            result = [self parsePseudoClassFunction];
            [self assertTypeAndAdvance:STKPXSS_RPAREN];
            break;

            // TODO: implement
        case STKPXSS_LINK_PSEUDO_CLASS:
        case STKPXSS_VISITED_PSEUDO_CLASS:
        case STKPXSS_HOVER_PSEUDO_CLASS:
        case STKPXSS_ACTIVE_PSEUDO_CLASS:
        case STKPXSS_FOCUS_PSEUDO_CLASS:
        case STKPXSS_TARGET_PSEUDO_CLASS:
        case STKPXSS_ENABLED_PSEUDO_CLASS:
        case STKPXSS_CHECKED_PSEUDO_CLASS:
        case STKPXSS_INDETERMINATE_PSEUDO_CLASS:
            result = [[STKPXPseudoClassSelector alloc] initWithClassName:currentLexeme.value];
            [self advance];
            break;

            // TODO: implement
        case STKPXSS_LANG_PSEUDO_CLASS:
            result = [[STKPXPseudoClassSelector alloc] initWithClassName:currentLexeme.value];
            [self advanceToType:STKPXSS_RPAREN];
            [self advance];
            break;

        case STKPXSS_RPAREN:
            // empty body
            break;

        default:
            if ([self isInTypeSet:TYPE_SELECTOR_SET])
            {
                result = [self parseTypeSelector];
            }
            else
            {
                [self errorWithMessage:@"Expected ID, CLASS, AttributeSelector, PseudoClass, or TypeSelect as negation argument"];
            }
            break;
    }

    return result;
}

#pragma mark - STKPXStylesheetLexerDelegate Implementation

- (void)lexerDidPopSource
{
    if (activeImports_.count > 0)
    {
        [activeImports_ pop];
    }
    else
    {
        DDLogError(@"Tried to pop an empty activeImports array");
    }
}

#pragma mark - Overrides

- (STKPXStylesheetLexeme *)advance
{
    return currentLexeme = lexer_.nextLexeme;
}

- (NSString *)lexemeNameFromType:(int)type
{
    STKPXStylesheetLexeme *lexeme = [[STKPXStylesheetLexeme alloc] initWithType:type text:nil];

    return lexeme.name;
}

- (void)dealloc
{
    lexer_ = nil;
    currentStyleSheet_ = nil;
    currentSelector_ = nil;
    activeImports_ = nil;
}

#pragma mark - Helpers

- (void)addImportName:(NSString *)name
{
    if (name.length > 0)
    {
        if (activeImports_ == nil)
        {
            activeImports_ = [[NSMutableArray alloc] init];
        }

        [activeImports_ push:name];
    }
}

- (void)advanceToType:(NSInteger)type
{
    while (currentLexeme && currentLexeme.type != type)
    {
        [self advance];
    }
}

- (void)pushLexeme:(STKPXStylesheetLexeme *)lexeme
{
    [self->lexer_ pushLexeme:currentLexeme];

    currentLexeme = lexeme;
}

- (NSString *)currentFilename
{
    return (activeImports_.count > 0) ? [activeImports_.lastObject lastPathComponent] : nil;
}

- (void)addError:(NSString *)error
{
    NSString *offset = (currentLexeme.type != STKPXSS_EOF) ? [NSString stringWithFormat:@"%lu", (unsigned long) currentLexeme.range.location] : @"EOF";

    [self addError:error filename:[self currentFilename] offset:offset];
}

@end
