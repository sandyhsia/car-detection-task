function [ gt ] = add_gt_score( gt,predict )
% find score

gt = preprocess_data(gt);

for ii = 1:size(gt.xmax,2)

    file_name = gt.name(ii);
    idx = [];
    found = 0;
    for jj = 1:size(predict,1)
        if (found == 0 && ~isempty(idx))
            break;
        else
            if strcmp(file_name,predict.name(jj))
                found = 1;
                idx = [idx,jj];
            else
                if found == 1
                    found = 0;
                end
            end
            
        end
    end
    min_distance = inf;
    min_idx = 0;
    xmin = gt.xmin(ii);
    ymin = gt.ymin(ii);
    xmax = gt.xmax(ii);
    ymax = gt.ymax(ii);
    for kk = 1:length(idx)
        temp_xmin = predict.xmin(idx(kk));
        temp_ymin = predict.ymin(idx(kk));
        temp_xmax = predict.xmax(idx(kk));
        temp_ymax = predict.ymax(idx(kk));
        
        local_distance = distance(xmin,ymin,xmax,ymax,temp_xmin,temp_ymin,temp_xmax,temp_ymax);
        if local_distance < min_distance
            min_distance = local_distance;
            min_idx = idx(kk);
        end
    end
    
    if min_distance < 80
        gt.score(ii) = predict.score(min_idx);
    end
end

function d = distance(xmin1,ymin1,xmax1,ymax1,xmin2,ymin2,xmax2,ymax2)
xc1 = (xmin1 + xmax1)/2;
yc1 = (ymin1 + ymax1)/2;
xc2 = (xmin2 + xmax2)/2;
yc2 = (ymin2 + ymax2)/2;
d = sqrt((xc1-xc2)^2 + (yc1 - yc2)^2);
end

end

