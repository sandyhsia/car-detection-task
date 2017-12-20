function [ box_features ] = add_test_feature( test_predict )
box_features = [];
non_box_features = [];
box_count = 1;
non_box_count =1;
file_name = [];
non_file_name = [];
for idx = 1:size(test_predict.label,2)
    
    
    %Change route here!!!
    snapshot = ['deploy/test/',test_predict.name{idx}];
    name = test_predict.name{idx}(1:end-10);
    if exist(snapshot, 'file') == 0
        continue;
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
    
    map_3D = cell(img_h,img_w);
    
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
        
        if p_x > img_w
            p_x = img_w;
        end
        
        if p_y > img_h
            p_y = img_h;
        end
        
        map_3D{p_y,p_x} = xyz(:,i);
    end
    
    x_min = test_predict.xmin(idx);
    y_min = test_predict.ymin(idx);
    x_max = test_predict.xmax(idx);
    y_max = test_predict.ymax(idx);
    
    
    minfo = [];
    d=[];
    count = 1;
    a = tan(50/180*pi);
    l = 3.0;
    v = [];
    for xx = x_min:x_max
        for yy = y_min:y_max
            if isempty(map_3D{yy,xx}) == 0
                minfo = [minfo,map_3D{yy,xx}];
                d=[d, sqrt(sum(map_3D{yy,xx}.^2))];
                count = count+1;
                temp_max = max(0,a^2*map_3D{yy,xx}(1)^2 - l^2);
                v = [v,map_3D{yy,xx}(3)-temp_max];
            end
        end
    end
    
    if ~isempty(minfo)
        box_feature = LiDAR_feature(map_3D,x_min,y_min,x_max,y_max,minfo,d,v,count);
        box_feature.x_ratio = (test_predict.xmax(idx) - test_predict.xmin(idx))/img_w;
        box_feature.y_ratio = (test_predict.ymax(idx) - test_predict.ymin(idx))/img_h;
        box_feature.area_ratio = (test_predict.xmax(idx) - test_predict.xmin(idx))*(test_predict.ymax(idx) - test_predict.ymin(idx))/(img_w*img_h);
        box_feature.score = test_predict.score(idx);
        box_features{box_count} = box_feature;
        file_name{box_count} = name;
        box_count = box_count+1;
        
    else
        non_file_name{non_box_count} = name;
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


end

