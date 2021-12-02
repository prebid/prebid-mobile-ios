// Copyright 2018-present the Material Components for iOS authors. All Rights Reserved.
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

#import "MDCAlertControllerView.h"
#import "MDCAlertActionManager.h"
#import "MDCAlertControllerView+Private.h"

#import <MDFInternationalization/MDFInternationalization.h>

#import "MaterialButtons.h"
#import "MaterialMath.h"
#import "MaterialTypography.h"

// https://material.io/go/design-dialogs#dialogs-specs
static const MDCFontTextStyle kTitleTextStyle = MDCFontTextStyleTitle;
static const MDCFontTextStyle kMessageTextStyle = MDCFontTextStyleBody1;
static const MDCFontTextStyle kButtonTextStyle = MDCFontTextStyleButton;

static const CGFloat MDCDialogMaximumWidth = 560.0f;
static const CGFloat MDCDialogMinimumWidth = 280.0f;

static const CGFloat MDCDialogActionButtonMinimumHeight = 36.0f;
static const CGFloat MDCDialogActionButtonMinimumWidth = 48.0f;
static const CGFloat MDCDialogActionMinTouchTarget = 48.0f;

static const CGFloat MDCDialogMessageOpacity = 0.54f;

@interface MDCNonselectableTextView : UITextView
@end

@interface MDCAlertControllerView ()

@property(nonatomic, getter=isVerticalActionsLayout) BOOL verticalActionsLayout;

@property(nonatomic, strong, nullable) UIFont *buttonFont UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong, nullable) UIColor *buttonColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong, nullable) UIColor *buttonInkColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) BOOL enableRippleBehavior;

@end

@implementation MDCAlertControllerView {
  BOOL _mdc_adjustsFontForContentSizeCategory;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.autoresizesSubviews = NO;
    self.clipsToBounds = YES;

    self.orderVerticalActionsByEmphasis = NO;
    self.actionsHorizontalAlignment = MDCContentHorizontalAlignmentTrailing;
    self.actionsHorizontalAlignmentInVerticalLayout = MDCContentHorizontalAlignmentCenter;

    self.titleIconInsets = UIEdgeInsetsMake(24.0f, 24.0f, 12.0f, 24.0f);
    self.titleInsets = UIEdgeInsetsMake(24.0f, 24.0f, 20.0f, 24.0f);
    self.contentInsets = UIEdgeInsetsMake(24.0f, 24.0f, 24.0f, 24.0f);
    self.actionsInsets = UIEdgeInsetsMake(8.0f, 8.0f, 8.0f, 8.0f);
    self.actionsHorizontalMargin = 8.0f;
    self.actionsVerticalMargin = 12.0f;
    self.accessoryViewVerticalInset = 20.0f;

    self.titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.titleScrollView];

    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.contentScrollView];

    self.actionsScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.actionsScrollView];

    // Set the background color after all surface subviews are added.
    self.backgroundColor = [UIColor whiteColor];

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentNatural;
    if (self.mdc_adjustsFontForContentSizeCategory) {
      self.titleLabel.font = [UIFont mdc_preferredFontForMaterialTextStyle:MDCFontTextStyleTitle];
    } else {
      self.titleLabel.font = [MDCTypography titleFont];
    }
    self.titleLabel.accessibilityTraits |= UIAccessibilityTraitHeader;
    [self.titleScrollView addSubview:self.titleLabel];

    self.messageTextView = [[MDCNonselectableTextView alloc] initWithFrame:CGRectZero];
    self.messageTextView.textAlignment = NSTextAlignmentNatural;
    self.messageTextView.textContainerInset = UIEdgeInsetsZero;
    self.messageTextView.textContainer.lineFragmentPadding = 0.0f;
    self.messageTextView.editable = NO;
    self.messageTextView.scrollEnabled = NO;
    self.messageTextView.selectable = YES;  // Enables link tap.
    if (self.mdc_adjustsFontForContentSizeCategory) {
      self.messageTextView.font =
          [UIFont mdc_preferredFontForMaterialTextStyle:MDCFontTextStyleBody1];
    } else {
      self.messageTextView.font = [MDCTypography body1Font];
    }
    self.messageTextView.textColor = [UIColor colorWithWhite:0 alpha:MDCDialogMessageOpacity];
    // The messageTextView is a private API, and therefore it needs to inherit its background
    // color from the alert's background so it can be themed (necessary for dark mode support,
    // for instance).
    self.messageTextView.backgroundColor = UIColor.clearColor;
    [self.contentScrollView addSubview:self.messageTextView];

    [self setNeedsLayout];
  }

  return self;
}

- (NSString *)title {
  return self.titleLabel.text;
}

