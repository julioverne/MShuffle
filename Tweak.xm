#import <substrate.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <sys/utsname.h>
#import <sys/types.h>
#import <sys/stat.h>
#import <dirent.h>
#import <mach-o/dyld.h>
#import <mach-o/ldsyms.h>
#import <mach-o/loader.h>
#import <sys/types.h>
#import <sys/sysctl.h>

#define NSLog(...)

@interface MPCMediaPlayerLegacyPlayer
- (void)clearPlaybackQueueWithCompletion:(id)arg1;
- (void)performCommandEvent:(id)arg1 completion:(id)arg2;
- (id)currentItem;
- (int)state; //1=stop
- (void)_playbackStateChangedNotification:(id)arg1;
@end

%hook MPCMediaPlayerLegacyPlayer
- (void)_playbackStateChangedNotification:(NSNotification*)notification
{
	%orig;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if(notification) {
			NSDictionary* infoDic = [notification userInfo]?:@{};
			int stateNew = [infoDic[@"MPAVControllerNewStateParameter"]?:@(0) intValue];
			int stateOld = [infoDic[@"MPAVControllerOldStateParameter"]?:@(0) intValue];
			if(stateNew==1 && stateOld!=0 && [self state]!=4 && [self currentItem]!=nil) {
				[self clearPlaybackQueueWithCompletion:^{
					//[self performCommandEvent:nil completion:nil];
				}];				
			}
		}
	});	
}
%end

%ctor
{
	dlopen("/System/Library/PrivateFrameworks/MediaPlaybackCore.framework/MediaPlaybackCore", RTLD_GLOBAL);
	%init;
}