function imdb = stscnnSetup_Test(varargin)
opts.dataDir = fullfile('data','THUMOS14/slices') ;
opts.includeDetection = false ;
opts.includeSegmentation = false ;
opts.includeTest = false ;
opts = vl_argparse(opts, varargin) ;

% Source images and classes
imdb.paths.image = esc(fullfile(opts.dataDir, 'slices/video_test_%07d_y-t_slice_x145.jpg')) ;
imdb.sets.id = uint8([3]) ;
imdb.sets.name = {'test'} ;
imdb.classes.id = uint8(1:1) ;
imdb.classes.name = {'action'} ;
imdb.classes.images = cell(1,1) ;
imdb.images.id = [] ;
imdb.images.name = {} ;
imdb.images.set = [] ;

[gt, label_name_list] = read_gt_THUMOS14(fullfile(opts.dataDir, 'annotation'));
load(fullfile(opts.dataDir, 'test_set_meta.mat'));
thumos14_videos = test_videos;
clear validation_videos;
generate_segmentation_masks_THUMOS14(fullfile(opts.dataDir, 'slices'), gt, thumos14_videos, fullfile(opts.dataDir,'masks'));

[imdb] = addImageSet(imdb, 3, gt) ; % 'train'

% Source segmentations: set the path of GT files
if opts.includeSegmentation
    imdb.paths.classSegmentation = esc(fullfile(opts.dataDir, 'masks', '%07d.png')) ;
end

% Compress data types
imdb.images.id = uint32(imdb.images.id) ;
imdb.images.set = uint8(imdb.images.set) ;
for i=1:1
    imdb.classes.images{i} = uint32(imdb.classes.images{i}) ;
end

% Check images on disk and get their size
imdb = getImageSizes(imdb);

% -------------------------------------------------------------------------
function [imdb] = addImageSet(imdb, setCode, gt) % need to take care of the validation split
% -------------------------------------------------------------------------
j = length(imdb.images.id) ;
for i=1:length(gt)
    j = j + 1;
    imdb.images.id(j) = j;
    imdb.images.set(j) = setCode ;
    imdb.images.name{j} = gt{i}.video_name;
    imdb.images.classification(j) = true ;
    imdb.images.segmentation(j) = true ;
    % because in slice image, there are both background and action classes
    % simultaneously.
    imdb.classes.images{1}(end+1) = j;
%     imdb.classes.images{2}(end+1) = j;
end

% -------------------------------------------------------------------------
function imdb = getImageSizes(imdb)
% -------------------------------------------------------------------------
for j=1:numel(imdb.images.id)
    info = imfinfo(sprintf(imdb.paths.image, imdb.images.name{j})) ;
    imdb.images.size(:,j) = uint16([info.Width ; info.Height]) ;
    fprintf('%s: checked image %d [%d x %d]\n', mfilename, imdb.images.name{j}, info.Height, info.Width) ;
end

% -------------------------------------------------------------------------
function str = esc(str)
% -------------------------------------------------------------------------
str = strrep(str, '\', '\\') ;
