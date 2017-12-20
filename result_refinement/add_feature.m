load('gt.mat');
for idx = 1:size(gt,1)
    snapshot = ['deploy/trainval/',gt.name{idx}];
    if mod(idx,1000) == 0
        idx
    end
    img = imread(snapshot);
    [img_h,img_w] = size(img);
    features{idx}.area_ratio = (gt.xmax(idx) - gt.xmin(idx))*(gt.ymax(idx) - gt.ymin(idx))/(img_w*img_h);
end

