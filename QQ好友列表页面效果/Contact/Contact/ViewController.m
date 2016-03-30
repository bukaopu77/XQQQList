//
//  ViewController.m
//  Contact
//
//  Created by 周剑 on 15/12/19.
//  Copyright © 2015年 bukaopu. All rights reserved.
//

#define k_screenWidth [UIScreen mainScreen].bounds.size.width
#define k_screenHeight [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "XQContactModel.h"


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, ViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

// 存放联系人的字典
@property (nonatomic, strong) NSMutableDictionary *contactDict;

// 存放联系人分组的数组
@property (nonatomic, strong) NSMutableArray *groupNameArray;

// 用来存放点开的分组名
@property (nonatomic, strong) NSMutableArray *titleArray;

@property (nonatomic, strong) NSIndexPath *indexPath;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.title = @"联系人";
    
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
    [self analysisPlist];
    
    [self.mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"flag"];

}
#pragma mark - tableView的代理方法
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.groupNameArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *string = [NSString stringWithFormat:@"%ld", section];
    if ([self.titleArray containsObject:string]) {
        NSArray *array = self.contactDict[self.groupNameArray[section]];
        return array.count;
    }else {
        return 0;
    }
}
#pragma mark - headerView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, k_screenWidth, 30)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, k_screenWidth, 30)];
    titleLabel.text = [self.groupNameArray objectAtIndex:section];
    [view addSubview:titleLabel];
    
    // 添加一个button用来监听展开的分组,实现分组的展开关闭
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, k_screenWidth, 50);
    button.tag = 200 + section;
    [button addTarget:self action:@selector(btnOpenList:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    return view;
}
#pragma mark - 按钮的点击事件,将字符串添加到数组
- (void)btnOpenList:(UIButton *) sender {
    NSString *string = [NSString stringWithFormat:@"%ld", sender.tag - 200];
    if ([self.titleArray containsObject:string]) {
        [self.titleArray removeObject:string];
    }else {
        [self.titleArray addObject:string];
    }
    [self.mainTableView reloadData];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"flag"];
    NSArray *array = self.contactDict[self.groupNameArray[indexPath.section]];
    XQContactModel *model = array[indexPath.row];
    cell.textLabel.text = model.name;
    cell.imageView.image = [UIImage imageNamed:model.picture];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
#pragma mark - 设置cell的编辑时的样式
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteActionBtnDidClicked)]) {
            [self.delegate deleteActionBtnDidClicked];
        }
    }];
    UITableViewRowAction *action2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"打你" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        action2.backgroundColor = [UIColor blueColor];
    }];
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:action1];
    [array addObject:action2];
    return array;
}
#pragma mark - 控制器的代理方法
- (void)deleteActionBtnDidClicked {
    NSString *key = self.groupNameArray[self.indexPath.section];
    NSMutableArray *mutableArray = self.contactDict[key];
    // 根据下标删除对应的模型
    [mutableArray removeObjectAtIndex:self.indexPath.row];
    if (mutableArray.count < 1) {
        [self.contactDict removeObjectForKey:key];
        // 删除对应的分组名
        [self.groupNameArray removeObject:key];
    }
    // 刷新UI
    [self.mainTableView reloadData];
}
#pragma mark - 分组名
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.groupNameArray[section];
}
#pragma mark - 解析plist文件
- (void)analysisPlist {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Person" ofType:@"plist"];
    // 取出plist文件的整体内容
    NSDictionary *sumDict = [NSDictionary dictionaryWithContentsOfFile:path];
    for (NSString *key in sumDict) {
        [self.groupNameArray addObject:key];
        // 创建数组存放联系人模型
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *smallDict in sumDict[key]) {
            XQContactModel *model = [[XQContactModel alloc] init];
            [model setValuesForKeysWithDictionary:smallDict];
            [array addObject:model];
        }
        [self.contactDict setObject:array forKey:key];
    }
    // 排序
    [self.groupNameArray sortUsingSelector:@selector(compare:)];
}
#pragma mark - 分区索引
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.groupNameArray;
}
#pragma mark - 分组高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55;
}
#pragma mark - 懒加载
- (NSMutableDictionary *)contactDict {
    if (!_contactDict) {
        _contactDict = [NSMutableDictionary dictionary];
    }
    return _contactDict;
}
- (NSMutableArray *)groupNameArray {
    if (!_groupNameArray) {
        _groupNameArray = [NSMutableArray array];
    }
    return _groupNameArray;
}
- (NSMutableArray *)titleArray {
    if (!_titleArray) {
        _titleArray = [NSMutableArray array];
    }
    return _titleArray;
}
@end
