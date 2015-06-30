function waitforpress(option, params)
if option.buttonbox == 1
    IOPort('Read', params.b_box, 1, 1);
else
    KbStrokeWait;
end