//
//  UIButtonAddition.h
//
//  Copyright 2012 Symbiotic Software LLC. All rights reserved.
//

@interface UIButton (Addition)

- (void)setImage:(UIImage *)image backgroundImage:(UIImage *)backgroundImage leftCap:(NSInteger)theLeftCap topCap:(NSInteger)theTopCap;
- (void)setTitle:(NSString *)title font:(UIFont *)font backgroundImage:(UIImage *)backgroundImage leftCap:(NSInteger)theLeftCap topCap:(NSInteger)theTopCap;

+ (UIButton *)buttonWithImage:(UIImage *)image backgroundImage:(UIImage *)backgroundImage leftCap:(NSInteger)theLeftCap topCap:(NSInteger)theTopCap;
+ (UIButton *)buttonWithTitle:(NSString *)title font:(UIFont *)font backgroundImage:(UIImage *)backgroundImage leftCap:(NSInteger)theLeftCap topCap:(NSInteger)theTopCap;

@end
