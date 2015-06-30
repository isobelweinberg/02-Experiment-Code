try
    %for this script to work, participant.Name and .Thresholds must exist
    clearvars -except participant %NB port is setup in the thresholding script to avoiding triggering signal if setting it up here
    sca;
    KbName('UnifyKeyNames');
     %% File Name
    formatDate = 'ddmmyy';
    date = datestr(now,formatDate);
    time = datestr(now, 'HHMMSS');
    %% === Experiment Type ====
    option.TMS = 1;
    option.scaletoRT = 1;
    option.explicitprior = 1; 
    option.mainexp = 1;
    option.setupport = 0;
    option.buttonbox = 0;
    %% ==== Inputs =====
    % Independent variables
    vars.CoherenceArray = participant.Thresholds; 
    vars.LeftProbabilityArray=[10, 50]; %probability the RDK goes left, as a percentage
    vars.TrialsPerCondition = 20; %must be even!
    vars.TMS.Timepoints = [0, 0.3, 0.4, 0.6]; %TMS timepoints, in SECONDS, relative to Timepoint Relations... 
    %NB if scaling to RT, give the timepoints relative to stim as proportion of mean RT e.g. 0.65
    vars.TMS.TimepointRelations = {'Stim', 'Stim', 'Stim', 'Stim'}; %....Fixation, Stim or ITI %NB this must match the numel in timepoints or a shitstorm occurs
    vars.TMS.Probability = 100; %in percent, gives you TMS trials vs behavioural trials
    %NB, if you are stimulating in the ITI, the interval needs to be less
    %than the minimum ITI duration!
    % Directions
    vars.conventions.Direction = {'Left', -1; 'Right', 1}; %LEFT is -1; RIGHT is 1
    if option.scaletoRT == 1
        gridsize = size(participant.meanRTgrid);
        if gridsize(1, 1) ~= numel(vars.CoherenceArray)
            error('Wrong number of coherences for RT scaling!')        
        end
        if gridsize(1, 2) ~= numel(vars.LeftProbabilityArray)
            error('Wrong number of probabilitiess for RT scaling!')
        end
    end    
    [params] = load_parameters(option); % Load Stimulus Parameters
    %% Calculate No Trials
    switch option.TMS
        case 1
            TotalNumTrials = vars.TrialsPerCondition*numel(vars.CoherenceArray)*numel(vars.LeftProbabilityArray)...
                *(numel(vars.TMS.Timepoints)/(vars.TMS.Probability/100));
        case 0
            TotalNumTrials = vars.TrialsPerCondition*numel(vars.CoherenceArray)*numel(vars.LeftProbabilityArray);
    end
    TrialsPerBlock = TotalNumTrials/(2*numel(vars.LeftProbabilityArray));
    %How many blocks are there?
    TotalNumBlocks = TotalNumTrials/TrialsPerBlock;
    %repeat the left probability array to match the block number
    vars.repeat = TotalNumBlocks/numel(vars.LeftProbabilityArray);
    if option.scaletoRT == 1
        vars.meanRTgrid = participant.meanRTgrid; %so it can be passed to generate_stimuli later
    end
    %% Setup the screen
    [screen] = screen_setup(params);
    %% Calculate the frames
    [params] = calc_frames(params, screen);
    %Human error check %HAVE ANOTHER LOOK AT THIS - STILL RELEVANT??
%     if numel(vars.LeftProbabilityArray)~=TotalNumBlocks
%         DrawFormattedText(screen.windowNo, 'Error. \n The number of blocks does not match the number of dot direction probabilities you have entered. \n Press any key', 'center', 'center', [0 0 0]);
%         Screen('Flip', screen.windowNo);
%         KbStrokeWait;
%         sca;
%         Priority(0);
%     end
    
