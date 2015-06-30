function [params] = load_parameters(option)

% Timings
params.StimulusDuration = 1000; %ms - how long participant gets to make a response
params.FixationDuration = 400; %length of fixation, milliseconds
params.FeedbackDuration = 200; %milliseconds
params.MinITIDuration = 300; %ms
params.MaxITIDuration = 700; %maximum lenth of intertrial interval, milliseconds
params.MinTMSITIDuration = 3500-params.FixationDuration-350; %ms; longer ITI needed when doing TMS
params.MaxTMSITIDuration = 4500-params.FixationDuration-350; %ms
params.TriggerLength = 0.1; %TMS stimulus duration, MILLISECONDS

% Screen Properties
params.Screen.Name = 'Lab 3 screen';
params.Screen.Width_cm = 38;
params.Screen.Height_cm = 30;
params.Screen.Width_px = 1280;
params.Screen.Height_px = 1024;
params.Screen.Screen_dist = 80; %distance from screen in cm
% params.Screen.Name = 'SB3 screen';
% params.Screen.Width_cm = 41;
% params.Screen.Height_cm = 25.5;
% params.Screen.Width_px = 1440;
% params.Screen.Height_px = 900;
% params.Screen.Screen_dist = 80; %distance from screen in cm
prompt = 'Do you want to change the screen setup? Y/N';
userans = input(prompt,'s');
if userans == 'Y'
    params.Screen.Name = input('params.Screen.Name', 's');
    params.Screen.Width_cm = input('params.Screen.Width_cm');
    params.Screen.Height_cm = input('params.Screen.Height_cm');
    params.Screen.Width_px = input('params.Screen.Width_px');
    params.Screen.Height_px = input('params.Screen.Height_px');
    params.Screen.Screen_dist = input('params.Screen.Screen_dist');
end

% Stimulus Properties
params.DotSpeed = 2.5; %pixels
params.NumDots = 300;
params.ApertureRadius = visualangle2RDKrad(params.Screen.Width_cm, params.Screen.Height_cm,...
    params.Screen.Width_px, params.Screen.Height_px, params.Screen.Screen_dist); %pixels; radius of circular aperture for RDK %should be 200px for an SB screen
params.DotSpeed = 1500; %pixels per second
params.FixationRadius = 2.5; %pixels; radius of fixation dot
params.BackgroundColour = 255; %white
params.DotColour = [0 0 0]; %black
params.DotRadius = 0.0125*params.ApertureRadius; %2.5px for an Aperture radius of 200
if params.DotRadius < 1
    params.DotRadius = 1;
end

%Parallel Port Setup
params.TMSbit = 1; %the parallel port bit that will trigger the TMS machine
params.collectbit = 2; %the parallel port bit that will trigger Signal & therefor data collection

% Set up parallel port (using Data Acquisition Toolbox)
if option.TMS == 1 && option.setupport == 1
    params.port = digitalio('parallel', 'LTP1'); %defines the port as an object called port
    addline(params.port, params.TMSbit, 'out'); %this now has Index 1
    addline(params.port, params.collectbit, 'out'); %this now has Index 2
    % params.port = 1; beep; disp('trigger'); %for debugging
end

end