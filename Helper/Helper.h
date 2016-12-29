//
//  Helper.h
//  Smuggler
//
//  Created by John Holdsworth on 24/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <libproc.h>

@interface Helper : NSObject

- (mach_error_t)inject:(NSString *)appPath bundle:(NSString *)payload client:(const char *)client
      dlopenPageOffset: (unsigned)dlopenPageOffset dlerrorPageOffset: (unsigned)dlerrorPageOffset;

@end
