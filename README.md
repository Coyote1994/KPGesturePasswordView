# KPGesturePasswordView

手势密码的封装

## 绘制：

1. 首先for循环添加布局九个圆形btn，给btn加上9个对应的tag值，btn上面的图片采用绘制的方法，分别绘制出btn的未选中状态、选中状态、选错状态对应的图片
2. 创建一个可变数组，用来存放选中的按钮
3. 通过touch的began、moved、ended来监听touch事件，从而更改btn的选中状态，并添加到数组中
4. touchsMoved 方法中通过 setNeedsDisplay 一直调用 drawRect
5. drawRect 中根据选中btn数组 和 当前touch点，用 UIBezierPath 绘制 path

## 逻辑：

**关于手势密码的存储，既然我们要将我们的app加上密码锁，就要实现最高的安全性。**

1. 初次设置密码需要二次确认，touchesEnded 方法中根据btn数组中btn的tag值拼接成字符串来二次确认手势密码
2. 设置成功的密码md5加密后存储在本地的keychain中，并上传到服务器（钥匙串相关操作代码：<http://blog.csdn.net/coyote1994/article/details/74550088>）
3. 密码在本地和服务器同时存储，有网的时候进行双重验证，没网的时候进行本地验证
