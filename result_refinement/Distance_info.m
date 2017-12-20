function [ max_d, min_d, mean_d,mean_gradient,max_gradient] = Distance_info(map_3D,x_min,y_min,x_max,y_max,d)


if isempty(d)
    max_d = 0;
    min_d = 0;
    mean_d = 0;
     mean_gradient = 0;
     max_gradient = 0;
else
    max_d = max(d);
    min_d = min(d);
    mean_d = mean(d);
    diff_d = zeros(max(size(d))-1,1);
    for ii = 1:max(size(d))-1
        diff_d(ii) = d(ii+1)-d(ii);
    end
    mean_gradient = mean(diff_d);
    max_gradient = max(diff_d);
end
end