#include <string>
#include <stdio.h>
#include <sys/stat.h>

#include "../Common/Globber.h"
#include "../DasherCore/AbstractXMLParser.h"
#include "../DasherCore/DasherInterfaceBase.h"
#include "FileUtils.h"

int FileUtils::GetFileSize(const std::string &strFileName) {
  NSError *err;
  NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithUTF8String:strFileName.c_str()] error:&err];
  if(err != nil) {
    NSLog(@"Warning request for file size failed: %s, error: %@", strFileName.c_str(), [err localizedDescription]);
    return 0;
  } else {
    return (int)[attrs fileSize];
  }
}

void FileUtils::ScanFiles(AbstractParser *parser, const std::string &strPattern) {
  const char *user[2], *sys[1];
  user[0] = user[1] = sys[0] = nullptr; //terminators
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *path;
  if([paths count] > 0) {
    const char *cstrPattern = strPattern.c_str();
    path = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], [NSString stringWithUTF8String:cstrPattern]];
    user[0] = [path cStringUsingEncoding:NSUTF8StringEncoding];
  }
  globScan(parser, user, sys);
}

bool FileUtils::WriteUserDataFile(const std::string &filename, const std::string &strNewText, bool append) {
  if (strNewText.length() == 0)
    return true;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  if([paths count] == 0) {
    return false;
  }
  const char *cfilename = filename.c_str();
  NSString *path = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], [NSString stringWithUTF8String:cfilename]];
  FILE* f = fopen([path fileSystemRepresentation], append ? "a+" : "w+");
  if (f == nullptr)
    return false;
  int written = fwrite(strNewText.c_str(), 1, strNewText.length(), f);
  fclose(f);
  return written == strNewText.length();
}