%     % Check for filename clash  
%     if exist([filename '.mat'], 'file')>0
%         DrawFormattedText(screen.windowNo, 'There is already a file with this name. Please check for errors.', 'center', 'center', [0 0 0]);
%         Screen('Flip', screen.windowNo);
%         KbStrokeWait;
%         sca;
%         Priority(0);
%     end
    
    %% Load
    % call these once to avoid a slow first iteration
    GetSecs;
    KbCheck;
        
    %Seed the random number generator
    %     rng('shuffle'); %modern
    rand('seed', sum(100 * clock)); %legacy
    
    
    %% Open Button box
    if option.buttonbox == 1
        params.b_box = start_buttonbox;
    end
    %% Main Experiment
    if option.mainexp == 1
        data.ProbabilityOrder = [];
        for repeat = 1:vars.repeat %make the Probability Order a random sequence but only varying in sets of 3 e.g. 3, 2, 1, 5, 4, 6
            data.ProbabilityOrder =[data.ProbabilityOrder, ((numel(vars.LeftProbabilityArray)*(repeat-1))+randperm(numel(vars.LeftProbabilityArray)))];
        end
        vars.LeftProbabilityArray = repmat(vars.LeftProbabilityArray, 1, vars.repeat);
        data.ExperimentStart = clock; %ExperimentStart = datetime;
        for BlockNo=1:TotalNumBlocks
            data.main = zeros(TrialsPerBlock, 23); %make a blank matrix (update this if increase no. of columns)
            data.labels(1, 1:3) = {'Trial Number', 'Block Number', 'Leftward Probability'};
            data.main(:, 2) = BlockNo;
            data.main(:, 3) = vars.LeftProbabilityArray(1, (data.ProbabilityOrder(1, BlockNo))); % Set Probability the dots will go left - determined by block
            % 5 triggers for MEP localisation
            if option.TMS == 1
                DrawFormattedText(screen.windowNo, 'Experiment begins with 14 TMS pulses. Press any key to continue.', 'center', 'center', [0 0 0]);
                Screen('Flip', screen.windowNo);
                waitforpress(option, params);
                localise.KeyName = '';
                NumTriggerLoops = 0;
                while strcmp (localise.KeyName, 'RightArrow') ~= 1
                DrawFormattedText(screen.windowNo, 'Triggering', 'center', 'center', [0 0 0]);
                Screen('Flip', screen.windowNo);
                WaitSecs(1);
                   for itrigger = 1:14
                        sendtrigger(participant.port, params.TriggerLength, 'both');
                        WaitSecs(params.MinTMSITIDuration/1000); 
                    end
                DrawFormattedText(screen.windowNo, 'Press left for further pulses or right to continue experiment.', 'center', 'center', [0 0 0]);
                Screen('Flip', screen.windowNo);
                if option.buttonbox == 1
                    KeyPress = IOPort('Read', params.b_box, 1, 1);
                    if KeyPress == 1
                        localise.KeyName = 'RightArrow';
                    end
                else
                    [localise.KeyPressTime, localise.KeyPress] = KbStrokeWait;
                    localise.KeyName = KbName(find(localise.KeyPress==1)); %get the name of the first key pressed
                end
                NumTriggerLoops = NumTriggerLoops + 1;
                end
            end
            [FixationXY, DotsXY, data, vars] = generate_stimuli(TrialsPerBlock, vars, params, option, data); % Generate stimuli 
            data = draw_stimuli(FixationXY, DotsXY, TrialsPerBlock, TrialsPerBlock, params, screen, option, data, participant); % Draw the stimuli
            filename = strcat('data/',date,'_',time,'_',participant.Initials,'_Block',num2str(BlockNo)); %save by block
            save (filename);
            if data.main(find(data.main(:,17),1,'last'), 17) == 3 %if the last trial with a response (non-zero) was a 3 (esc was pressed)
                break %end the experiment
            end
            data = rmfield(data, 'main'); %clears out data.main so that if the next block doesn't get all the way round, only new data shows up
            DrawFormattedText(screen.windowNo, 'Have a rest. Press any key to continue.', 'center', 'center', [0 0 0]);
            Screen('Flip', screen.windowNo);
            waitforpress(option, params)
        end
        experiment_end(screen, option, params);
        if option.buttonbox == 1
            stop_buttonbox(params.b_box);
        end
        data.ExperimentEnd = clock; %ExperimentEnd = datetime;
        %% Record Stimulation Intensities
        if option.TMS == 0 %CHANGE!
            prompt = cell(1, TotalNumBlocks);
            def = cell(1, TotalNumBlocks);
            for iDlg = 1:TotalNumBlocks
                prompt{1, iDlg} = ['Block ', num2str(iDlg), ':'];
                def{1, iDlg} = '60';
            end
            num_lines = 1;
            dlg_title = 'Enter Stimulation Intensities:';
            StimIntensities = inputdlg(prompt,dlg_title,num_lines,def);
            filename = strcat('data/',date,'_',time,'_',participant.Initials,'_StimulationIntensities'); %save by block
            save (filename, 'StimIntensities');
        end
    end
    %% Finish
catch err
    filename = strcat('data/',date,'_',time,'_',participant.Initials,'_ERR'); %filename for saves in case of error
    save (filename);
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end
%% ===To Do ====
%
% 1. 
% 2. 
% 3. Visual anagle
% 4. 
% 5. 
% 6. 
% 7. 
% 8. Reward based on mean RT?
% 9. What to do about/how to calculate mean RT

%Make random numbers repeatable?
%Compare to others' scripts
%button box!!

%Feedback based on RT?

% check have made allowances for dotwidth throughout