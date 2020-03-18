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
//  STKPXUITableViewCell.h
//  Pixate
//
//  Created by Paul Colton on 10/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *
 *  UITableViewCell supports the following element name:
 *
 *  - table-view-cell
 *
 *  UITableViewCell supports the following pseudo-class states:
 *
 *  - normal (default)
 *  - selected
 *  - multiple
 *
 *  UITableViewCell adds support for the following children:
 *
 *  - content-view
 *  - text-label
 *  - detail-text-label
 *
 *  content-view supports the following properties:
 *
 *  - STKPXOpacityStyler
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXBoxShadowStyler
 *  - STKPXAnimationStyler
 *
 *  text-label supports the following properties:
 *
 *  - STKPXTransformStyler
 *  - STKPXLayoutStyler
 *  - STKPXOpacityStyler
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXFontStyler
 *  - STKPXPaintStyler
 *  - STKPXTextContentStyler
 *  - text-align: left | center | right
 *  - text-transform: lowercase | uppercase | capitalize
 *  - text-overflow: clip | ellipsis | ellipsis-head | ellipsis-middle | ellipsis-tail | character-wrap | word-wrap
 *  - STKPXAnimationStyler
 *
 *  text-label supports the following children:
 *
 *  - attributed-text
 *
 *  detail-text-label supports the following properties:
 *
 *  - STKPXTransformStyler
 *  - STKPXLayoutStyler
 *  - STKPXOpacityStyler
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXFontStyler
 *  - STKPXPaintStyler
 *  - STKPXTextContentStyler
 *  - text-align: left | center | right
 *  - text-transform: lowercase | uppercase | capitalize
 *  - text-overflow: clip | ellipsis | ellipsis-head | ellipsis-middle | ellipsis-tail | character-wrap | word-wrap
 *  - STKPXAnimationStyler
 *
 *  detail-text-label supports the following children:
 *
 *  - attributed-text
 *
 *  UITableViewCell supports the following properties:
 *
 *  - STKPXOpacityStyler
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXBoxShadowStyler
 *
 *  The attributed-text child supports the following properties:
 *
 *  - STKPXAttributedTextStyler
 *
 */

@interface STKPXUITableViewCell : UITableViewCell
@end