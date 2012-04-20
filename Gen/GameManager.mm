//
//  GameManager.m
//  Gen
//
//  Created by Andrey Korikov on 13.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "GameManager.h"
#import "Scene1.h"

@implementation GameManager

static GameManager* _sharedGameManager = nil;

@synthesize isMusicON;
@synthesize isSoundEffectsON;
@synthesize gameOver;
@synthesize managerSoundState;
@synthesize listOfSoundEffectFiles;
@synthesize soundEffectsState;
@synthesize curLevel;
@synthesize lastLevel;

+ (GameManager*)sharedGameManager {
    @synchronized([GameManager class])
    {
        if (!_sharedGameManager) {
            [[self alloc] init];
        }
        return _sharedGameManager;
    }
    return nil;
}

+ (id)alloc {
    @synchronized([GameManager class])
    {
        NSAssert(_sharedGameManager == nil, @"Attempted to allocate a second instance of the Game Manager singleton");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    return nil;
}

- (void)playBackgroundTrack:(NSString*)trackFileName {
    // Wait to make sure soundEngine is initialized
    if ((managerSoundState != kAudioManagerReady) &&
        (managerSoundState != kAudioManagerFailed)) {
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) ||
                (managerSoundState == kAudioManagerFailed)) {
                break; 
            }
            waitCycles = waitCycles + 1;
        }
    }
    if (managerSoundState == kAudioManagerReady) {
        if ([soundEngine isBackgroundMusicPlaying]) {
            [soundEngine stopBackgroundMusic];
        }
        [soundEngine preloadBackgroundMusic:trackFileName];
        [soundEngine playBackgroundMusic:trackFileName loop:YES];
    }
}

- (void)stopSoundEffect:(ALuint)soundEffectID {
    if (managerSoundState == kAudioManagerReady) {
        [soundEngine stopEffect:soundEffectID];
    }
}

- (ALuint)playSoundEffect:(NSString *)soundEffectKey {
    ALuint soundID = 0;
    if (managerSoundState == kAudioManagerReady) {
        NSNumber *isSFXLoaded = [soundEffectsState objectForKey:soundEffectKey];
        if ([isSFXLoaded boolValue] == SFX_LOADED) {
            soundID = [soundEngine playEffect:[listOfSoundEffectFiles objectForKey:soundEffectKey]];
        } else {
            CCLOG(@"GameManager->SoundEffect %@ is not loaded",soundEffectKey);
        }
    } else {
        CCLOG(@"GameManager->Sound Manager is not ready, cannot play %@", soundEffectKey);
    }
    return soundID;
}

- (NSString*)formatSceneTypeToString:(SceneTypes)sceneID {
    NSString *result = nil;
    switch (sceneID) {
        case kNoSceneUninitialized:
            result = @"kNoSceneUninitialized";
            break;
        case kMainMenuScene:
            result = @"kMainMenuScene";
            break;
        case kOptionsScene:
            result = @"kOptionsScene";
            break;
        case kCreditsScene:
            result = @"kCreditsScene";
            break;
        case kIntroScene:
            result = @"kIntroScene";
            break;
        case kLevelCompleteScene:
            result = @"kLevelCompleteScene";
            break;
        case kGameLevel1:
            result = @"kGameLevel1";
            break;
        case kGameLevel2:
            result = @"kGameLevel2";
            break;
        case kGameLevel3:
            result = @"kGameLevel3";
            break;
        case kGameLevel4:
            result = @"kGameLevel4";
            break;
        case kGameLevel5:
            result = @"kGameLevel5";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected SceneType"];
    }
    return result;
}

