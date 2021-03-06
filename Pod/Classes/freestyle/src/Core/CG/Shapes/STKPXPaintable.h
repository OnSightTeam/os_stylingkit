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
//  STKPXStyleable.h
//  Pixate
//
//  Created by Kevin Lindsey on 6/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKPXStrokeRenderer.h"
#import "STKPXPaint.h"
#import "STKPXShadowPaint.h"

@class STKPXShape;

/**
 *  The STKPXPaintable protocol declares properties needed when rendering content to a CGContext.
 */
@protocol STKPXPaintable <NSObject>

/**
 *  A property returning a STKPXStrokeRenderer.
 *
 *  This renderer is used to paint the outline of a contour
 */
@property (nonatomic, strong) id<STKPXStrokeRenderer> stroke;

/**
 *  A property returning a STKPXPaint
 *
 *  This renderer is used to paint the interior of a contour
 */
@property (nonatomic, strong) id<STKPXPaint> fill;

/**
 *  A property indicating the opacity of a shape.
 *
 *  This value is in the closed interval [0,1] where 0 is transparent and 1 is opaque.
 */
@property (nonatomic) CGFloat opacity;

/**
 *  A property indicating if this shape is visible or not.
 */
@property (nonatomic) BOOL visible;

// NOTE: ideally the type here should be a protocol that returns a CGPathRef
/**
 *  A property returning a STKPXShape to be used as a clipping path on this shape
 */
@property (nonatomic, strong) STKPXShape *clippingPath;

/**
 *  A property returning a STKPXShadow to be used to case inner and outer shadows
 */
@property (nonatomic, strong) id<STKPXShadowPaint> shadow;

@end
