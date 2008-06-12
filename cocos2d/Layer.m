//
//  Layer.m
//  cocos2d
//

#import <OpenGLES/ES1/gl.h>

#import "Layer.h"
#import "Director.h"

@implementation Layer
-(id) init
{
	if( ! [super init] )
		return nil;
	
	CGRect s = [[Director sharedDirector] winSize];
	
	transformAnchor.x = s.size.width / 2;
	transformAnchor.y = s.size.height / 2;
	
	isEventHandler = NO;
	
	return self;
}

-(void) onEnter
{
	[super onEnter];
	
	if( isEventHandler )
		[[Director sharedDirector] setEventHandler:self];
}
-(void) onExit
{
	[super onExit];
	
	if( isEventHandler )
		[[Director sharedDirector] setEventHandler:nil];
}
@end

@implementation ColorLayer

@synthesize color;

- (id) init
{
	NSException* myException = [NSException
								exceptionWithName:@"ColorLayerInit"
								reason:@"Use ColorLayer initWithColor instead"
								userInfo:nil];
	@throw myException;	
}

+ (id) layerWithColor: (GLuint) aColor width:(GLint)w  height:(GLint) h
{
	return [[[self alloc] initWithColor: aColor width:w height:h] autorelease];
}

+ (id) layerWithColor: (GLuint) aColor
{
	return [[[self alloc] initWithColor: aColor] autorelease];
}

- (id) initWithColor: (GLuint) aColor width:(GLint)w  height:(GLint) h
{
	if (![super init])
		return nil;

	[self changeColor: aColor];
	[self initWidth:w height:h];
	return self;
}

- (id) initWithColor: (GLuint) aColor
{
	CGRect size = [[Director sharedDirector] winSize];
	
	return [self initWithColor: aColor width:size.size.width height:size.size.height];
}

- (void) changeColor: (GLuint) aColor
{
	GLubyte r, g, b, a;
	
	color = aColor;
	
	r = (color>>24) & 0xff;
	g = (color>>16) & 0xff;
	b = (color>>8) & 0xff;
	a = (color) & 0xff;

	for( int i=0; i < sizeof(squareColors) / sizeof(squareColors[0]);i++ )
	{
		if( i % 4 == 0 )
			squareColors[i] = r;
		else if( i % 4 == 1)
			squareColors[i] = g;
		else if( i % 4 ==2  )
			squareColors[i] = b;
		else
			squareColors[i] = a;
	}
}

-(void) setOpacity: (GLubyte) o
{
	GLuint c = (color & 0xffffff00) | o;
	[self changeColor:c];
}

-(GLubyte) opacity
{
	return (color & 0xff);
}

- (void) initWidth: (GLint) w height:(GLint) h
{
	for (int i=0; i<sizeof(squareVertices) / sizeof( squareVertices[0]); i++ )
		squareVertices[i] = 0.0f;
	
	squareVertices[2] = w;
	squareVertices[5] = h;
	squareVertices[6] = w;
	squareVertices[7] = h;
	
}
- (void)draw
{		
	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
	glEnableClientState(GL_COLOR_ARRAY);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}
@end

@implementation MultiplexLayer
+(id) layerWithLayers: (Layer*) layer, ... 
{
	va_list args;
	va_start(args,layer);
	
	id s = [[[self alloc] initWithLayers: layer, args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithLayers: (Layer*) layer, ... 
{
	if( ![super init] )
		return nil;
	
	layers = [[NSArray array] retain];
	
	[layers addObject: layer];
	
	va_list params;
	va_start(params,layer);

	Layer *l = va_arg(params,Layer*);
	while( l ) {
		[layers addObject: layer];
		l = va_arg(params,Layer*);
	}
	va_end(params);
	
	enabledLayer = 0;
	[self add: [layers objectAtIndex: enabledLayer]];		
	
	return self;
}

-(void) dealloc
{
	[layers release];
	[super dealloc];
}

-(void) switchTo: (unsigned int) n
{
	if( n >= [layers count] ) {
		NSException* myException = [NSException
									exceptionWithName:@"MultiplexLayerInvalidIndex"
									reason:@"Invalid index in MultiplexLayer switchTo message"
									userInfo:nil];
		@throw myException;		
	}
		
	[self remove: [layers objectAtIndex:enabledLayer]];
	
	enabledLayer = n;
	
	[self add: [layers objectAtIndex:n]];		
}
@end
