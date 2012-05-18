//
//  Constants.h
//  Gen
//
//  Created by Andrey Korikov on 17.01.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#define kBox2DLayer 15
#define kPauseLayer 16
#define kChildCellHealth 100
#define kParentCellSpriteTagValue 10
#define kRedCellDamage 100
#define kExitCellSpriteTagValue 20
#define kMagneticPowerMultiplier 0.1
#define kLevelCount 20

// Всего ячеек на уровне
typedef enum {
    kScene1Total = 20,
    kScene2Total = 11,
    kScene3Total = 7,
    kScene4Total = 10,
    kScene5Total = 14,
    kScene6Total = 40,
    kScene7Total = 10,
    kScene8Total = 10,
    kScene9Total = 4,
    kScene10Total = 12,
    kScene11Total = 13,
    kScene12Total = 15,
    kScene13Total = 8,
    kScene14Total = 25,
    kScene15Total = 16,
    kScene16Total = 14,
    kScene17Total = 26,
    kScene18Total = 9,
    kScene19Total = 14,
    kScene20Total = 14
} NumOfCellsTotal;

// Кол-во спасенных ячеек для окончания уровня
typedef enum {
    kScene1Needed = 20,
    kScene2Needed = 11,
    kScene3Needed = 6,
    kScene4Needed = 10,
    kScene5Needed = 14,
    kScene6Needed = 40,
    kScene7Needed = 10,
    kScene8Needed = 10,
    kScene9Needed = 4,
    kScene10Needed = 12,
    kScene11Needed = 13,
    kScene12Needed = 7,
    kScene13Needed = 8,
    kScene14Needed = 15,
    kScene15Needed = 16,
    kScene16Needed = 14,
    kScene17Needed = 26,
    kScene18Needed = 9,
    kScene19Needed = 14,
    kScene20Needed = 14
} NumOfCellsNeeded;

// Collision Filter Categories
typedef enum {
    kParentCellFilterCategory = 0x0002,
    kChildCellFilterCategory = 0x0003,
    kExitCellFilterCategory = 0x0004,
    kMagneticCellFilterCategory = 0x0005,
    kRedCellFilterCategory = 0x0006
} FilterCategories;

typedef enum {
    kNoSceneUninitialized=0,
    kMainMenuScene=1,
    kInfoScene=2,
    kLoadingScene=3,
    kLevelCompleteScene=4,
    kLevelSelectScene=5,
    kGameLevel1=101,
    kGameLevel2=102,
    kGameLevel3=103,
    kGameLevel4=104,
    kGameLevel5=105,
    kGameLevel6=106,
    kGameLevel7=107,
    kGameLevel8=108,
    kGameLevel9=109,
    kGameLevel10=110,
    kGameLevel11=111,
    kGameLevel12=112,
    kGameLevel13=113,
    kGameLevel14=114,
    kGameLevel15=115,
    kGameLevel16=116,
    kGameLevel17=117,
    kGameLevel18=118,
    kGameLevel19=119,
    kGameLevel20=120
} SceneTypes;

typedef enum {
    kLinkTypeGameSite,
    kLinkTypeDeveloperSite,
    kLinkTypePublisherSite
} LinkTypes;

typedef enum {
    kAudioManagerUninitialized=0,
    kAudioManagerFailed=1,
    kAudioManagerInitializing=2,
    kAudioManagerInitialized=100,
    kAudioManagerLoading=200,
    kAudioManagerReady=300
} GameManagerSoundState;

// Turn ON=1 or OFF=0 DEBUG DRAW
#define DEBUG_DRAW 0

// Audio Items
#define AUDIO_MAX_WAITTIME 150

// Audio Constants
#define SFX_NOTLOADED NO
#define SFX_LOADED YES

#define PLAYSOUNDEFFECT(...) [[GameManager sharedGameManager] playSoundEffect:__VA_ARGS__]
#define STOPSOUNDEFFECT(...) [[GameManager sharedGameManager] stopSoundEffect:__VA_ARGS__]

// Background Music
// Menu Scenes
//#define BACKGROUND_TRACK_MAIN_MENU @"VikingPreludeV1.mp3"

// GameLevel1
#define BACKGROUND_TRACK_1 @"back_Wallpaper.mp3"

// GameLevel2
//#define BACKGROUND_TRACK_PUZZLE @"VikingPreludeV1.mp3"

// GameLevel3
//#define BACKGROUND_TRACK_MINECRAFT @"DrillBitV2.mp3"

// GameLevel4
//#define BACKGROUND_TRACK_ESCAPE @"EscapeTheFutureV3.mp3"

// PTM ratio for Box2D
#define PTM_RATIO ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 64.0 : 32.0)
