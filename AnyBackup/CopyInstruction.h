//
//  CopyInstruction.h
//  AnyBackup
//
//  Created by Antoine d'Otreppe - Movify on 17/07/14.
//  Copyright (c) 2014 Aspyct. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CopyInstruction : NSObject

@property NSString *source;
@property NSString *destination;

- (void)copyNow:(void (^)(BOOL success))completion;

@end
