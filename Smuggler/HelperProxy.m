//
//  HelperProxy.m
//  Smuggler
//
//  Created by John Holdsworth on 24/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

#import "HelperProxy.h"
#import "Helper.h"

@implementation HelperProxy

+ (BOOL)inject:(NSString *)bundlePath error:(NSError **)error {
    NSConnection *c = [NSConnection connectionWithRegisteredName:@HELPER_MACH_ID host:nil];
    assert(c != nil);

    Helper *helper = (Helper *)[c rootProxy];
    assert(helper != nil);

    NSLog(@"Injecting %@", bundlePath);

    mach_error_t err = [helper inject:[NSBundle mainBundle].bundlePath bundle:bundlePath client:__FILE__];

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

@end
