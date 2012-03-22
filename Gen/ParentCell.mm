//
//  ParentCell.m
//  Gen
//
//  Created by Andrey Korikov on 15.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ParentCell.h"

@implementation ParentCell

- (void)destroyDisJoints
{
    for (NSValue *value in disJointsToDestroy) {
        b2Joint *disJoint = (b2Joint*)[value pointerValue];
        world->DestroyJoint(disJoint);
    }
    [disJointsToDestroy removeAllObjects];
}

- (void)changeBodyPosition:(b2Vec2)position
{
    body->SetTransform(position, 0.0f);
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
    fixtureDef.isSensor = TRUE;
    shape.m_radius = self.contentSize.width * 4 / PTM_RATIO;
    // Активируем коллизии для сенсора
    fixtureDef.filter.categoryBits = kParentCellFilterCategory;
    fixtureDef.filter.maskBits = kChildCellFilterCategory;
    body->CreateFixture(&fixtureDef);
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    // Если пользователь жмет на экран
    if (characterState == kStateTraveling) {
        for (Box2DSprite *spriteObj in listOfGameObjects) {
            // Притягиваем детей к главному герою
            if (spriteObj.gameObjectType == kChildCellType && spriteObj.characterState == kStateConnecting) {
                
                [spriteObj changeState:kStateConnected];
                
                // Joint Creation
                
                b2DistanceJointDef disJointDef;
                disJointDef.bodyA = body;
                disJointDef.bodyB = spriteObj.body;
                disJointDef.localAnchorA.SetZero();
                disJointDef.localAnchorB.SetZero();
                disJointDef.frequencyHz = 0.25f;
                disJointDef.dampingRatio = 0.4f;
                disJointDef.length = self.contentSize.width / PTM_RATIO;
                disJointDef.collideConnected = TRUE;
                world->CreateJoint(&disJointDef);
            }
            // Отсоединяем детей от главного героя
            else if (spriteObj.gameObjectType == kChildCellType && spriteObj.characterState == kStateDisconnecting) {
                [spriteObj changeState:kStateIdle];
                b2Body *childCellBody = spriteObj.body;
                for (b2JointEdge *edge = childCellBody->GetJointList(); edge; edge = edge->next)
                {
                    [disJointsToDestroy addObject:[NSValue valueWithPointer:edge->joint]];
                }
            }
        }
    }
    
    // Если пользователь НЕ жмет на экран
    if (characterState == kStateIdle) {
        for (Box2DSprite *spriteObj in listOfGameObjects) {
            if (spriteObj.gameObjectType == kChildCellType && spriteObj.characterState == kStateConnected) {
                [spriteObj changeState:kStateIdle];
                b2Body *childCellBody = spriteObj.body;
                for (b2JointEdge *edge = childCellBody->GetJointList(); edge; edge = edge->next)
                {
                    [disJointsToDestroy addObject:[NSValue valueWithPointer:edge->joint]];
                    [self changeBodyPosition:b2Vec2(0,0)];
                }
            }
        }
    }
    // После того как просканировали все объекты - удаляем джойнты
    [self destroyDisJoints];
}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init])) {
        world = theWorld;
        disJointsToDestroy = [[NSMutableArray alloc] init];
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"parentcell_travelling.png"]];
        // При запуске уровня спрайт не видет (visible = false), становится видимым только при нажатии на экран
        self.visible = FALSE;
        gameObjectType = kParentCellType;
        characterState = kStateIdle;
        
        [self createBodyAtLocation:location];
    }
    return self;
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
            self.visible = TRUE;
            break;
        }
            
        case kStateIdle:
        {
            // Включается когда игрок убирает палец от экрана. Спрайт клетки исчезает с экрата (visible = false),
            // дочерние клетки больше не притягиваются, и продолжают движение по энерции. Джоинты разрушаются. Тело не уничтожается
            self.visible = FALSE;
            break;
        }

        default:
            break;
    }
}

- (BOOL)mouseJointBegan
{
    return NO;
}

- (void)dealloc
{
    [disJointsToDestroy release];
    disJointsToDestroy = nil;
    
    [super dealloc];
}

@end
