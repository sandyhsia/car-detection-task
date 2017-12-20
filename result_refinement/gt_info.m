function [ gt] = gt_info()

classes = {'Unknown', 'Compacts', 'Sedans', 'SUVs', 'Coupes', ...
    'Muscle', 'SportsClassics', 'Sports', 'Super', 'Motorcycles', ...
    'OffRoad', 'Industrial', 'Utility', 'Vans', 'Cycles', ...
    'Boats', 'Helicopters', 'Planes', 'Service', 'Emergency', ...
    'Military', 'Commercial', 'Trains'};

% Data route
files = dir('deploy/trainval/*/*.jpg');
[nums,~] = size(files);
count = 1;
gt=[];
for idx = 1:nums
    
    folder_name = strsplit(files(idx).folder,'/');
    name = [folder_name{end},'/',files(idx).name];
    
    snapshot = [files(idx).folder, '/', files(idx).name];
    
    img = imread(snapshot);
    [img_h,img_w] = size(img);
    
    xyz = memmapfile(strrep(snapshot, '_image.jpg', '_cloud.bin'), ...
        'format', 'single').Data;
    xyz = reshape(xyz, [numel(xyz) / 3, 3])';
    
    proj = memmapfile(strrep(snapshot, '_image.jpg', '_proj.bin'), ...
        'format', 'single').Data;
    proj = reshape(proj, [4, 3])';
    
    try
        bbox = memmapfile(strrep(snapshot, '_image.jpg', '_bbox.bin'), ...
            'format', 'single').Data;
    catch
        continue;
    end
    bbox = reshape(bbox, [11, numel(bbox) / 11])';
    
    uv = proj * [xyz; ones(1, size(xyz, 2))];
    uv = uv ./ uv(3, :);
    clr = sqrt(sum(xyz.^2, 1));
    x=[];
    y=[];
    for k = 1:size(bbox, 1)
        b = bbox(k, :);
        
        n = b(1:3);
        theta = norm(n, 2);
        n = n / theta;
        R = rot(n, theta);
        t = reshape(b(4:6), [3, 1]);
        
        sz = b(7:9);
        [vert_3D, edges] = get_bbox(-sz / 2, sz / 2);
        vert_3D = R * vert_3D + t;
        
        vert_2D = proj * [vert_3D; ones(1, 8)];
        vert_2D = vert_2D ./ vert_2D(3, :);
        
        
        temp_x=[];
        temp_y=[];
        for i = 1:size(edges, 2)
            e = edges(:, i);
            temp = vert_2D(1, e);
            temp_x=[temp_x,temp(1)];
            temp_x=[temp_x,temp(2)];
            
            temp = vert_2D(2, e);
            temp_y=[temp_y,temp(1)];
            temp_y=[temp_y,temp(2)];
        end
        
        ignore_in_eval = logical(b(11));
        max_x = max(temp_x);
        max_y = max(temp_y);
        min_x = min(temp_x);
        min_y = min(temp_y);
        
        if min_x <= 0
            min_x = 1;
        end
        
        if min_y <= 0
            min_y = 1;
        end
        
        if max_x > img_w
            max_x = img_w;
        end
        
        if max_y > img_h
            max_y = img_h;
        end
        
        if ignore_in_eval
            gt.label(count) = 0;
            gt.xmin(count)= min_x;
            gt.ymin(count)= min_y;
            gt.xmax(count)= max_x;
            gt.ymax(count)= max_y;
            gt.name{count} = name;
            count = count + 1;
        else
            gt.label(count) = 1;
            gt.xmin(count)= min_x;
            gt.ymin(count)= min_y;
            gt.xmax(count)= max_x;
            gt.ymax(count)= max_y;
            gt.name{count} = name;
            count = count + 1;
        end
    end
end

end

function [v, e] = get_bbox(p1, p2)
v = [p1(1), p1(1), p1(1), p1(1), p2(1), p2(1), p2(1), p2(1)
    p1(2), p1(2), p2(2), p2(2), p1(2), p1(2), p2(2), p2(2)
    p1(3), p2(3), p1(3), p2(3), p1(3), p2(3), p1(3), p2(3)];
e = [3, 4, 1, 1, 4, 4, 1, 2, 3, 4, 5, 5, 8, 8
    8, 7, 2, 3, 2, 3, 5, 6, 7, 8, 6, 7, 6, 7];
end


function R = rot(n, theta)
n = n / norm(n, 2);
K = [0, -n(3), n(2); n(3), 0, -n(1); -n(2), n(1), 0];
R = eye(3) + sin(theta) * K + (1 - cos(theta)) * K^2;
end
