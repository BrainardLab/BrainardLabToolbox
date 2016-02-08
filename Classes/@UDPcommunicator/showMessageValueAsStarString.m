function showMessageValueAsStarString(obj, direction, msgLabel, msgValue, maxValue, maxStars)
    starsNum = msgValue / maxValue * maxStars;
    msg = '';
    while k < starsNum
        msg(k) = '*';
    end
    fprintf('\n %10s %10s: %40s', direction, msgLabel, msg);
end

