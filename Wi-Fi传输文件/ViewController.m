//
//  ViewController.m
//  Wi-Fi传输文件
//
//  Created by 朱信磊 on 2019/7/30.
//  Copyright © 2019 com.bandou.app.xib.demo. All rights reserved.
//

#import "ViewController.h"
#import <CocoaHTTPServer/HTTPServer.h>
#import "IPManager.h"
#import "MyHTTPConnection.h"
#import "BDModel.h"
@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) HTTPServer    *httpServer;

@property (strong, nonatomic) UITableView   *myTab;

@property (strong ,nonatomic) NSMutableArray    *aryDatas;

@property (strong, nonatomic) UILabel       *lbIpAddress;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.aryDatas = [[NSMutableArray alloc] init];
    self.view.backgroundColor = UIColor.whiteColor;
    
    
    //创建服务器
    self.httpServer = [[HTTPServer alloc] init];
    [self.httpServer setType:@"_http._tcp."];
    //webpath是server搜寻html等文件的路径
    NSString *webPath = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
    NSLog(@"%@",webPath);
    
    [self.httpServer setDocumentRoot:webPath];
    //z设置连接类
    [self.httpServer setConnectionClass:[MyHTTPConnection class]];
    
    NSError *error;
    if ([self.httpServer start:&error]) {
        NSString *ipString = [[IPManager shareManager] bd_getIPAddress];
        NSLog(@"ip地址为:%@",ipString);
        _lbIpAddress.text = [NSString stringWithFormat:@"请在浏览器中输入:%@:%d",ipString,self.httpServer.listeningPort];
    }else{
        NSLog(@"%@",[error description]);
    }
    
    //定时器 刷新沙盒文件
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkFile) userInfo:nil repeats:YES];
    [timer fire];
}


- (void)loadView{
    [super loadView];
    UITableView *tab = [[UITableView alloc] initWithFrame:UIScreen.mainScreen.bounds style:UITableViewStylePlain];
    [tab setDataSource:self];
    [tab setDelegate:self];
    [tab setShowsVerticalScrollIndicator:false];
    [tab setShowsHorizontalScrollIndicator:false];
    [tab setTableFooterView:[UIView new]];
    [tab setTableHeaderView:self.lbIpAddress];
    [self.view addSubview:tab];
    self.myTab = tab;
}


/**
 检测沙盒目录文件
 */
- (void)checkFile{
    [self.aryDatas removeAllObjects];
    //path
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDir = false;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir) {
            //获取文件夹下所有文件
            NSArray *ary = [fileManager contentsOfDirectoryAtPath:path error:nil];
            for (NSString *str in ary) {
                NSLog(@"%@", str);
                BDFileModel *model = [[BDFileModel alloc] init];
                NSArray *filesAry = [str componentsSeparatedByString:@"."];
                NSString *name = filesAry.count > 0 ? [filesAry firstObject] : [NSString stringWithFormat:@"%d",arc4random() % 100];
                long size = [self bd_safeGetFileSize:[path stringByAppendingPathComponent:str]];
                if (filesAry.count > 1) {
                    NSString *type = [filesAry lastObject];
                    if ([type isEqualToString:@"png"]) {
                        model.fileType = fileType_image;
                    }else if ([type isEqualToString:@"pdf"]){
                        model.fileType = fileType_pdf;
                    }else if ([type isEqualToString:@"docx"] || [type isEqualToString:@"doc"]){
                        model.fileType = fileType_word;
                    }else if ([type isEqualToString:@"xls"] || [type isEqualToString:@"xlsx"]){
                        model.fileType = fileType_excel;
                    }else if ([type isEqualToString:@"txt"]){
                        model.fileType = fileType_txt;
                    }else{
                        model.fileType = fileType_other;
                    }
                }
                model.fileName = name;
                model.fileSize = size / 1024.0 ;
                [self.aryDatas addObject:model];
            }
            [self.myTab reloadData];
        }
    }
}



/**
 lbIpAddress

 @return UIlable
 */
- (UILabel *)lbIpAddress{
    if (_lbIpAddress != nil) {
        return _lbIpAddress;
    }
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    lb.textColor = UIColor.blackColor;
    [lb setFont:[UIFont systemFontOfSize:18]];
    _lbIpAddress = lb;
    return _lbIpAddress;
}



#pragma mark - tableViewDataSourth

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.aryDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    BDFileModel *model = [self.aryDatas objectAtIndex:indexPath.row];
    cell.textLabel.text = model.fileName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"文件大小:%.1lf KB",model.fileSize];
    cell.imageView.image = [self cellImage:model];
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  55;
}

- (UIImage *)cellImage:(BDFileModel *)model{
    UIImage *img = nil;
     if (model.fileType == fileType_txt){
        img = [UIImage imageNamed:@"icon_txt"];
    }else if (model.fileType == fileType_excel){
        img = [UIImage imageNamed:@"icon_excel"];
    }else if (model.fileType == fileType_word){
        img = [UIImage imageNamed:@"icon_word"];
    }else if (model.fileType == fileType_pdf){
        img = [UIImage imageNamed:@"icon_pdf"];
    }else if (model.fileType == fileType_image){
        img = [UIImage imageNamed:@"icon_img"];
    }else{
         img = [UIImage imageNamed:@"icon_other"];
    }
    return img;
}




/**
 获取文件大小

 @param path filePath
 @return file size
 */
- (NSInteger)bd_safeGetFileSize:(NSString *)path{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *e = nil;
        NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&e];
        NSLog(@"%@", e);
        NSLog(@"%@",[info description]);
        NSInteger size = [[info objectForKey:NSFileSize] intValue];
        if (size > 0) {
            return size;
        }
    }
    return 0;
}

@end
