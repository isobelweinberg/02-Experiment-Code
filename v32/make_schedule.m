function schedule = make_schedule(NumTrials, vars, option)
%also need to output vars!
%WHAT ABOUT SCALING TO RT?
%% DISPLAY
%Control Trials
%allocate 1s to control trials, zeros to everything else
schedule.controloption = zeros(1, NumTrials);
schedule.controloption(1:vars.NoControlTrials) = 1;
%Coherent Trials
%allocate coherences to coherent trials, 100 to everything else
vars.NoCoherentTrials = NumTrials - vars.NoControlTrials;
vars.NoTrialsPerCoherence = vars.NoCoherentTrials/numel(vars.CoherenceArray);
schedule.coherence = zeros(1, NumTrials); %preallocate
schedule.coherence(1:vars.NoControlTrials)= 100; %set arbitratily high coherence to help debugging
%Randomise coherence and control trials together
order_disp = randperm(NumTrials);
schedule.controloption = schedule.controloption(order_disp);
schedule.coherence = schedule.coherence(order_disp);
%% TMS
if option.TMS == 1
    %Non-TMS trials
    %allocate 1 to TMS trials, 0 to everything else
    vars.NoTMSTrials = NumTrials*(vars.TMS.Probability/100);
    if round(vars.NoTMSTrials) ~= vars.NoTMSTrials
        error('vars.NoTMSTrials is not a whole number!');
    end
    schedule.TMSoption = zeros(1, NumTrials);
    schedule.TMSoption(1:vars.NoTMSTrials) = 1;
    %TMS Trials - how many have a fixed timepoint?
    vars.NoFixedTrials = (vars.TMS.FixedTimepointProb/100)*vars.NoTMSTrials;
    if round(vars.NoFixedTrials) ~= vars.NoFixedTrials
        error('vars.NoTMSTrials is not a whole number!');
    end
    %TMS Trials - how many are from a range?
    vars.NoRangeTrials = vars.NoTMSTrials*(vars.TMS.RangeTimepointProb/100);
    if round(vars.NoRangeTrials) ~= vars.NoRangeTrials
        error('vars.NoRangeTrials is not a whole number!');
    end
    %Give Fixed timepoint trials a timepoint
    vars.NoTrialsPerTimepoint = vars.NoFixedTrials/numel(vars.TMS.Timepoints);
    if round(vars.NoTrialsPerTimepoint) ~= vars.NoTrialsPerTimepoint
        error('vars.NoTrialsPerTimepoint is not a whole number!');
    end
    schedule.TMStimepoint = zeros(1, NumTrials); %preallocate
    schedule.TMSrelation = zeros(1, NumTrials); %preallocate
    if numel(vars.TMS.TimepointRelations) ~= numel(vars.TMS.Timepoints)
        error('different numbers of timepoints and timepoint relations')
    end
    schedule.TMStimepoint(1:vars.NoFixedTrials) = repmat(vars.TMS.Timepoints, 1, vars.NoTrialsPerTimepoint);
    schedule.TMSrelation(1:vars.NoFixedTrials) = repmat(vars.TMS.TimepointRelations, 1, vars.NoTrialsPerTimepoint);
    %Give Range timepont trials a range
    schedule.TMStimepoint(vars.NoFixedTrials+1:vars.NoFixedTrials+vars.NoRangeTrials) = ...
        (rand(1, vars.NoRangeTrials)*(vars.TMS.TimepointRangeEnd-vars.TMS.TimepointRangeStart))+...
        vars.TMS.TimepointRangeStart; %allocate a random number in the range
    schedule.TMSrelation(vars.NoFixedTrials+1:vars.NoFixedTrials+vars.NoRangeTrials) = 2; %for now, range trials always relative to Stim
    %Give remainder a Nan for timepoint
    schedule.TMStimepoint(vars.NoFixedTrials+vars.NoRangeTrials+1:end) = NaN;
    schedule.TMSrelation(vars.NoFixedTrials+vars.NoRangeTrials+1:end) = NaN;
    %Randomise timepoint and TMS option together
    order_timepoint = randperm(NumTrials);
    schedule.TMSoption = schedule.TMSoption(order_timepoint);
    schedule.TMStimepoint = schedule.TMStimepoint(order_timepoint);
    schedule.TMSrelation = schedule.TMSrelation(order_timepoint);
else
    schedule.TMSoption = zeros(1, NumTrials); %all 0
    schedule.TMStimepoint = NaN(1, NumTrials); %all NaN
end
end