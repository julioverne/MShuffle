#import "MShuffle.h"

static BOOL Enabled;
static int modeOption;

%hook MPCMediaPlayerLegacyPlayer
- (void)_playbackStateChangedNotification:(NSNotification*)notification
{
	%orig;
	if(Enabled) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			if(notification) {
				NSDictionary* infoDic = [notification userInfo]?:@{};
				int stateNew = [infoDic[@"MPAVControllerNewStateParameter"]?:@(0) intValue];
				int stateOld = [infoDic[@"MPAVControllerOldStateParameter"]?:@(0) intValue];
				if(stateNew==1 && stateOld!=0 && [self state]!=4 && [self currentItem]!=nil) {
					[self clearPlaybackQueueWithCompletion:^{
						if(modeOption == 1) {
							[self performCommandEvent:nil completion:nil];
						}
					}];
				}
			}
		});
	}
}
%end

static void settingsChangedMShuffle(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{	
	@autoreleasepool {		
		NSDictionary *MShufflePrefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSDictionary dictionary] copy];
		Enabled = (BOOL)[[MShufflePrefs objectForKey:@"Enabled"]?:@YES boolValue];
		modeOption = (int)[[MShufflePrefs objectForKey:@"modeOption"]?:@(0) intValue];
	}
}

%ctor
{
	dlopen("/System/Library/PrivateFrameworks/MediaPlaybackCore.framework/MediaPlaybackCore", RTLD_GLOBAL);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChangedMShuffle, CFSTR("com.julioverne.mshuffle/Settings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	settingsChangedMShuffle(NULL, NULL, NULL, NULL, NULL);
	%init;
}