- (void)setTitle:(NSString *)title {
  self.titleLabel.text = title;

  [self setNeedsLayout];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
  super.backgroundColor = backgroundColor;
  self.titleScrollView.backgroundColor = backgroundColor;
  self.contentScrollView.backgroundColor = backgroundColor;
  self.actionsScrollView.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor {
  return super.backgroundColor;
}

- (void)addActionButton:(nonnull MDCButton *)button {
  if (button.superview == nil) {
    [self.actionsScrollView addSubview:button];
    if (_buttonColor) {
      // We only set if _buttonColor since settingTitleColor to nil doesn't
      // reset the title to the default
      [button setTitleColor:_buttonColor forState:UIControlStateNormal];
    }
    [button setTitleFont:_buttonFont forState:UIControlStateNormal];
    button.enableRippleBehavior = self.enableRippleBehavior;
    button.inkColor = self.buttonInkColor;
    // These two lines must be after @c setTitleFont:forState: in order to @c MDCButton to handle
    // dynamic type correctly.
    button.adjustsFontForContentSizeCategoryWhenScaledFontIsUnavailable =
        self.adjustsFontForContentSizeCategoryWhenScaledFontIsUnavailable;
    button.mdc_adjustsFontForContentSizeCategory = self.mdc_adjustsFontForContentSizeCategory;
    // TODO(#1726): Determine default text color values for Normal and Disabled
    button.minimumSize =
        CGSizeMake(MDCDialogActionButtonMinimumWidth, MDCDialogActionButtonMinimumHeight);
    // Set centerVisibleArea to YES by default.
    button.centerVisibleArea = YES;
  }
}

+ (void)styleAsTextButton:(nonnull MDCButton *)button {
  // This preserves default buttons style (as MDCFlatButton/text) for backward compatibility reasons
  UIColor *themeColor = [UIColor blackColor];
  [button setBackgroundColor:UIColor.clearColor forState:UIControlStateNormal];
  [button setTitleColor:themeColor forState:UIControlStateNormal];
  [button setImageTintColor:themeColor forState:UIControlStateNormal];
  [button setInkColor:[UIColor colorWithWhite:0.0f alpha:0.06f]];
  button.disabledAlpha = 1.0f;
  [button setElevation:MDCShadowElevationNone forState:UIControlStateNormal];
}

- (void)setTitleFont:(UIFont *)font {
  _titleFont = font;

  [self updateTitleFont];
}

- (void)updateTitleFont {
  UIFont *titleFont = self.titleFont ?: [[self class] titleFontDefault];
  if (self.mdc_adjustsFontForContentSizeCategory) {
    if (self.adjustsFontForContentSizeCategoryWhenScaledFontIsUnavailable) {
      titleFont =
          [titleFont mdc_fontSizedForMaterialTextStyle:kTitleTextStyle
                                  scaledForDynamicType:self.mdc_adjustsFontForContentSizeCategory];
    }
  }

  self.titleLabel.font = titleFont;
  [self setNeedsLayout];
}

+ (UIFont *)titleFontDefault {
  if ([MDCTypography.fontLoader isKindOfClass:[MDCSystemFontLoader class]]) {
    return [UIFont mdc_standardFontForMaterialTextStyle:kTitleTextStyle];
  }
  return [MDCTypography titleFont];
}

- (void)setTitleColor:(UIColor *)titleColor {
  _titleColor = titleColor;

  _titleLabel.textColor = titleColor;
}

- (NSTextAlignment)titleAlignment {
  return self.titleLabel.textAlignment;
}

- (void)setTitleAlignment:(NSTextAlignment)titleAlignment {
  self.titleLabel.textAlignment = titleAlignment;
}

- (UIImage *)titleIcon {
  return self.titleIconImageView.image;
}

- (void)setTitleIcon:(UIImage *)titleIcon {
  if (titleIcon == nil) {
    [self.titleIconImageView removeFromSuperview];
    self.titleIconImageView = nil;
    [self setNeedsLayout];
    return;
  }

  if (self.titleIconImageView == nil) {
    self.titleIconImageView = [[UIImageView alloc] initWithImage:titleIcon];
    self.titleIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.titleScrollView addSubview:self.titleIconImageView];
  } else {
    self.titleIconImageView.image = titleIcon;
  }

  self.titleIconImageView.tintColor = self.titleIconTintColor;
  [self setNeedsLayout];
}

- (void)setTitleIconTintColor:(UIColor *)titleIconTintColor {
  _titleIconTintColor = titleIconTintColor;
  self.titleIconImageView.tintColor = titleIconTintColor;
}

- (void)setTitleIconAlignment:(NSTextAlignment)titleIconAlignment {
  _titleIconAlignment = titleIconAlignment;
  [self setNeedsLayout];
}

- (void)setTitleIconView:(UIView *)titleIconView {
  if (titleIconView != nil && self.titleIconImageView != nil) {
    NSLog(@"Warning: unintended use of the API. The following APIs are not expected to be used"
           "together: 'setTitleIconView:' and `setTitleIcon:` API. Please set either, but not "
           "both at the same time. If 'titleIconView' is set, 'titleIcon' is ignored.");
    [self.titleIconImageView removeFromSuperview];
    self.titleIconImageView = nil;
    [self setNeedsLayout];
  }
  if (_titleIconView == nil || ![_titleIconView isEqual:titleIconView]) {
    if (_titleIconView != nil) {
      [_titleIconView removeFromSuperview];
    }
    _titleIconView = titleIconView;
    if (_titleIconView != nil) {
      [self.titleScrollView addSubview:_titleIconView];
    }
    [self setNeedsLayout];
  }
}

- (NSString *)message {
  return self.messageTextView.text;
}

- (void)setMessage:(NSString *)message {
  self.messageTextView.text = message;

  [self setNeedsLayout];
}

- (void)setMessageFont:(UIFont *)messageFont {
  _messageFont = messageFont;

  [self updateMessageFont];
}

- (void)updateMessageFont {
  UIFont *messageFont = self.messageFont ?: [[self class] messageFontDefault];
  if (self.mdc_adjustsFontForContentSizeCategory) {
    if (self.adjustsFontForContentSizeCategoryWhenScaledFontIsUnavailable) {
      messageFont = [messageFont
          mdc_fontSizedForMaterialTextStyle:kMessageTextStyle
                       scaledForDynamicType:self.mdc_adjustsFontForContentSizeCategory];
    }
  }

  self.messageTextView.font = messageFont;
  [self setNeedsLayout];
}

+ (UIFont *)messageFontDefault {
  if ([MDCTypography.fontLoader isKindOfClass:[MDCSystemFontLoader class]]) {
    return [UIFont mdc_standardFontForMaterialTextStyle:kMessageTextStyle];
  }
  return [MDCTypography body1Font];
}

- (void)setMessageColor:(UIColor *)messageColor {
  _messageColor = messageColor;

  _messageTextView.textColor = messageColor;
}

