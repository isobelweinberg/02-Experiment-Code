function [participant] = get_input
% Open a dialogue box to get participant's details
prompt = {'Enter name (use underscores):', 'Initials:', 'Age:'};
dlg_title = 'Participant Details';
num_lines = 1;
default = {'Test', 'TS', '25'};
input = inputdlg(prompt,dlg_title,num_lines,default);
participant.Name = input{1};
participant.Initials = input{2};
participant.Age = input{3};
end
