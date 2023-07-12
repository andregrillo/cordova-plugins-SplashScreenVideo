//
//  MainViewController+SplashScreenVideo.m
//
//  Created by Andre Grillo on 12/07/2023.
//

#import "MainViewController+SplashScreenVideo.h"
#import <objc/runtime.h>

static char PlayerViewControllerKey;

@implementation MainViewController (CDVSplashScreenVideo)

- (void)setPlayerViewController:(AVPlayerViewController *)playerViewController
{
    objc_setAssociatedObject(self, &PlayerViewControllerKey, playerViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AVPlayerViewController *)playerViewController
{
    return objc_getAssociatedObject(self, &PlayerViewControllerKey);
}

AVPlayerViewController *playerViewController;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self playVideo];
}

-(void)videoDidFinishPlaying:(id)notification {
    NSString *fadeDurationStr = self.commandDelegate.settings[@"fade_duration"];
    double fadeDuration = [fadeDurationStr doubleValue];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:fadeDuration animations:^{
                self.playerViewController.view.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.playerViewController dismissViewControllerAnimated:false completion:nil];
                [self.playerViewController.view removeFromSuperview];
                self.playerViewController = nil;
            }];
        });
}

- (void)playVideo{
    NSString *fullpath = [[NSBundle mainBundle] pathForResource:@"SplashScreen" ofType:@"mp4"];
    NSURL *videoURL =[NSURL fileURLWithPath:fullpath];
    NSLog(@"⭐️ Path: %@", fullpath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:fullpath]) {
        NSLog(@"File exists");
    } else {
        NSLog(@"File does not exist");
    }

    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    AVPlayer* playVideo = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    self.playerViewController = [[AVPlayerViewController alloc] init];
    self.playerViewController.showsPlaybackControls = false;
    self.playerViewController.player = playVideo;
    self.playerViewController.player.volume = 0;
    self.playerViewController.view.frame = self.view.bounds;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoDidFinishPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:playerItem];
    });
    [self.view addSubview:self.playerViewController.view];
    [playVideo play];
}


@end