- (NSTextAlignment)messageAlignment {
  return self.messageTextView.textAlignment;
}

- (void)setMessageAlignment:(NSTextAlignment)messageAlignment {
  self.messageTextView.textAlignment = messageAlignment;
}

- (void)setAccessoryView:(UIView *)accessoryView {
  if (_accessoryView == accessoryView) {
    return;
  }

  if (_accessoryView.superview == self.contentScrollView) {
    [_accessoryView removeFromSuperview];
  }

  _accessoryView = accessoryView;

  if (_accessoryView) {
    [self.contentScrollView addSubview:_accessoryView];
  }

  [self setNeedsLayout];
}

- (void)setButtonFont:(UIFont *)font {
  _buttonFont = font;

  [self updateButtonFont];
}

- (void)updateButtonFont {
  UIFont *finalButtonFont = self.buttonFont ?: [[self class] buttonFontDefault];
  if (self.mdc_adjustsFontForContentSizeCategory) {
    if (self.adjustsFontForContentSizeCategoryWhenScaledFontIsUnavailable) {
      finalButtonFont = [finalButtonFont
          mdc_fontSizedForMaterialTextStyle:kTitleTextStyle
                       scaledForDynamicType:self.mdc_adjustsFontForContentSizeCategory];
    }
  }
  for (MDCButton *button in self.actionManager.buttonsInActionOrder) {
    [button setTitleFont:finalButtonFont forState:UIControlStateNormal];
  }

  [self setNeedsLayout];
}

+ (UIFont *)buttonFontDefault {
  if ([MDCTypography.fontLoader isKindOfClass:[MDCSystemFontLoader class]]) {
    return [UIFont mdc_standardFontForMaterialTextStyle:kButtonTextStyle];
  }
  return [MDCTypography titleFont];
}

- (void)setButtonColor:(UIColor *)color {
  _buttonColor = color;

  for (MDCButton *button in self.actionManager.buttonsInActionOrder) {
    [button setTitleColor:_buttonColor forState:UIControlStateNormal];
  }
}

- (void)setButtonInkColor:(UIColor *)color {
  _buttonInkColor = color;

  for (MDCButton *button in self.actionManager.buttonsInActionOrder) {
    button.inkColor = color;
  }
}

- (CGFloat)cornerRadius {
  return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
  if (MDCCGFloatEqual(cornerRadius, self.layer.cornerRadius)) {
    return;
  }
  self.layer.cornerRadius = cornerRadius;
  [self setNeedsLayout];
}

- (void)setEnableRippleBehavior:(BOOL)enableRippleBehavior {
  if (_enableRippleBehavior == enableRippleBehavior) {
    return;
  }
  _enableRippleBehavior = enableRippleBehavior;

  for (MDCButton *button in self.actionManager.buttonsInActionOrder) {
    button.enableRippleBehavior = enableRippleBehavior;
  }
}

#pragma mark - Internal

- (CGSize)actionFittingSizeInHorizontalLayout {
  CGSize size = CGSizeMake([self horizontalSpacing], 0.0f);
  NSArray<MDCButton *> *buttons = self.actionManager.buttonsInActionOrder;
  UIEdgeInsets actionsInsets = [self actionsInsetsForButtons:buttons isHorizontalLayout:YES];
  if (0 < buttons.count) {
    CGFloat maxButtonHeight =
        MAX(MDCDialogActionButtonMinimumHeight, MDCDialogActionMinTouchTarget);
    for (UIButton *button in buttons) {
      CGSize buttonSize = [button sizeThatFits:size];
      size.width += buttonSize.width;
      maxButtonHeight = MAX(maxButtonHeight, buttonSize.height);
    }
    size.height = actionsInsets.top + maxButtonHeight + actionsInsets.bottom;
  }

  return size;
}

- (CGSize)actionButtonsSizeInVerticalLayout {
  CGSize size = CGSizeZero;
  NSArray<MDCButton *> *buttons = self.actionManager.buttonsInActionOrder;
  UIEdgeInsets actionsInsets = [self actionsInsetsForButtons:buttons isHorizontalLayout:NO];
  if (0 < buttons.count) {
    size.height = actionsInsets.top + actionsInsets.bottom;
    CGFloat widthInset = actionsInsets.left + actionsInsets.right;
    for (NSUInteger index = 0; index < buttons.count; ++index) {
      MDCButton *button = buttons[index];
      CGSize buttonSize = [button sizeThatFits:size];
      CGFloat minButtonHeight =
          MAX(MDCDialogActionButtonMinimumHeight, MDCDialogActionMinTouchTarget);
      buttonSize.height = MAX(buttonSize.height, minButtonHeight);
      size.height += buttonSize.height;
      size.width = MAX(size.width, buttonSize.width + widthInset);
      if (button != buttons.lastObject) {
        MDCButton *nextButton = buttons[index + 1];
        CGFloat verticalMargin = [self actionsVerticalMarginBetweenTopButton:button
                                                                bottomButton:nextButton];
        size.height += verticalMargin;
      }
    }
  }

  return size;
}

