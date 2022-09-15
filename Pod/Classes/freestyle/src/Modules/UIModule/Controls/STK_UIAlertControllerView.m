/*
 * Copyright 2015-present StylingKit Development Team. All rights reserved..
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
// Created by Anton Matosov on 1/5/16.
//


#import "STKPXAnimationStyler.h"
#import "UIView+STKPXStyling-Private.h"
#import "STKPXOpacityStyler.h"
#import "STKPXShapeStyler.h"
#import "STKPXFillStyler.h"
#import "STKPXBorderStyler.h"
#import "STKPXBoxShadowStyler.h"
#import "STKPXStylingMacros.h"
#import "STK_UIAlertControllerView.h"

@implementation STK_UIAlertControllerView

+ (void) load
{
  if (self != STK_UIAlertControllerView.class)
    return;

  [UIView registerDynamicSubclass:self
                         forClass:[self targetSuperclass]
                  withElementName:@"alert-view"];
}

+ (Class)targetSuperclass
{
  static Class targetSuperclass = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
      targetSuperclass = NSClassFromString([[self description] substringFromIndex:3]);
  });

  return targetSuperclass;
}

- (NSArray*)viewStylers {
  static __strong NSArray* stylers = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
      stylers = @[
        STKPXOpacityStyler.sharedInstance,
        STKPXShapeStyler.sharedInstance,
        STKPXFillStyler.sharedInstance,
        STKPXBorderStyler.sharedInstance,
        STKPXBoxShadowStyler.sharedInstance,
        STKPXAnimationStyler.sharedInstance,
      ];
  });

  return stylers;
}

- (NSDictionary*)viewStylersByProperty {
  static NSDictionary* map = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
      map = [STKPXStyleUtils viewStylerPropertyMapForStyleable:self];
  });

  return map;
}

- (void)updateStyleWithRuleSet:(STKPXRuleSet*)ruleSet context:(STKPXStylerContext*)context {
  self.px_layer.contents = (__bridge id)(context.backgroundImage.CGImage);
}

// Px Wrapped Only
STKPX_PXWRAP_PROP(CALayer, layer);

// Styling overrides
STKPX_LAYOUT_SUBVIEWS_OVERRIDE

@end
