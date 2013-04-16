#line 1 "Tweak.xm"

#define BLACKLIST @"/var/mobile/Library/Preferences/BadgeClearer_blacklist.plist"
#define DEBUG 1

@interface SBApplication 
- (void)launch;
- (int)badgeValue;
- (void)setBadge:(id)badge;
- (id)applicationBundleID;
- (id)displayName;
@end

static BOOL justLaunch = NO;

#include <logos/logos.h>
#include <substrate.h>
@class SBApplicationIcon; 
static void (*_logos_orig$_ungrouped$SBApplicationIcon$launch)(SBApplicationIcon*, SEL); static void _logos_method$_ungrouped$SBApplicationIcon$launch(SBApplicationIcon*, SEL); static void _logos_method$_ungrouped$SBApplicationIcon$alertView$didDismissWithButtonIndex$(SBApplicationIcon*, SEL, UIAlertView *, NSInteger); 

#line 15 "Tweak.xm"


static void _logos_method$_ungrouped$SBApplicationIcon$launch(SBApplicationIcon* self, SEL _cmd) {
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:BLACKLIST]; 
	
	if (!prefs) {
		
		justLaunch = YES;
	}

	NSNumber *obj = (NSNumber *)[prefs objectForKey:@"disabled"];
	
	if (!obj || [obj boolValue]) {
		
		justLaunch = YES;
	}

	
	
	if ([prefs objectForKey:launchingBundleID]) {
		
		justLaunch = YES;
	}

	
	
	
	
	
	if (justLaunch || ![self badgeValue]) {
		
		justLaunch = NO;
		_logos_orig$_ungrouped$SBApplicationIcon$launch(self, _cmd);
	}
	else {
		
		NSString *launchingBundleID = [self applicationBundleID];
		NSString *displayName = [self displayName];

		
		UIAlertView *launchView = [[UIAlertView alloc] initWithTitle:(DEBUG?launchingBundleID:displayName) 
			message:nil
			delegate:self
			cancelButtonTitle:@"Cancel"
			otherButtonTitles:@"Clear Badges", @"Launch app", @"Both", nil];
		[launchView show];
		[launchView release];
	}
	[prefs release];
}

 static void _logos_method$_ungrouped$SBApplicationIcon$alertView$didDismissWithButtonIndex$(SBApplicationIcon* self, SEL _cmd, UIAlertView * alert, NSInteger button) {
	switch (button) {
	case 3: 
		
		[self setBadge:nil];   
	case 2: 
		
		justLaunch = YES;	
		[self launch];
		break;
	case 1: 
		
		[self setBadge:nil];
		break;
	}
}

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBApplicationIcon = objc_getClass("SBApplicationIcon"); MSHookMessageEx(_logos_class$_ungrouped$SBApplicationIcon, @selector(launch), (IMP)&_logos_method$_ungrouped$SBApplicationIcon$launch, (IMP*)&_logos_orig$_ungrouped$SBApplicationIcon$launch);{ const char *_typeEncoding = "v@:@@"; class_addMethod(_logos_class$_ungrouped$SBApplicationIcon, @selector(alertView:didDismissWithButtonIndex:), (IMP)&_logos_method$_ungrouped$SBApplicationIcon$alertView$didDismissWithButtonIndex$, _typeEncoding); }} }
#line 83 "Tweak.xm"
