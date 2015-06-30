
h = IOPort('OpenSerialPort', 'COM1');
IOPort('Purge',h);
IOPort('ConfigureSerialPort',h,'StartBackgroundRead=1')

bytestoget = IOPort('BytesAvailable',h);
[longdata,when,e] = IOPort('Read',h,1,1)
IOPort('ConfigureSerialPort',h,'StopBackgroundRead');
IOPort('Purge',h);
IOPort('Close',h);