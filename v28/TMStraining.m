try
    clearvars -except participant
    %% File Name
    formatDate = 'ddmmyy';
    date = datestr(now,formatDate);
    time = datestr(now, 'HHMMSS');
    %% === Experiment Type ====
    train_option.TMS = 1;
    train_option.explicitprior = 1;
    train_option.scaletoRT = 0;
    train_option.mainexp = 0;
    train_option.setupport = 0;
    train_option.buttonbox = 0;
    %% Load Parameters & Setup Screen
    [train_params] = load_parameters(train_option); %Get the stimulus parameters & timings from the function which stores them
    [train_screen] = screen_setup(train_params); %Initialise the screen
    [train_params] = calc_frames(train_params, train_screen); %Calculate the number of frames needed
    %% Open Button box
    if train_option.buttonbox == 1
        train_params.b_box = start_buttonbox;
    end
    %% ==== Inputs =====
    % Independent variables
    train_vars.LeftProbabilityArray = 50; %probability the RDK goes left, as a percentage
    train_vars.CoherenceArray = 20; %use 20% coherence - should be relatively nice and easy
    train_vars.TMS.Timepoints = [0, 0.3, 0.4, 0.6]*participant.meanRT;
    train_vars.TMS.TimepointRelations = {'Stim', 'Stim', 'Stim'}; 
    train_vars.TMS.Probability = 100;
    TrialsPerBlock = 12; %must be a multiple of 3
    train_vars.TrialsPerCondition = TrialsPerBlock/(numel(train_vars.LeftProbabilityArray)*numel(train_vars.CoherenceArray)*numel(train_vars.TMS.Timepoints));
    %% Information Screen
    DrawFormattedText(train_screen.windowNo, 'Please decide which way the dots are moving and press a Left or Right arrow key in response. \n Press any key to continue.', 'center', 'center', [0 0 0]);
    Screen('Flip', train_screen.windowNo);
    waitforpress(train_option, train_params);
    %% Trials
    train_data.main = zeros(TrialsPerBlock, 22); %make a blank matrix (update this if increase no. of columns)
    train_data.labels(1, 1:3) = {'Trial Number', 'Block Number', 'Leftward Probability'};
    train_data.main(:, 2) = 1;
    train_data.main(:, 3) = train_vars.LeftProbabilityArray(1, 1); % Set Probability the dots will go left - determined by block
    [FixationXY, DotsXY, train_data, train_vars] = generate_stimuli(TrialsPerBlock, train_vars, train_params, train_option, train_data); % Generate stimuli
    WaitSecs(0.5);
    train_data = draw_stimuli(FixationXY, DotsXY, TrialsPerBlock, TrialsPerBlock, train_params, train_screen, train_option, train_data, participant); % Draw the stimuli
    filename = strcat('data/',date,'_',time,'_',participant.Initials,'_TMSTraining');
    save (filename);
    DrawFormattedText(train_screen.windowNo, 'Press any key to continue.', 'center', 'center', [0 0 0]);
    Screen('Flip', train_screen.windowNo);
    waitforpress(train_option, train_params);
    experiment_end(train_screen, train_option, train_params);
     if train_option.buttonbox == 1
        stop_buttonbox(train_params.b_box);
    end
catch err
    filename = strcat('data/',date,'_',time,'_',participant.Initials,'_TMSTraining_ERR'); %filename for saves in case of error
    save (filename);
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end