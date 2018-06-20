//
//  WSTopSlidMenuView.m
//  Demo
//
//  Created by YanSY on 2018/6/20.
//  Copyright © 2018年 YanSY. All rights reserved.
//

#import "WSTopSlidMenuView.h"

#define SelectColor UIColorFromRGBA(0xFFFFFF, 1.f)
#define NormalColor UIColorFromRGBA(0xDDDDDD, 1.f)

#define SelectFont 19
#define NormalFont 18

@interface WSTopSlidMenuView ()

/// 背景图片
@property (nonatomic , strong) UIImageView * backImageView;
/// 房态按钮
@property (nonatomic , strong) UIButton * roomStateBt;
/// 订单按钮
@property (nonatomic , strong) UIButton * orderButton;
/// 统计按钮
@property (nonatomic , strong) UIButton * statisticalBt;
/// 选中下划线
@property (nonatomic , strong) UIView   * underLineView;

/// 搜索按钮
@property (nonatomic , strong) UIButton * searchButton;
/// 添加按钮
@property (nonatomic , strong) UIButton * addButton;

@end

@implementation WSTopSlidMenuView

#pragma mark -- 初始化
- (instancetype)init{
    
    self = [super init];
    if (self) {
        [self configuration];
        [self addUI];
        [self addConstraint];
        [self buttonClickAction:self.roomStateBt];
    }
    return self;
}

/// 配置
- (void)configuration{
    // 默认选中房态按钮
    self.selectBtCount = 0;
}

/// 添加 UI
- (void)addUI{
    
    self.roomStateBt   = [self createMenuButtonWithTitle:@"房态"];
    self.orderButton   = [self createMenuButtonWithTitle:@"订单"];
    self.statisticalBt = [self createMenuButtonWithTitle:@"统计"];
    
    [self addSubview:self.backImageView];
    [self addSubview:self.roomStateBt];
    [self addSubview:self.orderButton];
    [self addSubview:self.statisticalBt];
    [self addSubview:self.underLineView];

    [self addSubview:self.searchButton];
    [self addSubview:self.addButton];
}

#pragma mark -- 事件响应
- (void)buttonClickAction:(UIButton *)sender{
    
    // 重置菜单按钮状态
    [self resetMenuButtonState];
    
    // 更新选中按钮状态
    sender.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:SelectFont];
    sender.selected = YES;
    sender.userInteractionEnabled = NO;
    
    // 记录选中按钮
    if ([sender isEqual:self.roomStateBt]) {
        self.selectBtCount = 0;
    }else if ([sender isEqual:self.roomStateBt]){
        self.selectBtCount = 1;
    }else{
        self.selectBtCount = 2;
    }

    // TODO 切换左边视图控件显示

    // 移动下划线坐标并加载动画效果
    [self.underLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREENWIDTH/2/3/4);
        make.height.mas_equalTo(2.f);
        make.top.equalTo(sender.mas_bottom);
        make.centerX.equalTo(sender.mas_centerX);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGPoint centerSender = sender.center;
        self.underLineView.center = CGPointMake(centerSender.x, self.underLineView.center.y);
    }];
    
}

- (void)searchButtonAction:(UIButton *)sender{
    
}


- (void)addButtonAction:(UIButton *)sender{
    
}

#pragma mark -- 重置菜单按钮状态
- (void)resetMenuButtonState{
    
    [self.roomStateBt.titleLabel   setFont:[UIFont systemFontOfSize:NormalFont]];
    [self.orderButton.titleLabel   setFont:[UIFont systemFontOfSize:NormalFont]];
    [self.statisticalBt.titleLabel setFont:[UIFont systemFontOfSize:NormalFont]];
    
    self.roomStateBt.selected   = NO;
    self.orderButton.selected   = NO;
    self.statisticalBt.selected = NO;
    
    self.roomStateBt.userInteractionEnabled   = YES;
    self.orderButton.userInteractionEnabled   = YES;
    self.statisticalBt.userInteractionEnabled = YES;
}

#pragma mark -- 懒加载
- (UIImageView *)backImageView{
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc]init];
        _backImageView.image = [UIImage imageNamed:@"首页bg"];
    }
    return _backImageView;
}

- (UIView *)underLineView{
    if (!_underLineView) {
        _underLineView = [[UIView alloc]init];
        _underLineView.backgroundColor = SelectColor;
    }
    return _underLineView;
}

- (UIButton *)searchButton{
    if (!_searchButton) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [_searchButton addTarget:self action:@selector(searchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}

- (UIButton *)addButton{
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [_addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

#pragma mark -- 根据title创建按钮
- (UIButton *)createMenuButtonWithTitle:(NSString *)title{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:NormalFont]];
    [button setTitleColor:NormalColor forState:UIControlStateNormal];
    [button setTitleColor:SelectColor forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self addConstraint];
}

/// 添加 约束
- (void)addConstraint{
    
    [self.backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
    }];
    
    CGFloat marginTop = 20;
    if (@available(iOS 11.0, *)) {
        if (self.viewController.view.safeAreaInsets.bottom > 0) {
            marginTop = self.viewController.view.safeAreaInsets.bottom;
        }
    }
    
    [self.roomStateBt mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(marginTop);
        make.left.equalTo(self.mas_left).offset(10.f);
        make.width.mas_equalTo(SCREENWIDTH/2/3);
        make.height.mas_equalTo(44.f);
    }];
    
    [self.orderButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.roomStateBt);
        make.left.equalTo(self.roomStateBt.mas_right);
        make.width.mas_equalTo(self.roomStateBt);
    }];
    
    [self.statisticalBt mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.roomStateBt);
        make.left.equalTo(self.orderButton.mas_right);
        make.width.mas_equalTo(self.roomStateBt);
    }];
    
    [self.addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.roomStateBt);
        make.right.equalTo(self.mas_right).offset(-10);
        make.width.mas_equalTo(44.f);
    }];
    
    [self.searchButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.roomStateBt);
        make.right.equalTo(self.addButton.mas_left).offset(0.f);
        make.width.mas_equalTo(self.addButton);
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end









