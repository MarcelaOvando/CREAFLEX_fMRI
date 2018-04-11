clear
clc

main_dir = fullfile(pwd,'img');

e = exam(main_dir,'CREAFLEX');

e.addSerie('all_runs','anat',1)
e.addVolume('anat','anat_ns_at','s',1)

par.file_reg = [];
for r = 1 : 5
    e.addSerie(['Run_' num2str(r) '$'],['run_' num2str(r)],1)
    e.getSerie(['run_' num2str(r)]).addVolume('^srun','s',1)
    e.getSerie(['run_' num2str(r)]).addStim('all_onsets',sprintf('run%d',r),sprintf('run%d',r))
end

par.file_reg = '^srun';

e.unzipVolume

e.explore

model_name = 'spm_model1';

%% smooth

% par.run = 1;
% par.smooth = [4 4 4]; % FWH in mm
% 
% data_to_smooth = e.getSerie('run').getVolume('^f').toJob;
% job_smooth(data_to_smooth, par); % will be skipped if file already exist


%%

modelDir = e.mkdir(model_name);
dfonc = e.getSerie('run').toJob;
stimFiles = e.getSerie('run').getStim('run').toJob;
stimFiles = stimFiles{1};

%% fMRI design specification

par.rp = 0; % realignment paramters : movement regressors

par.pct = 0;

par.TR = 1.600; % s

par.run=1;
par.display=0;
par.redo = 1;

%%

if par.redo
j_fmri_desing = job_first_level_specify(dfonc,modelDir,{stimFiles},par);
end

%% Estime design

fspm = e.addModel(model_name, model_name);

if par.redo
j_estimate_model = job_first_level_estimate(fspm,par);
end

%% Prepare contrasts

cross_onset  = [1 0 0 0 0 0];
cross_change = [0 1 0 0 0 0];
word_onset   = [0 0 1 0 0 0];
slider_move  = [0 0 0 1 0 0];
after_click  = [0 0 0 0 1 0];
ITI          = [0 0 0 0 0 1];


contrast.names = {
    'cross_onset'
    'cross_change'
    'word_onset'
    'slider_move'
    'after_click'
    'ITI'
    
    'slider_move - word_onset'
    'word_onset - slider_move'
    
    };



contrast.values = {
    
cross_onset
cross_change
word_onset
slider_move
after_click
ITI

slider_move - word_onset
word_onset - slider_move

};

contrast.types = repmat({'T'},[1 length(contrast.values)]);
par.delete_previous=1;


%% Generate contrasts

par.sessrep = 'both';
j_contrast = job_first_level_contrast(fspm,contrast,par);

e.getModel(model_name).show
