function hp = calHp(data, TH)
[kVSize, kHSize, c] = size(data);
hp = zeros(kVSize, kHSize);
% 提取kernel中心像素值
cPX = data(round(kHSize/2), round(kVSize/2), 1);
cPY = data(round(kHSize/2), round(kVSize/2), 2);
cPV = data(round(kHSize/2), round(kVSize/2), 3);

for i = 1: kHSize
    for j = 1: kVSize
        deltaX = abs(data(i, j, 1) - cPX);
        deltaY = abs(data(i, j, 2) - cPY);
        deltaV = abs(data(i, j, 3) - cPV);
        if (deltaX > TH.ThH1) || (deltaY > TH.ThH2) || (deltaV > TH.ThH3) ||...
           (deltaX+deltaV) > TH.ThH4 || (deltaY+deltaV) > TH.ThH5 || (deltaX+deltaY) > TH.ThH6 ||...
           (deltaX+deltaY+deltaV) > TH.ThH6
            hp(i, j) = 1;
        else
            hp(i, j) = 0;
        end
    end
end