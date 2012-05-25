//
//  GameManager.h
//  Gen
//
//  Created by Andrey Korikov on 13.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "SimpleAudioEngine.h"

@interface GameManager : NSObject {
    BOOL isMusicON;
    BOOL isSoundEffectsON;
    BOOL hasLevelWin;
    SceneTypes currentScene;
    SceneTypes curLevel;
    SceneTypes lastLevel;
    int _numOfSavedCells;
    int _numOfTotalCells;
    int _numOfNeededCells;
    
    // Added for audio
    BOOL hasAudioBeenInitialized;
    GameManagerSoundState managerSoundState;
    SimpleAudioEngine *soundEngine;
    NSMutableDictionary *listOfSoundEffectFiles;
    NSMutableDictionary *soundEffectsState;

}

@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) BOOL hasLevelWin;
@property (readwrite) GameManagerSoundState managerSoundState;
@property (nonatomic, retain) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, retain) NSMutableDictionary *soundEffectsState;
@property (assign) SceneTypes curLevel;
@property (assign) SceneTypes lastLevel;
@property (readwrite) int numOfSavedCells;
@property (readwrite) int numOfTotalCells;
@property (readwrite) int numOfNeededCells;

+ (GameManager*)sharedGameManager;
- (void)runSceneWithID:(SceneTypes)sceneID;
- (void)runNextScene;
- (void)reloadCurrentScene;
- (void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen;
- (void)setupAudioEngine;
- (ALuint)playSoundEffect:(NSString*)soundEffectKey;
- (void)stopSoundEffect:(ALuint)soundEffectID;
- (void)playBackgroundTrack:(NSString*)trackFileName;
- (CGSize)getDimensionsOfCurrentScene;
- (void)setMusicState:(BOOL)state;

@end
