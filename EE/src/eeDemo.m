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

