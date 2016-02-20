//
//  DXLyricLabel.m
//  仿QQ音乐
//
//  Created by simon on 16/1/16.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "DXLyricLabel.h"

@implementation DXLyricLabel

- (void)setProcessPercent:(CGFloat)processPercent{
    _processPercent = processPercent;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIColor *color = [UIColor orangeColor];
    [color set];
    
    rect.size.width = rect.size.width *self.processPercent;
    
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
    
    
}


@end
