function [params] = load_parameters(option)

% Timings
params.StimulusDuration = 1000; %ms - how long participant gets to make a response
params.FixationDuration = 400; %length of fixation, milliseconds
params.FeedbackDuration = 200; %milliseconds
params.MinITIDuration = 300; %ms
params.MaxITIDuration = 700; %maximum lenth of intertrial interval, milliseconds
params.MinTMSITIDuration = 3500-params.FixationDuration-200; %ms; longer ITI needed when doing TMS
params.MaxTMSITIDuration = 4500-params.FixationDuration-200; %ms
params.TriggerLength = 0.1; %TMS stimulus duration, MILLISECONDS

% Stimulus Properties
params.DotSpeed = 2.5; %pixels
params.NumDots = 300;
params.ApertureRadius = 200; %pixels; radius of circular aperture for RDK
params.DotSpeed = 1500; %pixels per second
params.FixationRadius = 2.5; %pixels; radius of fixation dot
params.BackgroundColour = 255; %white
params.DotColour = [0 0 0]; %black
params.DotRadius = 2.5;

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