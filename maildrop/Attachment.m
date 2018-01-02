// Copyright (c) 2008,2010 Simon Fell
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
// THE SOFTWARE.
//

#import "Attachment.h"
#import "Email.h"
#import "zkSObject.h"
#import "WhoWhat.h"

@implementation Attachment

@synthesize name, mimeType, file, parentId, shouldUpload, salesforceId, parentWhoWhat;

-(id)init {
	self = [super init];
	file = [[[NSURL URLWithString:uniqueId relativeToURL:[NSURL fileURLWithPath:NSTemporaryDirectory()]] absoluteURL] retain];
	shouldUpload = YES;
	return self;
}

- (void)dealloc {
	[[NSFileManager defaultManager] removeItemAtPath:[[file absoluteURL] path] error:nil];
	[salesforceId release];
	[parentId release];
	[name release];
	[mimeType release];
	[file release];
	[parentWhoWhat release];
	[super dealloc];
}

-(ZKSObject *)makeSObject {
	ZKSObject *a = [[[ZKSObject alloc] initWithType:@"Attachment"] autorelease];
	[a setFieldValue:[self parentId] field:@"ParentId"];
	[a setFieldValue:name field:@"Name"];
	[a setFieldValue:mimeType field:@"ContentType"];
	NSData *d = [[NSData alloc] initWithContentsOfURL:file];
    [a setFieldValue:[d base64EncodedStringWithOptions:0] field:@"Body"];
	[d release];
	return a;
}

-(NSString *)parentId {
	return parentId != nil ? parentId : [parentWhoWhat salesforceId];
}

-(void)setParentId:(NSString *)newParentId {
    parentId = newParentId;
}

-(NSString *)uniqueId {
	return uniqueId;
}

-(NSString *)formattedSize {
    NSDictionary *p = [[NSFileManager defaultManager] attributesOfItemAtPath:[[[file absoluteURL] path] stringByResolvingSymlinksInPath] error:nil];
	long sz = [[p objectForKey:NSFileSize] longValue];
	if (sz < 1024)
		return [NSString stringWithFormat:@"%ld bytes", sz];
	if (sz < (1024 * 1024))
		return [NSString stringWithFormat:@"%2.1f Kb", (sz / 1024.0f)];
	return [NSString stringWithFormat:@"%2.1f Mb", (sz / (1024.0f * 1024))];
}

-(NSString *)description {
	return [NSString stringWithFormat:@"%@ :type %@ url %@ id %@", name, mimeType, file, uniqueId];
}

@end
