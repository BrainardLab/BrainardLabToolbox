function makeShadedPlot(obj, x,y, faceColor, edgeColor, ax)
    px = reshape(x, [1 numel(x)]);
    py = reshape(y, [1 numel(y)]);
    px = [px(1) px px(end)];
    py = [1*eps py 2*eps];
    pz = -10*eps*ones(size(py)); 
    patch(ax, px,py,pz,'FaceColor',faceColor,'EdgeColor',edgeColor, 'FaceAlpha', 0.5);
end
