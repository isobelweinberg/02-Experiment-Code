try
    clear all
    %% Open a dialogue box to get participant's details
    [participant] = get_input;
    %% === Experiment Type ====
    train_option.TMS = 0;
    train_option.explicitprior = 1;
    train_option.scaletoRT = 0;
    train_option.mainexp = 0;
    train_option.setupport = 0;
    train_option.buttonbox = 0;
    %% Load Parameters & Setup Screen
    [train_params] = load_parameters(train_option); %Get the stimulus parameters & timings from the function which stores them
    [train_screen] = screen_setup(train_params); %Initialise the screen
    [train_params] = calc_frames(train_params, train_screen); %Calculate the number of frames needed
    %% File Name
    formatDate = 'ddmmyy';
    date = datestr(now,formatDate);
    time = datestr(now, 'HHMMSS');
    %% ==== Inputs =====
    % Independent variables
    train_vars.LeftProbabilityArray = [10 50]; %probability the RDK goes left, as a percentage
    train_vars.CoherenceArray = 20; %use 20% coherence - should be relatively nice and easy
    train_vars.TrialsPerCondition = 30;
    train_vars.NoControlTrials = 12;
    TrialsPerBlock = 19; %4 blocks of 15 test trials + 4 control trials
    TotalNumBlocks = 4;
    % Repeats
    train_vars.repeat = TotalNumBlocks/numel(train_vars.LeftProbabilityArray);
    train_vars.LeftProbabilityArray = repmat(train_vars.LeftProbabilityArray, 1, train_vars.repeat);
    %% Start Button box
    if train_option.buttonbox == 1
        train_params.b_box = start_buttonbox;
    end
    %% Information Screen
    DrawFormattedText(train_screen.windowNo, 'Please decide which way the dots are moving and press a Left or Right arrow key in response. \n Press any key to continue.', 'center', 'center', [0 0 0]);
    Screen('Flip', train_screen.windowNo);
    waitforpress(train_option, train_params)
    %% Trials
    for BlockNo = 1:TotalNumBlocks
        train_data.main = zeros(TrialsPerBlock, 22); %make a blank matrix (update this if increase no. of columns)
        train_data.labels(1, 1:3) = {'Trial Number', 'Block Number', 'Leftward Probability'};
        train_data.main(:, 2) = BlockNo;
        train_data.main(:, 3) = train_vars.LeftProbabilityArray(1, BlockNo); % Set Probability the dots will go left - determined by block
        [FixationXY, DotsXY, train_data, train_vars] = generate_stimuli(TrialsPerBlock, train_vars, train_params, train_option, train_data); % Generate stimuli
        train_data = draw_stimuli(FixationXY, DotsXY, TrialsPerBlock, TrialsPerBlock, train_params, train_screen, train_option, train_data, participant); % Draw the stimuli
        filename = strcat('data/',date,'_',time,'_',participant.Initials,'_BehaviouralTraining_Block',num2str(BlockNo));
        save (filename);
        if train_data.main(find(train_data.main(:,17),1,'last'), 17) == 3 %if the last trial with a response (non-zero) was a 3 (esc was pressed)
            break %end the experiment
        end
    end
    DrawFormattedText(train_screen.windowNo, 'End of training. Press any key to continue.', 'center', 'center', [0 0 0]);
    Screen('Flip', train_screen.windowNo);
    waitforpress(train_option, train_params)
    experiment_end(train_screen, train_option, train_params);
    if train_option.buttonbox == 1
        stop_buttonbox(train_params.b_box);
    end    
catch err
    filename = strcat('data/',date,'_',time,'_',participant.Initials,'_BehaviouralTraining_ERR'); %filename for saves in case of error
    save (filename);
    disp('caught error');
    sca;
    Priority(0);
    rethrow (err);
end