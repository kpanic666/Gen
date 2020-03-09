//
//  ParentCell.m
//  Gen
//
//  Created by Andrey Korikov on 15.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ParentCell.h"
#import "Helper.h"
#import "HMVectorNode.h"

@implementation ParentCell

- (void)destroyDisJoints
{
    if ([disJointsToDestroy count] > 0)
    {
        for (NSValue *value in disJointsToDestroy) {
            b2Joint *disJoint = (b2Joint*)[value pointerValue];
            world->DestroyJoint(disJoint);
        }
        [disJointsToDestroy removeAllObjects];
    }
}

- (void)changeBodyPosition:(b2Vec2)position
{
    body->SetTransform(position, 0.0f);
    self.superpowerBatchNode.position = [Helper toPoints:position];
}

- (void)createBodyAtLocation:(CGPoint)location
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    body = world->CreateBody(&bodyDef);
    body->SetUserData(self);
    
    b2FixtureDef fixtureDef;
    b2CircleShape shape;
    shape.m_radius = self.contentSize.width * 0.5f / PTM_RATIO;
    fixtureDef.shape = &shape;
    // Задаем маску фильтрации столкновений. Главная клетка будет игнорироваться абсолютно всеми. Можно свободно двигаться
    fixtureDef.filter.categoryBits = kParentCellFilterCategory;
    fixtureDef.filter.maskBits = 0x0000;
    // Создаем игровой круг, видимый пользователю
    body->CreateFixture(&fixtureDef);
    
    // Создаем сенсор, который будет определять радиус, в котором будут притягиваться клетки
    // Определяем радиус захвата из текстуры superpower
    CCSprite *spriteForRadius = [CCSprite spriteWithSpriteFrameName:@"parentcell_wave.png"];
    radius = spriteForRadius.contentSize.width * 0.5;
    // Создаем fixture сенсора захвата еды
    fixtureDef.isSensor = TRUE;
    shape.m_radius =  radius / PTM_RATIO;
    fixtureDef.filter.categoryBits = kParentCellFilterCategory;
    fixtureDef.filter.maskBits = kChildCellFilterCategory;
    body->CreateFixture(&fixtureDef);
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    // Если пользователь жмет на экран
    if (characterState == kStateTraveling)
    {
        for (CCSprite *tempSprite in listOfGameObjects) {
            // Притягиваем детей к главному герою
            if ([tempSprite isKindOfClass:[Box2DSprite class]])
            {
                Box2DSprite *spriteObj = (Box2DSprite*)tempSprite;
                if ((spriteObj.gameObjectType == kChildCellType || spriteObj.gameObjectType == kEnemyTypeBomb) && spriteObj.characterState == kStateConnecting) {
                    
                    [spriteObj changeState:kStateConnected];
                    
                    // Distance Joint between ChildCell and ParentCell Creation
                    
                    b2DistanceJointDef disJointDef;
                    disJointDef.bodyA = body;
                    disJointDef.bodyB = spriteObj.body;
                    disJointDef.localAnchorA.SetZero();
                    disJointDef.localAnchorB.SetZero();
                    disJointDef.frequencyHz = 0.25f;
                    disJointDef.dampingRatio = 0.4f;
                    disJointDef.length = self.contentSize.width * 0.1 / PTM_RATIO;
                    disJointDef.collideConnected = TRUE;
                    disJointDef.userData = self;
                    world->CreateJoint(&disJointDef);
                }
                // Отсоединяем детей от главного героя
                else if ((spriteObj.gameObjectType == kChildCellType || spriteObj.gameObjectType == kEnemyTypeBomb) && spriteObj.characterState == kStateDisconnecting) {
                    [spriteObj changeState:kStateIdle];
                    b2Body *childCellBody = spriteObj.body;
                    for (b2JointEdge *edge = childCellBody->GetJointList(); edge; edge = edge->next)
                    {
                        if (edge->joint->GetUserData() == self) {
                            [disJointsToDestroy addObject:[NSValue valueWithPointer:edge->joint]];
                        }
                    }
                }
            }
        }
    }
    
    // Если пользователь НЕ жмет на экран
    if (characterState == kStateIdle)
    {
        for (CCSprite *tempSprite in listOfGameObjects)
        {
            if ([tempSprite isKindOfClass:[Box2DSprite class]])
            {
                Box2DSprite *spriteObj = (Box2DSprite*)tempSprite;
                if ((spriteObj.gameObjectType == kChildCellType || spriteObj.gameObjectType == kEnemyTypeBomb) && spriteObj.characterState == kStateConnected) {
                    [spriteObj changeState:kStateIdle];
                    b2Body *childCellBody = spriteObj.body;
                    for (b2JointEdge *edge = childCellBody->GetJointList(); edge; edge = edge->next)
                    {
                        if (edge->joint->GetUserData() == self) {
                            [disJointsToDestroy addObject:[NSValue valueWithPointer:edge->joint]];
                        }
                    }
                }
            }
        }
        [self changeBodyPosition:b2Vec2(-10,-10)];
    }
    // После того как просканировали все объекты - удаляем джойнты
    [self destroyDisJoints];
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location batchNodeForPower:(CCSpriteBatchNode*)powerBatchNode
{
    if ((self = [super init])) {
        world = theWorld;
        disJointsToDestroy = [[NSMutableArray alloc] init];
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"parentcell_travelling.png"]];
        self.superpowerBatchNode = powerBatchNode;
        // При запуске уровня спрайт не виден (visible = false), становится видимым только при нажатии на экран
        self.visible = FALSE;
        gameObjectType = kParentCellType;
        characterState = kStateIdle;
        
        [self createBodyAtLocation:location];
        
        // Adding superpower waves
        [self initSuperpowerWaves];
    }
    return self;
}

