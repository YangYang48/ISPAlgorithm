%% --------------------------------
%% author:Fred
%% date: 20220810
%% fuction: Debug on raw
%% note: Setting Public Parameters before running;
%%       Need a realtime raw and a BL raw(capture a black raw);
%%       Save a picture to current path named DM.png if DMEnalbe is 1;
%% --------------------------------
clc;clear;close all;

%% ------------Common Parameter----------
% -------raw path----------
rawPath = 'raw_long_3840x2160_16_GB_0810140359_[US=19999,AG=1091,DG=1024,R=2374,G=1024,B=2126].raw';
BLRawPath = 'BL.raw';

% -------raw format--------
bayerFormat = 'GBRG';
width = 3840;
height= 2160;
bits = 16;

% -------wb gain-----------
rGain = 2.318359375;
bGain = 2.076171875;

% -------enable flag-------
BLEnable = 1;
WBGainEnable = 1;
DMEnable = 1;

%% --------------------------------------
filePath = rawPath;
bayerData = readRaw(filePath, bits, width, height);

%% ------------BL -----------------------
if BLEnable
    BLData = readRaw(BLRawPath, bits, width, height);
    bayerData = (bayerData - BLData);
end

scalecoefficient = 2^(bits-8);
bayerData = bayerData / scalecoefficient;
figure();
imshow(uint8(bayerData));
title('raw image');

%% ------------AWB Gain------------------
if WBGainEnable
    switch bayerFormat
        case 'RGGB'
            bayerData(1:2:height, 1:2:width) = bayerData(1:2:height, 1:2:width).*rGain;
            bayerData(2:2:height, 2:2:width) = bayerData(2:2:height, 2:2:width).*bGain;
        case 'GRBG'
            bayerData(1:2:height, 2:2:width) = bayerData(1:2:height, 2:2:width).*rGain;
            bayerData(2:2:height, 1:2:width) = bayerData(2:2:height, 1:2:width).*bGain;
        case 'GBRG'
            bayerData(1:2:height, 2:2:width) = bayerData(1:2:height, 2:2:width).*bGain;
            bayerData(2:2:height, 1:2:width) = bayerData(2:2:height, 1:2:width).*rGain;
        case 'BGGR'
            bayerData(1:2:height, 1:2:width) = bayerData(1:2:height, 1:2:width).*bGain;
            bayerData(2:2:height, 2:2:width) = bayerData(2:2:height, 2:2:width).*rGain;
    end
end 