- (UIEdgeInsets)actionsInsetsForButtons:(NSArray<MDCButton *> *)buttons
                     isHorizontalLayout:(BOOL)isHorizontalLayout {
  UIEdgeInsets actionInsets = self.actionsInsets;

  if (buttons.count == 0) {
    return actionInsets;
  }

  if (isHorizontalLayout) {
    CGFloat maxButtonHeight = MDCDialogActionButtonMinimumHeight;
    for (MDCButton *button in buttons) {
      CGSize buttonSize = [button sizeThatFits:CGSizeZero];
      maxButtonHeight = MAX(maxButtonHeight, buttonSize.height);
    }
    if (maxButtonHeight < MDCDialogActionMinTouchTarget) {
      // Adjust actionInsets when buttons don't meet the minimum touch area requirement.
      CGFloat verticalInsetsAdjustment = MDCDialogActionMinTouchTarget - maxButtonHeight;
      actionInsets.top -= verticalInsetsAdjustment / 2;
      actionInsets.bottom -= verticalInsetsAdjustment / 2;
    }
  } else {
    MDCButton *topButton = buttons.firstObject;
    CGSize topButtonSize = [topButton sizeThatFits:CGSizeZero];
    if (topButtonSize.height < MDCDialogActionMinTouchTarget) {
      CGFloat verticalInsetsAdjustment = MDCDialogActionMinTouchTarget - topButtonSize.height;
      actionInsets.top -= verticalInsetsAdjustment / 2;
    }
    MDCButton *bottomButton = buttons.lastObject;
    CGSize bottomButtonSize = [bottomButton sizeThatFits:CGSizeZero];
    if (bottomButtonSize.height < MDCDialogActionMinTouchTarget) {
      CGFloat verticalInsetsAdjustment = MDCDialogActionMinTouchTarget - bottomButtonSize.height;
      actionInsets.bottom -= verticalInsetsAdjustment / 2;
    }
  }

  return actionInsets;
}

- (CGFloat)actionsVerticalMarginBetweenTopButton:(MDCButton *)topButton
                                    bottomButton:(MDCButton *)bottomButton {
  CGFloat actionsVerticalMargin = self.actionsVerticalMargin;
  CGSize topButtonSize = [topButton sizeThatFits:CGSizeZero];
  if (topButtonSize.height < MDCDialogActionMinTouchTarget) {
    CGFloat verticalInsetsAdjustment = MDCDialogActionMinTouchTarget - topButtonSize.height;
    actionsVerticalMargin -= verticalInsetsAdjustment / 2;
  }
  CGSize bottomButtonSize = [bottomButton sizeThatFits:CGSizeZero];
  if (bottomButtonSize.height < MDCDialogActionMinTouchTarget) {
    CGFloat verticalInsetsAdjustment = MDCDialogActionMinTouchTarget - bottomButtonSize.height;
    actionsVerticalMargin -= verticalInsetsAdjustment / 2;
  }
  return actionsVerticalMargin;
}

- (CGFloat)horizontalSpacing {
  NSUInteger count = self.actionManager.buttonsInActionOrder.count;
  CGFloat spacing = self.actionsInsets.left + self.actionsInsets.right +
                    (count - 1) * self.actionsHorizontalMargin;
  return spacing;
}

- (CGFloat)widestAction {
  CGFloat widest = 0.0f;
  for (MDCButton *button in self.actionManager.buttonsInActionOrder) {
    // For justified alignment, minimumSize is used to control button's visible area.
    // If user sets a custom value, it is ignored because button's final size is decided
    // during layout.
    // We need to reset minimumSize during sizeThatFits: to make sure it doesn't affect the
    // calculation here.
    CGSize currentMinimumSize = CGSizeZero;
    if (self.actionsHorizontalAlignment == MDCContentHorizontalAlignmentJustified) {
      currentMinimumSize = button.minimumSize;
      button.minimumSize =
          CGSizeMake(MDCDialogActionButtonMinimumWidth, MDCDialogActionButtonMinimumHeight);
    }
    CGSize buttonSize = [button sizeThatFits:CGSizeZero];
    if (buttonSize.width > widest) {
      widest = buttonSize.width;
    }
    if (self.actionsHorizontalAlignment == MDCContentHorizontalAlignmentJustified) {
      button.minimumSize = currentMinimumSize;
    }
  }
  return widest;
}

- (BOOL)hasTitleIconOrImage {
  return [self hasTitleIcon] || self.titleIconView != nil;
}

- (BOOL)hasTitleIcon {
  return self.titleIconImageView.image.size.height > 0.0f;
}

- (BOOL)hasTitle {
  return self.title.length > 0;
}

- (BOOL)hasMessage {
  return self.message.length > 0;
}

- (BOOL)hasAccessoryView {
  CGSize accessoryViewSize = [self.accessoryView systemLayoutSizeFittingSize:CGRectInfinite.size];
  return accessoryViewSize.height > 0.0f;
}

- (CGSize)messageTextViewSizeThatFits:(CGSize)size {
  // Returns a size of zero when there's no message, to ensure no space is reserved for it.
  return [self.messageTextView hasText] ? [self.messageTextView sizeThatFits:size] : CGSizeZero;
}

/** Return the space between the title and the title icon, or 0 if any of them is missing. */
- (CGFloat)titleIconInsetBottom {
  return [self hasTitleIconOrImage] && [self hasTitle] ? self.titleIconInsets.bottom : 0.0f;
}

- (CGFloat)titleInsetTop {
  return [self hasTitleIconOrImage] ? self.titleIconInsets.top
                                    : ([self hasTitle] ? self.titleInsets.top : 0.f);
}

- (CGFloat)titleInsetBottom {
  return ([self hasTitle] || [self hasTitleIconOrImage]) ? self.titleInsets.bottom : 0.0f;
}

- (CGFloat)titleViewInsetLeft {
  return [self hasTitleIconOrImage] ? MIN(self.titleInsets.left, self.titleIconInsets.left)
                                    : self.titleInsets.left;
}

- (CGFloat)titleViewInsetRight {
  return [self hasTitleIconOrImage] ? MIN(self.titleInsets.right, self.titleIconInsets.right)
                                    : self.titleInsets.right;
}

- (CGFloat)contentInsetTop {
  return ([self hasTitle] || [self hasTitleIconOrImage]) ? 0.0f : self.contentInsets.top;
}

- (CGFloat)accessoryVerticalInset {
  return ([self hasMessage] && [self hasAccessoryView]) ? self.accessoryViewVerticalInset : 0.0f;
}

