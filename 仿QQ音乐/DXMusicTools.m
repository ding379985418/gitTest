//
//  DXMusicTools.m
//  仿QQ音乐
//
//  Created by simon on 16/1/16.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "DXMusicTools.h"
#import <AVFoundation/AVFoundation.h>
@interface DXMusicTools ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) DXMusicModel *currentModel;
@end
@implementation DXMusicTools

+ (instancetype)sharedTools{
    static DXMusicTools *tools;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tools = [[DXMusicTools alloc]init];
    });
    
    return tools;
}

- (void)playeMusicWithString:(DXMusicModel *)model{
    if (model == self.currentModel) {
        return;
    }
    NSURL *musicUrl = [[NSBundle mainBundle]URLForResource:model.mp3 withExtension:nil];
//    NSURL *musicUrl = [NSURL URLWithString:@"http://localhost/Jason%20Mraz%20-%20I'm%20Yours.mp3"];
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:musicUrl error:nil];
    self.player.delegate = self;
    [self.player play];
    
    self.currentModel = model;

}

- (void)pause{
    
    [self.player pause];
}

- (void)resume{
 [self.player play];
}

- (NSTimeInterval)musicTotalTime{
 
    return self.player.duration;
}

- (NSTimeInterval)musicCurrentTime{

    return self.player.currentTime;
}

- (void)playerJumpToPercent:(CGFloat)percent{
    self.player.currentTime = percent * self.player.duration;

}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if ([self.delegate respondsToSelector:@selector(playerDidFinishPlaying:)]) {
    [self.delegate playerDidFinishPlaying:player];
    }

}
@end
