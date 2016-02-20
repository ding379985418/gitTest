//
//  ViewController.m
//  仿QQ音乐
//
//  Created by simon on 16/1/16.
//  Copyright © 2016年 simon. All rights reserved.
//

#import "ViewController.h"

#import "DXLyricTools.h"
#import "DXLycModel.h"
#import "DXLyricLabel.h"
#define KIntervalTime 0.05
@interface ViewController ()<DXMusicToolsDelegate>
//背景
@property (weak, nonatomic) IBOutlet UIImageView *bgImgViwe;
//歌词
@property (weak, nonatomic) IBOutlet DXLyricLabel *lyr;
//歌手照片
@property (weak, nonatomic) IBOutlet UIImageView *singerIcon;
//歌手名
@property (weak, nonatomic) IBOutlet UILabel *singerName;
//当前时间
@property (weak, nonatomic) IBOutlet UILabel *currentTimer;
//专辑名
@property (weak, nonatomic) IBOutlet UILabel *album;
//总时长
@property (weak, nonatomic) IBOutlet UILabel *totalTimer;
//进度条
@property (weak, nonatomic) IBOutlet UISlider *processSlider;
//播放按钮
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
//音乐数组
@property (nonatomic, strong) NSArray *musicArray;
//当前音乐数组的索引
@property (nonatomic, assign) NSInteger currentIndex;
//计时器
@property (nonatomic, strong) NSTimer *timer;
//歌词数组
@property (nonatomic, strong) NSArray *lycArray;
//当前歌词行数索引
@property (nonatomic, assign) NSInteger currentLyricIndex;;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];

}
#pragma mark -初始化UI
- (void)setUpUI{
//    设置导航栏样式
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    设置背景毛玻璃效果
    UINavigationBar *bar = [[UINavigationBar alloc]init];
    bar.barStyle = UIBarStyleBlack;
    [self.bgImgViwe addSubview:bar];
    [bar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bgImgViwe);
    }];
//    设置圆角效果
    self.singerIcon.layer.masksToBounds = YES;
    self.singerIcon.layer.cornerRadius = 100;
    self.currentIndex = 0;
    [self change];
 

}

- (IBAction)processSlider:(UISlider *)sender {
    [[DXMusicTools sharedTools] playerJumpToPercent:sender.value];
}
#pragma mark -上一曲
- (IBAction)preMusicBtnClick:(UIButton *)sender {
    
       NSLog(@"%zd",self.currentIndex);
    self.currentIndex --;
    if (self.currentIndex < 0) {
        self.currentIndex = self.musicArray.count - 1;
    }
     [self change];
 
}
#pragma mark -播放/暂停
- (IBAction)playMusicBtnClick:(UIButton *)sender {
  
    if ( sender.selected) {
         [[DXMusicTools sharedTools] resume];
          [self timerfire];

    }else{
        
         [[DXMusicTools sharedTools] pause];
        [self clearUpTimer];
    }
    
    sender.selected = !sender.selected;
   
}

#pragma mark -下一曲
- (IBAction)nextMusicBtnClick:(UIButton *)sender {
    
    NSLog(@"%zd",self.currentIndex);
    self.currentIndex ++;
    if (self.currentIndex >self.musicArray.count - 1) {
        self.currentIndex = 0;
    }
  [self change];
    
}

#pragma mark -改变界面
- (void)change{
    [self clearUpTimer];
    
    self.currentLyricIndex = 0;
   DXMusicModel *model = self.musicArray[self.currentIndex];
    self.singerName.text =[NSString stringWithFormat:@"歌手：%@", model.singer];

    UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:model.image ofType:nil]];
    self.singerIcon.image = img;
    self.bgImgViwe.image = img;
    self.album.text =[NSString stringWithFormat:@"专辑名：%@", model.album];
    self.title = model.name;
    self.lyr.text = model.lrc;
    DXMusicTools *musicTool = [DXMusicTools sharedTools];
    musicTool.delegate = self;
    
   [musicTool playeMusicWithString:model];
    [self timerfire];
     self.singerIcon.transform = CGAffineTransformIdentity;
    self.playBtn.selected = NO;

    self.totalTimer.text = [self timeStringWithsecond:musicTool.musicTotalTime];
