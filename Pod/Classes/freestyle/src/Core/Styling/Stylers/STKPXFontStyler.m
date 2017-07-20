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
//  PXFontStyler.m
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Paul Colton on 10/9/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXFontStyler.h"
#import "STKPXRectangle.h"
#import "STKPXFontRegistry.h"

@implementation STKPXFontStyler

- (NSDictionary *)declarationHandlers
{
    static __strong NSDictionary *handlers = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        handlers = @{
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
            }
        };
    });

    return handlers;
}

@end
