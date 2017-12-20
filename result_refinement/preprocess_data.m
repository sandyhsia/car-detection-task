function [ test] = preprocess_data( test )
test.xmin = test.xmin + 1;
test.ymin = test.ymin + 1;
test.xmax = test.xmax + 1;
test.ymax = test.ymax + 1;

for ii = 1:size(test,1)
    name_split = strsplit(test.name{ii},'/');
    test.name{ii} = [name_split{end-1},'/',name_split{end}];
end


%change directory here!
snapshot = ['deploy/*/',test.name{1}];

img = imread(snapshot);
[h,w] = size(img);
[ind] = find(test.xmin <1);
test.xmin(ind) = 1;

[ind] = find(test.ymin <1);
test.ymin(ind) = 1;

[ind] = find(test.xmax >= w);
test.xmax(ind) = w;

[ind] = find(test.ymax >= h);
test.ymax(ind) = h;



end

