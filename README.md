# Smuggler

Smuggler allows you to inject code bundles or frameworks into an application running in the iOS Simulator
after it has started running. Looking ahead to Xcode 8, this is could be useful for tooling such as
[Injection for Xcode](https://github.com/johnno1962/injectionforxcode) or [Xprobe](https://github.com/johnno1962/Xprobe)
if the current approach using plugins and lldb commands is no longer available.

To use this Project, clone the Repo, select "Smuggler" Scheme and run. This starts a menu bar agent for
the process. While this app is running you can use the command line tool ~/bin/smuggle to force loading
of a built bundle or framework into the app after the fact. Error reporting is through a log file 
"/tmp/helper.log" which is the place to look for any errors when the payload bundle is dlopen()'d.

![Icon](http://injectionforxcode.johnholdsworth.com/trace.png)

Included in the app is an example bundle [SwiftTrace](https://github.com/johnno1962/SwiftTrace)
(actually it's an iOS framework - they are both dynamic libraries at the end of the day.) If you are
running a Swift application in the simulator and also running the Smuggler app, if use the 
menu bar, menu item "Trace Swift" it will log all non-final Swift (and Objective-C) calls made
to classes in the main bundle as well as RxSwift if it is in use.

    RxSwift.SingleAssignmentDisposable.dispose () -> ()
    RxSwift.SingleAssignmentDisposable.disposable.setter : RxSwift.Disposable11
    RxSwift.CompositeDisposable.dispose () -> ()
    RxSwift.SingleAssignmentDisposable.dispose () -> ()
    RxSwift.SingleAssignmentDisposable.disposable.setter : RxSwift.Disposable11
    RxSwift.CompositeDisposable.addDisposable (RxSwift.Disposable11) -> Swift.Optional<RxSwift.BagKey>
    RxSwift.CurrentThreadScheduler.schedule <A> (A, action : (A) -> RxSwift.Disposable11) -> RxSwift.Disposable11
    -[RxSwift.CurrentThreadSchedulerKey copyWithZone:] -> @24@0:8^v16
    RxSwift.CompositeDisposable.addDisposable (RxSwift.Disposable11) -> Swift.Optional<RxSwift.BagKey>
    RxSwift.CompositeDisposable.addDisposable (RxSwift.Disposable11) -> Swift.Optional<RxSwift.BagKey>
    RxSwift.SerialDisposable.disposable.setter : RxSwift.Disposable11
    RxSwift.SingleAssignmentDisposable.dispose () -> ()
    RxSwift.SingleAssignmentDisposable.disposable.setter : RxSwift.Disposable11
    RxSwift.SingleAssignmentDisposable.dispose () -> ()
    RxSwift.CompositeDisposable.removeDisposable (RxSwift.BagKey) -> ()
    RxSwift.SingleAssignmentDisposable.dispose () -> ()
    RxSwift.SingleAssignmentDisposable.disposable.setter : RxSwift.Disposable11

For your code bundle to perform some action it would normally have a +load or initializer something
like that of SwiftTrace's main.m below. When the bundle is loaded and it's initializer is called
the thread's state is somewhat precarious so dispatch any code to one of the application's queues
to have it execute successfully.

```objc
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
```

Note: In order to inject code between processes the Smuggle app installs a "privileged helper".
The system will ask for your administrator password when you first use it. The helper binary
can be removed at any time or to have it update by executing:

    sudo rm /Library/PrivilegedHelperTools/com.jh.Smuggler.Helper

# MIT License

The MIT License (MIT)
Copyright (c) 2016, John Holdsworth

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

This project reuses code from [rentzsch/mach_inject](https://github.com/rentzsch/mach_inject) and [erwanb/MachInjectSample](https://github.com/erwanb/MachInjectSample) under this license.
