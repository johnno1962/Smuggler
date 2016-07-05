//
//  main.m
//  SwiftTrace
//
//  Created by John Holdsworth on 04/07/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SwiftTrace-Swift.h"

@implementation NSObject(SwiftTraceSetup)

+ (void)load {
    dispatch_async( dispatch_get_main_queue(), ^{
        [SwiftTrace traceMainBundle];
        Class rxSwift = NSClassFromString(@"RxSwift.DisposeBase");
        NSLog( @"SwiftTrace of: %@", rxSwift);
        if (rxSwift)
            [SwiftTrace traceBundleContainingClass:rxSwift];
    } );
}

@end
