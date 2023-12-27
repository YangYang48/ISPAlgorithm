%% --------------------------------
%% author:Fred
%% date: 20220903
%% fuction: 
%% note:
%% --------------------------------

clc;close all;clear;
addpath('../publicFunction/')
width = 3840;
height = 2160;

% read raw
rawFile = 'images/SSC_raw_long_3840x2160_16_GB_0815103405_[US=16666,AG=1193,DG=1024,R=2231,G=1024,B=2465].raw';
raw = readRaw(rawFile, 16, width, height);
figure();
imshow(uint8(raw/256));
title('raw');

% read YUV
YUVFileName = 'images/SSC_ispout_long_3840x2160_16_GB_0815103416_[US=16666,AG=1193,DG=1024,R=2231,G=1024,B=2465].yuv';
fin = fopen(YUVFileName, 'r');
YUV = fread(fin, width*height*2, 'uint8=>uint8');
Y = YUV(1:2:end);
U = YUV(2:4:end);
V = YUV(4:4:end);
z = reshape(Y, width, height);
z = z';
rawData = z;
figure();
imshow(z);
title('Y of YUV');

