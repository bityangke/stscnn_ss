function generate_segmentation_masks_THUMOS14(slice_image_path, gt, thumos14_videos, segmentation_mask_path)

if exist(segmentation_mask_path)
    return
else
    mkdir(segmentation_mask_path)
end

img_file_list = dir(fullfile(slice_image_path,'*x145.jpg'));

for i=1:length(img_file_list)
     filename = img_file_list(i).name;
     tmp = strsplit(filename, '_');
     file_index = str2num(tmp{3});

     % find index of gt matched to the file
     for j=1:length(gt)
         if gt{j}.video_name == file_index
             gt_index = j;
             gt_start_points = gt{j}.start;
             gt_end_points = gt{j}.end;
             break;
         end            
     end
     
     % find fps of the video file
     fps = thumos14_videos(gt{gt_index}.video_name).frame_rate_FPS;
     gt_start_frames = uint32(gt_start_points*fps);
     gt_start_frames(find(gt_start_frames==0)) = 1;
     gt_end_frames = uint32(gt_end_points*fps);
     
     % find the width and height of the S-T slice image
     info = imfinfo(fullfile(slice_image_path, filename));
     width = info.Width;
     height = info.Height;
     
     % generate a mask image
     gt_mask = zeros(height, width,3);
     for j=1:length(gt_start_frames)
        gt_mask(:,gt_start_frames(j):gt_end_frames(j),1) = 0.5020;% which value the label should be?
        if (gt_start_frames(j) == 0) || (gt_start_frames(j) == 1)
            gt_mask(:,1,:) = 1;
        else
            gt_mask(:,gt_start_frames(j)-1,:) = 1;
        end
        if (gt_end_frames(j) == width) || (gt_end_frames(j)+1 == width)
            gt_mask(:,gt_end_frames(j),:) = 1; 
        else
            gt_mask(:,gt_end_frames(j)+1,:) = 1;
        end 
     end
    [gt_ind, gt_map] = rgb2ind(gt_mask,2);
    
%     gt_mask = zeros(height, width);
%      for j=1:length(gt_start_frames)
%         gt_mask(:,gt_start_frames(j):gt_end_frames(j)) = 1;% which value the label should be?
%         if (gt_start_frames(j) == 0) || (gt_start_frames(j) == 1)
%             gt_mask(:,1) = 255;
%         else
%             gt_mask(:,gt_start_frames(j)-1) = 255;
%         end
%         if (gt_end_frames(j) == width) || (gt_end_frames(j)+1 == width)
%             gt_mask(:,gt_end_frames(j)) = 255; 
%         else
%             gt_mask(:,gt_end_frames(j)+1) = 255;
%         end 
%      end
%      gt_map = [0 0 0; 0.5020 0 0];
%     [gt_ind, gt_map] = rgb2ind(gt_mask,2);
%      subplot(2,1,1);
%      imshow(gt_mask);
%      im=imread(fullfile(slice_image_path,filename));
%      subplot(2,1,2);
%      imshow(im);

     imwrite(gt_ind, gt_map, fullfile(segmentation_mask_path, sprintf('%07d.png',gt{gt_index}.video_name)));     
end
