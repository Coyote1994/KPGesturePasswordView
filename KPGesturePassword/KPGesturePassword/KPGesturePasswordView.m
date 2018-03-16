//
//  KPGesturePasswordView.m
//  KPGesturePassword
//
//  Created by 刘鲲鹏 on 2018/3/15.
//  Copyright © 2018年 刘鲲鹏. All rights reserved.
//

/*
####绘制：

1. 首先for循环添加布局九个圆形btn，给btn加上9个对应的tag值，btn上面的图片采用绘制的方法，分别绘制出btn的未选中状态、选中状态、选错状态对应的图片
2. 创建一个可变数组，用来存放选中的按钮
3. 通过touch的began、moved、ended来监听touch事件，从而更改btn的选中状态，并添加到数组中
4. touchsMoved 方法中通过 setNeedsDisplay 一直调用 drawRect
5. drawRect 中根据选中btn数组 和 当前touch点，用 UIBezierPath 绘制 path

####逻辑：

**关于手势密码的存储，既然我们要将我们的app加上密码锁，就要实现最高的安全性。**

1. 初次设置密码需要二次确认，touchesEnded 方法中根据btn数组中btn的tag值拼接成字符串来二次确认手势密码
2. 设置成功的密码md5加密后存储在本地的keychain中，并上传到服务器（钥匙串相关操作代码：<http://blog.csdn.net/coyote1994/article/details/74550088>）
3. 密码在本地和服务器同时存储，有网的时候进行双重验证，没网的时候进行本地验证
 
 */

#import "KPGesturePasswordView.h"
#import "KeyChainStore.h"
#import "MDFiveEncryption.h"

#define KeyChainGesturePasswordKey   @"KeyChainGesturePasswordKey"

@interface KPGesturePasswordView ()

/** 选中btn数组 */
@property (strong, nonatomic) NSMutableArray *selectBtnArray;
/** 当前touch触发点 */
@property (assign, nonatomic) CGPoint currentPoint;
/** 第一次设置的手势密码 */
@property (strong, nonatomic) NSString *firstGesture;
/** 验证密码输入错误次数 */
@property (nonatomic, assign) int errorNumber;
@end


@implementation KPGesturePasswordView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectBtnArray = [[NSMutableArray alloc]initWithCapacity:0];
        self.backgroundColor = [UIColor clearColor];
        float interval = frame.size.width/13;
        float radius = interval*3;
        for (int i = 0; i < 9; i ++) {
            int row = i/3;
            int list = i%3;
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(list*(interval+radius)+interval, row*(interval+radius)+interval, radius, radius)];
            btn.userInteractionEnabled = NO;
            [self addSubview:btn];
            btn.tag = i + 1;
        }
    }
    return self;
}

- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    
    NSArray *subViews = self.subviews;
    for (UIButton *btn in subViews) {
        [btn setImage:[self drawUnselectImageWithRadius:btn.frame.size.width-6 color:self.normalColor] forState:UIControlStateNormal];
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    
    NSArray *subViews = self.subviews;
    for (UIButton *btn in subViews) {
        [btn setImage:[self drawSelectImageWithRadius:btn.frame.size.width-6 color:self.selectedColor] forState:UIControlStateSelected];
    }
}

/** 重设手势密码 */
- (void)reSetGesturePassword {
    [KeyChainStore deleteKeyData:KeyChainGesturePasswordKey];
}


- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path;
    if (_selectBtnArray.count == 0) {
        return;
    }
    path = [UIBezierPath bezierPath];
    path.lineWidth = 6;
    path.lineJoinStyle = kCGLineCapRound;
    path.lineCapStyle = kCGLineCapRound;
    if (self.userInteractionEnabled) {
        [self.selectedColor set];
    }else
    {
        [self.errorColor set];
    }
    for (int i = 0; i < _selectBtnArray.count; i ++) {
        UIButton *btn = _selectBtnArray[i];
        if (i == 0) {
            [path moveToPoint:btn.center];
        }else
        {
            [path addLineToPoint:btn.center];
        }
    }
    [path addLineToPoint:_currentPoint];
    [path stroke];
}


// 视图恢复原样
- (void)resetView
{
    for (UIButton *oneSelectBtn in _selectBtnArray) {
        oneSelectBtn.selected = NO;
    }
    [_selectBtnArray removeAllObjects];
    [self setNeedsDisplay];
}

// 验证密码错误回到原状态
- (void)wrongRevert:(NSArray *)arr
{
    self.userInteractionEnabled = YES;
    for (UIButton *btn in arr) {
        float interval = self.frame.size.width/13;
        float radius = interval*3;
        [btn setImage:[self drawSelectImageWithRadius:radius-6 color:self.selectedColor] forState:UIControlStateSelected];
    }
    [self resetView];
}

