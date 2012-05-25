//
//  ParentCell.m
//  Gen
//
//  Created by Andrey Korikov on 15.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ParentCell.h"
#import "Helper.h"

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
    shape.m_radius = self.contentSize.width * 0.25f / PTM_RATIO;
    fixtureDef.shape = &shape;
    // Задаем маску фильтрации столкновений. Главная клетка будет игнорироваться абсолютно всеми. Можно свободно двигаться
    fixtureDef.filter.categoryBits = kParentCellFilterCategory;
    fixtureDef.filter.maskBits = 0x0000;
    // Создаем игровой круг, видимый пользователю
    body->CreateFixture(&fixtureDef);
    
    // Создаем сенсор, который будет определять радиус, в котором будут притягиваться клетки
    fixtureDef.isSensor = TRUE;
    shape.m_radius = self.contentSize.width * 1.7 / PTM_RATIO;
    // Активируем коллизии для сенсора
    fixtureDef.filter.categoryBits = kParentCellFilterCategory;
    fixtureDef.filter.maskBits = kChildCellFilterCategory;
    body->CreateFixture(&fixtureDef);
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    // Если пользователь жмет на экран
    if (characterState == kStateTraveling) {
        for (CCSprite *tempSprite in listOfGameObjects) {
            // Притягиваем детей к главному герою
            if ([tempSprite isKindOfClass:[Box2DSprite class]])
            {
                Box2DSprite *spriteObj = (Box2DSprite*)tempSprite;
                if (spriteObj.gameObjectType == kChildCellType && spriteObj.characterState == kStateConnecting) {
                    
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
                else if (spriteObj.gameObjectType == kChildCellType && spriteObj.characterState == kStateDisconnecting) {
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
                if (spriteObj.gameObjectType == kChildCellType && spriteObj.characterState == kStateConnected) {
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

- (void)dealloc
{
    [disJointsToDestroy release];
    disJointsToDestroy = nil;
    
    [super dealloc];
}

- (void)drawDisJoints
{
    for (b2Joint *jointList = world->GetJointList(); jointList; jointList = jointList->GetNext())
    {
        if (jointList->GetType() == e_distanceJoint)
        {
            CHECK_GL_ERROR_DEBUG();
            
            // Вычисляем расстояние между клетками и центром притяжение. Чем больше расстояние тем прозрачней линия
            CGPoint anchorA = [Helper toPoints:jointList->GetAnchorA()];
            CGPoint anchorB = [Helper toPoints:jointList->GetAnchorB()];
//            int16 jointLenght = ccpDistance(anchorA, anchorB);
//            
//            // Прозрачность линии
//            GLubyte lineAlpha = 150;
//            if (lineAlpha < 1) {
//                lineAlpha = 1; 
//            } else if (lineAlpha > 255) {
//                lineAlpha = 255;
//            }
            
            ccDrawColor4B(172, 255, 255, 230);
            glLineWidth(1.0f);
            ccDrawLine(anchorA, anchorB);
        }
    }
}

@end
