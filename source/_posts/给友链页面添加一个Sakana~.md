---
title: 给友链页面添加一个Sakana~
description: 给博客友链页面添加一个Sakana~
categories:
  - 魔改教程
top_img: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/sakana.jpg'
cover: 'https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/sakana.jpg'
businesscard: true
comments: 'yes'
url: /archives/sakana
tags:
  - butterfly
abbrlink: e5482ed2
date: 2023-02-27 08:28:49
---
{% wow animate__flip %}
{% note orange 'fas fa-fan' modern%}
## 给hexo博客添加一个Sakana~
{% endnote %}
{% endwow %}
{% radio ### 来自开源项目[itorr/sakana](https://github.com/itorr/sakana/) %}
{% radio 同[脑阔疼ﻩ٥](https://naokuoteng.cn/)一同制作完成 %}
{% folding cyan open orange, 效果如下 %}
{% hideBlock 预览点我 ,orange %}
{% video https://cdn1.tianli0.top/gh/linjiangyu2/halo/video/sakana.mp4 %}
{% endhideBlock %}
{% sitegroup %}
{% site 你会发光吧, url=https://blog.linjiangyu.com/link/, screenshot=https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/saka.png, avatar=https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg, description=我的站点 %}
{% endsitegroup %}
{% endfolding %}
### 教程
{% radio 写入到root_blog\themes\butterfly\source\css\custom.css文件中并引用 %}
```css
html .sakana-box {
  position: fixed;
  right: 0;
  bottom: 0;
  transform-origin: 100% 100%; /* 从右下开始变换 */
}
.sakana-box {
    width: 500px;
    height: 80px;
    position: relative;
    pointer-events: none;
    z-index: 100;
}
@media screen and (max-width: 768px){
  .sakana-box {
  width: 500px;
  height: 80px;
  position: relative;
  pointer-events: none;
}
}
@media screen and (max-width: 768px){
  html .sakana-box {
    position: inherit;
    right: 0;
    bottom: 0;
    transform-origin: 36% 160%;
}
}
[data-theme="light"] .layout > div:first-child:not(.recent-posts) {
    background: rgba(255, 255, 255, .8);
    -webkit-backdrop-filter: none;
    backdrop-filter: none!important;
}
[data-theme="dark"] .layout > div:first-child:not(.recent-posts) {
    background: rgba(15, 15, 15, .75);
    -webkit-backdrop-filter: none;
    backdrop-filter: none!important;
}
html.hide-aside .layout > div:first-child {
    width: 90%;
}
```
{% radio 直接写入到root_blog\source\link\index.md文件中 %}
```css
<div class="sakana-box"></div>
<script src="https://cdn1.tianli0.top/gh/linjiangyu2/halo/js/sakana.js"></script>
<script>
Sakana.init({
  el:         '.sakana-box',     // 启动元素 node 或 选择器
  scale:      .5,                // 缩放倍数
  canSwitchCharacter: true,      // 允许换角色
});
</script>
```
{% radio 修改root_blog\themes\butterfly\_config.yml %}
```yaml
inject:
  head:
+    - <link rel="stylesheet" href="/css/custom.css">
......
pjax:
  enable: true
  exclude:
+    - /link/
    # - xxxx
    # - xxxx
```
就可以得到一个Sakana了~
{% radio ### 这里我还给[Heo的音乐播放器](https://github.com/zhheo/HeoMusic)加上了 %}
{% folding cyan open orange, 效果如下 %}
{% hideBlock 预览点我 ,orange %}
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/1677466852471.png)
{% endhideBlock %}
{% sitegroup %}
{% site 心灵庇护所, url=https://music.linjiangyu.com/, screenshot=https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/1677466852471.png, avatar=https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/fa.jpg, description=我的站点 %}
{% endsitegroup %}
{% endfolding %}
{% radio 修改index.html文件 %}
```html
  <link rel="apple-touch-icon-precomposed" sizes="180x180" href="./img/icon-r.webp">
  <meta name="description" content="念念不忘 必有回响">
+  <style>
+  html .sakana-box{
+    position: fixed;
+    right: 0;
+    bottom: 0;
+    transform-origin: 100% 100%; /* 从右下开始变换 */
+  }
+  </style>
......
<script src="./js/APlayer.min.js"></script>
<script src="./js/Meting2.min.js"></script>
<script async data-pjax src="./js/main.js"></script>
+  <div class="sakana-box"></div>
+  <script src="https://cdn.jsdelivr.net/gh/linjiangyu2/halo/js/sakana.js"></script>
+  <script>
+  // 取消静音
+  Sakana.setMute(false);
+  // 启动
+  Sakana.init({
+    el:         '.sakana-box',     // 启动元素 node 或 选择器
+    scale:      .5,                // 缩放倍数
+    canSwitchCharacter: true,      // 允许换角色
+  });
+  </script>
</body>
</html>
```
然后
```nginx
# git add index.html
# git commit -m 'none'
# git push
```
推到github就可以了
![](https://cdn1.tianli0.top/gh/linjiangyu2/halo/img/siMAqL1Zewz3QlJ.webp)
