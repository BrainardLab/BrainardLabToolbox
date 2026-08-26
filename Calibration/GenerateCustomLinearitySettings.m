function LinearityMatrix = customizeLinearityMatrix(rgb_vec, rgb_fg, composite_val)
    % Initialize an empty matrix to store the customized color matrix.
    LinearityMatrix = [];
    
    % Loop through each element in rgb_vec to create rows for LinearityMatrix.
    for i = 1:length(rgb_vec)
        % Add a row of the same RGB values to create uniform color.
        LinearityMatrix = [LinearityMatrix; ones(1,3) .* rgb_vec(i); ...
            % Add rows with each RGB channel varying individually, with others set to 0.
            eye(3) .* rgb_vec(i)]; ...
    end

    assert(length(rgb_vec) >= 3, 'The input rgb vector has to have more than 3 elements!');

    for j = 1:length(composite_val)
        val_j = composite_val(j);
        % Get all unique pairs from the vector
        pairs = nchoosek(rgb_vec, 2);
        % Calculate the sum of each pair
        pairSums = sum(pairs, 2);   
        % Find pairs that match any of the target sums
        matches = ismember(pairSums, val_j);

        matches_val = pairs(matches,:);

        LinearityMatrix = [LinearityMatrix;...   % Mix rgb_vec value for each channel while keeping other channels fixed to rgb_fg.
            [val_j,          rgb_fg(2),      rgb_fg(3)];...
            [matches_val(1), rgb_fg(2),      rgb_fg(3)];...
            [matches_val(2), rgb_fg(2),      rgb_fg(3)];...
            [0,              rgb_fg(2),      rgb_fg(3)]; ...
            [rgb_fg(1),      val_j,          rgb_fg(3)];...
            [rgb_fg(1),      matches_val(1), rgb_fg(3)];...
            [rgb_fg(1),      matches_val(2), rgb_fg(3)];...
            [rgb_fg(1),      0,              rgb_fg(3)]; ...
            [rgb_fg(1),      rgb_fg(2),      val_j];...
            [rgb_fg(1),      rgb_fg(2),      matches_val(1)];...
            [rgb_fg(1),      rgb_fg(2),      matches_val(2)];...
            [rgb_fg(1),      rgb_fg(2),      0]]; ...  % Vary the R channel, keep G and B as rgb_fg.
    end

    % Append specific color values required for the linearity test.
    LinearityMatrix = [LinearityMatrix; zeros(1,3); ...              % Black (0, 0, 0)
        [0.5378, 0.5321, 0.5406]; ...                                % Custom color 1 (Nicolas' choice)
        [0.4674, 0.4249, 0.3573]; ...                                % Custom color 2 (Nicolas' choice)
        [0.4106, 0.4399, 0.5388]];                                   % Custom color 3 (Nicolas' choice)
    
    % Transpose the matrix to ensure each row represents an RGB value for the test.
    LinearityMatrix = LinearityMatrix';
end