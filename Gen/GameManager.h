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
    
    // Added for game statistic and score
    int _numOfSavedCells;
    int _numOfTotalCells;
    int _numOfMaxCells;
    int _numOfNeededCells;
    int _levelTotalScore;
    double _levelElapsedTime;
    Byte _levelStarsNum;
    uint _levelTappedNum;
    
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
@property (readwrite) int numOfSavedCells; // Ячеек добравшихся до выхода
@property (readwrite) int numOfTotalCells; // Кол-во свободных ячеек (не мертвых и не в выходе) плавающих на уровне
@property (readwrite) int numOfNeededCells; // Кол-во ячеек, которое нужно загнать в выход чтобы пройти уровень
@property (readwrite) int numOfMaxCells; // Максимальное кол-во ячеек которое доступно изначально
@property (readwrite) int levelTotalScore; // Счет к концу уровня
@property (readwrite) double levelElapsedTime; // Время затраченное на уровень
@property (readwrite) Byte levelStarsNum; // Колво полученных звезда за уровень
@property (readwrite) uint levelTappedNum; // Колво раз, которое игрок нажал на игровое поле

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
