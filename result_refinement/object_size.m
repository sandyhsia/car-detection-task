function [length,width,height,diff_d,v_size] = object_size(map_3D,x_min,y_min,x_max,y_max,info)

if isempty(info)
    length = 0.1;
    width = 0.1;
    height = 0.1;
    diff_d = 0.01;
    v_size = 0.1^3;
else
    length = max(info(1,:)) - min(info(1,:));
    width = max(info(2,:)) - min(info(2,:));
    height = max(info(3,:)) - min(info(3,:));
    diff_d = sqrt(length^2+width^2+height^2);
    v_size = length*width*height;
end
end