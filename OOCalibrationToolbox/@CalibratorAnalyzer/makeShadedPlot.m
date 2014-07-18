function makeShadedPlot(obj, x,y, faceColor, edgeColor)
    px = [0, reshape(x, [1 length(x)]), x(end)]; % make closed patch
    py = [0, reshape(y, [1 length(y)]), 0];
    pz = -10*eps*ones(1,length(x)+2);
    patch(px,py,pz,'FaceColor',faceColor,'EdgeColor',edgeColor);
end
