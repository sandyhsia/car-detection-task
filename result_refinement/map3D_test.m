clc;clear;close all;
classes = {'Unknown', 'Compacts', 'Sedans', 'SUVs', 'Coupes', ...
    'Muscle', 'SportsClassics', 'Sports', 'Super', 'Motorcycles', ...
    'OffRoad', 'Industrial', 'Utility', 'Vans', 'Cycles', ...
    'Boats', 'Helicopters', 'Planes', 'Service', 'Emergency', ...
    'Military', 'Commercial', 'Trains'};

box_features = [];
non_box_features = [];
box_count = 1;
non_box_count =1;
for idx = 1:size(gt.xmax,2)
    
    % change the directory for test and training set
    snapshot = ['deploy/trainval/',gt.name{idx}];
    if mod(idx,1000) == 0
        idx
    end
    
    img = imread(snapshot);
    [img_h,img_w] = size(img);
    
    xyz = memmapfile(strrep(snapshot, '_image.jpg', '_cloud.bin'), ...
        'format', 'single').Data;
    xyz = reshape(xyz, [numel(xyz) / 3, 3])';
    
    proj = memmapfile(strrep(snapshot, '_image.jpg', '_proj.bin'), ...
        'format', 'single').Data;
    proj = reshape(proj, [4, 3])';
    
    uv = proj * [xyz; ones(1, size(xyz, 2))];
    uv = uv ./ uv(3, :);
    
    [h,w] = size(img);
    
    map_3D = cell(h,w);
    
    car_size = [];
    
    for i = 1:size(uv,2)
        p_x = round(uv(1,i));
        p_y = round(uv(2,i));
        
        if p_x <= 0
            p_x = 1;
        end
        
        if p_y <= 0
            p_y = 1;
        end
        
        if p_x > w
            p_x = w;
        end
        
        if p_y > h
            p_y = h;
        end
        
        map_3D{p_y,p_x} = xyz(:,i);
    end
    
    x_min = round(gt.xmin(idx));
    y_min = round(gt.ymin(idx));
    x_max = round(gt.xmax(idx));
    y_max = round(gt.ymax(idx));
    
    if x_min <= 0
        x_min = 1;
    end
    
    if y_min <= 0
        y_min = 1;
    end
    
    if x_max > img_w
        x_max = img_w;
    end
    
    if y_max > img_h
        y_max = img_h;
    end
    
    info = [];
    d=[];
    count = 1;
    a = tan(50/180*pi);
    l = 3.0;
    v = [];
    for xx = x_min:x_max
        for yy = y_min:y_max
            if isempty(map_3D{yy,xx}) == 0
                info = [info,map_3D{yy,xx}];
                d=[d, sqrt(sum(map_3D{yy,xx}.^2))];
                count = count+1;
                temp_max = max(0,a^2*map_3D{yy,xx}(1)^2 - l^2);
                v = [v,map_3D{yy,xx}(3)-temp_max];
            end
        end
    end
    
    if ~isempty(info)
        box_feature = LiDAR_feature(map_3D,x_min,y_min,x_max,y_max,info,d,v,count);
        box_feature.label = gt.label(idx);
        box_feature.x_ratio = (gt.xmax(idx) - gt.xmin(idx))/img_w;
        box_feature.y_ratio = (gt.ymax(idx) - gt.ymin(idx))/img_h;
        box_feature.area_ratio = (gt.xmax(idx) - gt.xmin(idx))*(gt.ymax(idx) - gt.ymin(idx))/(img_w*img_h);
        if gt.score(idx) == 0
            box_feature.score = nan;
        else
            box_feature.score = gt.score(idx);
        end
        box_features{box_count} = box_feature;
        box_count = box_count+1;
    else
        box_feature.label = gt.label(idx);
        box_feature.x_ratio = (gt.xmax(idx) - gt.xmin(idx))/img_w;
        box_feature.y_ratio = (gt.ymax(idx) - gt.ymin(idx))/img_h;
        box_feature.area_ratio = (gt.xmax(idx) - gt.xmin(idx))*(gt.ymax(idx) - gt.ymin(idx))/(img_w*img_h);
        if gt.score(idx) == 0
            box_feature.score = nan;
        else
            box_feature.score = gt.score(idx);
        end
        non_box_features{non_box_count} = box_feature;
        non_box_count = non_box_count + 1;
    end
    
    
end


function r = over_lap(min_x,min_y,max_x,max_y,global_map)

width = max_x - min_x + 1;
height = max_y - min_y + 1;

local_map = zeros(height,width);

[g_h,g_w] = size(global_map);

if min_x <= 0
    min_x = 1;
end

if min_y <= 0
    min_y = 1;
end

if max_x > g_w
    max_x = g_w;
end

if max_y > g_h
    max_y = g_h;
end


for ii = min_x:max_x
    for jj = min_y:max_y
        local_map(jj-min_y+1,ii-min_x+1) = global_map(jj,ii);
    end
end

count = 1 + sum(sum(local_map));
r = count/(width*height);

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
