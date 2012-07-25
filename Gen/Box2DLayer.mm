//
//  Box2DLayer.m
//  Gen
//
//  Created by Andrey Korikov on 11.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "Box2DLayer.h"
#import "Box2DSprite.h"
#import "GameManager.h"

@interface Box2DLayer()
{
    // Added for game stat and scores
    double levelStartTime;
    double levelRemainingTime;
}

@end

@implementation Box2DLayer

////время в сек. на прохождение уровня. После этого времени очки не начисляются
//static double LEVEL_MAX_TIME = 120;

- (void)setupWorld
{
    b2Vec2 gravity;
    gravity.Set(0.0f, 0.0f);
    world = new b2World(gravity);
    
    // Add custom listener
    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(TRUE);
	world->SetContinuousPhysics(TRUE);
}

- (void)setupDebugDraw
{
    m_debugDraw = new GLESDebugDraw(PTM_RATIO);
    world->SetDebugDraw(m_debugDraw);
    uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
//	flags += b2Draw::e_jointBit;
//    flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
}

- (void)createGround
{
    CGSize levelSize = [[GameManager sharedGameManager] getDimensionsOfCurrentScene];
    b2Vec2 lowerLeft = b2Vec2(0, 0);
    // Сдвигаем рамку земли в центр экрана если игра запущена на iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        lowerLeft += b2Vec2(kiPadScreenOffsetX / PTM_RATIO, kiPadScreenOffsetY / PTM_RATIO);
    }
    b2Vec2 lowerRight = lowerLeft + b2Vec2(levelSize.width/PTM_RATIO, 0);
    b2Vec2 upperRight = lowerRight + b2Vec2(0, levelSize.height/PTM_RATIO);
    b2Vec2 upperLeft = lowerLeft + b2Vec2(0, levelSize.height/PTM_RATIO);
    
    b2BodyDef groundBodyDef;
    groundBodyDef.type = b2_staticBody;
    groundBodyDef.position.Set(0, 0);
    b2Body *groundBody = world->CreateBody(&groundBodyDef);
    
    b2EdgeShape groundShape;
    
    // Bottom
    groundShape.Set(lowerLeft, lowerRight);
    groundBody->CreateFixture(&groundShape, 0);
    // Top
    groundShape.Set(upperLeft, upperRight);
    groundBody->CreateFixture(&groundShape, 0);
    // Left
    groundShape.Set(upperLeft, lowerLeft);
    groundBody->CreateFixture(&groundShape, 0);
    // Right
    groundShape.Set(upperRight, lowerRight);
    groundBody->CreateFixture(&groundShape, 0);
}

- (ChildCell*)createChildCellAtLocation:(CGPoint)location
{
    ChildCell *childCell = [[[ChildCell alloc] initWithWorld:world atLocation:location] autorelease];
    [sceneSpriteBatchNode addChild:childCell z:1];
    [GameManager sharedGameManager].numOfTotalCells++;
    return childCell;
}

- (BombCell*)createBombCellAtLocation:(CGPoint)location
{
    BombCell *bombCell = [[[BombCell alloc] initWithWorld:world atLocation:location] autorelease];
    [sceneSpriteBatchNode addChild:bombCell z:1];
    [GameManager sharedGameManager].numOfTotalCells++;
    return bombCell;
}

- (GroundCell*)createGroundCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    GroundCell *groundCell = [GroundCell groundCellInWorld:theWorld position:pos name:name];
    [self addChild:groundCell z:-1];
    [groundCell createParticles];
    return groundCell;
}

- (RedCell*)createRedCellInWorld:(b2World *)theWorld position:(CGPoint)pos name:(NSString *)name
{
    RedCell *redCell = [RedCell redCellInWorld:theWorld position:pos name:name];
    [self addChild:redCell z:-1];
    [redCell createParticles];
    return redCell;
}

