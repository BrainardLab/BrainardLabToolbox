function response = observe(ob, stimulus)
% response = observe(observer, stimulus)
%
% Description: Previously instantiated observer object observes a stimulus
% and gives a response. This can be extended to other experiments,
% currently only implemented for AChromForcedChoice. Also, the obsever
% currently looks at the stimulus and makes a decision in this function;
% later it might be better to have them separate from each other?
%
% Currently implemented observers:
%
% Toddler - Always chooses a negative response.
% Lackey - Always chooses a positive response.
% Washington - Randomly chooses between two binary values (coinflip, geddit?).
% WineTaster - Always chooses the 'correct' answer, based on some prefed
%                   descriminant during construction. There might be noise.
%
% 10/29/09 bjh      Created it.

[exptype, obtype]= getTypes(ob);
obtype = lower(obtype);
exptype = lower(exptype);

switch exptype
	case 'achrom'
		switch obtype
			case 'toddler'
				response = 0;
			case 'lackey'
				response = 1;
			case 'washington'
				response = round(rand);
			case 'winetaster'
				ndiscrim = ob.discrim + ((-1)^round(rand))*rand*ob.noise;
				if stimulus > ndiscrim
					response = 1;
				else
					response = 0;
				end
		end
end

end