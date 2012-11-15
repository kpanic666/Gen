//
//  GameState.m
//  SpaceViking
//
//  Created by Andrey Korikov on 15.02.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#import "GameState.h"
#import "GCDatabase.h"

@implementation GameState

static GameState *sharedInstance = nil;

+ (GameState*)sharedInstance
{
    @synchronized([GameState class])
    {
        if (!sharedInstance) {
            sharedInstance = [loadData(@"GameState") retain];
            if (!sharedInstance) {
                [[self alloc] init];
            }
        }
        return sharedInstance;
    }
    return nil;
}

+ (id)alloc
{
    @synchronized([GameState class])
    {
        NSAssert(sharedInstance == nil, @"Attempted to allocated a \
                 second instance of the GameState singleton");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    return nil;
}

- (void)save
{
    saveData(self, @"GameState");
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:_completedLevel10 forKey:@"CompletedLevel10"];
    [aCoder encodeBool:_completedLevel20 forKey:@"CompletedLevel20"];
    [aCoder encodeBool:_completedLevel30 forKey:@"CompletedLevel30"];
    [aCoder encodeBool:_completedLevel40 forKey:@"CompletedLevel40"];
    [aCoder encodeBool:_completedFirstFail forKey:@"CompletedFirstFail"];
    [aCoder encodeBool:_completedUnwary forKey:@"CompletedUnwary"];
    [aCoder encodeBool:_completedDestroyer forKey:@"CompletedDestroyer"];
    [aCoder encodeInt:_cellsKilled forKey:@"CellsKilled"];
    [aCoder encodeInt:_highestOpenedLevel forKey:@"HighestOpenedLevel"];
    [aCoder encodeObject:_levelHighestScoreArray forKey:@"LevelHighestScoreArray"];
    [aCoder encodeObject:_levelHighestStarsNumArray forKey:@"LevelHighestStarsNumArray"];
}

- (id)init {
    if ((self = [super init])) {
        _highestOpenedLevel = 1;
        _levelHighestScoreArray = [[NSMutableArray alloc] initWithCapacity:kLevelCount];
        _levelHighestStarsNumArray = [[NSMutableArray alloc] initWithCapacity:kLevelCount];
        for (int i = 0 ; i < kLevelCount ; i++)
        {
            [_levelHighestScoreArray insertObject:[NSNumber numberWithInt:0] atIndex:i];
            [_levelHighestStarsNumArray insertObject:[NSNumber numberWithInt:0] atIndex:i];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        [self setCompletedLevel10:[aDecoder decodeBoolForKey:@"CompletedLevel10"]];
        [self setCompletedLevel20:[aDecoder decodeBoolForKey:@"CompletedLevel20"]];
        [self setCompletedLevel30:[aDecoder decodeBoolForKey:@"CompletedLevel30"]];
        [self setCompletedLevel40:[aDecoder decodeBoolForKey:@"CompletedLevel40"]];
        [self setCompletedFirstFail:[aDecoder decodeBoolForKey:@"CompletedFirstFail"]];
        [self setCompletedUnwary:[aDecoder decodeBoolForKey:@"CompletedUnwary"]];
        [self setCompletedDestroyer:[aDecoder decodeBoolForKey:@"CompletedDestroyer"]];
        [self setCellsKilled:[aDecoder decodeIntForKey:@"CellsKilled"]];
        [self setHighestOpenedLevel:[aDecoder decodeIntForKey:@"HighestOpenedLevel"]];
        _levelHighestScoreArray = [[aDecoder decodeObjectForKey:@"LevelHighestScoreArray"] retain];
        _levelHighestStarsNumArray = [[aDecoder decodeObjectForKey:@"LevelHighestStarsNumArray"] retain];
    }
    return self;
}

- (void)resetState
{
    [self setCompletedLevel10:NO];
    [self setCompletedLevel20:NO];
    [self setCompletedLevel30:NO];
    [self setCompletedLevel40:NO];
    [self setCompletedFirstFail:NO];
    [self setCompletedUnwary:NO];
    [self setCompletedDestroyer:NO];
    [self setCellsKilled:0];
    [self setHighestOpenedLevel:1];
    [_levelHighestScoreArray removeAllObjects];
    [_levelHighestStarsNumArray removeAllObjects];
    
    for (int i = 0 ; i < kLevelCount ; i++)
    {
        [_levelHighestScoreArray insertObject:[NSNumber numberWithInt:0] atIndex:i];
        [_levelHighestStarsNumArray insertObject:[NSNumber numberWithInt:0] atIndex:i];
    }
    
    [self save];
}

- (int)getHighestScoreForSceneID:(SceneTypes)sceneID
{
    return [[_levelHighestScoreArray objectAtIndex:(int)sceneID-101] integerValue];
}

- (void)dealloc
{
    [_levelHighestScoreArray release];
    _levelHighestScoreArray = nil;
    [_levelHighestStarsNumArray release];
    _levelHighestStarsNumArray = nil;
    
    [super dealloc];
}

@end
