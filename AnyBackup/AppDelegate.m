//
//  AppDelegate.m
//  AnyBackup
//
//  Created by Antoine d'Otreppe - Movify on 17/07/14.
//  Copyright (c) 2014 Aspyct. All rights reserved.
//

#import "AppDelegate.h"

#import "CopyInstruction.h"

enum {
    IntervalHour = 1,
    IntervalDay = 2
};

enum {
    EditTableAdd = 1,
    EditTableRemove = 2
};

enum {
    ColumnFrom = 0,
    ColumnTo = 1
};

@interface AppDelegate ()

@property (weak) IBOutlet NSPopUpButton *intervalSelector;
@property (weak) IBOutlet NSTableView *table;
@property (weak) IBOutlet NSTableColumn *columnFrom;
@property (weak) IBOutlet NSTableColumn *columnTo;

@property NSDate *lastSync;
@property NSTimer *nextSync;
@property NSMutableArray *instructions;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.instructions = [NSMutableArray array];
    
    CopyInstruction *instruction = [[CopyInstruction alloc] init];
    instruction.source = @"/tmp/hello";
    instruction.destination = @"/tmp/world";
    
    [self.instructions addObject:instruction];
    
    self.table.dataSource = self;
}

- (IBAction)doCopyAllNow:(NSButton *)sender
{
    [self copyNow:nil];
}

- (IBAction)doEditTable:(NSSegmentedControl *)sender
{
    [sender setSelected:NO forSegment:sender.selectedSegment];
}

- (IBAction)doSelectInterval:(NSPopUpButton *)sender
{
    NSTimeInterval interval;
    
    switch (sender.selectedItem.tag) {
        case IntervalHour:
            interval = 3600;
            break;
        case IntervalDay:
        default:
            interval = 3600 * 24;
            break;
    }
    
    [self scheduleNextCopy:interval];
}

- (void)scheduleNextCopy:(NSTimeInterval)interval
{
    [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(copyNow:) userInfo:nil repeats:YES];
}

- (void)copyNow:(NSTimer *)sender
{
    for (CopyInstruction *instruction in self.instructions) {
        [instruction copyNow:^(BOOL success) {
            NSLog(@"Completion block called");
        }];
    }
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.instructions.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    CopyInstruction *instruction = [self.instructions objectAtIndex:row];
    
    if (tableColumn == self.columnFrom) {
        return instruction.source;
    }
    else if (tableColumn == self.columnTo){
        return instruction.destination;
    }
    else {
        return @"";
    }
}

- (void)sendSuccessNotification
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"AnyCopy successful";
    notification.informativeText = @"All the copies succeeded";
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)sendFailureNotification
{
    // TODO This should be an alert that the user must dismiss manually
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"AnyCopy failed";
    notification.informativeText = @"The copy process failed";
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end
