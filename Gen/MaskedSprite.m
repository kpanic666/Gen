//
//  MaskedSprite.m
//  MaskedCal2
//
//  Created by Andrey Korikov on 08.04.12.
//  Copyright (c) 2012 kpanic666@gmail.com. All rights reserved.
//

#import "MaskedSprite.h"

@implementation MaskedSprite

- (CCTexture2D*)genTextureWithSize:(CGSize)textureSize {
    
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize.width height:textureSize.height pixelFormat:kCCTexture2DPixelFormat_RGB5A1];
    
    // 2: Call CCRenderTexture:begin
    [rt begin];
    
    // 3:
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
    // 1
    ccGLBlendFunc(blendFunc_.src, blendFunc_.dst);
    ccGLUseProgram(shaderProgram_->program_);
    [shaderProgram_ setUniformForModelViewProjectionMatrix];
    
    // 2
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, [texture_ name]);
    glUniform1i(_textureLocation, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, [_maskTexture name]);
    glUniform1i(_maskLocation, 1);
    
    // 3
#define kQuadSize sizeof(quad_.bl)
    long offset = (long)&quad_;
    
    // vertex
    NSInteger diff = offsetof(ccV3F_C4B_T2F, vertices);
    glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
    
    // texCoods
    diff = offsetof( ccV3F_C4B_T2F, texCoords);
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
    // color
    diff = offsetof( ccV3F_C4B_T2F, colors);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
    // 4
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);    
    glActiveTexture(GL_TEXTURE0);
    
    // 4
    [rt end];
    
    return rt.sprite.texture;
}

- (id)initWithTexture:(CCTexture2D *)texture rect:(CGRect)rect maskTexture:(CCTexture2D*)maskTexture {
    
    self = [super initWithTexture:texture rect:rect];
    if (self) {
        
        // 1
        _maskTexture = maskTexture;
        
        // 2
        const GLchar *fragmentSource = (GLchar*) [[NSString stringWithContentsOfFile:
                                                   [CCFileUtils fullPathFromRelativePath:@"Mask.fsh"] 
                                                                            encoding:NSUTF8StringEncoding 
                                                                               error:nil] 
                                                  UTF8String];
        
        self.shaderProgram = [[[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureColor_vert fragmentShaderByteArray:fragmentSource] autorelease];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 3
        [shaderProgram_ addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
        [shaderProgram_ addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
        [shaderProgram_ addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 4
        [shaderProgram_ link];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 5
        [shaderProgram_ updateUniforms];
        
        CHECK_GL_ERROR_DEBUG();
        
        // 6
        _textureLocation = glGetUniformLocation(shaderProgram_->program_, "u_texture");
        _maskLocation = glGetUniformLocation(shaderProgram_->program_, "u_mask");
        
        CHECK_GL_ERROR_DEBUG();
        
        [self setTexture:[self genTextureWithSize:rect.size]];
        [self setTextureRect:rect rotated:NO untrimmedSize:rect.size];
    }
    return self;
}

@end
