function [ histfeatures ] = histogram_feature( info ,d)

if isempty(info)
    histfeatures.med_x = 0;
    histfeatures.med_y = 0;
    histfeatures.med_z = 0;
    histfeatures.med_d = 0;
    
    histfeatures.r1 = 0;
    histfeatures.r2 = 0;
    histfeatures.r3 = 0;
    histfeatures.r4 = 0;
    histfeatures.r5 = 0;
    
    histfeatures.val1 = 0;
    histfeatures.val2 = 0;
    histfeatures.val3 = 0;
    histfeatures.val4 = 0;
    histfeatures.val5 = 0;
    
    histfeatures.hist_div = 0;
else
    x = info(1,:);
    y = info(2,:);
    z = info(3,:);
    
    histfeatures.med_x = median(x);
    histfeatures.med_y = median(y);
    histfeatures.med_z = median(z);
    histfeatures.med_d = median(d);
    
    [hist_count,hist_val] = hist(d,5);
    histfeatures.r1 = hist_count(1)/sum(hist_count);
    histfeatures.r2 = hist_count(2)/sum(hist_count);
    histfeatures.r3 = hist_count(3)/sum(hist_count);
    histfeatures.r4 = hist_count(4)/sum(hist_count);
    histfeatures.r5 = hist_count(5)/sum(hist_count);
    
    histfeatures.val1 = hist_val(1);
    histfeatures.val2 = hist_val(2);
    histfeatures.val3 = hist_val(3);
    histfeatures.val4 = hist_val(4);
    histfeatures.val5 = hist_val(5);
    
    [~,sorted_val] = sort(hist_val,'descend');
    
    histfeatures.hist_div = hist_val(sorted_val(1)) - hist_val(sorted_val(2));
    
end
end

