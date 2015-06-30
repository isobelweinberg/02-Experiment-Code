% This script calculates the performance-related reward the participant should get, on a scale
% from £3.50 - 5
%% Concatenate the blocks
all_data.main = [];
for BlockNo = 1:TotalNumBlocks
    load(['data/',date,'_',time,'_',participant.Initials,'_Block',num2str(BlockNo),'.mat']);
    all_data.blocks{BlockNo} = data.main;
    all_data.main = [all_data.main; all_data.blocks{BlockNo}];
end
%% Calcuate mean RT on correct trials and allocate reward
all_data.CorrectMean = mean(all_data.main(find(all_data.main(:,18)==1),16)); %the mean RT for correct trials only
if all_data.CorrectMean <= 0.55
    reward_pounds = 5;
elseif all_data.CorrectMean <= 0.63 && all_data.CorrectMean > 0.55
    reward_pounds = 4.5;
elseif all_data.CorrectMean <= 0.7 && all_data.CorrectMean > 0.63
    reward_pounds = 4;
else
    reward_pounds = 3.5;
end
%% Output to command line
disp(['£', num2str(reward_pounds)]);
%% Save
formatDate = 'ddmmyy';
date = datestr(now,formatDate);
time = datestr(now, 'HHMMSS');
filename = ['data/',date,'_',time,'_',participant.Initials,'_Reward.mat'];
save(filename, 'all_data', 'reward_pounds');
