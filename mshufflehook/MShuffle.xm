#import "MShuffle.h"

static BOOL Enabled;
static int modeOption;

static __strong MPMusicPlayerController* MPcontroller = [MPMusicPlayerController iPodMusicPlayer];

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
						} else if(modeOption == 2) {
							MPMediaItem* currentMediaItm = [self currentItem];
							NSString* mediaIdenOld = [[NSString stringWithFormat:@"%@%@", [currentMediaItm title], [currentMediaItm albumName]] copy];
							NSMutableArray* itemsMut = [[NSMutableArray alloc] init];
							MPMediaQuery *myPlaylistsQuery = [MPMediaQuery songsQuery];
							MPMediaItem* itmToPlay = nil;
							for(MPMediaItemCollection *playlist in [myPlaylistsQuery collections]) {
								for (MPMediaItem *song in [playlist items]) {
									[itemsMut addObject:song];
									if(!itmToPlay) {
										NSString* mediaIdenNow = [NSString stringWithFormat:@"%@%@", [song valueForProperty:MPMediaItemPropertyTitle], [song valueForProperty:MPMediaItemPropertyAlbumTitle]];
										if([mediaIdenNow isEqualToString:mediaIdenOld]) {
											itmToPlay = song;
										}
									}
								}
							}
							if(itmToPlay && [itmToPlay respondsToSelector:@selector(dateAdded)]) {
								NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
								[itemsMut sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
								MPMediaItemCollection* mutPlay = [[MPMediaItemCollection alloc] initWithItems:itemsMut];
								[MPcontroller setQueueWithItemCollection:mutPlay];
								[MPcontroller setNowPlayingItem:itemsMut[[itemsMut indexOfObject:itmToPlay]+1]];
								[MPcontroller prepareToPlay];
								[MPcontroller play];
							}
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