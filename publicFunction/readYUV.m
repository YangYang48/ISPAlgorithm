%% --------------------------------
%% author:wtzhu
%% date: 20221222
%% fuction: 
%% note: 
%% --------------------------------

clear;
close all;
clc;

%% --------------FORMAT------------
width = 4208;
height = 3120;
YUVFormat = 'YUYV';
fileName = 'G:\Fred\ISP\matlab\images\normal_4208_3120.yuv';
%% --------------------------------

%% --------------------------------
fin = fopen(fileName, 'r');
switch YUVFormat
    case 'YUYV'
        % YUYV: Y-U-Y-V 422 宽度上做降采样，高度采样维持不变
        I = fread(fin, width*height*2, 'uint8=>uint8');
        Y = I(1:2:end);
        U = I(2:4:end);
        V = I(4:4:end);
        Y = reshape(Y, width, height);
        U = reshape(U, width/2, height);
        V = reshape(V, width/2, height);
        Y = Y'; 
        U = U';
        V = V';
    case 'NV12'
        disp('...')
    case 'NV21'
        disp('...')
end
figure();imshow(Y);title('Y');
figure();imshow(U);title('U')
figure();imshow(V);title('V');

%% ------------YCbCr2RGB------------
IYCbCr = zeros([height, width, 3]);
Cb = imresize(U, [height, width], 'nearest');
Cr = imresize(V, [height, width], 'nearest');
IYCbCr(:, :, 1) = Y;
IYCbCr(:, :, 2) = Cb;
IYCbCr(:, :, 3) = Cr;

IRGB = ycbcr2rgb(uint8(IYCbCr)); %将YCbCr转换为rgb
figure();
imshow(IRGB);
title('RGB');