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
//  STKPXBoxModel.h
//  Pixate
//
//  Modified by Anton Matosov on 12/30/15.
//  Created by Kevin Lindsey on 3/25/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "STKPXShape.h"
#import "STKPXBoundable.h"
#import "STKPXBorderInfo.h"

typedef NS_ENUM(unsigned int, STKPXBoxSizing) {
    STKPXBoxSizingContentBox,
    STKPXBoxSizingPaddingBox,
    STKPXBoxSizingBorderBox
};

@interface STKPXBoxModel : STKPXShape <STKPXBoundable>

@property (nonatomic) id<STKPXPaint> borderTopPaint;
@property (nonatomic) CGFloat borderTopWidth;
@property (nonatomic) STKPXBorderStyle borderTopStyle;

@property (nonatomic) id<STKPXPaint> borderRightPaint;
@property (nonatomic) CGFloat borderRightWidth;
@property (nonatomic) STKPXBorderStyle borderRightStyle;

@property (nonatomic) id<STKPXPaint> borderBottomPaint;
@property (nonatomic) CGFloat borderBottomWidth;
@property (nonatomic) STKPXBorderStyle borderBottomStyle;

@property (nonatomic) id<STKPXPaint> borderLeftPaint;
@property (nonatomic) CGFloat borderLeftWidth;
@property (nonatomic) STKPXBorderStyle borderLeftStyle;

@property (nonatomic) CGSize radiusTopLeft;
@property (nonatomic) CGSize radiusTopRight;
@property (nonatomic) CGSize radiusBottomRight;
@property (nonatomic) CGSize radiusBottomLeft;

@property (nonatomic, readonly) CGRect borderBounds;
@property (nonatomic, readonly) CGRect contentBounds;

@property (nonatomic) STKPXOffsets *padding;
@property (nonatomic) STKPXBoxSizing boxSizing;

- (instancetype)initWithBounds:(CGRect)bounds NS_DESIGNATED_INITIALIZER;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasBorder;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasCornerRadius;

@property (NS_NONATOMIC_IOSONLY, getter=isOpaque, readonly) BOOL opaque;

/**
 *  Set the corner radius of all corners to the specified value
 *
 *  @param radius A corner radius
 */
- (void)setCornerRadius:(CGFloat)radius;

/**
 *  Set the corner radius of all corners to the specified value
 *
 *  @param radii The x and y radii
 */
- (void)setCornerRadii:(CGSize)radii;

- (void)setBorderPaint:(id<STKPXPaint>)paint;
- (void)setBorderWidth:(CGFloat)width;
- (void)setBorderStyle:(STKPXBorderStyle)style;
- (void)setBorderPaint:(id<STKPXPaint>)paint width:(CGFloat)width style:(STKPXBorderStyle)style;

- (void)setBorderTopPaint:(id<STKPXPaint>)paint width:(CGFloat)width style:(STKPXBorderStyle)style;
- (void)setBorderRightPaint:(id<STKPXPaint>)paint width:(CGFloat)width style:(STKPXBorderStyle)style;
- (void)setBorderBottomPaint:(id<STKPXPaint>)paint width:(CGFloat)width style:(STKPXBorderStyle)style;
- (void)setBorderLeftPaint:(id<STKPXPaint>)paint width:(CGFloat)width style:(STKPXBorderStyle)style;

@end