- (NSDictionary*)getSoundEffectsListForSceneWithID:(SceneTypes)sceneID {
    NSString *fullFileName = @"SoundEffects.plist";
    NSString *plistPath;
    
    // 1: Получаем путь к файлу Plist
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"SoundEffects" ofType:@"plist"];
    }
    
    // 2: Читаем файл свойст
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3: Если прочитанный файл пуст - то файл не найден
    if (plistDictionary == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return nil;
    }
    
    // 4: Если listOfSoundEffects пуст, то загружаем его
    if ((listOfSoundEffectFiles == nil) || ([listOfSoundEffectFiles count] < 1)) {
        [self setListOfSoundEffectFiles:[[NSMutableDictionary alloc] init]];
        for (NSString *sceneSoundDictionary in plistDictionary) {
            [listOfSoundEffectFiles addEntriesFromDictionary:[plistDictionary objectForKey:sceneSoundDictionary]];
        }
        CCLOG(@"Number of SFX filenames:%d",[listOfSoundEffectFiles count]);
    }
    
    // 5: Загрузить список звуковых эффектов и присвоить им состояние Unloaded
    if ((soundEffectsState == nil) || ([soundEffectsState count] < 1)) {
        [self setSoundEffectsState:[[NSMutableDictionary alloc] init]];
        for (NSString *soundEffectKey in listOfSoundEffectFiles) {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:soundEffectKey];
        }
    }
    
    // 6: Возвращаем только мини список звуковых эффектов для текущей сцены
    NSString *sceneIDName = [self formatSceneTypeToString:sceneID];
    NSDictionary *soundEffectsList = [plistDictionary objectForKey:sceneIDName];
    return soundEffectsList;
}

- (void)loadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
    if (managerSoundState == kAudioManagerInitializing) {
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) || (managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (managerSoundState == kAudioManagerFailed) {
        return;
    }
    NSDictionary *soundEffectsToLoad = [self getSoundEffectsListForSceneWithID:sceneID];
    if (soundEffectsToLoad == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return;
    }
    // Получить список файлов и предзагрузить их
    for (NSString *keyString in soundEffectsToLoad) {
        CCLOG(@"\nLoading Audio Key:%@ File:%@", keyString, [soundEffectsToLoad objectForKey:keyString]);
        [soundEngine preloadEffect:[soundEffectsToLoad objectForKey:keyString]];
        [soundEffectsState setObject:[NSNumber numberWithBool:SFX_LOADED] forKey:keyString];
    }
    [pool release];
}

- (void)unloadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
    if (sceneID == kNoSceneUninitialized) {
        return; // Nothing to unload
    }
    NSDictionary *soundEffectsToUnload = [self getSoundEffectsListForSceneWithID:sceneID];
    if (soundEffectsToUnload == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return; 
    }
    if (managerSoundState == kAudioManagerReady) {
        // Get all of the entries and unload
        for(NSString *keyString in soundEffectsToUnload) {
            [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:keyString];
            [soundEngine unloadEffect:keyString];
            CCLOG(@"\nUnloading Audio Key:%@ File:%@",keyString,
                  [soundEffectsToUnload objectForKey:keyString]);
        }
    }
    [pool release];
}