#pragma mark - Touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *oneTouch = [touches anyObject]; // anyObject 返回一个集合中最方便的值，不担保是随机的
    CGPoint point = [oneTouch locationInView:self]; // locationInView 返回一个touch在对应view中的位置
    for (UIButton *oneBtn in self.subviews) {
        if (CGRectContainsPoint(oneBtn.frame, point)) { // CGRectContainsPoint(A,B) 判断点B是否在A中
            oneBtn.selected = YES;
            if (![_selectBtnArray containsObject:oneBtn]) { // containsObject 判断一个数组中是否含有一个元素
                [_selectBtnArray addObject:oneBtn];
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *oneTouch = [touches anyObject];
    CGPoint point = [oneTouch locationInView:self];
    _currentPoint = point;
    for (UIButton *oneBtn in self.subviews) {
        if (CGRectContainsPoint(oneBtn.frame, point)) {
            oneBtn.selected = YES;
            if (![_selectBtnArray containsObject:oneBtn]) {
                [_selectBtnArray addObject:oneBtn];
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 获取结果
    NSMutableString *result = [[NSMutableString alloc]initWithCapacity:0];
    for (int i = 0; i < _selectBtnArray.count; i ++) {
        UIButton *btn = (UIButton *)_selectBtnArray[i];
        [result appendFormat:@"%d",(int)btn.tag];
    }
    
    UIButton *lastBtn = [_selectBtnArray lastObject];
    _currentPoint = lastBtn.center;
    
    if (![KeyChainStore load:KeyChainGesturePasswordKey]) { // 钥匙串中没有对应的密码，设置密码
        
        // 第二次手势密码与第一次手势密码比较
        if (_firstGesture) {
            if ([_firstGesture isEqualToString:result]) { // 两次一致
                
                // md5后保存到keychain
                NSString *password = [MDFiveEncryption md5EncryptWithString:result];
                [KeyChainStore save:KeyChainGesturePasswordKey data:password];
                
                !self.setPassword ? : self.setPassword(YES, password);
                [self resetView];
                
            }else { // 两次不一致
                self.firstGesture = nil;
                
                !self.setPassword ? : self.setPassword(NO, nil);
                
                [self drawError];
                
                
            }
        }else{ // 设置第一次手势密码
            !self.firstGestureFinished ? : self.firstGestureFinished();
            self.firstGesture = result;
            [self resetView];
        }
    }else { // 验证密码
        NSString *password = [MDFiveEncryption md5EncryptWithString:result];
        BOOL isRight = [[KeyChainStore load:KeyChainGesturePasswordKey] isEqualToString:password];
        if (isRight) {
            [self resetView];
        }else {
            [self drawError];
            _errorNumber ++;
        }
        !self.verifyPassword ? : self.verifyPassword(isRight, self.allowErrorNumber - _errorNumber);
        
    }
    
    
}

/** 绘制错误时的显示 */
- (void)drawError {
    for (UIButton *btn in _selectBtnArray) {
        float interval = self.frame.size.width/13;
        float radius = interval*3;
        [btn setImage:[self drawSelectImageWithRadius:radius-6 color:self.errorColor] forState:UIControlStateSelected];
    }
    [self performSelector:@selector(wrongRevert:) withObject:[NSArray arrayWithArray:_selectBtnArray] afterDelay:0.5];
    self.userInteractionEnabled = NO;
    [self setNeedsDisplay];
}


#pragma mark - CGContext使用

// 画未选中点图片
- (UIImage *)drawUnselectImageWithRadius:(float)radius color:(UIColor *)normalColor
{
    UIGraphicsBeginImageContext(CGSizeMake(radius+6, radius+6));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddEllipseInRect(context, CGRectMake(3, 3, radius, radius));
    [normalColor setStroke];
    CGContextSetLineWidth(context, 5);
    
    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage *unselectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return unselectImage;
}

// 画选中点图片
- (UIImage *)drawSelectImageWithRadius:(float)radius color:(UIColor *)selectColor
{
    UIGraphicsBeginImageContext(CGSizeMake(radius+6, radius+6));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 5);
    
    CGContextAddEllipseInRect(context, CGRectMake(3+radius*5/12, 3+radius*5/12, radius/6, radius/6));
    
    [selectColor set];
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextAddEllipseInRect(context, CGRectMake(3, 3, radius, radius));
    
    [selectColor setStroke];
    
    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}







@end
