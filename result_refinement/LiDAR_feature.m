function [ feature ] = LiDAR_feature( map_3D,x_min,y_min,x_max,y_max,info,d,v,count)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

d = double(d);
info = double(info);
v = double(v);

[max_d,min_d,mean_d,mean_gradient,max_gradient] =  Distance_info(map_3D,x_min,y_min,x_max,y_max,d);
op = Occupancy(map_3D,x_min,y_min,x_max,y_max,count);
%max_diff_dis = max_distance(map_3D,x_min,y_min,x_max,y_max);
[rms_x,rms_y,rms_z,rms_d,std_x,std_y,std_z,std_d] = map_var(map_3D,x_min,y_min,x_max,y_max,info);
[length,width,height,max_diff_dis,v_size] = object_size(map_3D,x_min,y_min,x_max,y_max,info);

feature.max_distance = max_d;
feature.min_distance = min_d;
feature.mean_distance = mean_d;
feature.occupancy = op;
feature.distance_diff = max_diff_dis;
feature.length = length;
feature.rms_length = rms_x;
feature.width = width;
feature.rms_width = rms_y;
feature.height = height;
feature.rms_height = rms_z;
feature.rms_distance = rms_d;
feature.size = v_size;
feature.std_length = std_x;
feature.std_width = std_y;
feature.std_height = std_z;
feature.std_distance = std_d;
feature.mean_gradient = mean_gradient;
feature.max_gradient = max_gradient;
if isinf(max_d/max_diff_dis)
    feature.dist_ratio = 200;
else
    feature.dist_ratio = max_d/max_diff_dis;
end
feature.visible = visuability(map_3D,x_min,y_min,x_max,y_max,v);

hist_feature = histogram_feature(info ,d);



aa = fieldnames(hist_feature);
for ii = 1:max(size(aa))
    feature.(aa{ii}) = hist_feature.(aa{ii});
end

end