- (void)initAudioAsync {
    // Initializes the audio engine asynchronously
    managerSoundState = kAudioManagerInitializing;
    // Indicate that we are trying to start up the Audio Manager
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    
    //Init audio manager asynchronously as it can take a few seconds
    //The FXPlusMusicIfNoOtherAudio mode will check if the user is
    // playing music and disable background music playback if
    // that is the case.
    [CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
    
    // Wait for the audio manager to initialize
    while ([CDAudioManager sharedManagerState] != kAMStateInitialised) {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    // At this point the CocosDenshion should be initialized
    // Grab the CDAudioManager and check the state
    CDAudioManager *audioManager = [CDAudioManager sharedManager];
    if (audioManager.soundEngine == nil || audioManager.soundEngine.functioning == NO) {
        CCLOG(@"CocosDenshion failed to init, no audio will play.");
        managerSoundState = kAudioManagerFailed;
    } else {
        [audioManager setResignBehavior:kAMRBStopPlay autoHandle:YES];
        soundEngine = [SimpleAudioEngine sharedEngine];
        managerSoundState = kAudioManagerReady;
        CCLOG(@"CocosDenshion is Ready");
    }
}

- (void)setupAudioEngine {
    if (hasAudioBeenInitialized == YES) {
        return;
    } else {
        hasAudioBeenInitialized = YES;
        NSOperationQueue *queue = [[NSOperationQueue new] autorelease];
        NSInvocationOperation *asyncSetupOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(initAudioAsync) object:nil];
        [queue addOperation:asyncSetupOperation];
        [asyncSetupOperation autorelease];
    }
}

- (id)init {
    self = [super init];
    if (self != nil) {
        // Game Manager Initialized
        CCLOG(@"Game Manager Singleton init");
        isMusicON = YES;
        isSoundEffectsON = YES;
        hasAudioBeenInitialized = NO;
        soundEngine = nil;
        managerSoundState = kAudioManagerUninitialized;
        gameOver = NO;
        currentScene = kNoSceneUninitialized;
    }
    return self;
}

- (void)runSceneWithID:(SceneTypes)sceneID {
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    lastLevel = curLevel;
    curLevel = sceneID;
    id sceneToRun = nil;
    switch (sceneID) {
        case kMainMenuScene:
            //sceneToRun = [MainMenuScene node];
            break;
            
        case kOptionsScene:
            //sceneToRun = [OptionsScene node];
            break;
            
        case kCreditsScene:
            //sceneToRun = [CreditsScene node];
            break;
            
        case kIntroScene:
            //sceneToRun = [IntroScene node];
            break;
            
        case kLevelCompleteScene:
            //sceneToRun = [LevelCompleteScene node];
            break;
            
        case kGameLevel1:
            sceneToRun = [Scene1 scene];
            break;
            
        case kGameLevel2:
            //sceneToRun = [GameScene2 node];
            break;
            
        case kGameLevel3:
            //sceneToRun = [PuzzleLayer scene];
            break;
            
        case kGameLevel4:
            //sceneToRun = [Scene4 node];
            break;
            
        case kGameLevel5:
            // Placeholder for Level 5
            break;
            
        default:
            CCLOG(@"Unknown ID, cannot switch scenes");
            return;
            break;
    }
    
    if (sceneToRun == nil) {
        currentScene = oldScene;
        return;
    }
    
    // Load Audio for new scene based on sceneID
    [self performSelectorInBackground:@selector(loadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:currentScene]];
    
    // Menu Scenes have a value of < 100
    if (sceneID < 100) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            CGSize screenSize = [CCDirector sharedDirector].winSizeInPixels;
            if (screenSize.width == 960.0f) {
                // IPhone 4 Retina
                [sceneToRun setScaleX:0.9375f];
                [sceneToRun setScaleY:0.8333f];
                CCLOG(@"GM:Scaling for Iphone 4 (retina)");
            } else {
                [sceneToRun setScaleX:0.4688f];
                [sceneToRun setScaleY:0.4166f];
                CCLOG(@"GM:Scaling for Iphone 3G (or older)");
            }
        }
    }
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] pushScene:sceneToRun];
    } else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFlipAngular transitionWithDuration:0.5f scene:sceneToRun]];
    }
    
    [self performSelectorInBackground:@selector(unloadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:oldScene]];
}

- (void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen {
    NSURL *urlToOpen = nil;
    switch (linkTypeToOpen) {
        case kLinkTypeDeveloperSite:
            CCLOG(@"Opening Developer Site");
            urlToOpen = [NSURL URLWithString:@"http://www.atomgames.com"];
            break;
            
        case kLinkTypeGameSite:
            CCLOG(@"Opening Game Site");
            urlToOpen = [NSURL URLWithString:@"http://www.atomgames.com/genby"];
            break;
            
        case kLinkTypePublisherSite:
            CCLOG(@"Opening Publisher Site");
            urlToOpen = [NSURL URLWithString:@"http://www.chillingo.com"];
            break;
 
        default:
            CCLOG(@"Defaulting to Developer Site");
            urlToOpen = [NSURL URLWithString:@"http://www.atomgames.com/"];
            break;
    }
    if (![[UIApplication sharedApplication] openURL:urlToOpen]) {
        CCLOG(@"%@%@",@"Failed to open url:",[urlToOpen description]);
        [self runSceneWithID:kMainMenuScene];
    }
}

- (CGSize)getDimensionsOfCurrentScene {
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CGSize levelSize;
    switch (currentScene) {
        case kGameLevel1:
            levelSize = screenSize;
            break;
//        case kGameLevel2:
//            levelSize = CGSizeMake(screenSize.width * 4.0f, screenSize.height);
//            break;
        default:
            CCLOG(@"Unknown Scene ID, returning default size");
            levelSize = screenSize;
            break;
    }
    return levelSize;
}

@end
