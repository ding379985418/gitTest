//
//  DXMusicTools.h
//  仿QQ音乐
//
//  Created by simon on 16/1/16.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVAudioPlayer;
@protocol DXMusicToolsDelegate <NSObject>
@optional
- (void)playerDidFinishPlaying:(AVAudioPlayer *)player;
@end

@interface DXMusicTools : NSObject

@property (nonatomic, assign) NSTimeInterval musicCurrentTime;
@property (nonatomic, assign,readonly) NSTimeInterval musicTotalTime;

@property (nonatomic, weak) id<DXMusicToolsDelegate>delegate;
//单例
+ (instancetype)sharedTools;
//播放音乐
- (void)playeMusicWithString:(DXMusicModel *)model;

- (void)pause;

- (void)resume;

- (void)playerJumpToPercent:(CGFloat)percent;
@end