//    得到歌词数组
    self.lycArray = [DXLyricTools lyricArrayWithFileName:model.lrc];
    

    
}
#pragma mark -计时器间隔更新方法
- (void)timeCycle{
    
    DXMusicTools *tools = [DXMusicTools sharedTools];
//    设置当前时间
    self.currentTimer.text = [self timeStringWithsecond:tools.musicCurrentTime];
//    设置进度
    self.processSlider.value = tools.musicCurrentTime / tools.musicTotalTime;
//    icon旋转
    [UIView animateWithDuration:2 animations:^{
        self.singerIcon.transform = CGAffineTransformRotate( self.singerIcon.transform, M_PI/4 *KIntervalTime );
    }];
//    更新歌词
    [self updateLyric];
    
    
}

#pragma mark -更新歌词
- (void)updateLyric{
    self.currentLyricIndex = [self findLyricIndex];
    DXLycModel *lyricModel = self.lycArray[self.currentLyricIndex];
    
    self.lyr.text = lyricModel.lyricContent;
    self.lyr.processPercent =[self lyricProcessPersent];

}

- (CGFloat)lyricProcessPersent{
//  ProcessPersen = 当前歌曲时间-当前歌词开始时间 /(总时间= 下句歌词开始时间 - 当前歌词时间)
 DXLycModel *nextModel = self.currentLyricIndex != self.lycArray.count - 1?self.lycArray[self.currentLyricIndex + 1]:self.lycArray[self.currentLyricIndex];
    DXLycModel *currentModel = self.lycArray[self.currentLyricIndex];
    DXMusicTools *tools = [DXMusicTools sharedTools];
    
    return (tools.musicCurrentTime - currentModel.beginTime)/(nextModel.beginTime - currentModel.beginTime);
}
-(NSInteger )findLyricIndex{
    DXMusicTools *tools = [DXMusicTools sharedTools];
    NSTimeInterval currentSongTime = tools.musicCurrentTime;
    DXLycModel *currentModel = self.lycArray[self.currentLyricIndex];
    
    DXLycModel *nextModel = self.currentLyricIndex != self.lycArray.count - 1?self.lycArray[self.currentLyricIndex + 1]:self.lycArray[self.currentLyricIndex];
  DXLycModel * lastModel = self.currentLyricIndex == 0? self.lycArray[self.currentLyricIndex]:self.lycArray[self.currentLyricIndex - 1];
    
    if (currentModel.beginTime < currentSongTime && nextModel.beginTime < currentSongTime&& self.currentLyricIndex != self.lycArray.count - 1) {
        //       说明歌词慢了，需要加
        self.currentLyricIndex ++;
        [self updateLyric];
    }else if (currentModel.beginTime > currentSongTime && lastModel.beginTime > currentSongTime && self.currentLyricIndex != 0){
//    说明歌词快了，需减速
     self.currentLyricIndex --;
         [self updateLyric];
    }else{
        return self.currentLyricIndex;
    }
    
    return self.currentLyricIndex;
    
}
#pragma mark -时间转换方法

- (NSString *)timeStringWithsecond:(NSTimeInterval)time{
    int min = (int)time/60;
    int seco = (int)time%60;
    return [NSString stringWithFormat:@"%02d:%02d",min,seco];
}
#pragma mark -计数器
//清除计时器
- (void)clearUpTimer{
    [self.timer invalidate];
    self.timer = nil;
}
//初始化计时器
- (void)timerfire{
    
    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer fire];
}

#pragma mark -DXMusicToolsDelegate代理
- (void)playerDidFinishPlaying:(AVAudioPlayer *)player{
    [self nextMusicBtnClick:nil];

}
#pragma mark -懒加载
- (NSArray *)musicArray{
    if (!_musicArray) {
        NSError *error;
        _musicArray = [DXMusicModel objectArrayWithFilename:@"mlist.plist" error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
    }
    return _musicArray;
}
- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:KIntervalTime target:self selector:@selector(timeCycle) userInfo:nil repeats:YES];
       
    }
    return _timer;
}
@end
