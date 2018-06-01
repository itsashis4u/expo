/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI28_0_0RCTMultilineTextInputView.h"

#import <ReactABI28_0_0/ABI28_0_0RCTUtils.h>

#import "ABI28_0_0RCTUITextView.h"

@implementation ABI28_0_0RCTMultilineTextInputView
{
  ABI28_0_0RCTUITextView *_backedTextInputView;
}

- (instancetype)initWithBridge:(ABI28_0_0RCTBridge *)bridge
{
  if (self = [super initWithBridge:bridge]) {
    // `blurOnSubmit` defaults to `false` for <TextInput multiline={true}> by design.
    self.blurOnSubmit = NO;

    _backedTextInputView = [[ABI28_0_0RCTUITextView alloc] initWithFrame:self.bounds];
    _backedTextInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backedTextInputView.backgroundColor = [UIColor clearColor];
    _backedTextInputView.textColor = [UIColor blackColor];
    // This line actually removes 5pt (default value) left and right padding in UITextView.
    _backedTextInputView.textContainer.lineFragmentPadding = 0;
#if !TARGET_OS_TV
    _backedTextInputView.scrollsToTop = NO;
#endif
    _backedTextInputView.scrollEnabled = YES;
    _backedTextInputView.textInputDelegate = self;

    [self addSubview:_backedTextInputView];
  }

  return self;
}

ABI28_0_0RCT_NOT_IMPLEMENTED(- (instancetype)initWithFrame:(CGRect)frame)
ABI28_0_0RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)coder)

- (id<ABI28_0_0RCTBackedTextInputViewProtocol>)backedTextInputView
{
  return _backedTextInputView;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  ABI28_0_0RCTDirectEventBlock onScroll = self.onScroll;

  if (onScroll) {
    CGPoint contentOffset = scrollView.contentOffset;
    CGSize contentSize = scrollView.contentSize;
    CGSize size = scrollView.bounds.size;
    UIEdgeInsets contentInset = scrollView.contentInset;

    onScroll(@{
      @"contentOffset": @{
        @"x": @(contentOffset.x),
        @"y": @(contentOffset.y)
      },
      @"contentInset": @{
        @"top": @(contentInset.top),
        @"left": @(contentInset.left),
        @"bottom": @(contentInset.bottom),
        @"right": @(contentInset.right)
      },
      @"contentSize": @{
        @"width": @(contentSize.width),
        @"height": @(contentSize.height)
      },
      @"layoutMeasurement": @{
        @"width": @(size.width),
        @"height": @(size.height)
      },
      @"zoomScale": @(scrollView.zoomScale ?: 1),
    });
  }
}

@end
