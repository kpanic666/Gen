//
//  Constants.h
//  Gen
//
//  Created by Andrey Korikov on 17.01.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#define kChildCellHealth 100
#define kChildCellSpriteTagValue 1
#define kChildCellStartNum 25
#define kParentCellSpriteTagValue 10
#define kRedCellDamage 100

// Collision Filter Categories
typedef enum {
    kParentCellFilterCategory = 0x0002,
    kChildCellFilterCategory = 0x0003
} FilterCategories;

typedef enum {
    kNoSceneUninitialized=0,
    kMainMenuScene=1,
    kOptionsScene=2,
    kCreditsScene=3,
    kIntroScene=4,
    kLevelCompleteScene=5,
    kGameLevel1=101,
    kGameLevel2=102,
    kGameLevel3=103,
    kGameLevel4=104,
    kGameLevel5=105
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
//#define BACKGROUND_TRACK_OLE_AWAKES @"SpaceDesertV2.mp3"

// GameLevel2
//#define BACKGROUND_TRACK_PUZZLE @"VikingPreludeV1.mp3"

// GameLevel3
//#define BACKGROUND_TRACK_MINECRAFT @"DrillBitV2.mp3"

// GameLevel4
//#define BACKGROUND_TRACK_ESCAPE @"EscapeTheFutureV3.mp3"

// PTM ratio for Box2D
#define PTM_RATIO ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 32.0 : 16.0)
