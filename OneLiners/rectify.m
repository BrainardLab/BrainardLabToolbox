function retval = rectify(signal, mode)
% retval = rectify(signal, mode)
%
% Rectify a given signal. Two modes (as specified in 'mode') are supported:
%
% - 'half' - Half-wave rectification, which turns the negative half
%                into zeros.
% - 'full' - Full-wave rectification, which turns the sign-inverts the
%                negative half.
%
% Note that the implementation proposed here may not be the most
% efficient one, but it works.
%
% 4/27/14   ms      Wrote it.

retval = signal;
switch mode
    case 'half'
        retval = max(retval, 0);
    case 'full'
        retval = abs(retval);
end