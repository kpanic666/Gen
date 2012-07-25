//
//  GameState.h
//  SpaceViking
//
//  Created by Andrey Korikov on 15.02.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject <NSCoding> {
    BOOL completedLevel10;
    int cellsKilled;
}

+ (GameState*)sharedInstance;
- (void)save;

@property (assign) BOOL completedLevel10;
@property (assign) int cellsKilled;

@end