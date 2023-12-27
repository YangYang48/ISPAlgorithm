function lp = calLp(data, TH)
[kVSize, kHSize, c] = size(data);
lp = zeros(kVSize, kHSize);
% 提取kernel中心像素值
cPX = data(round(kHSize/2), round(kVSize/2), 1);
cPY = data(round(kHSize/2), round(kVSize/2), 2);
cPV = data(round(kHSize/2), round(kVSize/2), 3);

for i = 1: kHSize
    for j = 1: kVSize
        deltaX = abs(data(i, j, 1) - cPX);
        deltaY = abs(data(i, j, 2) - cPY);
        deltaV = abs(data(i, j, 3) - cPV);
        if (deltaX <= TH.ThL1) && (deltaY <= TH.ThL2) && (deltaV <= TH.ThL3) &&...
           (deltaX+deltaV) <= TH.ThL4 && (deltaY+deltaV) <= TH.ThL5 && (deltaX+deltaY) <= TH.ThL5 &&...
           (deltaX+deltaY+deltaV) <= TH.ThL7
            lp(i, j) = 1;
        else
            lp(i, j) = 0;
        end
    end
end
