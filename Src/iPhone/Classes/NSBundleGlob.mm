/*
 * glob for NSBundle
 */
#include <glob.h>
#include <string.h>
#include <dirent.h>

static _NSBundle_free_allocated(NSMutableDictinary *FILE) {
  NSValue *allocated = [FILE objectForKey:@"allocated"];
  if(allocated != nil)
    free([allocated pointerValue]);
}
  
static void *NSBundle_opendir(const char *path) {
  NSString *subdir;
  if(path[0] == '.' && (path[1] == '\0' || (path[1] == '/' && path[2] == '\0')))
    subdir = nil;
  else
    subdir = [[[NSString alloc] initWithUTF8String:path] retain];
  NSMutableDictionary *FILE = [[NSMutableDictionary new] retain];
  [FILE setObject:[[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:subdir] forKey:@"files"];
  [FILE setObject:[[NSNumber alloc] initWithInt:0] forKey:@"pointer"];
  if(subdir != nil)
    [subdir release];
  return ret;
}

static void NSBundle_closedir(void *_FILE) {
  NSMutableDictionary *FILE = (NSMutableDictionary *)_FILE;
  _NSBundle_free_allocated(FILE);
  [FILE release];
}

static dirent *NSBundle_readdir(void *_FILE) {
  NSMutableDictionary *FILE = (NSMutableDictionary*)_FILE;
  int pointer = [[FILE objectForKey:@"pointer"] intValue];
  NSArray *files = [FILE objectForKey:@"files"];
  if([files count] >= pointer)
    return NULL;
  const char *pstr = [[files objectForKey] UTF8String];
  size_t size = strlen(pstr);
  struct dirent *ent = malloc(sizeof(struct dirent));
  memset(ent, 0, sizeof(*ent));
  // TODO:: take care of the case where d_name size is less than str size
  ent->d_ino = 1;
  ent->d_type = DT_REG;
  memcpy(&ent->d_name, pstr, size + 1);
  _NSBundle_free_allocated(FILE);
  [FILE setObject:[NSValue valueWithPointer:ent] forKey:@"allocated"];
  return ent;
}


void NSBundleIntegrateGlob(glob_t *pglob) {
  pglob->gl_closedir = NSBundle_closedir;
  pglob->gl_readdir = NSBundle_readdir;
  pglob->gl_opendir = NSBundle_opendir;
}