- (void)initSuperpowerWaves
{
    glBlendColor(0.0f, 0, 0, 30.0/255);
    _superpowerBatchNode.blendFunc = (ccBlendFunc){GL_CONSTANT_ALPHA, GL_ONE};
    _superpowerBatchNode.visible = false;
    for (int x = 1; x <= kSuperpowerNumOfWaves; x++) {
        CCSprite *spWave = [CCSprite spriteWithSpriteFrameName:@"parentcell_wave.png"];
        [self.superpowerBatchNode addChild:spWave];
    }
}

- (void)enableSuperpowerWaves
{
    float scaleDelta = 1.0f / kSuperpowerNumOfWaves;
    CCArray *spArray = [self.superpowerBatchNode children];
    for (int x = 0; x < [spArray count]; x++) {
        CCSprite *spWave = (CCSprite*)[spArray objectAtIndex:x];
        spWave.scale = scaleDelta * (x+1);
        float rotAngle = 180;
        if (x % 2 == 0) rotAngle *= -1;
        [spWave runAction:[CCFadeIn actionWithDuration:0.3]];
        [spWave runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                           [CCScaleTo actionWithDuration:2/(x+1) scale:0],
                           [CCScaleTo actionWithDuration:0 scale:1], nil]]];
        [spWave runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1 angle:rotAngle]]];
    }
    self.superpowerBatchNode.visible = true;
}

- (void)disableSuperpowerWaves
{
    _superpowerBatchNode.visible = false;
    for (CCSprite *spWave in [_superpowerBatchNode children]) {
        [spWave stopAllActions];
    }
}

- (void)changeState:(CharacterStates)newState
{
    if (characterState == newState) {
        return;
    }
    
    [self stopAllActions];
    [self setCharacterState:newState];
    
    switch (newState) {
            
        case kStateTraveling:
        {
            // Клетка начинает отображаться на экране и ей можно управлять. В этом состоянии к ней притягиваются дочерние клетки
//            PLAYSOUNDEFFECT(@"PARENTCELL_PRESSED");
            self.visible = TRUE;
            [self enableSuperpowerWaves];
            break;
        }
            
        case kStateIdle:
        {
            // Включается когда игрок убирает палец от экрана. Спрайт клетки исчезает с экрата (visible = false),
            // дочерние клетки больше не притягиваются, и продолжают движение по энерции. Джоинты разрушаются. Тело не уничтожается
            self.visible = FALSE;
            [self disableSuperpowerWaves];
            break;
        }

        default:
            break;
    }
}

- (void)dealloc
{
    [disJointsToDestroy release];
    disJointsToDestroy = nil;
    _superpowerBatchNode = nil;
    
    [super dealloc];
}

- (void)drawDisJoints
{
    // New realisation with Batched Anti-aliased drawing
    HMVectorNode *drawNode = (HMVectorNode*)[[[self parent] parent] getChildByTag:kDrawNodeTagValue];
    
    for (b2Joint *jointList = world->GetJointList(); jointList; jointList = jointList->GetNext())
    {
        if (jointList->GetType() == e_distanceJoint)
        {
            CGPoint anchorA = [Helper toPoints:jointList->GetAnchorA()];
            CGPoint anchorB = [Helper toPoints:jointList->GetAnchorB()];
            ccColor4B lineColor;
            float lineWidth = 0;
            
            if (jointList->GetUserData() == self)
            {
                // Настройки линий для Связей между дочерними клетками и parent
                // Вычисляем расстояние между клетками и центром притяжение. Чем больше расстояние тем прозрачней линия
                float lenght = ccpDistance(anchorA, anchorB);
                // Длина не должна быть больше радиуса сенсора родительской клетки. Если больш, то приравниваем к радиусу
                lenght = MIN(lenght, radius);
                GLuint lineAlpha = (radius - lenght) / radius * 255 * 2;
                // Проверяем прозрачность линии на допустимые пределы
                if (lineAlpha > 255) {
                    lineAlpha = 255;
                }
                else if (lineAlpha < 40) {
                    lineAlpha = 40;
                }
                lineColor = ccc4(252, 252, 255, lineAlpha); // light green
                lineWidth = 1;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    lineWidth *= 2;
                }
            }
            else
            {
                // Для всех остальных distance joints
                lineColor = ccc4(172, 255, 255, 255); // white
                lineWidth = 0.75;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    lineWidth *= 2;
                }
            }
            
            [drawNode drawSegmentFrom:anchorA to:anchorB radius:lineWidth color:ccc4FFromccc4B(lineColor)];
        }
    }
}

@end
