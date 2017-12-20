function max_diff_dis = max_distance(map_3D,x_min,y_min,x_max,y_max)
max_diff_dis = -1;
info = [];
for xx = x_min:x_max
    for yy = y_min:y_max
        if isempty(map_3D{yy,xx}) == 0
            info = [info,map_3D{yy,xx}];
        end
    end
end

if isempty(info)
    max_diff_dis = 0;
else
    
    for ii = 1:size(info,2)
        for jj = ii + 1:size(info,2)
            temp = sqrt(sum((info(:,ii)-info(:,jj)).^2));
            if temp > max_diff_dis
                max_diff_dis = temp;
            end
        end
    end
end
end