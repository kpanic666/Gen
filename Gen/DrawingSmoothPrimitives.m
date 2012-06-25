//
//  DrawingSmoothPrimitives.m
//  Gen
//
//  Created by Andrey Korikov on 15.06.12.
//  Copyright (c) 2012 Atom Games. All rights reserved.
//

#import "DrawingSmoothPrimitives.h"
#import "ccMacros.h"
#import "CCGL.h"
#import "ccGLStateCache.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "CCActionCatmullRom.h"
#import "OpenGL_Internal.h"

static BOOL initialized = NO;
static CCGLProgram *shader_ = nil;
static int colorLocation_ = -1;
static ccColor4B color_ = {255,255,255,255};

static void lazy_init( void )
{
	if( ! initialized ) {
        
		//
		// Position and 1 color passed as a uniform (to similate glColor4ub )
		//
		shader_ = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
        
		colorLocation_ = glGetAttribLocation(shader_->program_, "a_color");
        
		initialized = YES;
	}
    
}

void drawSmoothLine( CGPoint origin, CGPoint destination, float width )
{
    lazy_init();
    
    GLfloat lineVertices[12]; 
    CGPoint dir, tan;
    
    dir.x = destination.x - origin.x;
    dir.y = destination.y - origin.y;
    float len = sqrtf(dir.x*dir.x+dir.y*dir.y);
    if (len < 0.00001)
        return;
    dir.x = dir.x/len;
    dir.y = dir.y/len;
    tan.x = -width*dir.y;
    tan.y = width*dir.x;
    
    lineVertices[0] = origin.x + tan.x;
    lineVertices[1] = origin.y + tan.y;
    lineVertices[2] = destination.x + tan.x;
    lineVertices[3] = destination.y + tan.y;
    lineVertices[4] = origin.x;
    lineVertices[5] = origin.y;
    lineVertices[6] = destination.x;
    lineVertices[7] = destination.y;
    lineVertices[8] = origin.x - tan.x;
    lineVertices[9] = origin.y - tan.y;
    lineVertices[10] = destination.x - tan.x;
    lineVertices[11] = destination.y - tan.y;
    
    const GLubyte lineColors[] = {
        color_.r, color_.g, color_.b, 0,
        color_.r, color_.g, color_.b, 0,
        color_.r, color_.g, color_.b, color_.a,
        color_.r, color_.g, color_.b, color_.a,
        color_.r, color_.g, color_.b, 0,
        color_.r, color_.g, color_.b, 0
    };
    
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
    
    [shader_ use];
    [shader_ setUniformForModelViewProjectionMatrix];
    
    
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, lineVertices);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, lineColors);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 6);
	
	CC_INCREMENT_GL_DRAWS(1);
}

void drawColor4B(ccColor4B color)
{
	color_ = color;
}
