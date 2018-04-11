clear
clc

main_dir = fullfile(pwd,'img');

e = exam(main_dir,'Pilote01');


%%

for run = 1:6
    
e.addSerie(['Run_' num2str(run) '$'],['run_' num2str(run)],1)

pth = e.getSerie(['run_' num2str(run)]).path;
dics = get_subdir_regex_files(pth,'^d*'); dics = cellstr(dics{1});

res = get_string_from_json(dics,{'EchoTime'},{'numeric'});
allTE = cell2mat([res{:}]);

[sortedTE,order] = sort(allTE);

for echo = 1 : length(order)
    switch order(echo)
        case 1
            e.addVolume(['run_' num2str(run)],'^f.*Run_\d.nii',['f_e' num2str(echo)])
        case 2
            e.addVolume(['run_' num2str(run)],'^f.*Run_\d_V002.nii',['f_e' num2str(echo)])
        case 3
            e.addVolume(['run_' num2str(run)],'^f.*Run_\d_V003.nii',['f_e' num2str(echo)])
    end
end

end

e.addSerie('3DT1','anat',1)
e.addVolume('anat','^s.*nii','s',1)

e.explore


%%

working_dir = e.mkdir('all_runs');


for run = 6
    
    e1 = e.getSerie(sprintf('run_%d',run)).getVolume('f_e1').path;
    e2 = e.getSerie(sprintf('run_%d',run)).getVolume('f_e2').path;
    e3 = e.getSerie(sprintf('run_%d',run)).getVolume('f_e3').path;
    
    e1 = r_movefile(e1,fullfile(working_dir,['run' num2str(run) '_e1.nii.gz']),'link');
    e2 = r_movefile(e2,fullfile(working_dir,['run' num2str(run) '_e2.nii.gz']),'link');
    e3 = r_movefile(e3,fullfile(working_dir,['run' num2str(run) '_e3.nii.gz']),'link');
    
        
        a = e.getSerie('anat').getVolume('s').path;
        a = r_movefile(a,fullfile(working_dir,'anat.nii.gz'),'link');
        
    
    
    [~,e1,~] = fileparts(char(e1)); e1 = [e1 '.gz'];
    [~,e2,~] = fileparts(char(e2)); e2 = [e2 '.gz'];
    [~,e3,~] = fileparts(char(e3)); e3 = [e3 '.gz'];
    [~,a ,~] = fileparts(char(a )); a  = [a '.gz'];
    
        cmd = sprintf('cd %s;\n meica.py -d %s,%s,%s -e 15.2,37.17,59.14 -a %s --MNI --prefix %s',...
            char(working_dir), e1,e2,e3, a, sprintf('run%d__',run))
    
unix(cmd)
    
end
