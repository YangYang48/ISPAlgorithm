# ISP-EE(Edge Enhance)

EE模块在某些ISP主控中叫做sharpness或者sharpen，这些名称指代的模块是同一个，不用再纠结。主要就是在YUV域内弥补成像过程中图像的锐度损失，对边缘和细节进行加强，从而恢复场景本应具有的自然锐度。

## 锐度下降的原因

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202312111017038.jpg)

如上图所示，理想的边缘如左侧所示，是个高反差，对比强的边。而实际成像的效果是右侧的状况，反差变弱，且边缘过渡缓慢，给人的视觉冲击不够，也就看上去没有左侧清晰锐利。造成边缘这种衰减的主要原因一方面是镜头的物理性质的限制，具体的原因不做深入讨论，属于光学范畴，简单理解就是镜头本身就是低通属性，所以图像成像光信号经过镜头后相当于进行了一次低通滤波，会导致边缘衰减。另一方面就是Pipeline中例如去买赛克，NR等算法都是低通特性的，都会导致高频损失从而表现出锐度下降。

## 锐化的原理

由于图像中的细节和边缘在频域中主要体现为尖锐程度较高的高频段上，因此锐化基本思想就是增强图像分离后产生的高频分量在像素值中的比重。

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202312111027171.jpg)

上图摘自知乎博文《[Understanding ISP Pipeline - Sharpen - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/98979968)》。

我们在实际算法中的的做法就是将边缘反差过渡区域调整得更陡峭更突变，从而到达高反差，高对比实现锐利度的提升。如上图右下角图，白色为未处理的变化曲线，红色为处理后的效果，处理后过渡明显更快，反差更大，左上经过处理到右上后人眼视觉感觉也确实对比更强，更清晰。

算法又需要如何实际实现呢，其实这个和我们学习美术的时候一样，我们会描边，用2B把边缘描绘一遍，那么边缘在政府图像中就会更清楚，其实算法也是这种思路，就是通过边缘算法提取图像边缘，然后将边缘“描绘”到原始图像上，那么边缘也就更加请处理。

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202312111042390.jpg)

上述的描边过程其实可以简化为以下的流程：

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202312111043653.png)

从上图中可以看出叠加后的图像确实清晰度有提升，但是感觉效果并不太好，主要因为鸟的主体部分加强了，但是后面的背景本来平坦的区域经过加强后也出现了很多颗粒感，看上去很难受。所以针对这些问题我们需要优化算法，其实从这个框架看，我们唯一能做的其实就是一个优化边缘提取的filter，另外一个就是优化λ，所以实际用的时候往往采取一下框图：

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202312111047555.png)

经过filter提取的边缘经过一个边缘判决器，然后λ根据这个判决器的判决动态调整加强力度。关于这个判决器和λ的自适应调整内容有点绕，不做过多赘述，有兴趣的朋友可以参考[B站本算法讲解](https://www.bilibili.com/video/BV1EN4y1a7xn/?spm_id_from=333.999.0.0)。

## 代码演示

```matlab
clc, clear, close all;

preDelta = 2;   % 预滤波强度，值越大，边缘越强
th = 5;         % 边缘检测阈值
gain = 0.8;       % 边缘增强力度控制

img = imread('./images/blurring.png');
figure();
imshow(img);
title('org');

[h, w, c] = size(img);
img_yuv = rgb2ycbcr(img);
y = img_yuv(:, :, 1);

Iblur = imgaussfilt(y, preDelta);
HighFC = y - Iblur;


for i = 1: h
    for j = 1: w
        if HighFC(i, j) > th
            HighFC(i, j) = HighFC(i, j) * gain;
        else
            HighFC(i, j) = 0;
        end
    end
end
figure();
imshow(HighFC);
imwrite(HighFC, './images/edgeDemo.png');
title('edge');

y = y + HighFC;
img_yuv(:, :, 1) = y;
res = ycbcr2rgb(img_yuv);
imwrite(res, './images/ee.png');
figure();
imshow(res);
title('res');
```

![](https://gitee.com/wtzhu13/figure-bed/raw/master/images/202312111054360.jpg)

