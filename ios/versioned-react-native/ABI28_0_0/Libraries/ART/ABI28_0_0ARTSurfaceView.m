/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI28_0_0ARTSurfaceView.h"

#import <ReactABI28_0_0/ABI28_0_0RCTLog.h>

#import "ABI28_0_0ARTNode.h"

@implementation ABI28_0_0ARTSurfaceView

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    self.opaque = NO;
  }

  return self;
}

- (void)insertReactABI28_0_0Subview:(UIView *)subview atIndex:(NSInteger)atIndex
{
  [super insertReactABI28_0_0Subview:subview atIndex:atIndex];
  [self insertSubview:subview atIndex:atIndex];
  [self invalidate];
}

- (void)removeReactABI28_0_0Subview:(UIView *)subview
{
  [super removeReactABI28_0_0Subview:subview];
  [self invalidate];
}

- (void)didUpdateReactABI28_0_0Subviews
{
  // Do nothing, as subviews are inserted by insertReactABI28_0_0Subview:
}

- (void)invalidate
{
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  for (ABI28_0_0ARTNode *node in self.subviews) {
    [node renderTo:context];
  }
}

@end