// Returns the size of the title view or the current size of the title icon imageView.
- (CGSize)titleIconViewSize {
  if (self.titleIconView != nil) {
    return self.titleIconView.frame.size;
  } else if (self.titleIconImageView != nil) {
    return self.titleIconImageView.frame.size;
  }
  return CGSizeZero;
}

// Returns the size of the title view or the original size of the title icon image.
- (CGSize)titleIconImageSize {
  if (self.titleIconView != nil) {
    return self.titleIconView.frame.size;
  } else if (self.titleIcon != nil) {
    return self.titleIcon.size;
  }
  return CGSizeZero;
}

- (CGRect)titleFrameWithTitleSize:(CGSize)titleSize {
  CGFloat leftInset = self.titleInsets.left;
  CGFloat titleTop =
      [self titleIconViewSize].height + [self titleInsetTop] + [self titleIconInsetBottom];
  return CGRectMake(leftInset, titleTop, titleSize.width, titleSize.height);
}

- (CGRect)messageFrameWithSize:(CGSize)messageSize {
  CGFloat top = [self contentInsetTop];
  return CGRectMake(self.contentInsets.left, top, messageSize.width, messageSize.height);
}

/**
 Calculate the frame of the titleIcon, given the title size and bounds size.

 @param titleSize is the pre-calculated size of the title.
 @param boundsSize is the total bounds without any internal margins or padding.
*/
- (CGRect)titleIconFrameWithTitleSize:(CGSize)titleSize boundsSize:(CGSize)boundsSize {
  CGSize titleIconViewSize = [self titleIconImageSize];
  CGFloat leftInset = self.titleIconInsets.left;
  CGFloat topInset = self.titleIconInsets.top;
  CGFloat titleIconHeight = titleIconViewSize.height;
  CGFloat titleIconWidth = titleIconViewSize.width;
  BOOL isRightOrRTLNatural = (self.titleIconAlignment == NSTextAlignmentRight ||
                              (self.titleIconAlignment == NSTextAlignmentNatural &&
                               [self mdf_effectiveUserInterfaceLayoutDirection] ==
                                   UIUserInterfaceLayoutDirectionRightToLeft));

  if (self.titleIconAlignment == NSTextAlignmentJustified) {
    // Justified images are sized to fit the alert's width (minus the insets).
    titleIconWidth = boundsSize.width - leftInset - self.titleIconInsets.right;
    if (titleIconViewSize.width > titleIconWidth && [self hasTitleIcon]) {
      // If the width decreased, then decrease the height proportionally.
      titleIconHeight *= titleIconWidth / titleIconViewSize.width;
    }
  } else {
    CGRect titleFrame = [self titleFrameWithTitleSize:titleSize];
    if (self.titleIconAlignment == NSTextAlignmentCenter) {
      leftInset =
          CGRectGetMinX(titleFrame) + (CGRectGetWidth(titleFrame) - titleIconViewSize.width) / 2.0f;
    } else if (isRightOrRTLNatural) {
      leftInset = CGRectGetMaxX(titleFrame) - titleIconViewSize.width;
    }
  }

  return CGRectMake(leftInset, topInset, titleIconWidth, titleIconHeight);
}

// @param boundsSize should not include any internal margins or padding
- (CGSize)calculatePreferredContentSizeForBounds:(CGSize)boundsSize {
  // Even if we have more room, limit our maximum width
  boundsSize.width = MIN(MAX(boundsSize.width, MDCDialogMinimumWidth), MDCDialogMaximumWidth);

  // Title, Content & Actions
  CGSize titleViewSize = [self calculateTitleViewSizeThatFitsWidth:boundsSize.width];
  CGSize contentSize = [self calculateContentSizeThatFitsWidth:boundsSize.width];
  CGSize actionSize = [self calculateActionsSizeThatFitsWidth:boundsSize.width];

  // Final Sizing
  CGSize totalSize;
  totalSize.width = MAX(MAX(titleViewSize.width, MAX(contentSize.width, actionSize.width)),
                        MDCDialogMinimumWidth);
  totalSize.height = titleViewSize.height + contentSize.height + actionSize.height;

  return totalSize;
}

// @param boundingWidth should not include any internal margins or padding
- (CGSize)calculateContentSizeThatFitsWidth:(CGFloat)boundingWidth {
  CGFloat contentInsets = self.contentInsets.left + self.contentInsets.right;
  CGFloat titleInsets = [self titleViewInsetLeft] + [self titleViewInsetRight];
  CGSize boundsSize = CGRectInfinite.size;

  boundsSize.width = boundingWidth - titleInsets;
  CGFloat titleWidth = [self.titleLabel sizeThatFits:boundsSize].width;

  boundsSize.width = boundingWidth - contentInsets;

  CGSize messageSize = [self messageTextViewSizeThatFits:boundsSize];
  CGSize accessoryViewSize = [self.accessoryView systemLayoutSizeFittingSize:boundsSize];

  CGFloat maxWidth = MAX(messageSize.width, accessoryViewSize.width);
  CGFloat contentWidth = MAX(titleWidth + titleInsets, maxWidth + contentInsets);

  CGFloat totalElementsHeight = messageSize.height + accessoryViewSize.height;
  CGFloat contentHeight = (fabs(contentWidth) <= FLT_EPSILON) || totalElementsHeight <= FLT_EPSILON
                              ? 0.0f
                              : totalElementsHeight + [self accessoryVerticalInset] +
                                    self.contentInsets.bottom + [self contentInsetTop];

  return CGSizeMake((CGFloat)ceil(contentWidth), (CGFloat)ceil(contentHeight));
}

