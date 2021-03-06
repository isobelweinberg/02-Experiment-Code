try
    clearvars -except participant
    %% === Experiment Type ====
    option.TMS = 0;
    option.explicitprior = 1;
    option.scaletoRT = 0;
    option.mainexp = 0;
    option.setupport = 0;
    option.buttonbox = 0;
    %% Load Parameters & Setup Screen
    [params] = load_parameters(option); %Get the stimulus parameters & timings from the function which stores them
    [screen] = screen_setup(params); %Initialise the screen
    [params] = calc_frames(params, screen); %Calculate the number of frames needed
    %% File Name
    formatDate = 'ddmmyy';
    date = datestr(now,formatDate);
    time = datestr(now, 'HHMMSS');
    %% ==== Inputs =====
    % Independent variables
    vars.LeftProbabilityArray = [10, 25, 50]; %probability the RDK goes left, as a percentage
    vars.CoherenceArray = participant.Thresholds;
    vars.TrialsPerCondition = 75;
    TrialsPerBlock = 75;
    TotalNumBlocks = 3;
    vars.NoControlTrials = 0;
    vars.ConditionRepeatsPerBlock = (TrialsPerBlock-vars.NoControlTrials)/(numel(vars.CoherenceArray));
    %% Adjust probability array to block number
    vars.repeat = TotalNumBlocks/numel(vars.LeftProbabilityArray);
    vars.LeftProbabilityArray = repmat(vars.LeftProbabilityArray, 1, vars.repeat);
    %% Start Button box
    if option.buttonbox == 1
        params.b_box = start_buttonbox;
    end
    %% Information Screen
    DrawFormattedText(screen.windowNo, 'Please decide which way the dots are moving and press a Left or Right arrow key in response. \n Press any key to continue.', 'center', 'center', [0 0 0]);
    Screen('Flip', screen.windowNo);
    waitforpress(option, params)
    %% Trials
    alldata.main = []; %create matrix to store RTs in
    RTs = cell(numel(vars.CoherenceArray), numel(unique(vars.LeftProbabilityArray)));
    for BlockNo = 1:TotalNumBlocks
        data.main = zeros(TrialsPerBlock, 22); %make a blank matrix (update this if increase no. of columns)
        data.labels(1, 1:3) = {'Trial Number', 'Block Number', 'Leftward Probability'};
        data.main(:, 2) = BlockNo;
        data.main(:, 3) = vars.LeftProbabilityArray(1, BlockNo); % Set Probability the dots will go left - determined by block
        [FixationXY, DotsXY, data, vars] = generate_stimuli(TrialsPerBlock, vars, params, option, data); % Generate stimuli
        data = draw_stimuli(FixationXY, DotsXY, TrialsPerBlock, TrialsPerBlock, params, screen, option, data, participant); % Draw the stimuli
        filename = strcat('data/',date,'_',time,'_',participant.Initials,'_meanRT_Block',num2str(BlockNo));
        save (filename);
        if data.main(find(data.main(:,17),1,'last'), 17) == 3 %if the last trial with a response (non-zero) was a 3 (esc was pressed)
            break %end the experiment
        end
        alldata.main = [alldata.main; data.main];
    end
    DrawFormattedText(screen.windowNo, 'End of this section. Press any key to continue.', 'center', 'center', [0 0 0]);
    Screen('Flip', screen.windowNo);
    waitforpress(option, params)
    %%=Find mean RTs for different situations
%     participant.overallmeanRT = nanmean(RTs);
    
for iCoherence = 1:numel(vars.CoherenceArray)
    for iProbability = 1:numel(unique(vars.LeftProbabilityArray))
        RTs{iCoherence, iProbability} = alldata.main(find(alldata.main(:,4)==vars.CoherenceArray(1,iCoherence)...
            & alldata.main(:,3)==vars.LeftProbabilityArray(1,iProbability)), 16); %find RTS with the relevant coherence and probability and put them in a cell array
        participant.meanRTgrid(iCoherence, iProbability) = nanmean(RTs{iCoherence, iProbability});
    end
end
  
    filename = strcat('data/',date,'_',time,'_',participant.Initials,'_meanRT_OverallmeanRT',num2str(BlockNo));
    save (filename);
    if sum(sum(isnan(participant.meanRTgrid))) > 0 %if any means are NaNs
        error('ERROR: Not enough response for at least one of the conditions!');
    end
    experiment_end(screen, option, params);
    if option.buttonbox == 1
        stop_buttonbox(params.b_box);
    end
catch err
    filename = strcat('data/',date,'_',time,'_',participant.Initials,'_meanRT_ERR'); %filename for saves in case of error
    save (filename);
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end