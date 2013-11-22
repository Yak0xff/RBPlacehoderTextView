//
//  RBPlacehoderTextView.m
//  RBPlacehoderTextView
//
//  Created by Yongchao on 22/11/13.
//  Copyright (c) 2013 Yongchao. All rights reserved.
//

#import "RBPlacehoderTextView.h"


@interface RBPlacehoderTextView ()

@property (strong, nonatomic) UIView *keyboardView;
@property (assign, nonatomic) CGFloat previousKeyboardY;

- (void)handleKeyboardWillShowHideNotification:(NSNotification *)notification;
- (void)handlePanGesture:(UIPanGestureRecognizer *)pan;

@end



@implementation RBPlacehoderTextView

#pragma mark - Initialization


#pragma mark - Initialization

- (void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextDidChangeNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    _placeHolderTextColor = [UIColor lightGrayColor];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 8.0f);
    self.contentInset = UIEdgeInsetsZero;
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    self.font = [UIFont systemFontOfSize:16.0f];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    self.textAlignment = NSTextAlignmentLeft;
}



#pragma mark - Setters

- (void)setPlaceHolder:(NSString *)placeHolder
{
    if([placeHolder isEqualToString:_placeHolder]) {
        return;
    }
    
    NSUInteger maxChars = [RBPlacehoderTextView maxCharactersPerLine];
    if([placeHolder length] > maxChars) {
        placeHolder = [placeHolder substringToIndex:maxChars - 8];
        placeHolder = [[placeHolder stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAppendingFormat:@"..."];
    }
    
    _placeHolder = placeHolder;
    [self setNeedsDisplay];
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor
{
    if([placeHolderTextColor isEqual:_placeHolderTextColor]) {
        return;
    }
    
    _placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}

#pragma mark - Message text view

- (NSUInteger)numberOfLinesOfText
{
    return [RBPlacehoderTextView numberOfLinesForMessage:self.text];
}

+ (NSUInteger)maxCharactersPerLine
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 33 : 109;
}

+ (NSUInteger)numberOfLinesForMessage:(NSString *)text
{
    return (text.length / [RBPlacehoderTextView maxCharactersPerLine]) + 1;
}

#pragma mark - Text view overrides

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)insertText:(NSString *)text
{
    [super insertText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if([self.text length] == 0 && self.placeHolder) {
        CGRect placeHolderRect = CGRectMake(10.0f,
                                            7.0f,
                                            rect.size.width,
                                            rect.size.height);
        
        [self.placeHolderTextColor set];
        
        [self.placeHolder drawInRect:placeHolderRect
                            withFont:self.font
                       lineBreakMode:NSLineBreakByTruncatingTail
                           alignment:self.textAlignment];
    }
}

#pragma mark - Notifications

- (void)didReceiveTextDidChangeNotification:(NSNotification *)notification
{
    [self setNeedsDisplay];
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.editable = YES;
        
        self.inputAccessoryView = [[UIView alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleKeyboardWillShowHideNotification:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleKeyboardWillShowHideNotification:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleKeyboardWillShowHideNotification:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        
        
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_dismissivePanGestureRecognizer removeTarget:self action:@selector(handlePanGesture:)];
    _dismissivePanGestureRecognizer = nil;
    _keyboardDelegate = nil;
    _keyboardView = nil;
    
    _placeHolder = nil;
    _placeHolderTextColor = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
}

#pragma mark - Setters

- (void)setDismissivePanGestureRecognizer:(UIPanGestureRecognizer *)pan
{
    _dismissivePanGestureRecognizer = pan;
    [_dismissivePanGestureRecognizer addTarget:self action:@selector(handlePanGesture:)];
}

#pragma mark - Notifications

- (void)handleKeyboardWillShowHideNotification:(NSNotification *)notification
{
    if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        self.keyboardView.hidden = NO;
    }
    else if([notification.name isEqualToString:UIKeyboardDidShowNotification]) {
        self.keyboardView = self.inputAccessoryView.superview;
        self.keyboardView.hidden = NO;
        
        if(self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(keyboardDidShow)])
            [self.keyboardDelegate keyboardDidShow];
    }
    else if([notification.name isEqualToString:UIKeyboardDidHideNotification]) {
        self.keyboardView.hidden = NO;
        [self resignFirstResponder];
    }
}

#pragma mark - Gestures

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    if(!self.keyboardView || self.keyboardView.hidden)
        return;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    UIWindow *panWindow = [[UIApplication sharedApplication] keyWindow];
    CGPoint location = [pan locationInView:panWindow];
    CGPoint velocity = [pan velocityInView:panWindow];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.previousKeyboardY = self.keyboardView.frame.origin.y;
            break;
        case UIGestureRecognizerStateEnded:
            if(velocity.y > 0 && self.keyboardView.frame.origin.y > self.previousKeyboardY) {
                
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     self.keyboardView.frame = CGRectMake(0.0f,
                                                                          screenHeight,
                                                                          self.keyboardView.frame.size.width,
                                                                          self.keyboardView.frame.size.height);
                                     
                                     if(self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(keyboardWillBeDismissed)])
                                         [self.keyboardDelegate keyboardWillBeDismissed];
                                 }
                                 completion:^(BOOL finished) {
                                     self.keyboardView.hidden = YES;
                                     self.keyboardView.frame = CGRectMake(0.0f,
                                                                          self.previousKeyboardY,
                                                                          self.keyboardView.frame.size.width,
                                                                          self.keyboardView.frame.size.height);
                                     [self resignFirstResponder];
                                 }];
            }
            else { // gesture ended with no flick or a flick upwards, snap keyboard back to original position
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     if(self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(keyboardWillSnapBackToPoint:)]) {
                                         [self.keyboardDelegate keyboardWillSnapBackToPoint:CGPointMake(0.0f, self.previousKeyboardY)];
                                     }
                                     
                                     self.keyboardView.frame = CGRectMake(0.0f,
                                                                          self.previousKeyboardY,
                                                                          self.keyboardView.frame.size.width,
                                                                          self.keyboardView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){
                                 }];
            }
            break;
            
            // gesture is currently panning, match keyboard y to touch y
        default:
            if(location.y > self.keyboardView.frame.origin.y || self.keyboardView.frame.origin.y != self.previousKeyboardY) {
                
                CGFloat newKeyboardY = self.previousKeyboardY + (location.y - self.previousKeyboardY);
                newKeyboardY = newKeyboardY < self.previousKeyboardY ? self.previousKeyboardY : newKeyboardY;
                newKeyboardY = newKeyboardY > screenHeight ? screenHeight : newKeyboardY;
                
                self.keyboardView.frame = CGRectMake(0.0f,
                                                     newKeyboardY,
                                                     self.keyboardView.frame.size.width,
                                                     self.keyboardView.frame.size.height);
                
                if(self.keyboardDelegate && [self.keyboardDelegate respondsToSelector:@selector(keyboardDidScrollToPoint:)])
                    [self.keyboardDelegate keyboardDidScrollToPoint:CGPointMake(0.0f, newKeyboardY)];
            }
            break;
    }
}

@end
