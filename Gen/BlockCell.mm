//
//  Block.m
//  Gen
//  Общий класс для groundCell, RedCell, MetalCell.
//  Created by Andrey Korikov on 18.04.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "BlockCell.h"
#import "MaskedSprite.h"
#import "GB2ShapeCache.h"
#import "Helper.h"

@implementation BlockCell

- (void) setBodyShape:(NSString *)shapeName {
    
    // remove any existing fixtures from the body
    b2Fixture *fixture;
    while ((fixture = body->GetFixtureList()))
    {
        body->DestroyFixture(fixture);
    }
    
    // attach a new shape from the shape cache
    if (shapeName) {
        GB2ShapeCache *shapeCache = [GB2ShapeCache sharedShapeCache];
        [shapeCache addFixturesToBody:body forShapeName:shapeName];
        
        // Assign the shape's anchorPoint
        self.anchorPoint = [shapeCache anchorPointForShape:shapeName];
    }
}

- (void) initWithShape:(NSString *)shapeName inWorld:(b2World *)theWorld {
    
    NSAssert(theWorld != NULL, @"World is null!");
    NSAssert(shapeName != nil, @"Name is nil!");
    
    world = theWorld;
    markedForDestruction = FALSE;
    
    // create the body
    b2BodyDef bodyDef;
    body = world->CreateBody(&bodyDef);
    
    // set the shape
    [self setBodyShape:shapeName];
}

