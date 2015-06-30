function [FixationXY, DotsXY, data, vars] = generate_stimuli(NumTrials, vars, params, option, data)

%% Seed the random number generator
%     rng('shuffle'); %modern
rand('seed', sum(100 * clock)); %legacy

%% Allocate initial dot coordinates
FixationXY = [0; 0];  % fixation spot is in middle of screen
%pay attention - this is complicated! this is a vector of the dot coordinates with 4
%dimensions:
%     Dimension 1 (ROWS): x or y (i.e. top row is x and bottom row is y)
%     Dimension 2 (COLUMNS): dots (i.e. 1 column per dot)
%     Dimension 3 (Z): frames (i.e. 1 table per frame)
%     Dimension 4: trials (i.e. 1 thing impossible to imagine per trial)
DotsXY = zeros(2, params.NumDots, params.TotalNumFrames, NumTrials); %preallocate
data.labels(1,4:9) = {'Coherence', 'Direction', 'TMS Timepoint', 'TMS Relation', 'Number of Coherent Dots', 'TMS Index'};
data.labels(1, 24:25) = {'Timepoint before RT scaling', 'Mean RT for the condition'};
%allocate non-coherent positions to all dots
Radii = sqrt(rand(1, params.NumDots, params.TotalNumFrames, NumTrials))*params.ApertureRadius; %generate some random distances from the centre of the aperture
%sqrt is needed to stop dots clustering in middle
Angles = rand(1, params.NumDots, params.TotalNumFrames, NumTrials)*360; %generate some random angles
DotsXY(1, :, :, :) = Radii.*cosd(Angles);% fill with random X coordinates
DotsXY(2, :, :, :) = Radii.*sind(Angles); % fill random Ys

%% Randomise trial order
vars.schedule = make_schedule(vars, option);
%% Replace a subset with coherent coordinates
data.labels(1,21) = {'Actual Coherence'};
for TrialNo = 1:NumTrials
    data.main(TrialNo, 1) = TrialNo; %record the Trial number
    %set coherence for the trial
    data.main(TrialNo, 4) = vars.schedule.coherence(TrialNo); %pick a coherence at random from the Coherence Array for this trial
    data.main(TrialNo, 8) = round((data.main(TrialNo, 4)/100)*params.NumDots); %find out how many dots need to be coherent
    data.main(TrialNo, 21) = ((data.main(TrialNo, 8)/params.NumDots)*100); %record the actual coherence used (i.e. taking into account that num coherent dots was rounded) and give as %
    %set direction for the trial
    if randi(100) <= data.main(TrialNo, 3)
        data.main(TrialNo, 5) = -1; %left
    else
        data.main(TrialNo, 5) = 1; %right
    end
    %set TMS index for the trial
    if option.TMS == 1 && vars.schedule.TMSoption(TrialNo) == 1
        for iTimepoint = 1:numel(vars.TMS.Timepoints)
            if vars.schedule.TMStimepoint(TrialNo)==vars.TMS.Timepoints(iTimepoint)
                data.main(TrialNo, 9) = iTimepoint; %create a TMS index
            end             
        end
    else
        data.main(TrialNo, 9) = NaN;
    end
    
    %set TMS timepoint for the trial
    if option.TMS == 1
        data.main(TrialNo, 6) = vars.schedule.TMStimepoint(TrialNo); %timepoint
        if vars.schedule.TMSoption(TrialNo) == 1 && strcmp(vars.TMS.TimepointRelations(1, (data.main(TrialNo, 9))), 'Fixation') == 1
            data.main(TrialNo, 7) = 1; %1 in the timepoint relation col means relative to Fixation
        elseif vars.schedule.TMSoption(TrialNo) == 1 && strcmp(vars.TMS.TimepointRelations(1, (data.main(TrialNo, 9))), 'Stim') == 1
            data.main(TrialNo, 7) = 2; %2 in the timepoint relation col means relative to Stim
        elseif vars.schedule.TMSoption(TrialNo) == 1 && strcmp(vars.TMS.TimepointRelations(1, (data.main(TrialNo, 9))), 'ITI') == 1
            data.main(TrialNo, 7) = 3; %3 in the timepoint relation col means relative to ITI
        else
            data.main(TrialNo, 7) = NaN;
        end
        
        %make the timepoint relative to meanRT
        if option.scaletoRT == 1
            for iCoherence = 1:numel(vars.CoherenceArray); %for each coherence
                for iProbability = 1:numel(unique(vars.LeftProbabilityArray))
                    if (data.main(TrialNo, 4) == vars.CoherenceArray(1, iCoherence)) && (data.main(TrialNo, 3) == vars.LeftProbabilityArray(1,iProbability));
                        %if coherence value(4) equals that coherence and left
                        %probability value(3) equals that probability
                        if data.main(TrialNo, 7) == 2 %if it is a timepoint relativative to Stimulus
                            data.main(TrialNo, 24) = data.main(TrialNo, 6); %record original timepoint
                            data.main(TrialNo, 25) = vars.meanRTgrid(iCoherence, iProbability); %record mean RT value used here
                            data.main(TrialNo, 6) = data.main(TrialNo, 6)*vars.meanRTgrid(iCoherence, iProbability);
                            %multiply timepoint(6) by relevant mean RT to
                            %get new timepoint, which overwrites
                        end
                    end
                end
            end
        end
    end
    
    for DotNumber = 1:data.main(TrialNo, 8) % allocate coherent positions to a subset
        DotsXY(2, DotNumber, 2:params.TotalNumFrames, TrialNo) = DotsXY(2, DotNumber, 1, TrialNo);%coherent dots - their Y coord stays the same throughout
        for FrameNo = 2:params.TotalNumFrames %X coord incremements by a fixed amount (speed x time)
            DotsXY(1, DotNumber, FrameNo, TrialNo) = DotsXY(1, DotNumber, FrameNo-1, TrialNo) + (data.main(TrialNo,5)*params.DotSpeed*params.IFI);
            %is the dot outside the circle?
            y = DotsXY(2, DotNumber, FrameNo, TrialNo);
            Width = sqrt(((params.ApertureRadius)^2)-((y)^2));
            if abs(DotsXY(1, DotNumber, FrameNo, TrialNo)) + params.DotRadius > Width %if outside circle
                if data.main(TrialNo, 5) == -1 %if going Left, make the Width negative - need this to make the mod calc work
                    Width = -1*Width;
                end
                XRemainder = mod((DotsXY(1, DotNumber, FrameNo, TrialNo)), Width);
                DotsXY(1, DotNumber, FrameNo, TrialNo) = XRemainder - Width;
            end
        end
    end
end