if DMEnable
    %% expand image inorder to make it easy to calculate edge pixels
    bayerPadding = zeros(height + 2,width+2);
    bayerPadding(2:height+1,2:width+1) = uint32(bayerData);
    bayerPadding(1,:) = bayerPadding(3,:);
    bayerPadding(height+2,:) = bayerPadding(height,:);
    bayerPadding(:,1) = bayerPadding(:,3);
    bayerPadding(:,width+2) = bayerPadding(:,width);

    %% main code of imterpolation
    imDst = zeros(height+2, width+2, 3);
    for ver = 2:height + 1
        for hor = 2:width + 1
            switch bayerFormat
                case 'RGGB'
                    % G B -> R
                    if(0 == mod(ver, 2) && 0 == mod(hor, 2))
                        imDst(ver, hor, 1) = bayerPadding(ver, hor);
                        % G -> R
                        imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                             bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                        % B -> R
                        imDst(ver, hor, 3) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                             bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                    % G R -> B
                    elseif (1 == mod(ver, 2) && 1 == mod(hor, 2))    
                        imDst(ver, hor, 3) = bayerPadding(ver, hor);
                        % G -> B
                        imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                             bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                        % R -> B
                        imDst(ver, hor, 1) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                             bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                    elseif(0 == mod(ver, 2) && 1 == mod(hor, 2))
                        imDst(ver, hor, 2) = bayerPadding(ver, hor);
                        % R -> Gr
                        imDst(ver, hor, 1) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                        % B -> Gr
                        imDst(ver, hor, 3) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                    elseif(1 == mod(ver, 2) && 0 == mod(hor, 2))
                        imDst(ver, hor, 2) = bayerPadding(ver, hor);
                        % B -> Gb
                        imDst(ver, hor, 3) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                        % R -> Gb
                        imDst(ver, hor, 1) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                    end
                case 'GRBG'
                    % G B -> R
                    if(0 == mod(ver, 2) && 1 == mod(hor, 2))
                        imDst(ver, hor, 1) = bayerPadding(ver, hor);
                        % G -> R
                        imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                             bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                        % B -> R
                        imDst(ver, hor, 3) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                             bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                    % G R -> B
                    elseif (1 == mod(ver, 2) && 0 == mod(hor, 2))    
                        imDst(ver, hor, 3) = bayerPadding(ver, hor);
                        % G -> B
                        imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                             bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                        % R -> B
                        imDst(ver, hor, 1) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                             bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                    elseif(1 == mod(ver, 2) && 1 == mod(hor, 2))
                        imDst(ver, hor, 2) = bayerPadding(ver, hor);
                        % R -> Gr
                        imDst(ver, hor, 3) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                        % B -> Gr
                        imDst(ver, hor, 1) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                    elseif(0 == mod(ver, 2) && 0 == mod(hor, 2))
                        imDst(ver, hor, 2) = bayerPadding(ver, hor);
                        % B -> Gb
                        imDst(ver, hor, 1) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                        % R -> Gb
                        imDst(ver, hor, 3) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                    end
                case 'GBRG'
                    % G B -> R
                    if(1 == mod(ver, 2) && 0 == mod(hor, 2))
                        imDst(ver, hor, 1) = bayerPadding(ver, hor);
                        % G -> R
                        imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                             bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                        % B -> R
                        imDst(ver, hor, 3) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                             bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                    % G R -> B
                    elseif (0 == mod(ver, 2) && 1 == mod(hor, 2))    
                        imDst(ver, hor, 3) = bayerPadding(ver, hor);
                        % G -> B
                        imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                             bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                        % R -> B
                        imDst(ver, hor, 1) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                             bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                    elseif(1 == mod(ver, 2) && 1 == mod(hor, 2))
                        imDst(ver, hor, 2) = bayerPadding(ver, hor);
                        % R -> Gr
                        imDst(ver, hor, 1) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                        % B -> Gr
                        imDst(ver, hor, 3) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                    elseif(0 == mod(ver, 2) && 0 == mod(hor, 2))
                        imDst(ver, hor, 2) = bayerPadding(ver, hor);
                        % B -> Gb
                        imDst(ver, hor, 3) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                        % R -> Gb
                        imDst(ver, hor, 1) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                    end
                case 'BGGR'
                    % G R -> B
                    if(0 == mod(ver, 2) && 0 == mod(hor, 2))
                        imDst(ver, hor, 3) = bayerPadding(ver, hor);
                        % G -> B
                        imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                             bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                        % R -> B
                        imDst(ver, hor, 1) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                             bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                    % G B -> R
                    elseif (1 == mod(ver, 2) && 1 == mod(hor, 2))    
                        imDst(ver, hor, 1) = bayerPadding(ver, hor);
                        % G -> B
                        imDst(ver, hor, 2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor) +...
                                             bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/4;
                        % R -> B
                        imDst(ver, hor, 3) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver-1, hor+1) + ...
                                             bayerPadding(ver+1, hor-1) + bayerPadding(ver+1, hor+1))/4; 
                    elseif(0 == mod(ver, 2) && 1 == mod(hor, 2))
                        imDst(ver, hor, 2) = bayerPadding(ver, hor);
                        % R -> Gr
                        imDst(ver, hor, 3) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                        % B -> Gr
                        imDst(ver, hor, 1) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                    elseif(1 == mod(ver, 2) && 0 == mod(hor, 2))
                        imDst(ver, hor, 2) = bayerPadding(ver, hor);
                        % B -> Gb
                        imDst(ver, hor, 1) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1))/2;
                        % R -> Gb
                        imDst(ver, hor, 3) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor))/2;
                    end
            end
        end
    end
    imDst = uint8(imDst(2:height+1,2:width+1,:));
    figure,imshow(imDst);title('demosaic image');
    imwrite(imDst,'DM.png')
end