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
<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIButton.h
//  STKPXUIButton.h
========
//  STKUIButton.h
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIButton.h
//  Pixate
//
//  Created by Paul Colton on 9/13/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *
 *  UIButton supports the following element name:
 *
 *  - button
 *
 *  UIButton adds support for the following children:
 *
 *  - icon
 *  - attributed-text
 *
 *  UIButton supports the following pseudo-class states:
 *
 *  - normal (default)
 *  - highlighted
 *  - selected
 *  - disabled
 *
 *  UIButton supports the following properties:
 *
 *  - STKPXTransformStyler
 *  - STKPXLayoutStyler
 *  - STKPXOpacityStyler
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXBoxShadowStyler
 *  - STKPXTextShadowStyler
 *  - STKPXFontStyler
 *  - STKPXPaintStyler
 *  - content-edge-inset: <inset>
 *  - content-edge-top-inset: <length>
 *  - content-edge-right-inset: <length>
 *  - content-edge-bottom-inset: <length>
 *  - content-edge-left-inset: <length>
 *  - title-edge-inset: <inset>
 *  - title-edge-top-inset: <length>
 *  - title-edge-right-inset: <length>
 *  - title-edge-bottom-inset: <length>
 *  - title-edge-left-inset: <length>
 *  - image-edge-inset: <inset>
 *  - image-edge-top-inset: <length>
 *  - image-edge-right-inset: <length>
 *  - image-edge-bottom-inset: <length>
 *  - image-edge-left-inset: <length>
 *  - STKPXTextContentStyler
 *  - text-transform: lowercase | uppercase | capitalize
 *  - text-overflow: clip | ellipsis | ellipsis-head | ellipsis-middle | ellipsis-tail | character-wrap | word-wrap
 *  - STKPXAnimationStyler
 *
 *  UIButton icon supports the following properties:
 *
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXBoxShadowStyler
 *
 *  UIButton attributed-text supports the following properties:
 *  
 *  - STKPXAttributedTextStyler
 *
 */
<<<<<<<< HEAD:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKPXUIButton.h
@interface STKPXUIButton : UIButton
========
@interface STKUIButton : UIButton
>>>>>>>> 27bba7ae5b4ef1d48809e50f4d67780e15e00e9a:Pod/Classes/freestyle/src/Modules/UIModule/Controls/STKUIButton.h

@end
