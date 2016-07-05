//
//  Helper.h
//  Smuggler
//
//  Created by John Holdsworth on 24/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define HELPER_MACH_ID "com.jh.Smuggler.Helper.mach"

@interface Helper : NSObject

- (mach_error_t)inject:(NSString *)appPath bundle:(NSString *)payload client:(const char *)client;

@end
