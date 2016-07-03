//
//  AiTalkAddHeader.m
//  aiTalkSample
//  (c) 2014 NTT DOCOMO, INC. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import "AiTalkAddHeader.h"

@implementation AiTalkAddHeader

+ (Byte *)setHeader: (long)dataLength
{
    static Byte header[44] = {0};
    long longSampleRate = 16000;
    int channels = 1;
    long byteRate = 16 * 11025.0 * channels/8;
    long totalDataLen = dataLength + 44;
    
    header[0] = 'R';
    header[1] = 'I';
    header[2] = 'F';
    header[3] = 'F';
    header[4] = (Byte) (totalDataLen & 0xff);
    header[5] = (Byte) ((totalDataLen >> 8) & 0xff);
    header[6] = (Byte) ((totalDataLen >> 16) & 0xff);
    header[7] = (Byte) ((totalDataLen >> 24) & 0xff);
    header[8] = 'W';
    header[9] = 'A';
    header[10] = 'V';
    header[11] = 'E';
    header[12] = 'f';
    header[13] = 'm';
    header[14] = 't';
    header[15] = ' ';
    header[16] = 16;
    header[17] = 0;
    header[18] = 0;
    header[19] = 0;
    header[20] = 1;
    header[21] = 0;
    header[22] = (Byte) channels;
    header[23] = 0;
    header[24] = (Byte) (longSampleRate & 0xff);
    header[25] = (Byte) ((longSampleRate >> 8) & 0xff);
    header[26] = (Byte) ((longSampleRate >> 16) & 0xff);
    header[27] = (Byte) ((longSampleRate >> 24) & 0xff);
    header[28] = (Byte) (byteRate & 0xff);
    header[29] = (Byte) ((byteRate >> 8) & 0xff);
    header[30] = (Byte) ((byteRate >> 16) & 0xff);
    header[31] = (Byte) ((byteRate >> 24) & 0xff);
    header[32] = (Byte) (2 * 8 / 8);
    header[33] = 0;
    header[34] = 16;
    header[35] = 0;
    header[36] = 'd';
    header[37] = 'a';
    header[38] = 't';
    header[39] = 'a';
    header[40] = (Byte) (dataLength & 0xff);
    header[41] = (Byte) ((dataLength >> 8) & 0xff);
    header[42] = (Byte) ((dataLength >> 16) & 0xff);
    header[43] = (Byte) ((dataLength >> 24) & 0xff);
    return header;
}

/**
 wavヘッダ情報を付加する
 
 @param path ファイルパス
 @param data wav音声データ
 */
+ (NSData*)addHeader: (NSData*)data
{
    NSMutableData * soundFileData=nil;
    if([data length]>0)
    {
        Byte *header = [self setHeader:data.length];
        NSData *headerData = [NSData dataWithBytes:header length:44];
        soundFileData = [NSMutableData alloc];
        [soundFileData appendData:[headerData subdataWithRange:NSMakeRange(0, 44)]];
        [soundFileData appendData:data];
    }
    return soundFileData;
}

@end

