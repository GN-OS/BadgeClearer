//Hello World! (keeping traditions alive)
#define BLACKLIST @"/var/mobile/Library/Preferences/BadgeClearer_blacklist.plist"
#define DEBUG 0

@interface SBApplication 
- (void)launch;
- (int)badgeValue;
- (void)setBadge:(id)badge;
- (id)applicationBundleID;
- (id)displayName;
@end

%hook SBApplicationIcon

- (void)launch {
    if ([self badgeValue] == 0) {
        %orig;
        return;
    }
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:BLACKLIST]; // Load the plist
    NSString *launchingBundleID = [self applicationBundleID];
	NSString *displayName = [self displayName];

    if (prefs && [prefs objectForKey:launchingBundleID]) { // Application is present in blacklist
        %orig;
    } else {
        // Show the alert view   
        UIAlertView *launchView = [[UIAlertView alloc] initWithTitle:@"BadgeClearer"
            message:DEBUG?launchingBundleID:displayName
            delegate:self
            cancelButtonTitle:@"Cancel"
            otherButtonTitles:@"Clear Badges", @"Launch app", @"Both", nil];
        [launchView show];
        [launchView release];
    }
    [prefs release];
}

%new(v@:@@) - (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)button {
    switch (button) {
        case 3: // "Both" pressed
            // Because there is no break;, code will continue onto case 2 and then break
            [self setBadge:nil];   
        case 2: // "Launch app" pressed
            // Launch the app
            [self launch];
            break;
        case 1: // "Clear badge count" pressed
            // Clear badge count
            [self setBadge:nil];
            break;
    }
}

%end
