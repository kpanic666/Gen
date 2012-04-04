//
//  MagneticCell.m
//  Gen
//  Ловушка - отталкивает ChildCell от себя.
//  Created by Andrey Korikov on 02.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "MagneticCell.h"
#import "Helper.h"

@implementation MagneticCell

- (void)destroyDisJoints
{
    for (NSValue *value in disJointsToDestroy) {
        b2Joint *disJoint = (b2Joint*)[value pointerValue];
        world->DestroyJoint(disJoint);
    }
    [disJointsToDestroy removeAllObjects];
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
    // Создаем игровой круг, видимый пользователю
    body->CreateFixture(&fixtureDef);
    
    // Создаем сенсор, который будет определять радиус, в котором будут притягиваться клетки
    fixtureDef.isSensor = TRUE;
    shape.m_radius = self.contentSize.width * 1.5 / PTM_RATIO;
    // Активируем коллизии для сенсора
    fixtureDef.filter.categoryBits = kParentCellFilterCategory;
    fixtureDef.filter.maskBits = kChildCellFilterCategory;
    body->CreateFixture(&fixtureDef);
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{
    for (Box2DSprite *spriteObj in listOfGameObjects) {
        // Притягиваем детей к self
        if (spriteObj.gameObjectType == kChildCellType && spriteObj.characterState == kStateMagnitting) {
            
            [spriteObj changeState:kStateMagnited];
            
            // Distance Joint between ChildCell and MagneticCell Creation
            
            b2DistanceJointDef disJointDef;
            disJointDef.bodyA = body;
            disJointDef.bodyB = spriteObj.body;
            disJointDef.localAnchorA.SetZero();
            disJointDef.localAnchorB.SetZero();
            disJointDef.frequencyHz = 0.25f;
            disJointDef.dampingRatio = 0.8f;
            disJointDef.length = self.contentSize.width * 1.8 / PTM_RATIO;
            disJointDef.collideConnected = TRUE;
            world->CreateJoint(&disJointDef);
        }
        // Отсоединяем детей от магнита
        else if (spriteObj.gameObjectType == kChildCellType && spriteObj.characterState == kStateDismagnitting) {
//            [spriteObj changeState:kStateIdle];
            b2Body *childCellBody = spriteObj.body;
            for (b2JointEdge *edge = childCellBody->GetJointList(); edge; edge = edge->next)
            {
                Box2DSprite *otherSprite = (Box2DSprite*)edge->other->GetUserData();
                if ([otherSprite gameObjectType] == kEnemyTypeMagneticCell) {
                    [disJointsToDestroy addObject:[NSValue valueWithPointer:edge->joint]];
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
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"magneticcell_idle.png"]];
        gameObjectType = kEnemyTypeMagneticCell;
        characterState = kStateIdle;
        [self createBodyAtLocation:location];
    }
    return self;
}

- (void)changeState:(CharacterStates)newState
{
    
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
