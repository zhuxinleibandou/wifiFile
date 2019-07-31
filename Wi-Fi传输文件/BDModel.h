//
//  BDModel.h
//  Wi-Fi传输文件
//
//  Created by 朱信磊 on 2019/7/31.
//  Copyright © 2019 com.bandou.app.xib.demo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    fileType_txt,
    fileType_image,
    fileType_word,
    fileType_excel,
    fileType_pdf,
    fileType_other
} FileType;

@interface BDFileModel : NSObject

@property (strong, nonatomic) NSString *fileName;

@property (assign, nonatomic) double   fileSize;

/**
 文件类型:
 */
@property (assign, nonatomic) FileType       fileType;

@end

NS_ASSUME_NONNULL_END
