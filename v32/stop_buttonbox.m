function stop_buttonbox(b_box)
    IOPort('Purge', b_box);
    IOPort('Close', b_box);
end