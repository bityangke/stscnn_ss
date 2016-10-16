path = 'data/THUMOS14/sample';
filelist = dir(path);

for i=1:length(filelist)
    if ~strcmp(filelist(i).name, '.') && ~strcmp(filelist(i).name, '..')
        filename = strsplit(filelist(i).name,'_s0');
        system(sprintf('mv %s/%s %s/%s.jpg', path, filelist(i).name, path, filename{1}));
    end
end