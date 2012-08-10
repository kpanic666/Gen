//
//  GameState.h
//  SpaceViking
//
//  Created by Andrey Korikov on 15.02.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface GameState : NSObject <NSCoding> {
    // Achievements
    BOOL _completedLevel10;
    unsigned int _cellsKilled;
    // Level Stats
    unsigned int _highestOpenedLevel;
    NSMutableArray *_levelHighestStarsNumArray;
    NSMutableArray *_levelHighestScoreArray;
}

+ (GameState*)sharedInstance;
- (void)save;
- (void)resetState;

@property (assign) BOOL completedLevel10;
@property (assign) unsigned int cellsKilled;
@property unsigned int highestOpenedLevel;
@property (assign) NSMutableArray *levelHighestStarsNumArray;
@property (assign) NSMutableArray *levelHighestScoreArray;

@end
