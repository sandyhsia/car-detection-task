function [rms_x,rms_y,rms_z,rms_d,std_x,std_y,std_z,std_d] = map_var(map_3D,x_min,y_min,x_max,y_max,info)


if isempty(info)
    rms_x = 0;
    rms_y = 0;
    rms_z = 0;
    rms_d = 0;
    std_x = 0;
    std_y = 0;
    std_z = 0;
    std_d = 0;
else
    rms_x = rms(info(1,:));
    rms_y = rms(info(2,:));
    rms_z = rms(info(3,:));
    std_x = std(info(1,:));
    std_y = std(info(2,:));
    std_z = std(info(3,:));
    
    len = size(info,2);
    d = ones(len,1);
    for ii = 1:len
        d(ii) = sqrt(sum(info(:,ii).^2));
    end
    rms_d = rms(d);
    std_d = std(d);
end

end