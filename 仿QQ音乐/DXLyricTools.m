//
//  DXLyricTools.m
//  仿QQ音乐
//
//  Created by simon on 16/1/16.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "DXLyricTools.h"
#import "DXLycModel.h"

@implementation DXLyricTools
+ (NSArray *)lyricArrayWithFileName:(NSString *)lyricFileName{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    NSError *error;
    NSString *lyricString = [[NSString alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:lyricFileName ofType:nil] encoding:NSUTF8StringEncoding error:&error];
//    NSLog(@"%@",lyricString);
    NSArray * subLyricStrArray = [lyricString componentsSeparatedByString:@"\n"];
//    NSLog(@"%@",subLyricStrArray);

    for (NSString *subLyricStr in subLyricStrArray) {
//        NSLog(@"%@",subLyricStr);
        
        NSString *pattern = @"\\[\\d{2}:\\d{2}.\\d{2}\\]";
        NSRegularExpression *regx = [[NSRegularExpression alloc]initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
       NSArray *resultArray = [regx matchesInString:subLyricStr options:NSMatchingReportCompletion range:NSMakeRange(0, subLyricStr.length)];
        
//        NSArray<NSTextCheckingResult
        NSTextCheckingResult *result = resultArray.lastObject;
        NSUInteger lyricIndex = result.range.location + result.range.length;
       NSString *contentLyricStr = [subLyricStr substringFromIndex:lyricIndex];
//        NSLog(@"%@",contentLyricStr);
        
        for (NSTextCheckingResult *result in resultArray) {
            NSString *beginTime = [subLyricStr substringWithRange:result.range];
            DXLycModel *lycModel = [DXLycModel new];
            lycModel.beginTime = [self timeIntervalWithTimeString:beginTime];
            lycModel.lyricContent = contentLyricStr;
            
            [tempArray addObject:lycModel];
        }
    }
    
//    将获得的歌词时间按照升序排列
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"beginTime" ascending:YES];
    
 return   [tempArray sortedArrayUsingDescriptors:@[sort]];
}


+ (NSTimeInterval)timeIntervalWithTimeString:(NSString *)timeStr{
    NSString *originalTimeString = @"[00:00.00]";
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    fmt.dateFormat = @"[mm:ss.SS]";
    
    NSDate *currentDate = [fmt dateFromString:timeStr];
    NSDate *originalDate = [fmt dateFromString:originalTimeString];
    
    NSTimeInterval time = [currentDate timeIntervalSinceDate:originalDate];
    return time;
}
@end












