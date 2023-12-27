%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20230422
%% fuction: 
%% --------------------------------
clc; close all; clear;

%% ------- global value -----------
TH = struct('ThL1', 0, 'ThL2', 0, 'ThL3', 0, 'ThL4', 0, 'ThL5', 0, 'ThL6', 0, 'ThL7', 0,...
            'ThH1', 0, 'ThH2', 0, 'ThH3', 0, 'ThH4', 0, 'ThH5', 0, 'ThH6', 0, 'ThH7', 0);
KSharp = 128;
kernelHSize = 3;
kernelVSize = 3;
GaussSigma = 0.5;

%% ------- Data preparation -------
imgRGB = imread('./images/kodim19.png');
[h, w, c] = size(imgRGB);
imgHSV = rgb2hsv(imgRGB);
padHSize = floor(kernelHSize / 2);
padVSize = floor(kernelVSize / 2);
imgHSVPad = padarray(imgHSV, [padHSize, padVSize], 'replicate');
dstHSV = zeros(h, w, c);
guassKernel = fspecial('gaussian',[kernelVSize kernelHSize], GaussSigma); 

Eedge = zeros(h, w);
%% ----------- main loop ----------
for y = 1+padHSize: w+padHSize
    for x = 1+padVSize: h+padVSize
        calWin = imgHSVPad(x-padVSize: x+padVSize, y-padHSize: y+padHSize, :);
        lp = calLp(calWin, TH);
        hp = calHp(calWin, TH);
        dstHSV(x-padHSize, y-padVSize, 1) = sum(sum(lp .* calWin(:, :, 1))) / sum(sum(lp));
        dstHSV(x-padHSize, y-padVSize, 2) = sum(sum(lp .* calWin(:, :, 2))) / sum(sum(lp));
        Eedge(x-padHSize, y-padVSize) = sum(sum(hp .* calWin(:, :, 2))) * KSharp/ sum(sum(hp));
    end
end















