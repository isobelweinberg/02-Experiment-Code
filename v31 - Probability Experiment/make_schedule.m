function schedule = make_schedule(vars, option)
j = 0;
for iCoherence = 1: numel(vars.CoherenceArray) %schedule coherence, option, and timepoint on trigger trials/if TMS option is off
    for iTrial = 1: vars.ConditionRepeatsPerBlock
        if option.TMS == 1
            for iTimepoint = 1: numel(vars.TMS.Timepoints)
                j = j + 1;
                schedule.coherence(j) = vars.CoherenceArray(1, iCoherence);
                schedule.TMSoption(j) = 1;
                schedule.TMStimepoint(j) = vars.TMS.Timepoints(1, iTimepoint);
            end
        else
            j = j + 1;
            schedule.coherence(j) = vars.CoherenceArray(1, iCoherence);
            schedule.TMSoption(j) = 0;
        end
    end
end

if option.TMS == 1 %schedule cohernce and option on non-trigger trials
    k = 0;
    for iCoherence = 1: numel(vars.CoherenceArray)
        for iTrial = 1: ceil((100/vars.TMS.Probability-1)*vars.ConditionRepeatsPerBlock*numel(vars.TMS.Timepoints))
            k = k + 1;
            schedule.coherence(j+k) = vars.CoherenceArray(1, iCoherence);
            schedule.TMSoption(j+k) = 0;
            schedule.TMStimepoint(j+k) = NaN;
        end
    end
end

%control trials
schedule.controloption(1:(numel(schedule.coherence))) = 0; %give all trials that exist so far a 0 for control option
trialssofar = numel(schedule.coherence); trialsend = trialssofar + vars.NoControlTrials;
schedule.controloption(trialssofar+1:trialsend) = 1; %new trials that will become controls
schedule.coherence(trialssofar+1:trialsend) = 100; %add control trials to coherence - set arbitratily high coherence to help debugging
schedule.TMSoption(trialssofar+1:trialsend) = 0; %fill up with 0s
if option.TMS == 1    
    schedule.TMStimepoint(trialssofar:trialsend) = NaN;
    NumTMSControl = round(vars.TMS.Probability/100*vars.NoControlTrials); %how many control trials should have TMS?
    schedule.TMSoption(trialssofar+1:trialssofar+NumTMSControl)=1; %overwrite the correct proportion to be 1s
    % NumControlPerTimepoint = round(NumTMSControl/numel(varsTMSTimepoints));
   x = numel(vars.TMS.Timepoints);
    p = 0;
   for m = 1:NumTMSControl %allocate timepoints
       p = p + 1;
       if p > x
           p = 1;
       end
      schedule.TMStimepoint(trialssofar+m) = vars.TMS.Timepoints(1, p);  
   end    
end

%randomise order
order = randperm(numel(schedule.coherence)); %reorder trials
schedule.coherence = schedule.coherence(order);
schedule.controloption = schedule.controloption(order);
if option.TMS == 1
    schedule.TMSoption = schedule.TMSoption(order);
    schedule.TMStimepoint = schedule.TMStimepoint(order);
end
% 
% 
% schedule.controloption(1:vars.NoControlTrials) = 1; %overwrite the 0 to 1 for a set number of trials [LEFT]
% % schedule.controloption(1:(round(vars.NoControlTrials/2))) = 1; %overwrite to 2 for half these trials (round in case of uneven number) [RIGHT]
% schedule.controloption = schedule.controloption(randperm(numel(schedule.controloption))); %randomise order

end