- (void)resetBubbleWithNode:(id)node
{
    CCSprite *bubble = (CCSprite*)node;
    [bubble stopAllActions];
    bubble.scale = 1;
    
    // Set Random Position
    float yOffset = [bubble boundingBox].size.height * 0.5;
    float offScreenYPosition = screenSize.height + 1 + yOffset;
    int yPosition =  (yOffset * -1) - 1;
    int xPosition = random() % (int)screenSize.width;
    [bubble setPosition:ccp(xPosition, yPosition)];
    
    // Set Random Move Duration 
    int moveDuration = random() % kMaxBubbleMoveDuration;
    if (moveDuration < kMinBubbleMoveDuration) {
        moveDuration = kMinBubbleMoveDuration;
    }
    
    // Set Horizontal Reflection (flipX)
    if ([bubble flipX]) {
        [bubble setFlipX:NO];
    }
    else {
        [bubble setFlipX:YES];
    }
    
    
    // Set Random texture
    int bubbleToDraw = random() % 3 + 1; // 1 to 3
    NSString *bubbleFileName = [NSString stringWithFormat:@"bubble%d.png",bubbleToDraw];
    [bubble setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:bubbleFileName]];
    
    // Actions
    id scaleAction = [CCScaleBy actionWithDuration:1 scaleX:1.3 scaleY:0.6];
    id scaleSeqAction = [CCSequence actions:scaleAction, [scaleAction reverse], nil];
    id moveAction = [CCMoveTo actionWithDuration:moveDuration position:ccp([bubble position].x, offScreenYPosition)];
    id resetAction = [CCCallFuncN actionWithTarget:self selector:@selector(resetBubbleWithNode:)];
    id sequenceAction = [CCSequence actions:moveAction, resetAction, nil];
    
    [bubble runAction:sequenceAction];
    [bubble runAction:[CCRepeatForever actionWithAction:scaleSeqAction]];
    int newZOrder = kMaxBubbleMoveDuration - moveDuration;
    [sceneSpriteBatchNode reorderChild:bubble z:newZOrder];
}

- (void)createBubble
{
    int bubbleToDraw = random() % 3 + 1; // 1 to 3
    NSString *bubbleFileName = [NSString stringWithFormat:@"bubble%d.png",bubbleToDraw];
    CCSprite *bubbleSprite = [CCSprite spriteWithSpriteFrameName:bubbleFileName];
    [sceneSpriteBatchNode addChild:bubbleSprite];
    [self resetBubbleWithNode:bubbleSprite];
}

- (void)displayLevelName
{
    [uiLayer displayText:[GameManager sharedGameManager].levelName];
}

- (id)init
{
    if ((self = [super init])) {
        screenSize = [[CCDirector sharedDirector] winSize];
        
        // enable events
        self.isTouchEnabled = YES;
        self.tag = kBox2DLayer;
        gameOver = false;
        
        // seed randomizer
        srandom(time(NULL));
        
        bodiesToDestroy = [[NSMutableArray alloc] init];
        
        // Обнуляем переменные для статистики и счета
        levelStartTime = CACurrentMediaTime();
        levelRemainingTime = 0;
        
        [self setupWorld];
        [self createGround];
#if DEBUG_DRAW
        [self setupDebugDraw];
#endif
        [self scheduleUpdate];
        
        // pre load the sprite frames from the texture atlas
        sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"genbyatlas.pvr.ccz"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"genbyatlas.plist"];
        [self addChild:sceneSpriteBatchNode z:1 tag:kMainSpriteBatchNode];
        
        // add ParentCell (main hero will always be under the finger)
        parentCell = [[[ParentCell alloc] initWithWorld:world atLocation:ccp(100, 100)] autorelease];
        [sceneSpriteBatchNode addChild:parentCell z:10 tag:kParentCellSpriteTagValue];
        
        // Create water bubbles
        for (int x = 0; x < kMaxNumOfBubbleOnScene; x++) {
            [self createBubble];
        }
        
        // Create plankton particles
        psPlankton = [CCParticleSystemQuad particleWithFile:@"ps_plankton.plist"];
        [self addChild:psPlankton z:-1];
//        psPlankton.position = ccp(screenSize.width * 0.5, screenSize.height);
        
        // Display level name with delay
        [self scheduleOnce:@selector(displayLevelName) delay:0.5];
    }
    return self;
}

