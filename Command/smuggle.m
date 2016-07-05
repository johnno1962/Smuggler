//
//  smuggler.m
//  smuggler
//
//  Created by John Holdsworth on 05/07/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if ( argc < 2 ) {
            fprintf(stderr, "Usage: %s <bundle/framework to load>\n", argv[0]);
            exit(1);
        }

        // insert code here...
        NSConnection *connection = [NSConnection connectionWithRegisteredName:@SMUGGLER_DO
                                                                         host:nil];//@"localhost"];
        id<Smuggler> smuggler = (id<Smuggler>)[connection rootProxy];
        if (!smuggler) {
            fprintf( stderr, "Could not connect to %s. Is Smuggler.app running?\n", SMUGGLER_DO);
            exit(1);
        }

        NSString *bundlePath = [NSString stringWithUTF8String:argv[1]];
        [smuggler loadBundle:bundlePath];
    }
    return 0;
}
