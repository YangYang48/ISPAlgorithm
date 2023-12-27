# ISP算法——UVNR 

## 概念简介

UVNR也就是经过CSC只有在YUV域对UV两个色域进行降噪，在有些方案里也叫CNR（chroma noise reduction）。主要就是在YUV域针对彩燥进行特殊处理的一系列算法。

关于噪声产生的原因在前面关于降噪的文章和视频中已经做了描述和讲解，这里就不做更多的解释，关于彩噪产生的原因，可以通过一个简单的方式来理解，就是如果一个灰色的画面，原本R，G，B三个通道的值应该是一样的（理论白平衡之后），但是由于前面提到过的噪声因素会导致三个通道的pixel value发生变化，且三个通道变化是随机的，那么三个通道各自偏差就不确定，那么经过插值处理后原本应该一样的三个通道就会出现偏差，也就出现了各种颜色，也就导致的彩燥的出现，然后经过pipeline各个阶段的gain的加持就会更显著。

也可以参考这篇论文的解释（看的时候随手截图的，忘记论文名了）：

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101038827.bmp)

## 算法讲解

降噪算是图像处理一个很大的方向，所以这一块的算法很多，没法一一介绍，针对彩噪其实也就是将基本的降噪或者灰度图像降噪的方法进行调整后适配这个应用。这里就直接通过几个专利介绍几个相关算法。

### CHROMA NOISE REDUCTION FOR CAMERAS

#### 专利信息

该专利可以参考如下图片信息，这是苹果公司2009的一份专利。

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101050719.jpg)

#### 专利算法

![Snipaste_2023-11-10_11-10-24](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101110374.jpg)

算法主要思路如上图，就是再YUV域对Cr和Cb通道分别进行处理。比如针对Cb，在一个滤波窗口中，中心点的像素值就通过周围点的值的加权平均值来计算得到。权重的计算也很简单，就是判断该点和窗口中心的Cr,Cb插值的和是否大于阈值，如果大于阈值就认为是边缘，那么就不参与平均，权重设置为0，如果小于阈值就参与计算，权重就设置为1。

### IMAGE CHROMA NOISE REDUCTION

#### 专利信息

该专利是ST公司2012年的一份专利

![Snipaste_2023-11-10_11-35-38](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101137738.jpg)

#### 专利算法

首先计算出窗口中各个通道的分布范围：

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101140562.png)

根据分布范围求出一个滤波强度系数：

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101141463.png)

针对Cr和Cb进行加权平均降噪：

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101142376.png)

权重计算方式是通过亮度知道色度，然后通过高斯分布的方式计算，差别越大越不相似，权重就越小。

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101408381.png)

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101145162.png)

最后通过将原始图像和去噪后的图像进行blending得到最终的图像，系数由局部动态范围决定。

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101148336.png)

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101149310.png)

### REMOVING CHROMA NOISE FROM DIGITAL IMAGES BY USIING VARIABLE SHAPE PIXEL NEIGHBORHOOD REGIONS

#### 专利信息

该专利是柯达公司1999年的一份专利

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101153157.jpg)

#### 专利算法

直接参考当时的笔记吧。具体的讲解可以参考B站的视频讲解。

![image-20231110115434290](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202311101154432.png)

## 相关链接

- zhihu： [ISP图像处理 - 知乎 (zhihu.com)](https://www.zhihu.com/column/c_1389227246742335488)
- CSDN：[ISP图像处理_wtzhu_13的博客-CSDN博客](https://blog.csdn.net/wtzhu_13/category_11144092.html?spm=1001.2014.3001.5482)
- Bilibili：[食鱼者的个人空间_哔哩哔哩_Bilibili](https://space.bilibili.com/439454715/video)
- Gitee：[ISPAlgorithmStudy: ISP算法学习汇总，主要是论文总结 (gitee.com)](https://gitee.com/wtzhu13/ISPAlgorithmStudy)