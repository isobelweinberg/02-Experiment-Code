function schedule = make_schedule(vars, option)
j = 0;
for iCoherence = 1: numel(vars.CoherenceArray)
    for iTrial = 1: vars.TrialsPerCondition
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
%             schedule.TMSoption(j) = 0;
        end
    end
end

if option.TMS == 1
    k = 0;
    for iCoherence = 1: numel(vars.CoherenceArray)
        for iTrial = 1: ceil((100/vars.TMS.Probability-1)*vars.TrialsPerCondition*numel(vars.TMS.Timepoints))
            k = k + 1;
            schedule.coherence(j+k) = vars.CoherenceArray(1, iCoherence);
            schedule.TMSoption(j+k) = 0;
            schedule.TMStimepoint(j+k) = NaN;
        end
    end
end

order = randperm(numel(schedule.coherence));
schedule.coherence = schedule.coherence(order);
if option.TMS == 1
    schedule.TMSoption = schedule.TMSoption(order);
    schedule.TMStimepoint = schedule.TMStimepoint(order);
end
end