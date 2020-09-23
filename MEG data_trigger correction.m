addpath('C:\MyTemp\Natalias project\Trigger program'); %Trigger programs
addpath('C:\MyTemp\fieldtrip-20160110'); ft_defaults; %FieldTrip program

subjectdata.datadir       = 'C:\MyTemp\Natalias project\MEG data';
subjectdata.logdir       = 'C:\MyTemp\Natalias project\log file';
subjectdata.besadir       = 'C:\MyTemp\Natalias project\besa event';
subjectdata.outputdir = 'C:\MyTemp\Natalias project\Output';
subjectdata.dataname         =  {'file1.fif','file2.fif'};
subjectdata.logfile = {'log1.txt','log2.txt','log3.txt'};
subjectdata.besafile= {'besa1.evt','besa2.evt'};

for N = 1: length(subjectdata.dataname);

cfg.dataset  = [subjectdata.datadir filesep subjectdata.dataname{1,N}];
cfg.trialdef.eventtype  = 'STI101';


hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

value= {event(:).value}';
sample= {event(:).sample}';

%load the sound file timing
load('C:\MyTemp\Natalias project\324 sound files timing_Hän on &jä');

% To take only specific triggers sample
trl = [];
for j = 1:(length(value)-1)
    trg1 = value{j};
%     if trg1==12 ||trg1==22 || trg1==32 ||trg1==42 || trg1==52 || trg1==62
        if trg1==12 ||trg1==22 
        trlbegin = sample{j};
        newtrl   = [trlbegin value{j}];
        trl      = [trl; newtrl];
                
    end
end


%import log file from presentation
lexical_log =lexical_fn([subjectdata.logdir filesep subjectdata.logfile{1,N}],2, inf);

% Insert sound file name from log file in trl (:,3)
trl(1:length(trl),3) = cell2mat(lexical_log(1:length(trl),1)); 

%check whether  log file events and fif event match or not.
% if length(trl) == length(lexical_log)
% trl(1:length(trl),3) = cell2mat(lexical_log(:,1)); % Insert sound file name from log file in trl (:,3)
% else
%    disp(['Error: check_' subjectdata.dataname{1,N}]);
% end



% based on the sound length, trial end sample is calculated
trlend_3 ={};

for  i = 1: length(trl);
    for j = 1:length(sound);
        if trl(i,end)== sound(j,1); 
           trled_3 = trl(i,1) + sound(j,2);  %3rd trigger       
            trlend_3= [trlend_3; trled_3];  %3rd trigger

            
            
        end
    end
end


%structring in BESA events format
for  i = 1: length(trl);
	trlend_3{i,1} = trlend_3{i,1}*1000;  % multiply by 1000 each value to look exactly like BESA event format
	trlend_3{i,2}=1; % adding 1 to match the BESA event file structure
    trlend_3{i,3} = trl(i,2) + 1; %13,23,33,43,54,63 
	trlend_3{i,4}= strcat('FIFF Trigger:',num2str(trlend_3{i,3}));
  
end

%importing BESA events
Besa_triggers = besa_events([subjectdata.besadir filesep subjectdata.besafile{1,N}], 2, inf);

triggers = vertcat(Besa_triggers,trlend_3); % append the Original triggers with new triggers

%save the file
fileID = fopen([subjectdata.outputdir filesep subjectdata.dataname{1,N} '_triggers.evt' ],'w');
fprintf(fileID,' %s %s %s %s \r\n', ...
'Tmu','Code','TriNo','Comnt');

formatSpec = '%d %d %d %s\r\n';
[nrows,ncols] = size(triggers);

for row = 1:nrows
    fprintf(fileID,formatSpec,triggers{row,:});
end
fclose(fileID);

end