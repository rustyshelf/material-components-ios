// Copyright 2019-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "MaterialSnapshot.h"

#import <UIKit/UIKit.h>

#import "MaterialTextControls.h"

#import "MDCTextControlSnapshotTestHelpers.h"

#import "MDCBaseTextFieldTestsSnapshotTestHelpers.h"

// This timeout value is intended to be temporary. These snapshot tests currently take longer than
// we'd want them to. They don't come close to 30 seconds.
static const NSTimeInterval kTextFieldValidationAnimationTimeout = 30.0;

@implementation MDCTextControlSnapshotTestHelpers

#pragma mark Validation

+ (void)addTextControlToKeyWindow:(UIView<MDCTextControl> *)textControl {
  // Add the text control to a container view. This is the view we snapshot. Snapshotting this view
  // instead of the text control allows us to see the floating label go outside the bounds for the
  // outlined style
  UIView *container = [[UIView alloc] init];
  container.layer.borderColor = UIColor.blackColor.CGColor;
  container.layer.borderWidth = (CGFloat)1;
  [container addSubview:textControl];

  // Add the textfield to the window so it's part of a valid view hierarchy and things like
  // `-becomeFirstResponder` work.
  UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
  [keyWindow addSubview:container];
}

+ (void)removeTextControlFromKeyWindow:(UIView<MDCTextControl> *)textControl {
  UIView *container = [textControl superview];
  [textControl removeFromSuperview];
  [container removeFromSuperview];
}

+ (void)validateTextControl:(UIView<MDCTextControl> *)textControl
               withTestCase:(MDCSnapshotTestCase *)testCase {
  [MDCTextControlSnapshotTestHelpers forceLayoutOfTextControl:textControl];
  XCTestExpectation *expectation =
      [[XCTestExpectation alloc] initWithDescription:@"text_control_validation_expectation"];
  dispatch_async(dispatch_get_main_queue(), ^{
    // We take a snapshot of the text control so we don't have to remove it from the app
    // host's key window. Removing the text control from the app host's key window
    // before validation can affect the textt control's editing behavior, which has a
    // large effect on the appearance of the text control.
    UIView *textControlSnapshot = [[textControl superview] snapshotViewAfterScreenUpdates:YES];
    [MDCTextControlSnapshotTestHelpers generateSnapshotAndVerifyForView:textControlSnapshot
                                                           withTestCase:testCase];
    [expectation fulfill];
  });
  [testCase waitForExpectations:@[ expectation ] timeout:kTextFieldValidationAnimationTimeout];
}

+ (void)forceLayoutOfTextControl:(UIView<MDCTextControl> *)textControl {
  [textControl sizeToFit];
  [textControl setNeedsLayout];
  [textControl layoutIfNeeded];
  UIView *container = [textControl superview];
  CGRect textControlFrame = textControl.frame;
  CGFloat textControlWidth = CGRectGetWidth(textControlFrame);
  CGFloat textControlHeight = CGRectGetHeight(textControlFrame);
  CGFloat containerPadding = (CGFloat)15.0;
  CGFloat containerWidth = textControlWidth + (CGFloat)2.0 * containerPadding;
  CGFloat containerHeight = textControlHeight + (CGFloat)2.0 * containerPadding;
  CGRect newContainerFrame = CGRectMake(0, 0, containerWidth, containerHeight);
  CGRect newTextControlFrame =
      CGRectMake(containerPadding, containerPadding, CGRectGetWidth(textControlFrame),
                 CGRectGetHeight(textControlFrame));
  container.frame = newContainerFrame;
  textControl.frame = newTextControlFrame;
}

+ (void)generateSnapshotAndVerifyForView:(UIView *)view
                            withTestCase:(MDCSnapshotTestCase *)testCase {
  UIView *snapshotView = [view mdc_addToBackgroundView];
  [testCase snapshotVerifyView:snapshotView];
}

@end
