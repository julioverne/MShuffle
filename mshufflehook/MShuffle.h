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

@interface MPCMediaPlayerLegacyPlayer
- (void)clearPlaybackQueueWithCompletion:(id)arg1;
- (void)performCommandEvent:(id)arg1 completion:(id)arg2;
- (id)currentItem;
- (int)state; //1=stop
- (void)_playbackStateChangedNotification:(id)arg1;
@end
