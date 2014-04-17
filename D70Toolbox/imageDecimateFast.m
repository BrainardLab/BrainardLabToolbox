function img1 = imageDecimateFast(img)
    img1 = 0.25*(img(2:end,1:end-1) + img(1:end-1, 2:end) + img(1:end-1,1:end-1) + img(2:end,2:end));
    img1 = img1(1:2:end,1:2:end);
end