//
//  tfWrap.h
//  Student
//
//  Created by Trần T. Dũng on 8/4/24.
//

#ifndef tfWrap_h
#define tfWrap_h

#endif /* tfWrap_h */

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface tfWrap : NSObject
- (void) loadModel:(NSString*)graphFileName labels:(NSString*)labelsFileName memMapped:(bool)map optEnv:(bool)opt;
- (void) setInputLayer:(NSString*)inLayer outputLayer:(NSString*)outLayer;
- (NSArray*)runOnFrame:(CVPixelBufferRef)pixelBuffer;
- (void) clean;
@end