-(void) dealloc
{
    delete contactListener;
    contactListener = NULL;
    [bodiesToDestroy release];
    bodiesToDestroy = nil;
    exitCell = nil;
    parentCell = nil;
    if (world) {
        delete world;
        world = NULL;
    }
    if (m_debugDraw) {
        delete m_debugDraw;
        m_debugDraw = nil;
    }
    
    [super dealloc];
}

- (void)draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
    //
	[super draw];
    
    // Draw lines for distance joints between ChildCell and ParentCell
    [parentCell drawDisJoints];
    
    // Рисуем линии от магнитов к ChildCells
    for (CCSprite *tempSprite in [sceneSpriteBatchNode children])
    {
        if ([tempSprite isKindOfClass:[MagneticCell class]])
        {
            MagneticCell *magneticCell = (MagneticCell*)tempSprite;
            [magneticCell drawMagnetForces];
        }
    }

#if DEBUG_DRAW	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();	
	
	kmGLPopMatrix();
#endif
}

- (void)displayGameOverLayer
{
    [uiLayer setVisible:FALSE];
    ccColor4B c = ccc4(255, 255, 255, 0); // Black transparent background
    CompleteLevelLayer *gameOverLayer = [[[CompleteLevelLayer alloc] initWithColor:c] autorelease];
    [self addChild:gameOverLayer z:10 tag:kGameOverLayer];
    [self pauseSchedulerAndActions];
}

- (void)showTipsElement:(CCNode*)element delay:(float)delay
{
    [element runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay], [CCFadeIn actionWithDuration:1], nil]];
}

- (void)calcScore
{
    GameManager *gameManager = [GameManager sharedGameManager];
    gameManager.levelElapsedTime = CACurrentMediaTime() - levelStartTime;
    levelRemainingTime = kLevelMaxTime - gameManager.levelElapsedTime;
    
    // Проверяем оставшееся время. может быть отрицательным если игрок сильно замешкался, то ставим в 0
    levelRemainingTime = MAX(0, levelRemainingTime);
    // Насчитываем очки за оставшееся время
    gameManager.levelTotalScore += levelRemainingTime * kRemainingTimeMulti;
    // Насчитываем очки за кол-во спасенных ячеек
    gameManager.levelTotalScore += gameManager.numOfNeededCells * kGoalCellsMulti;
    gameManager.levelTotalScore += (gameManager.numOfSavedCells - gameManager.numOfNeededCells) * kExtraCellsMulti;
    // Насчитываем очки за набранные звезды. 1 звезда - Collected == Needed, 2 - Collected > Needed < Max, 3 - Coll=Max
    if (gameManager.numOfSavedCells == gameManager.numOfNeededCells) {
        gameManager.levelStarsNum = 1;
    }
    if (gameManager.numOfSavedCells > gameManager.numOfNeededCells && gameManager.numOfSavedCells < gameManager.numOfMaxCells)
    {
        gameManager.levelStarsNum = 2;
    }
    if (gameManager.numOfSavedCells == gameManager.numOfMaxCells) {
        gameManager.levelStarsNum = 3;
    }
    gameManager.levelTotalScore += gameManager.levelStarsNum * kStarAchievedMulti;
    // Насчитываем очки за кол-во нажатий на игровое поле при прохождении уровня. За каждое нажатие вычитаем очки
    gameManager.levelTotalScore += gameManager.levelTappedNum * kTapMulti;
    // Проверяем на положительность
    gameManager.levelTotalScore = MAX(0, gameManager.levelTotalScore);
}

