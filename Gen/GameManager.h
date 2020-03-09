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
    NSString *playedBackgroundMusic;
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
    BOOL _levelHighScoreAchieved;
    double _levelElapsedTime;
    Byte _levelStarsNum;
    uint _levelTappedNum;
    NSString *_levelName;
    BOOL _needToUpdateScore;
    
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
@property (nonatomic) int numOfSavedCells; // Ячеек добравшихся до выхода
@property (nonatomic) int numOfTotalCells; // Кол-во свободных ячеек (не мертвых и не в выходе) плавающих на уровне
@property (readwrite) int numOfNeededCells; // Кол-во ячеек, которое нужно загнать в выход чтобы пройти уровень
@property (readwrite) int numOfMaxCells; // Максимальное кол-во ячеек которое доступно изначально
@property (readwrite) int levelTotalScore; // Счет к концу уровня
@property (readwrite) BOOL levelHighScoreAchieved;  // True - когда набирается новый лучший результат. В levelComplete выскакивает рисунок
@property (readwrite) double levelElapsedTime; // Время затраченное на уровень
@property (readwrite) Byte levelStarsNum; // Колво полученных звезда за уровень
@property (readwrite) uint levelTappedNum; // Колво раз, которое игрок нажал на игровое поле
@property (nonatomic, retain) NSString *levelName;
@property (readwrite) BOOL needToUpdateScore; //Св-во dirty устанавливается в True, когда меняется характеристика для обновления счета UI

+ (GameManager*)sharedGameManager;
- (void)runSceneWithID:(SceneTypes)sceneID;
- (void)runNextScene;
- (void)reloadCurrentScene;
- (void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen;
- (void)setupAudioEngine;
- (ALuint)playSoundEffect:(NSString*)soundEffectKey;
- (void)stopSoundEffect:(ALuint)soundEffectID;
- (void)playBackgroundTrack:(NSString*)trackFileName;
- (void)setMusicState:(BOOL)state;

@end
