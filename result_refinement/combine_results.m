%Count vehicle number
% Import the prediction file
% name it as prediction
% name the first coloum name
% name the second coloum as label
% Sample input "test_file_names.csv"

ori = prediction.name{1};
next = 0;
results = [];
count = 0;
sample = 1;
for i = 1:size(prediction,1)
    now = prediction.name{i};
    if ~strcmp(ori,now)
        results.name{sample} = ori;
        results.count(sample) = count;
        sample = sample+1;
        ori = now;
        count = prediction.label(i);
    else
        count = count + prediction.label(i);
    end
end
results.name{sample} = ori;
results.count(sample) = count;

% You need to change the test image route here
files = dir('deploy/test/*/*.jpg');
for i = 1:max(size(files))
    folders=files(i).folder;
    names = strsplit(folders,'/');
    combined_name = [names{end},'/',files(i).name];
    final_name = combined_name(1:end-10);
    found = 0;
    for j = 1:max(size(results.count))
        if strcmp(final_name,results.name{j})
            found = 1;
            break;
        end
    end
    
    if found == 0
        next = max(size(results.count)) + 1;
        results.name{next} = final_name;
        results.count(next) = 0;
    end
end

%save the results as the submission form
fid = fopen('submission.csv','wt');
fprintf(fid,'%s,%s\n','guid/image','N');
for ii = 1:max(size(results.count))
    fprintf(fid,'%s,%d\n',results.name{ii},results.count(ii));
end
fclose(fid);
