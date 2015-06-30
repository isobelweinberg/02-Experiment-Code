%for hotspot localisation
option.TMS = 1;
option.setupport = 1;
[params] = load_parameters(option);
participant.port = params.port; %a bit of a hack - the port object is created in the parameters, and the easiest way to pass it on to other scripts is to stick it in the participant structure
KbQueueCreate;
KbQueueStart;
for i = 1:1000
    sendtrigger(participant.port, params.TriggerLength, 'both');
    WaitSecs (4);
    [keypressed] = KbQueueCheck; 
    if keypressed
        break
    end
end
KbQueueStop;