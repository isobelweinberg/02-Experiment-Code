
%IF YOU WANT TO READ IN THE BACKGROUND 
b_box = IOPort('OpenSerialPort', 'COM1');
IOPort('Purge', b_box);
IOPort('ConfigureSerialPort', b_box,'StartBackgroundRead=1')
[KeyPress, KeyPressTime] = IOPort('Read', b_box, 1, 1); %this waits until you have 1 byte of data, then returns it
IOPort('ConfigureSerialPort', b_box, 'StopBackgroundRead');
IOPort('Purge', b_box);
IOPort('Close', b_box);

% IF YOU WANT TO WAIT FOR A KEYPRESS BEFORE CONTINUING (NB. DON'T USE
% BACKGROUND READ)
b_box = IOPort('OpenSerialPort', 'COM1');
IOPort('Purge', b_box);
IOPort('ConfigureSerialPort', b_box, 'ReceiveTimeout=0'); %this means there is no timeout. If you want a timeout, change the number
[KeyPress, KeyPressTime] = IOPort('Read', b_box, 1, 1)
 IOPort('Purge', b_box);
 IOPort('Close', b_box);
 

        KeyPress = 0
while KeyPress == 0
        [KeyPress, KeyPressTime] = IOPort('Read', b_box, 0, 1);
        WaitSecs(0.0005); %half a ms
end

   IOPort('ConfigureSerialPort', b_box, 'StopBackgroundRead');
        IOPort('Purge', b_box);
        IOPort('Close', b_box);
        
        
        b_box = IOPort('OpenSerialPort', 'COM1');
        IOPort('Purge', b_box);
        IOPort('ConfigureSerialPort', b_box, 'ReceiveTimeout=0')
        IOPort('ConfigureSerialPort', b_box,'StartBackgroundRead=1')
        [KeyPress, KeyPressTime] = IOPort('Read', b_box, 1, 1)