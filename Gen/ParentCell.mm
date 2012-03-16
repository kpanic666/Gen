//
//  ParentCell.m
//  Gen
//
//  Created by Andrey Korikov on 15.03.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "ParentCell.h"
#import "Box2DHelpers.h"

@implementation ParentCell

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
    fixtureDef.filter.categoryBits = 0x1;
    fixtureDef.filter.maskBits = 0x0000;
    // Создаем игровой круг, видимый пользователю
    body->CreateFixture(&fixtureDef);
    
    // Создаем сенсор, который будет определять какие ячейки притягивать
    shape.m_radius = self.contentSize.width * 4 / PTM_RATIO;
    fixtureDef.isSensor = TRUE;
    body->CreateFixture(&fixtureDef);
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects
{

}

- (id)initWithWorld:(b2World *)theWorld atLocation:(CGPoint)location
{
    if ((self = [super init])) {
        world = theWorld;
        [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"parentcell_travelling.png"]];
        // При запуске уровня спрайт не видет (visible = false), становится видимым только при нажатии на экран
        self.visible = FALSE;
        gameObjectType = kParentCellType;
        characterState = kStateSpawning;
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

@end