- (CGSize)getBodySize {
    
    const b2Transform &xf = body->GetTransform();
    b2Vec2 minVertex = b2Vec2(5000, 5000);
    b2Vec2 maxVertex = b2Vec2(-5000, -5000);
    
    for (b2Fixture *f = body->GetFixtureList(); f; f = f->GetNext())
    {
        switch (f->GetType())
        {
            case b2Shape::e_circle:
            {
                // Если тело иммет форму круга, то вычисляем крайнюю нижнюю и верхнюю точку
                b2CircleShape *circle = (b2CircleShape*)f->GetShape();
                b2Vec2 center = b2Mul(xf, circle->m_p);
                float32 radius = circle->m_radius;
                b2Vec2 circleLowerBound = b2Vec2(center.x - radius, center.y - radius);
                b2Vec2 circleUpperBound = b2Vec2(center.x + radius, center.y + radius);
                minVertex = b2Min(minVertex, circleLowerBound);
                maxVertex = b2Max(maxVertex, circleUpperBound);
            }
                break;
                
            case b2Shape::e_polygon:
            {
                b2PolygonShape *poly = (b2PolygonShape*)f->GetShape();
                int32 vertexCount = poly->m_vertexCount;
                b2Assert(vertexCount <= b2_maxPolygonVertices);
                for (int32 i = 0; i < vertexCount; ++i)
                {
                    b2Vec2 tempVertex = b2Mul(xf, poly->m_vertices[i]);
                    minVertex = b2Min(minVertex, tempVertex);
                    maxVertex = b2Max(maxVertex, tempVertex);
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    // Высчитываем размер тела в системе координат Cocos2d
    CGPoint lowerBound = [Helper toPoints:minVertex];
    CGPoint upperBound = [Helper toPoints:maxVertex];
    CGPoint thirdBound = ccp(upperBound.x, lowerBound.y);
    CGSize retValue = CGSizeMake(ccpDistance(lowerBound, thirdBound), ccpDistance(thirdBound, upperBound));
    return retValue;
}

- (CCTexture2D*)genTextureWithSize:(CGSize)textureSize {
    
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize.width height:textureSize.height pixelFormat:kCCTexture2DPixelFormat_RGB565];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:1 g:1 b:1 a:1];
    
    // 3: Draw into the texture
    // Layer 1: Noise
    CGRect rect = CGRectZero;
    rect.size = textureSize;
    
    CCTexture2D *noiseTex;
    switch (gameObjectType) {
        case kEnemyTypeRedCell:
            noiseTex = [[CCTextureCache sharedTextureCache] addImage:@"redCell.png"];
            break;
            
        case kGroundType:
            noiseTex = [[CCTextureCache sharedTextureCache] addImage:@"groundCell.png"];
            break;
            
        case kMetalType:
            noiseTex = [[CCTextureCache sharedTextureCache] addImage:@"metalCell.png"];
            break;
            
        default:
            break;
    }
    
    CCSprite *noise = [CCSprite spriteWithTexture:noiseTex rect:rect];
    ccTexParams tp2 = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [noise.texture setTexParameters:&tp2];
    noise.position = ccp(textureSize.width/2, textureSize.height/2);
    [noise visit];
    
    // 4: Call CCRenderTexture:end
    [rt end];
    
    // 5: Create a new Sprite from texture
    return rt.sprite.texture;
}

- (CCTexture2D*)genMaskTextureWithSize:(CGSize)textureSize {
    
    // Функция рисует точную копию физического тела на прозрачном листе. В месте где прозрачность останется - на результирующем спрайте будет прозрачно.
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize.width height:textureSize.height pixelFormat:kCCTexture2DPixelFormat_RGB5A1];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:1 g:1 b:1 a:0];
    
    // 3: Draw into the texture
    // Layer 1: Shapes
    
    // temp, only for calculations
    float xPoint;
    float yPoint;
    
    for (b2Fixture *f = body->GetFixtureList(); f; f = f->GetNext())
    {
        switch (f->GetType())
        {
            case b2Shape::e_circle:
            {
                b2CircleShape *circle = (b2CircleShape*)f->GetShape();
                b2Vec2 center = circle->m_p;
                float32 radius = circle->m_radius;
                const float32 k_segments = 32.0f;
                const float32 k_increment = 2.0f * b2_pi / k_segments;
                float32 theta = 0.0f;
                
                CGPoint vertices[int(k_segments)];
                for (int32 i = 0; i < k_segments; ++i)
                {
                    b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
                    xPoint = v.x * PTM_RATIO + textureSize.width * 0.5;
                    yPoint = v.y * PTM_RATIO + textureSize.height * 0.5;
                    vertices[i]=ccp(xPoint, yPoint);
                    theta += k_increment;
                }
                
                ccDrawSolidPoly(vertices, k_segments, ccc4f(0, 0, 0, 1));
            }
                break;
                
            case b2Shape::e_polygon:
            {
                b2PolygonShape *poly = (b2PolygonShape*)f->GetShape();
                int32 vertexCount = poly->m_vertexCount;
                b2Assert(vertexCount <= b2_maxPolygonVertices);
                CGPoint vertices[b2_maxPolygonVertices];
                
                for (int32 i = 0; i < vertexCount; ++i)
                {
                    xPoint = poly->m_vertices[i].x * PTM_RATIO + textureSize.width * 0.5;
                    yPoint = poly->m_vertices[i].y * PTM_RATIO + textureSize.height * 0.5;
                    vertices[i] = ccp(xPoint, yPoint);
                }
                
                ccDrawSolidPoly(vertices, vertexCount, ccc4f(0, 0, 0, 1));
            }
                break;
                
            default:
                break;
        }
    }
    
    // 4: Call CCRenderTexture:end
    [rt end];
    
    // 5: Create a new Sprite from texture
    return rt.sprite.texture;
}

- (id) initWithType:(GameObjectType)objectType withWorld:(b2World*)theWorld position:(CGPoint)pos name:(NSString*)name
{
    if ((self = [super init])) {
        
        [self initWithShape:name inWorld:theWorld];
        
        gameObjectType = objectType;
        characterState = kStateIdle;
        
        // set the body position
        body->SetTransform([Helper toMeters:pos], 0.0f);
        
        // Make mainTexture for body before transparent mask (еще не прозрачна)
        CGSize texSize = [self getBodySize];
        CGRect texRect = CGRectZero;
        texRect.size = texSize;
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCTexture2D *mainTexture = [self genTextureWithSize:texSize];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
        CCTexture2D *maskTexture = [self genMaskTextureWithSize:texSize];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
        MaskedSprite *resultSprite = [[[MaskedSprite alloc] initWithTexture:mainTexture rect:texRect maskTexture:maskTexture] autorelease];
        [self setTexture:resultSprite.texture];
        [self setTextureRect:texRect rotated:NO untrimmedSize:texSize];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    }
    return self;
}

@end
