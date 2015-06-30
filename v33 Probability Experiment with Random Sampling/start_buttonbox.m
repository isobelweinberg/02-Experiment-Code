function [b_box] = start_buttonbox
b_box = IOPort('OpenSerialPort', 'COM1');
IOPort('Purge', b_box);
IOPort('ConfigureSerialPort', b_box, 'ReceiveTimeout=0');
end