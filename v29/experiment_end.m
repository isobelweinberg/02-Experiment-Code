function experiment_end(screen, option, params);
DrawFormattedText(screen.windowNo, 'Experiment finished! Press any key to continue.', 'center', 'center', [0 0 0]);
Screen('Flip', screen.windowNo);
waitforpress(option, params);
sca;
Priority(0);
end