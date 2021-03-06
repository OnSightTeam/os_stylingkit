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
//  STKPXUIStepper.h
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *
 *  UIStepper supports the following element name:
 *
 *  - stepper
 *
 *  UIStepper supports the following properties:
 *
 *  - STKPXTransformStyler
 *  - STKPXLayoutStyler
 *  - STKPXOpacityStyler
 *  - STKPXPaintStyler
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXBoxShadowStyler
 *  - STKPXAnimationStyler
 *
 *  UIStepper supports the following pseudo-class states:
 *
 *  - normal (default)
 *  - highlighted
 *  - selected
 *  - disabled
 *
 *  UIStepper adds support for the following children:
 *
 *  - divider   // iOS 6.x only
 *  - increment // iOS 6.x only
 *  - decrement // iOS 6.x only
 *
 *  UIStepper divider supports the following properties:
 *
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXBoxShadowStyler
 *
 *  UIStepper increment supports the following properties:
 *
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXBoxShadowStyler
 *
 *  UIStepper decrement supports the following properties:
 *
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXBoxShadowStyler
 *
 */
@interface STKPXUIStepper : UIStepper

@end
