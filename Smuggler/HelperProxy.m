//
//  HelperProxy.m
//  Smuggler
//
//  Created by John Holdsworth on 24/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

#import "HelperProxy.h"
#import "Helper.h"

static unsigned dlopenPageOffset, dlerrorPageOffset;

@implementation HelperProxy

+ (BOOL)inject:(NSString *)bundlePath error:(NSError **)error {
    NSConnection *c = [NSConnection connectionWithRegisteredName:@HELPER_MACH_ID host:nil];
    assert(c != nil);

    Helper *helper = (Helper *)[c rootProxy];
    assert(helper != nil);

    NSLog(@"Injecting %@", bundlePath);

    mach_error_t err = [helper inject:[NSBundle mainBundle].bundlePath bundle:bundlePath client:__FILE__
                     dlopenPageOffset: dlopenPageOffset dlerrorPageOffset: dlerrorPageOffset];

    if (err == 0) {
        NSLog(@"Injected Simulator");
        return YES;
    } else {
        NSString *description = [NSString stringWithCString:mach_error_string(err) encoding:NSASCIIStringEncoding];
        NSLog(@"an error occurred while injecting Simulator: %@ (error code: %d)", description, (int)err);

        *error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                     code:err
                                 userInfo:@{NSLocalizedDescriptionKey: description}];
        
        return NO;
    }
}

+ (pid_t)pidContaining:(const char *)text returning:(char *)returning {
    int procCnt = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
    pid_t pids[65536];
    memset(pids, 0, sizeof pids);
    proc_listpids(PROC_ALL_PIDS, 0, pids, sizeof(pids));

    char curPath[PROC_PIDPATHINFO_MAXSIZE];
    memset(curPath, 0, sizeof curPath);
    for (int i = 0; i < procCnt; i++) {
        proc_pidpath(pids[i], curPath, sizeof curPath);
        if ( strstr(curPath, text) != NULL ) {
            if (returning)
                strcpy( returning, curPath );
            return pids[i];
        }
    }

    return 0;
}

+ (NSString *)run:(NSString *)command {
    NSTask *task = [NSTask new];
    NSPipe *pipe = [NSPipe new];
    task.launchPath = @"/bin/bash";
    task.arguments = @[@"-c", command];
    task.standardOutput = pipe.fileHandleForWriting;
    [task launch];
    [pipe.fileHandleForWriting closeFile];
    [task waitUntilExit];
    NSData *output = pipe.fileHandleForReading.readDataToEndOfFile;
    return [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
}

@end
