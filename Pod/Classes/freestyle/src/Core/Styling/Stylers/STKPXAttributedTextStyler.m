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
//  STKPXAttributedTextStyler.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Robin Debreuil on 1/9/2014.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "STKPXAttributedTextStyler.h"

@implementation STKPXAttributedTextStyler

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        handlers = @{
                     // text                     
                     @"text" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                         context.text = declaration.stringValue;
                     },
                     
                     // color
                     @"color" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                         [context setPropertyValue:declaration.colorValue forName:@"color"];
                     },
                     
                     // fonts
                     @"font-family" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                         context.fontName = declaration.stringValue;
                     },
                     @"font-size" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                         context.fontSize = declaration.floatValue;
                     },
                     @"font-style" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                         context.fontStyle = declaration.stringValue;
                     },
                     @"font-weight" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                         context.fontWeight = (declaration.stringValue).lowercaseString;
                     },
                     @"font-stretch" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                         context.fontStretch = (declaration.stringValue).lowercaseString;
                     },
                     
                     // kerning
                     @"letter-spacing" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                         context.letterSpacing = declaration.letterSpacingValue;
                     },
                     
                     // special text
                     @"text-transform" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                         context.textTransform = (declaration.stringValue).lowercaseString;
                     },
                     @"text-decoration" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                         context.textDecoration = (declaration.stringValue).lowercaseString;
                     },
                     @"text-shadow" : ^(STKPXDeclaration *declaration, STKPXStylerContext *context) {
                         context.textShadow = declaration.shadowValue;
                     }
                     
                     };
    });
    
    return handlers;
}

@end
