function setOutlets(obj, s)

    % set the values of the outlets
    outletNames = fieldnames(s);
    for k = 1:numel(outletNames)
        obj.(outletNames{k}) = s.(outletNames{k});
    end
end

