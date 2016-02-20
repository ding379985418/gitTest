//
//  DXMusicModel.h
//  仿QQ音乐
//
//  Created by simon on 16/1/16.
//  Copyright © 2016年 simon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    DXMusicTypeLocal = 1,
    DXMusicTypeRomote = 2
} DXMusicType;
@interface DXMusicModel : NSObject
/// 图片
@property (nonatomic, copy) NSString *image;
/// 歌词
@property (nonatomic, copy) NSString *lrc;
/// 音乐
@property (nonatomic, copy) NSString *mp3;
/// 名称
@property (nonatomic, copy) NSString *name;
/// 歌手
@property (nonatomic, copy) NSString *singer;
/// 专辑
@property (nonatomic, copy) NSString *album;
/// 类型 远程 /本地
@property (nonatomic, assign) DXMusicType type;

@end
