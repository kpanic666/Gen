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
    BOOL gameOver;
    SceneTypes currentScene;
    SceneTypes curLevel;
    SceneTypes lastLevel;
    
    // Added for audio
    BOOL hasAudioBeenInitialized;
    GameManagerSoundState managerSoundState;
    SimpleAudioEngine *soundEngine;
    NSMutableDictionary *listOfSoundEffectFiles;
    NSMutableDictionary *soundEffectsState;

}

@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) BOOL gameOver;
@property (readwrite) GameManagerSoundState managerSoundState;
@property (nonatomic, retain) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, retain) NSMutableDictionary *soundEffectsState;
@property (assign) SceneTypes curLevel;
@property (assign) SceneTypes lastLevel;

+ (GameManager*)sharedGameManager;
- (void)runSceneWithID:(SceneTypes)sceneID;
- (void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen;
- (void)setupAudioEngine;
- (ALuint)playSoundEffect:(NSString*)soundEffectKey;
- (void)stopSoundEffect:(ALuint)soundEffectID;
- (void)playBackgroundTrack:(NSString*)trackFileName;
- (CGSize)getDimensionsOfCurrentScene;

@end