/**
 Calculate the size of the title frame, which includes an optional title, optional title icon and
 optional icon view.

 @param boundingWidth should not include any internal margins or padding
*/
- (CGSize)calculateTitleViewSizeThatFitsWidth:(CGFloat)boundingWidth {
  CGFloat contentInsets = self.contentInsets.left + self.contentInsets.right;
  CGFloat titleInsets = [self titleViewInsetLeft] + [self titleViewInsetRight];

  CGSize contentSize = CGRectInfinite.size;
  contentSize.width = boundingWidth - contentInsets;
  CGFloat messageWidth = [self messageTextViewSizeThatFits:contentSize].width;
  CGFloat contentWidth =
      MAX(messageWidth, [self.accessoryView systemLayoutSizeFittingSize:contentSize].width);

  CGSize titleViewSize = CGRectInfinite.size;
  titleViewSize.width = boundingWidth - titleInsets;
  CGSize titleLabelSize = [self.titleLabel sizeThatFits:titleViewSize];
  CGSize titleIconSize = [self titleIconViewSize];
  CGFloat titleViewWidth = MAX(titleLabelSize.width + titleInsets, contentWidth + contentInsets);

  CGFloat totalElementsHeight = titleIconSize.height + titleLabelSize.height;
  CGFloat titleHeight = totalElementsHeight + [self titleInsetTop] + [self titleIconInsetBottom] +
                        [self titleInsetBottom];

  return CGSizeMake((CGFloat)ceil(titleViewWidth), (CGFloat)ceil(titleHeight));
}

// @param boundingWidth should not include any internal margins or padding
- (CGSize)calculateActionsSizeThatFitsWidth:(CGFloat)boundingWidth {
  CGSize boundsSize = CGRectInfinite.size;
  boundsSize.width = boundingWidth;

  CGSize horizontalSize = [self actionFittingSizeInHorizontalLayout];
  CGSize verticalSize = [self actionButtonsSizeInVerticalLayout];

  BOOL isVertical = boundsSize.width < horizontalSize.width;
  NSUInteger count = self.actionManager.buttonsInActionOrder.count;
  if (self.actionsHorizontalAlignment == MDCContentHorizontalAlignmentJustified && count > 1) {
    // b/155350470: ensure long justified actions are vertically aligned based on the longest
    // button.
    isVertical =
        [self widestAction] > (CGFloat)ceil((boundingWidth - [self horizontalSpacing]) / count);
  }
  CGSize actionsSize;
  if (isVertical) {
    // Use VerticalLayout
    if (self.actionsHorizontalAlignmentInVerticalLayout == MDCContentHorizontalAlignmentJustified) {
      verticalSize.width = boundingWidth - (self.actionsInsets.left + self.actionsInsets.right);
    }
    actionsSize.width = MIN(verticalSize.width, boundsSize.width);
    actionsSize.height = MIN(verticalSize.height, boundsSize.height);
    self.verticalActionsLayout = YES;
  } else {
    // Use HorizontalLayout
    if (self.actionsHorizontalAlignment == MDCContentHorizontalAlignmentJustified) {
      horizontalSize.width = boundingWidth - (self.actionsInsets.left + self.actionsInsets.right);
    }
    actionsSize.width = MIN(horizontalSize.width, boundsSize.width);
    actionsSize.height = MIN(horizontalSize.height, boundsSize.height);
    self.verticalActionsLayout = NO;
  }

  actionsSize.width = (CGFloat)ceil(actionsSize.width);
  actionsSize.height = (CGFloat)ceil(actionsSize.height);

  return actionsSize;
}

