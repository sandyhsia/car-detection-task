
fid_feature = fopen('test_box_features.csv','wt');
fid_name = fopen('test_file_names.csv','wt');
for ii = 1:size(box_features,2)
    fprintf(fid_name,'%s\n',file_name{ii});
    %fprintf(fid_label,'%d\n',names{ii});
    fprintf(fid_feature,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n',...
        box_features{ii}.max_distance,...
        box_features{ii}.min_distance,...
        box_features{ii}.mean_distance,...
        box_features{ii}.occupancy,...
        box_features{ii}.distance_diff,...
        box_features{ii}.length,...
        box_features{ii}.rms_length,...
        box_features{ii}.width,...
        box_features{ii}.rms_width,...
        box_features{ii}.height,...
        box_features{ii}.rms_height,...
        box_features{ii}.rms_distance,...
        box_features{ii}.size,...
        box_features{ii}.dist_ratio,...
        box_features{ii}.visible,...
        box_features{ii}.score,...
        box_features{ii}.med_x,...
        box_features{ii}.med_y,...
        box_features{ii}.med_z,...
        box_features{ii}.med_d,...
        box_features{ii}.r1,...
        box_features{ii}.r2,...
        box_features{ii}.r3,...
        box_features{ii}.r4,...
        box_features{ii}.r5,...
        box_features{ii}.val1,...
        box_features{ii}.val2,...
        box_features{ii}.val3,...
        box_features{ii}.val4,...
        box_features{ii}.val5,...
        box_features{ii}.hist_div,...
        box_features{ii}.x_ratio,...
        box_features{ii}.y_ratio,...
        box_features{ii}.area_ratio...
        );     
end
fclose(fid_name);
fclose(fid_feature);