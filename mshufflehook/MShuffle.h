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

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.mshuffle.plist"

extern "C" id MPMediaItemPropertyTitle;
extern "C" id MPMediaItemPropertyAlbumTitle;
extern "C" id MPMediaItemPropertyArtist;
extern "C" id MPMediaItemPropertyArtwork;
extern "C" id MPMediaItemPropertyPlaybackDuration;
extern "C" id MPMediaItemPropertyAlbumTrackNumber;
extern "C" id MPMediaItemPropertyReleaseDate;

@interface MPCMediaPlayerLegacyPlayer
- (void)clearPlaybackQueueWithCompletion:(id)arg1;
- (void)performCommandEvent:(id)arg1 completion:(id)arg2;
- (id)currentItem;
- (int)state; //1=stop
- (void)_playbackStateChangedNotification:(id)arg1;
@end

@interface MPMediaQuery : NSObject
- (NSArray*)items;
+ (id)albumsQuery;
+ (id)songsQuery;
+ (id)playlistsRecentlyAddedQuery; // iOS 9 - 11
- (NSArray*)collections;
@end
@interface MPMediaItem : NSObject
- (id)valueForProperty:(id)arg1;
- (id)imageWithSize:(CGSize)arg1;
- (id)title;
- (id)albumName;
-(NSDate *)dateAdded; // iOS 10 - 11
@end

@interface MPMusicPlayerController : NSObject
+(id)iPodMusicPlayer;
+(id)applicationMusicPlayer;
- (id)nowPlayingItem;
-(void)setQueueWithItemCollection:(id)arg1;
-(void)setNowPlayingItem:(id)arg1;
-(void)prepareToPlay;
-(void)play;
@end

@interface MPMediaItemCollection : NSObject
- (MPMediaItem*)representativeItem;
- (id)initWithItems:(id)arg1;
- (NSArray*)items;
@end