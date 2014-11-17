function obj = updateForTrial(obj, trialValue, response)
% obj = updateForTrial(obj, trialValue, response)
%
% Description: Updates the staircase object with info from a trial.
% 
% For standard staircase, should use recommended value or quite
% what happens isnt' clear.
%
% Required Inputs:
%   obj -         The staircase object to be updated.
%   trialValue -  The value actually utilized for the current trial.
%   response -    The response from the current trial.
%
% 10/19/09  dhb  Take input in linear rather than log terms.  Store values.
% 10/21/09  dhb  Update for staircase
% 10/22/09  dhb  Rewrite staircase logic to make more sense.
% 1/13/09   dhb  Dropped back a version and added comment that used and
%                recommended values should match for standard staircase.
% 02/08/11  dhb  Track stepsizes for staircase version.

% Keep track of trials run in staircase, and responses
obj.Values(obj.NextTrial) = trialValue;
obj.Responses(obj.NextTrial) = response;

switch obj.StaircaseType
    case 'standard'
        % Set reversals to 0.  Will be changed if a reversal happens
        obj.Reversals(obj.NextTrial) = 0;
        
        % Response was correct/bigger
        if (response == 1)
            if (obj.UpDownCounter == 0 | obj.CountType == 1)
                obj.CountType = 1;
                obj.UpDownCounter = obj.UpDownCounter + 1;
            elseif (obj.CountType == 0)
                obj.CountType = 1;
                obj.UpDownCounter = 1;
            end
            
            % Reached criterion number of 1 responses, step down
            if (obj.UpDownCounter == obj.NUp)
                % Was it a reversal?  If so, indicate and bump step size
                if (~isnan(obj.LastChange) & obj.LastChange == 1)
                    obj.Reversals(obj.NextTrial) = 1;
                    if (obj.Stepindex < obj.NStepSizes)
                        obj.Stepindex = obj.Stepindex + 1;
                    end
                end
                
                % Update value
                obj.NextValue = obj.Values(obj.NextTrial) - obj.StepSizes(obj.Stepindex);
                obj.UpDownCounter = 0;
                obj.LastChange = 0;
            end
            
        % Response was incorrect/smaller
        else
            if (obj.UpDownCounter == 0 | obj.CountType == 0)
                obj.CountType = 0;
                obj.UpDownCounter = obj.UpDownCounter + 1;
            elseif (obj.CountType == 1)
                obj.CountType = 0;
                obj.UpDownCounter = 1;
            end
            
            % Reached criterion number of 1 responses, step up
            if (obj.UpDownCounter == obj.NDown)
                % Was it a reversal?  If so, indicate and bump step size
                if (~isnan(obj.LastChange) & obj.LastChange == 0)
                    obj.Reversals(obj.NextTrial) = 1;
                    if (obj.Stepindex < obj.NStepSizes)
                        obj.Stepindex = obj.Stepindex + 1;
                    end
                end
                
                % Update value
                obj.NextValue = obj.Values(obj.NextTrial) + obj.StepSizes(obj.Stepindex);
                obj.UpDownCounter = 0;
                obj.LastChange = 1;
            end
        end
        
        % Store step sizes.  Also convenient to store whether we are at smallest step size for threshold
        % estimation later
        %obj.TrialStepIndices(obj.NextTrial) = obj.Stepindex;
        if (obj.Stepindex == obj.NStepSizes)
            obj.AtSmallestStep(obj.NextTrial) = 1;
        else
            obj.AtSmallestStep(obj.NextTrial) = 0;
        end
        
    case 'quest'
        % Let quest know what happened
        obj.QuestObj = QuestUpdate(obj.QuestObj, log10(trialValue), response);
        
end

% Bump trial counter
obj.NextTrial = obj.NextTrial+1;