- (BOOL)canBecomeFirstResponder {
  return YES;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  // Used to calculate the height of the scrolling content, so we limit the width.
  CGSize boundsSize = CGRectInfinite.size;
  boundsSize.width = CGRectGetWidth(self.bounds);

  // Title view
  CGSize titleViewSize = [self calculateTitleViewSizeThatFitsWidth:boundsSize.width];

  CGRect titleViewRect = CGRectZero;
  titleViewRect.size.width = CGRectGetWidth(self.bounds);
  titleViewRect.size.height = titleViewSize.height;

  self.titleScrollView.contentSize = titleViewRect.size;
  self.titleScrollView.frame = titleViewRect;

  // Content
  CGSize contentSize = [self calculateContentSizeThatFitsWidth:boundsSize.width];

  CGRect contentRect = CGRectZero;
  contentRect.size.width = CGRectGetWidth(self.bounds);
  contentRect.size.height = contentSize.height;

  self.contentScrollView.contentSize = contentRect.size;

  // Place Content in contentScrollView
  CGSize titleBoundsSize = boundsSize;
  titleBoundsSize.width = boundsSize.width - (self.titleInsets.left + self.titleInsets.right);
  CGSize titleSize = [self.titleLabel sizeThatFits:titleBoundsSize];
  titleSize.width = titleBoundsSize.width;

  CGSize contentBoundsSize = boundsSize;
  contentBoundsSize.width = boundsSize.width - (self.contentInsets.left + self.contentInsets.right);
  CGSize messageSize = [self messageTextViewSizeThatFits:contentBoundsSize];
  messageSize.width = contentBoundsSize.width;

  CGSize accessoryViewSize =
      [self.accessoryView systemLayoutSizeFittingSize:contentBoundsSize
                        withHorizontalFittingPriority:UILayoutPriorityRequired
                              verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
  accessoryViewSize.width = contentBoundsSize.width;

  CGRect titleIconImageViewRect = [self titleIconFrameWithTitleSize:titleSize
                                                         boundsSize:boundsSize];
  if (self.titleIconView != nil) {
    self.titleIconView.frame = titleIconImageViewRect;
  } else if (self.titleIconImageView != nil) {
    // Match the title icon alignment to the title alignment.
    self.titleIconImageView.frame = titleIconImageViewRect;
  }

  // Calculate the title frame after the title icon size has been determined.
  CGRect titleFrame = [self titleFrameWithTitleSize:titleSize];
  CGRect messageFrame = [self messageFrameWithSize:messageSize];
  CGRect accessoryViewFrame = CGRectMake(
      self.contentInsets.left, CGRectGetMaxY(messageFrame) + [self accessoryVerticalInset],
      accessoryViewSize.width, accessoryViewSize.height);

  self.titleLabel.frame = titleFrame;
  self.messageTextView.frame = messageFrame;
  self.accessoryView.frame = accessoryViewFrame;

  // Actions
  NSArray<MDCButton *> *buttons = self.actionManager.buttonsInActionOrder;
  CGSize actionSize = [self calculateActionsSizeThatFitsWidth:boundsSize.width];

  CGRect actionsFrame = CGRectZero;
  actionsFrame.size.width = CGRectGetWidth(self.bounds);
  if (buttons.count > 0) {
    actionsFrame.size.height = actionSize.height;
  }
  self.actionsScrollView.contentSize = actionsFrame.size;

  for (MDCButton *button in buttons) {
    [button sizeToFit];
    CGRect buttonFrame = button.frame;
    button.frame = CGRectMake(buttonFrame.origin.x, buttonFrame.origin.y,
                              MAX(MDCDialogActionMinTouchTarget, CGRectGetWidth(buttonFrame)),
                              MAX(MDCDialogActionMinTouchTarget, CGRectGetHeight(buttonFrame)));
  }

  if (self.isVerticalActionsLayout) {
    [self layoutVerticalButtons:buttons];
  } else {
    [self layoutHorizontalButtons:buttons actionSize:actionSize];
  }

  // Place scrollviews
  CGRect contentScrollViewRect = CGRectZero;
  contentScrollViewRect.size = self.contentScrollView.contentSize;
  contentScrollViewRect.origin.y = CGRectGetMaxY(titleFrame) + [self titleInsetBottom];

  CGRect actionsScrollViewRect = CGRectZero;
  actionsScrollViewRect.size = self.actionsScrollView.contentSize;
  actionsScrollViewRect.origin.y = CGRectGetHeight(self.bounds) - actionsScrollViewRect.size.height;

  const CGFloat requestedHeight = contentScrollViewRect.origin.y +
                                  self.contentScrollView.contentSize.height +
                                  self.actionsScrollView.contentSize.height;
  // Check the layout: do both content and actions fit on the screen at once?
  if (requestedHeight > CGRectGetHeight(self.bounds)) {
    // Complex layout case : Split the space between the two scrollviews.
    CGFloat maxActionsHeight = CGRectGetHeight(self.bounds) / 2.0f;
    if (CGRectGetHeight(contentScrollViewRect) < maxActionsHeight) {
      maxActionsHeight =
          MIN(maxActionsHeight, CGRectGetHeight(self.bounds) - contentScrollViewRect.size.height);
    }
    actionsScrollViewRect.size.height = MIN(maxActionsHeight, actionsScrollViewRect.size.height);
    contentScrollViewRect.size.height =
        MAX(0.f, actionsScrollViewRect.origin.y - contentScrollViewRect.origin.y);

    self.messageTextView.accessibilityFrame = UIAccessibilityConvertFrameToScreenCoordinates(
        CGRectMake(messageFrame.origin.x, contentScrollViewRect.origin.y, messageFrame.size.width,
                   MIN(contentScrollViewRect.size.height, messageFrame.size.height)),
        self);
  }
  self.actionsScrollView.frame = actionsScrollViewRect;
  self.contentScrollView.frame = contentScrollViewRect;
}

- (void)layoutHorizontalButtons:(NSArray<MDCButton *> *)buttons actionSize:(CGSize)actionSize {
  UIEdgeInsets actionsInsets = [self actionsInsetsForButtons:buttons isHorizontalLayout:YES];
  CGFloat maxButtonWidth =
      self.actionsScrollView.contentSize.width - (actionsInsets.left + actionsInsets.right);
  CGPoint buttonOrigin = CGPointZero;
  CGFloat buttonWidth = 0.f;
  CGFloat multiplier =
      self.actionsHorizontalAlignment == MDCContentHorizontalAlignmentLeading ? 1.f : -1.f;
  if (self.actionsHorizontalAlignment == MDCContentHorizontalAlignmentLeading) {
    buttonOrigin.x = actionsInsets.left;
  } else if (self.actionsHorizontalAlignment == MDCContentHorizontalAlignmentCenter) {
    CGFloat actionWidthNoInsets = actionSize.width - actionsInsets.left - actionsInsets.right;
    buttonOrigin.x = ((self.actionsScrollView.contentSize.width - actionWidthNoInsets) / 2.f) +
                     actionWidthNoInsets;
  } else {  // trailing or justified
    buttonOrigin.x = self.actionsScrollView.contentSize.width - actionsInsets.right;
  }
  buttonOrigin.y = actionsInsets.top;
  for (MDCButton *button in buttons) {
    CGRect buttonRect = button.frame;

    buttonWidth = buttonRect.size.width;
    if (self.actionsHorizontalAlignment == MDCContentHorizontalAlignmentJustified) {
      if (buttons.count > 1) {
        CGFloat totalMargin = self.actionsHorizontalMargin * (buttons.count - 1);
        buttonWidth = (maxButtonWidth - totalMargin) / buttons.count;
      } else {
        buttonWidth = maxButtonWidth;
      }
      // Adjust minimumSize based on maxButtonWidth to increase the visible area of button.
      button.minimumSize = CGSizeMake(MAX(buttonWidth, MDCDialogActionButtonMinimumWidth),
                                      button.minimumSize.height);
    }

    if (self.actionsHorizontalAlignment != MDCContentHorizontalAlignmentLeading) {
      buttonOrigin.x += multiplier * buttonWidth;
    }

    buttonRect.origin = buttonOrigin;
    buttonRect.size.width = buttonWidth;

    button.frame = buttonRect;

    if (button != buttons.lastObject) {
      if (self.actionsHorizontalAlignment == MDCContentHorizontalAlignmentLeading) {
        buttonOrigin.x += multiplier * (buttonWidth + self.actionsHorizontalMargin);
      } else {
        buttonOrigin.x += multiplier * self.actionsHorizontalMargin;
      }
    }
  }
  // Handle RTL
  if (self.mdf_effectiveUserInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
    for (UIButton *button in buttons) {
      CGRect flippedRect = MDFRectFlippedHorizontally(button.frame, CGRectGetWidth(self.bounds));
      button.frame = flippedRect;
    }
  }
}

- (void)layoutVerticalButtons:(NSArray<MDCButton *> *)buttons {
  UIEdgeInsets actionsInsets = [self actionsInsetsForButtons:buttons isHorizontalLayout:NO];
  CGFloat maxButtonWidth =
      self.actionsScrollView.contentSize.width - (actionsInsets.left + actionsInsets.right);
  CGFloat multiplier = self.orderVerticalActionsByEmphasis ? 1.f : -1.f;
  CGPoint buttonCenter;
  CGPoint buttonOrigin;
  buttonOrigin.y = self.orderVerticalActionsByEmphasis
                       ? actionsInsets.top
                       : self.actionsScrollView.contentSize.height - actionsInsets.top;
  if (self.actionsHorizontalAlignmentInVerticalLayout == MDCContentHorizontalAlignmentCenter ||
      self.actionsHorizontalAlignmentInVerticalLayout == MDCContentHorizontalAlignmentJustified) {
    buttonCenter.x = self.actionsScrollView.contentSize.width / 2.0f;
    buttonCenter.y = buttonOrigin.y;
    for (NSUInteger index = 0; index < buttons.count; ++index) {
      MDCButton *button = buttons[index];
      CGRect buttonRect = button.bounds;

      if (CGRectGetWidth(buttonRect) > maxButtonWidth ||
          self.actionsHorizontalAlignmentInVerticalLayout ==
              MDCContentHorizontalAlignmentJustified) {
        buttonRect.size.width = maxButtonWidth;
        button.bounds = buttonRect;
        // Adjust minimumSize based on maxButtonWidth to increase the visible area of button.
        button.minimumSize = CGSizeMake(MAX(maxButtonWidth, MDCDialogActionButtonMinimumWidth),
                                        button.minimumSize.height);
      }

      buttonCenter.y += multiplier * (buttonRect.size.height / 2.0f);

      button.center = buttonCenter;

      if (button != buttons.lastObject) {
        buttonCenter.y += multiplier * (buttonRect.size.height / 2.0f);
        MDCButton *nextButton = buttons[index + 1];
        CGFloat verticalMargin = [self actionsVerticalMarginBetweenTopButton:button
                                                                bottomButton:nextButton];
        buttonCenter.y += multiplier * verticalMargin;
      }
    }

  } else {  // Leading/Trailing alignment.
    for (NSUInteger index = 0; index < buttons.count; ++index) {
      MDCButton *button = buttons[index];
      CGRect buttonRect = button.bounds;
      buttonOrigin.x = actionsInsets.left;
      if (self.actionsHorizontalAlignmentInVerticalLayout ==
          MDCContentHorizontalAlignmentTrailing) {
        buttonOrigin.x =
            self.actionsScrollView.contentSize.width - buttonRect.size.width - actionsInsets.right;
      }
      buttonRect.origin = buttonOrigin;
      button.frame = buttonRect;
      if (button != buttons.lastObject) {
        MDCButton *nextButton = buttons[index + 1];
        CGFloat verticalMargin = [self actionsVerticalMarginBetweenTopButton:button
                                                                bottomButton:nextButton];
        buttonOrigin.y += multiplier * (buttonRect.size.height + verticalMargin);
      }
    }
    // Handle RTL
    if (self.mdf_effectiveUserInterfaceLayoutDirection ==
        UIUserInterfaceLayoutDirectionRightToLeft) {
      for (UIButton *button in buttons) {
        CGRect flippedRect = MDFRectFlippedHorizontally(button.frame, CGRectGetWidth(self.bounds));
        button.frame = flippedRect;
      }
    }
  }
}

#pragma mark - Dynamic Type

- (BOOL)mdc_adjustsFontForContentSizeCategory {
  return _mdc_adjustsFontForContentSizeCategory;
}

- (void)mdc_setAdjustsFontForContentSizeCategory:(BOOL)adjusts {
  _mdc_adjustsFontForContentSizeCategory = adjusts;

  for (MDCButton *button in self.actionManager.buttonsInActionOrder) {
    button.mdc_adjustsFontForContentSizeCategory = adjusts;
  }

  [self updateFonts];
}

// Update the fonts used based on whether Dynamic Type is enabled.
- (void)updateFonts {
  [self updateTitleFont];
  [self updateMessageFont];
  [self updateButtonFont];

  [self setNeedsLayout];
}

@end

@implementation MDCNonselectableTextView

// Disabling text selection when selectable is YES, while allowing gestures for inlined links.
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  if (![super pointInside:point withEvent:event]) {
    return NO;
  }

  UITextPosition *position = [self closestPositionToPoint:point];
  if (!position) {
    return NO;
  }

  UITextRange *range = [self.tokenizer rangeEnclosingPosition:position
                                              withGranularity:UITextGranularityCharacter
                                                  inDirection:UITextLayoutDirectionLeft];
  if (!range) {
    return NO;
  }

  NSInteger offset = [self offsetFromPosition:self.beginningOfDocument toPosition:range.start];
  id link = [self.attributedText attribute:NSLinkAttributeName atIndex:offset effectiveRange:nil];
  return link != nil;
}

@end
