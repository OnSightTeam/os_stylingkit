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
//  STKPXUITableViewHeaderFooterView.h
//  Pixate
//
//  Created by Paul Colton on 11/1/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *
 *  UITableViewHeaderFooterView supports the following element name:
 *
 *  - table-view-headerfooter-view
 *
 *  UITableViewHeaderFooterView adds support for the following children:
 *
 *  - background-view
 *  - text-label
 *
 *  background-view supports the following properties:
 *
 *  - STKPXOpacityStyler
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXBoxShadowStyler
 *
 *  textLabel supports the following properties:
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
 *  - attributed-text-label: <STKPXAttributedTextStyler>
 *
 *  UITableViewHeaderFooterView supports the following properties:
 *
 *  - STKPXTransformStyler
 *  - STKPXOpacityStyler
 *  - STKPXShapeStyler
 *  - STKPXFillStyler
 *  - STKPXBorderStyler
 *  - STKPXBoxShadowStyler
 *  - -ios-tint-color: <paint>
 */

@interface STKPXUITableViewHeaderFooterView : UITableViewHeaderFooterView

@end
