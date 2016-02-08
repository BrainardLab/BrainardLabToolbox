function showMessageValueAsStarString(obj, direction, msgLabel, msgValue, maxValue, maxStars)
    starsNum = msgValue / maxValue * maxStars;
    msg = '';
    for k = 1:starsNum
        msg(k) = '*';
    end
    fprintf('\n %10s %-20s: %40s', direction, msgLabel, msg);
end

