#define prefs.plist@"/var/mobile/Library/Preferences/com.ge0rges.badgeclearer.plist"

static BOOL allowLaunch=NO;

@interface SBApplicationIcon
- (void)launch;
- (void)setBadge:(id)arg1;
- (id)badgeValue;
@end

%hook SBApplicationIcon

- (void)launch {
if ([self badgeValue]==0)  {
        %orig;
        return;
}

NSDictionary *prefs=[[NSDictionary alloc] initWithContentsOfFile:prefs.plist]; //checks if the enable/disable switch in rpefs is enable ord disabled
if (![[prefs objectForKey:@"enabled"] boolValue] || allowLaunch){
	%orig;
} else if([[prefs objectForKey:@"enabled"] boolValue]) {
	UIAlertView *launchView = [[UIAlertView alloc] initWithTitle:@"Clear the badges or just launch the App?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Clear Badges", @"Launch the App", nil];
	[launchView show];
	[launchView release];
}
[prefs release];
}


%new(v@:@@) - (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)button {
	if (button == 1) {
		[self setBadge:nil];
	}
	if (button == 2) {
		allowLaunch = YES;
		[self launch];
		allowLaunch = NO;
	}
}


%end