- (void)update:(ccTime)dt
{
	// Update Box2D World: Fixed Time Step
    static double UPDATE_INTERVAL = 1.0f/60.0f;
    static double MAX_CYCLES_PER_FRAME = 5;
    static double timeAccumulator = 0;
    
    timeAccumulator += dt;
    if (timeAccumulator > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL)) {
        timeAccumulator = UPDATE_INTERVAL;
    }
    
    int32 velocityIterations = 8;
    int32 positionIterations = 3;
    while (timeAccumulator >= UPDATE_INTERVAL) {
        timeAccumulator -= UPDATE_INTERVAL;
        world->Step(UPDATE_INTERVAL, velocityIterations, positionIterations);
    }
    
    // Adjust sprite for physics bodies
    for (b2Body *b = world->GetBodyList(); b != NULL; b = b->GetNext()) {
        if (b->GetUserData() != NULL) {
            Box2DSprite *sprite = (Box2DSprite*) b->GetUserData();
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            sprite.rotation = CC_RADIANS_TO_DEGREES(b->GetAngle() * -1);
            // Mark body for delete
            if (sprite.markedForDestruction) {
                [self markBodyForDestruction:sprite];
            }
        }
    }
    
    // Уничтожаем тела клеток попавших в опасность или в выход
    [self destroyBodies];
    
    // Force update all objects и подсчет детей загнаных в выход
    CCArray *listOfGameObjects = [sceneSpriteBatchNode children];
    int i = 0;
    for (CCSprite *tempSprite in listOfGameObjects)
    {
        if ([tempSprite isKindOfClass:[GameCharacter class]])
        {
            GameCharacter *tempChar = (GameCharacter*)tempSprite;
            [tempChar updateStateWithDeltaTime:dt andListOfGameObjects:listOfGameObjects];
            if ([tempChar characterState] == kStateSoul)
            {
                i++;
            }

        }
    }
    
    // Подсчитываем кол-во клеток. Сколько из них спасено, сколько их всего и обновляем счетчик
    // i - кол-во ячеек попавших в выход
    GameManager *gameManager = [GameManager sharedGameManager];
    if (gameManager.numOfSavedCells != i) {
        gameManager.numOfSavedCells = i;
        [uiLayer updateScore:i need:gameManager.numOfNeededCells];
    }
    
    // Проверяем выигрыш или проигрыш
    if (!gameOver)
    {
        // Если не осталось свободноплавающих ячеек и спасено нужно количество то ВЫИГРЫШ
        if (gameManager.numOfTotalCells == 0 && gameManager.numOfSavedCells >= gameManager.numOfNeededCells)
        {
            gameOver = true;
            [gameManager setHasLevelWin:YES];
            [self calcScore];
            [self scheduleOnce:@selector(displayGameOverLayer) delay:1.5];
        }
        else if (gameManager.numOfTotalCells == 0 && gameManager.numOfSavedCells < gameManager.numOfNeededCells)
        {
            gameOver = true;
            [self scheduleOnce:@selector(displayGameOverLayer) delay:1.5];
        }
    }
}

- (void)markBodyForDestruction:(Box2DSprite *)obj
{
    [bodiesToDestroy addObject:[NSValue valueWithPointer:obj]];
}

- (void)destroyBodies
{
    for (NSValue *value in bodiesToDestroy) {
        Box2DSprite *obj = (Box2DSprite*)[value pointerValue];
        if (obj && obj.body && obj.markedForDestruction) {
            obj.body->SetTransform(b2Vec2(0,0), 0);
            world->DestroyBody(obj.body);
            obj.body = nil;
        }
    }
    [bodiesToDestroy removeAllObjects];
}

#pragma mark Touch Events

- (void)registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [Helper locationFromTouch:touch];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    
    // Отображаем главную ячейку под пальцем игрока и она начинает притягивать
    [parentCell changeBodyPosition:locationWorld];
    [parentCell changeState:kStateTraveling];
    
    // Увеличиваем счетчик нажатий на экран
    [GameManager sharedGameManager].levelTappedNum++;
    
    return TRUE;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [Helper locationFromTouch:touch];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    if ([parentCell characterState] == kStateTraveling) {
        [parentCell changeBodyPosition:locationWorld];
    }    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{    
    // Прячем главную клетку и перестаем притягивать
    [parentCell changeState:kStateIdle];
}


- (id)initWithBox2DUILayer:(Box2DUILayer *)box2DUILayer
{
    return self;
}

@end
