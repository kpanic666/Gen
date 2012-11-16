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
    // Level Stats
    unsigned int _highestOpenedLevel;
    NSMutableArray *_levelHighestStarsNumArray;
    NSMutableArray *_levelHighestScoreArray;
}

+ (GameState*)sharedInstance;
- (void)save;
- (void)resetState;
- (int)getHighestScoreForSceneID:(SceneTypes)sceneID;

// Achievements properties
@property (assign) BOOL completedLevel10;
@property (assign) BOOL completedLevel20;
@property (assign) BOOL completedLevel30;
@property (assign) BOOL completedLevel40;
@property (assign) BOOL completedFirstFail;
@property (assign) BOOL completedUnwary;
@property (assign) BOOL completedDestroyer;
@property (assign) BOOL completedLightHunger;
@property (assign) BOOL completedIFeelGood;
@property (assign) BOOL completedOhNoNo;
@property (assign) unsigned int cellsKilled;
@property (assign) unsigned int starsCollected;
@property (assign) unsigned int foodEaten;
@property (assign) unsigned int bubblesPoped;
@property (assign) unsigned int bombsExploded;
// Game Stats properties
@property unsigned int highestOpenedLevel;
@property (assign) NSMutableArray *levelHighestStarsNumArray;
@property (assign) NSMutableArray *levelHighestScoreArray;

@end
