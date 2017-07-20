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
//  PXGraphics.h
//  Pixate
//
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

// categories
#import "UIColor+PXColors.h"

// math
#import "STKPXDimension.h"
#import "PXMath.h"
#import "STKPXVector.h"

// paints
#import "STKPXGradient.h"
#import "PXLinearGradient.h"
#import "PXPaint.h"
#import "STKPXPaintGroup.h"
#import "STKPXRadialGradient.h"
#import "STKPXSolidPaint.h"

// parsing
#import "STKPXSVGLoader.h"

// shadows
#import "STKPXShadow.h"
#import "STKPXShadowGroup.h"
#import "PXShadowPaint.h"

// shapes
#import "STKPXArc.h"
#import "PXBoundable.h"
#import "STKPXCircle.h"
#import "STKPXEllipse.h"
#import "STKPXLine.h"
#import "PXPaintable.h"
#import "STKPXPath.h"
#import "STKPXPie.h"
#import "STKPXPolygon.h"
#import "STKPXRectangle.h"
#import "PXRenderable.h"
#import "STKPXShapeDocument.h"
#import "STKPXShape.h"
#import "STKPXShapeGroup.h"
#ifdef PXTEXT_SUPPORT
#import "PXText.h"
#endif

// strokes
#import "STKPXNonScalingStroke.h"
#import "STKPXStroke.h"
#import "STKPXStrokeGroup.h"
#import "PXStrokeRenderer.h"
#import "STKPXStrokeStroke.h"

// views
#import "STKPXShapeView.h"
