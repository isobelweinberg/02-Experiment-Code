%a script to threshold using Quest
try
    clearvars -except participant
    %% Open a dialogue box to get participant's details
%     [participant] = get_input;
    %% File Name
    formatDate = 'ddmmyy';
    date = datestr(now,formatDate);
    time = datestr(now, 'HHMMSS');
    %% === Experiment Type ====
    t_option.TMS = 0;
    t_option.explicitprior = 0;
    t_option.scaletoRT = 0;
    t_option.mainexp = 0;
    t_option.setupport = 0;
    t_option.buttonbox = 0;
    %% Load Parameters & Setup Screen
    [t_params] = load_parameters(t_option); %Get the stimulus parameters & timings from the function which stores them
    [t_screen] = screen_setup(t_params); %Initialise the screen
    [t_params] = calc_frames(t_params, t_screen); %Calculate the number of frames needed
    %[port] = setup_port(t_params); %set up now so doesn't trigger Signal in main experiment
%     t_params.MinITIDuration = 300; %ms, overwrite the min and max ITI because doesn't need to be so long in thresholding
%     t_params.MaxITIDuration = 700; %milliseconds
%% Open Button box
if t_option.buttonbox == 1
    t_params.b_box = start_buttonbox;
end
    %% ==== Inputs =====
    % Independent variables
    t_vars.LeftProbabilityArray = 50; %probability the RDK goes left, as a percentage
    t_vars.TrialsPerCondition = 20; %?
    t_vars.ConditionRepeatsPerBlock = 1;
    t_vars.NoControlTrials = 0;
    %% Give Priors for Weibull distribution
    beta=1.22;delta=0.01;gamma=0.5;%beta was estimated based on collected data %suggested values for delta and gamma come from Quest helpfiles
    q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
    trialsDesired=100;
    wrongRight={'wrong','right'};
    %% Start the experiment
    DrawFormattedText(t_screen.windowNo, 'Please decide which way the dots are moving and press a Left or Right arrow key in response. \n Press any key to continue.', 'center', 'center', [0 0 0]);
    Screen('Flip', t_screen.windowNo);
    waitforpress(t_option, t_params)
     %% === Set thresholds and priors ==== 
     t_vars.Thresholds = 0.7;
     t_vars.ThresholdPriors = 10.4;
%          t_vars.Thresholds = [0.7, 0.8, 0.9]; %thresholds you want evaluated
%     t_vars.Thresholds = [0.55, 0.7, 0.9]; %thresholds you want evaluated
%         t_vars.ThresholdPriors = [10.4, 16.8, 26.7]; % from estimatebeta_analysisJan.m, depending on threshold used
%     t_vars.ThresholdPriors = [2.9, 10.4, 26.7]; % from estimatebeta_analysisJan.m, depending on threshold used
    participant.ThresholdedProbs = t_vars.Thresholds; %hack to save in an easily accessible place
    participant.ThresholdPriors = t_vars.ThresholdPriors;
