//
//  CopyInstruction.m
//  AnyBackup
//
//  Created by Antoine d'Otreppe - Movify on 17/07/14.
//  Copyright (c) 2014 Aspyct. All rights reserved.
//

#import "CopyInstruction.h"

@implementation CopyInstruction

- (void)copyNow:(void (^)(BOOL))completion
{
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/rsync";
    task.arguments = @[self.source, self.destination];
    
    NSPipe *stdout = [[NSPipe alloc] init];
    NSPipe *stderr = [[NSPipe alloc] init];
    task.standardOutput = stdout;
    task.standardError = stderr;
    
    NSFileHandle *stdoutHandle = [stdout fileHandleForReading];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc removeObserver:self];
    [nc addObserver:self
           selector:@selector(taskFinished:)
               name:NSFileHandleReadToEndOfFileCompletionNotification
             object:task];
    [nc addObserver:self
           selector:@selector(taskFinished:)
               name:NSTaskDidTerminateNotification
             object:task];
    
    [task launch];
    [stdoutHandle readToEndOfFileInBackgroundAndNotify];
}

- (void)taskFinished:(NSNotification *)notification
{
    NSLog(@"Task finished: %@ -> %@", self.source, self.destination);
    
    NSTask *task = notification.object;
    NSLog(@"Termination status: %d", task.terminationStatus);
}

@end
