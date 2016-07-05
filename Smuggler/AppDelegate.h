//
//  AppDelegate.h
//  Smuggler
//
//  Created by John Holdsworth on 24/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SMUGGLER_DO "com.jh.Smuggler.Service"

@protocol Smuggler
- (void)loadBundle:(NSString *)bundlePath;
@end

@interface AppDelegate : NSObject <Smuggler>

@end

