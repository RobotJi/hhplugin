# hhplugin
Xcode选中、语法 高亮插件

以前用eclipse开发，自带的有语法高亮的效果。做ios开发也许久了，但是没发现一款语法高亮的插件，因为xcode自己的效果是仅在变量或类名下面加了个虚线，平时看起代码来十分不舒服，最近果断为xcode写了一款语法高亮的插件，不过功能非常有限，没有eclipse的那么好用，也没对对象的作用域区分，勉强能使用吧。和有需要的分享一下吧。
下载附件，解压后放在：你的用户/Library/Application Support/Developer/Shared/Xcode/Plug-ins目录下，有的童鞋还没有Plug-ins这个目录吧，那就手动建一个，然后把解压后的highlight-Plugin.xcplugin放进去，重启xcode即可。然后就能看到高亮的菜单了。
有其他xcode插件需求和开发经验的请留言，共同学习。
以前一直是放在cocoachina上，现在放在这里维护吧。

不同Xcode版本的插件安装目录：
//Xcode 5.x  install path ~/Library/Application Support/Xcode/Plug-ins
//Xcode 6.x  install path ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins
//Xcode 7.x  install path ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins

/**
 *  在新版Xcode里面插件会失效，请做如下操作
 *  1、打开终端，输入：defaults read /Applications/Xcode.app/Contents/Info DVTPlugInCompatibilityUUID
 *  命令后，会得到你的Xcode唯一串，如：7265231C-39B4-402C-89E1-16167C4CC990，
 *  2、然后打开插件安装目录（上面），找到highlight-Plugin.xcplugin，右键-显示包内容，进去之后找到Info.plist
 *  3、打开Info.plist，找到key为DVTPlugInCompatibilityUUID的array项，把刚才得到的Xcode唯一串添加进去，保存
 *  4、然后重启Xcode，记得重启后在弹出的alert里面选择load bundle
 *
 */
