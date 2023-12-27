clc, clear, close all;

testPath = 'G:\Fred\ISP\matlab\images\DPTest';
subdir  = dir(testPath);
DPTh = 50;

for ii = 1 : length( subdir )
    if( isequal( subdir( ii ).name, '.' )||isequal( subdir( ii ).name, '..'))          
        continue;
    end
    
    fullFilePath = fullfile(testPath, subdir( ii ).name);
    disp(fullFilePath)
    
    img = imread(fullFilePath);
    [h, w, c] = size(img);
    imgGray = rgb2gray(img);
    [x, y] = find(imgGray>DPTh);
    numOFDP = length(x);

    for i=1:numOFDP
        if x(i) < 100
            if x(i) < 100 && y(i) < 100
                subImg = img(1: 100, 1: 100, :);
            elseif x(i) < 100 && y(i) > w-100
                subImg = img(1: 100, w-100: w, :);
            else
                subImg = img(1: 100, y(i)-50: y(i)+50, :);
            end
        elseif x(i) > h-100
            if x(i) > h-100 && y(i) > w-100
                subImg = img(h-100: h, w-100: w, :);
            elseif x(i) > h-100 && y(i) < 100
                subImg = img(h-100: h, 1: 100, :);
            else
                subImg = img(h-100: h, y(i)-50: y(i)+50, :);
            end
        else
            if y(i) < 100
                subImg = img(x(i)-50: x(i)+50, 1:100, :);
            elseif y(i) > w-100
                subImg = img(x(i)-50: x(i)+50, w-100:w, :);
            else
                subImg = img(x(i)-50: x(i)+50, y(i)-50: y(i)+50, :);
            end
        end

        t = sprintf('%s-sub%d img',subdir( ii ).name, i);
        hfig = figure();					% 创建图形窗口
        set(hfig, 'outerposition', get(0, 'ScreenSize'));	    % 设置图形窗口位置和外尺寸为屏幕大小
        imshow(subImg);
        title(t);
    end
end
