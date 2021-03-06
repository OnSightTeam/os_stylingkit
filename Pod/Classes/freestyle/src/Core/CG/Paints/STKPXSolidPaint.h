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
//  STKPXSolidPaint.h
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 6/7/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXPaint.h"

/**
 *  STKPXSolidPaint is used to fill a contour with a solid color
 */
@interface STKPXSolidPaint : NSObject <STKPXPaint>

/**
 *  The color used when filling a specified contour
 */
@property (nonatomic, strong) UIColor *color;

/**
 *  Allocate and initialize a new solid paint with the specified color
 *
 *  @param color The color of this paint
 */
+ (instancetype)paintWithColor:(UIColor *)color;

/**
 *  Initialize a new solid paint with the specified color
 *
 *  @param color The color of this paint
 */
- (instancetype)initWithColor:(UIColor *)color NS_DESIGNATED_INITIALIZER;

@end
