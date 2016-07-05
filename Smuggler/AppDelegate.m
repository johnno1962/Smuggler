//
//  AppDelegate.m
//  Smuggler
//
//  Created by John Holdsworth on 24/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AppDelegate.h"
#import "HelperInstaller.h"
#import "HelperProxy.h"
#import "Helper.h"

@interface AppDelegate () <NSApplicationDelegate>

@property (weak) IBOutlet NSMenu *statusMenu;
@property IBOutlet NSStatusItem *statusItem;
@property NSConnection *connection;

@end

@implementation AppDelegate

- (NSString *)agentPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/LaunchAgents/smuggler.launch.plist"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *agentPath = [self agentPath];

    NSString *execPath = [NSBundle mainBundle].executablePath;
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"smuggler.launch" ofType:@"plist"];
    NSString *agentPlist = [NSString stringWithContentsOfFile:plistPath encoding:NSUTF8StringEncoding error:NULL];

    agentPlist = [agentPlist stringByReplacingOccurrencesOfString:@"__APPPATH__" withString:execPath];
    [agentPlist writeToFile:agentPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];

    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:statusBar.thickness];
    self.statusItem.image = [NSImage imageNamed:@"Smuggler"];
    self.statusItem.menu = self.statusMenu;
    self.statusItem.toolTip = @"Smuggler";
    self.statusItem.highlightMode = YES;
    self.statusItem.enabled = YES;
    self.statusItem.title = @"";

    self.connection = [NSConnection serviceConnectionWithName:@SMUGGLER_DO rootObject:self];
}

- (void)loadBundle:(NSString *)bundlePath {
    //dispatch_async( dispatch_get_main_queue(), ^{
        NSError *error = nil;

        // Install helper tool
        if ([HelperInstaller isInstalled] == NO && [HelperInstaller install:&error] == NO) {
            assert(error != nil);

            NSLog(@"Couldn't install Smuggler Helper (domain: %@ code: %d)", error.domain, (int)error.code);
            [[NSAlert alertWithError:error] runModal];
        }

        // Inject Simulator process
        if ([HelperProxy inject:bundlePath error:&error] == FALSE) {
            assert(error != nil);

            NSLog(@"Couldn't inject Simulator (domain: %@ code: %d)", error.domain, (int)error.code);
            [[NSAlert alertWithError:error] runModal];
        }
    //} );
}

- (IBAction)loadSmuggler:sender {
    NSOpenPanel *panel = [NSOpenPanel new];
    if ( [panel runModalForTypes:@[@"bundle", @"framework"]] == NSModalResponseOK )
        [self loadBundle:panel.URL.path];
}

- (IBAction)traceSwift:sender {
    [self loadBundle:[[NSBundle mainBundle] pathForResource:@"SwiftTrace" ofType:@"framework"]];
}

- (IBAction)quit:sender {
    [[NSFileManager defaultManager] removeItemAtPath:[self agentPath] error:NULL];
    [NSApp terminate:sender];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
