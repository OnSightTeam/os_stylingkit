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
//  STKPXText.h
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 7/2/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import "STKPXShape.h"

/**
 *  A STKPXShape sub-class used to render text
 */
@interface STKPXText : STKPXShape

/**
 *  A point indicating the location of the top of this text region
 */
@property (nonatomic) CGPoint origin;

/**
 *  The text to be rendered
 */
@property (nonatomic, strong) NSString *text;

/**
 *  The font name of the rendered text
 */
@property (nonatomic, strong) NSString *fontName;

/**
 *  The font size of the rendered text
 */
@property (nonatomic) CGFloat fontSize;

/**
 *  Allocates and initializes a new STKPXText instance using the specified text
 *
 *  @param text The text to render
 */
+ (instancetype)textWithString:(NSString *)text;

/**
 *  Initializers a newly allocated STKPXText instance and sets its text to the specified value
 *
 *  @param text The text to render
 */
- (instancetype)initWithString:(NSString *)text NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end