%     t_vars.TMS.Timepoints = [0.05, 0.1, 0.2];
    %% Give an explicit prior
    message = strcat('For the next', 32, num2str(trialsDesired*numel(t_vars.Thresholds)), ' trials, the probability the dot field will be moving LEFT is \n',...
        32, num2str(t_vars.LeftProbabilityArray), '%, and the probability it will be moving RIGHT is', 32,...
        num2str(100-t_vars.LeftProbabilityArray), '%');
    LeftColour = (1*(100-t_vars.LeftProbabilityArray)/100)*[255 255 255];
    RightColour = (1*t_vars.LeftProbabilityArray/100)*[255 255 255];
    RectSize = [0 0 100 100];
    offset = 150;
    LeftRect = CenterRectOnPoint(RectSize, (t_screen.xmiddle-offset), (t_screen.ymiddle+150));
    RightRect = CenterRectOnPoint(RectSize, (t_screen.xmiddle+offset), (t_screen.ymiddle+150));
    
    DrawFormattedText(t_screen.windowNo, message, 'center', (t_screen.ymiddle-250), [0 0 0], '', '', '', 2.5);
    Screen(t_screen.windowNo,'FillRect', LeftColour, LeftRect);
    Screen(t_screen.windowNo,'FillRect', RightColour, RightRect);
    DrawFormattedText(t_screen.windowNo, 'Left', (t_screen.xmiddle-offset), 'center', [0 0 0], '', '', '', 2.5);
    DrawFormattedText(t_screen.windowNo, strcat(num2str(t_vars.LeftProbabilityArray), '%'), (t_screen.xmiddle-offset), (t_screen.ymiddle+50), [0 0 0], '', '', '', 2.5);
    DrawFormattedText(t_screen.windowNo, 'Right', (t_screen.xmiddle+offset), 'center', [0 0 0], '', '', '', 2.5);
    DrawFormattedText(t_screen.windowNo, strcat(num2str(100-t_vars.LeftProbabilityArray), '%'), (t_screen.xmiddle+offset), (t_screen.ymiddle+50), [0 0 0], '', '', '', 2.5);
    DrawFormattedText(t_screen.windowNo, 'Press any key to continue', 'center', t_screen.ymiddle+300, [0 0 0], '', '', '', 2.5);
    Screen('Flip', t_screen.windowNo);
    waitforpress(t_option, t_params);
    %% Block loop (1 block per threshold)
    for thresholdblock = 1:numel(t_vars.Thresholds)
        pThreshold=t_vars.Thresholds(1, thresholdblock); %what threshold are you working on this block
        tGuess=t_vars.ThresholdPriors(1, thresholdblock); %find prior
        tGuessSd=3*tGuess; %a large SD
        q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);
        timeZero=GetSecs;
        t_data.labels(1, 1:3) = {'Trial Number', 'Block Number', 'Leftward Probability'};
        for k=1:trialsDesired
            t_data.main(:, 2) = thresholdblock;
            t_data.main(:, 3) = t_vars.LeftProbabilityArray;
            % Get recommended level.  Choose your favorite algorithm.
            tTest=QuestQuantile(q);	% Recommended by Pelli (1987), and still our favorite.
            t_vars.CoherenceArray = tTest;
            % Run a trial
            NumTrials = 1;
            TrialsPerBlock = 1;
            timeSplit=GetSecs;
            [t_FixationXY, t_DotsXY, t_data, t_vars] = generate_stimuli(NumTrials, t_vars, t_params, t_option, t_data);
            t_data = draw_stimuli(t_FixationXY, t_DotsXY, NumTrials, TrialsPerBlock, t_params, t_screen, t_option, t_data, participant);
            timeZero = timeZero+GetSecs-timeSplit;
            response = t_data.main(1, 18);
            % Update the pdf
            actualcoherence = t_data.main(1, 21);
            q=QuestUpdate(q,actualcoherence,response); % Add the new datum (actual test intensity and observer response) to the database.
            t_alldata.main(k, :) = t_data.main; %put data for each trial in an overall structure called t_alldata, because t_data is getting overwritten
            t_alldata.labels = t_data.labels;
            if t_data.main(find(t_data.main(:,17),1,'last'), 17) == 3 %if the last trial with a response (non-zero) was a 3 (esc was pressed)
                break %end the experiment
            end
        end
        t=QuestMode(q);	% Similar and preferable to the maximum likelihood recommended by Watson & Pelli (1983).
        participant.Thresholds(1, thresholdblock) = t;
        filename = strcat('data/',date,'_',time,'_',participant.Initials,'_Thresholding_t',num2str(pThreshold*100));
        save (filename);
        fprintf('Mode threshold estimate is %4.2f\n',t);
        clear t_alldata;
        clear q;
    end
    experiment_end(t_screen, t_option, t_params);
     if t_option.buttonbox == 1
        stop_buttonbox(t_params.b_box);
    end
catch err
    filename = strcat('data/',date,'_',time,'_',participant.Initials,'_Thresholding_ERR');
    save (filename);
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end