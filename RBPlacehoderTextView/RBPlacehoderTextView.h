//
//  RBPlacehoderTextView.h
//  RBPlacehoderTextView
//
//  Created by Yongchao on 22/11/13.
//  Copyright (c) 2013 Yongchao. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol RBPlacehoderTextViewDelegate <NSObject>

@optional
- (void)keyboardDidShow;

- (void)keyboardDidScrollToPoint:(CGPoint)point;

- (void)keyboardWillBeDismissed;


- (void)keyboardWillSnapBackToPoint:(CGPoint)point;

@end



@interface RBPlacehoderTextView : UITextView


@property (copy, nonatomic) NSString *placeHolder;


@property (strong, nonatomic) UIColor *placeHolderTextColor;


- (NSUInteger)numberOfLinesOfText;

+ (NSUInteger)maxCharactersPerLine;


+ (NSUInteger)numberOfLinesForMessage:(NSString *)text;




@property (weak, nonatomic) id<RBPlacehoderTextViewDelegate> keyboardDelegate;


@property (strong, nonatomic) UIPanGestureRecognizer *dismissivePanGestureRecognizer;



@end
