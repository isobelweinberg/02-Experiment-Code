function triggertime = sendtrigger(port, triggerlength, instruction)
if strcmp(instruction, 'computeronly') == 1
    triggertime = GetSecs;
    putvalue(port.Line(2), 1) % just triggers computer
    WaitSecs(triggerlength/1000);
    putvalue(port.Line(2), 0);
elseif strcmp(instruction, 'both') == 1
    triggertime = GetSecs;
    putvalue(port.Line([1 2]), [1 1]) % triggers computer and TMS pulse
    WaitSecs(triggerlength/1000);
    putvalue(port.Line([1 2]), [0 0]);
% beep; disp('trigger'); %for debugging
end
% triggertime = 1; %for debugging
end

%Some useful things to know about parallel port triggering:
% 1) Typing in the name of the object (e.g. port) gives a list of its lines/bits
% 2) getvalue(port) gives the current state of the port for all lines
% 3) putvalue(port.Line(x),1) can be used to trigger individual bits, where x is the number of the bit (get this from 1 - the 'index')
% 4) If you do putvalue for more than one bit, you have to give a binary number to write more than one bit - [1 1 0] etc
% Index depends on order the bits were added - first time you use addline
% it gives Index = 1, etc.

