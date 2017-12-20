function predict2txt()
file_out = fopen('test_tmp2.txt', 'w');
fileID = fopen('output_test_640.csv', 'r');

whole_line = textscan(fileID, '%s');
line_num = size(whole_line{1}, 1);
this_image_name = ' ';
valid_img_signal = 0;
if_train = 0;
actual_car_num = 0;
for i = 1:line_num
    strtmp = whole_line{1}{i};
    csv_cell = textscan(strtmp, '%s %f %f %f %f %f', 'delimiter', ',');
    jpg_name = strsplit(csv_cell{1}{1}, '/');
    jpg_name_size = size(jpg_name, 2);
    if size(jpg_name{jpg_name_size}, 2) == 14 % valid
        img_tmpname = strrep(csv_cell{1}{1}, 'data/deploy', 'dataset');
        if strcmp(img_tmpname, this_image_name) == 0
            if strcmp(this_image_name, ' ') ==0
                %%
                sp = textscan(this_image_name, '%s', 'delimiter', '/');
                str_to_write = [sp{1}{4}, '/', strrep(sp{1}{5}, '_image.jpg', ''), ',' int2str(car_num)];
                if if_train == 1
                    for k = 1:size(bbox, 1)
                        b = bbox(k, :);
                        ignore_in_eval = logical(b(11));
                        if ignore_in_eval ~= 1
                            actual_car_num = actual_car_num + 1;
                        end
                    end
                    str_to_write = [str_to_write, ',',int2str(actual_car_num)];
                    actual_car_num = 0;
                end
                fprintf(file_out, str_to_write);
                fprintf(file_out, '\r\n');
            end
            %%
            img = imread(img_tmpname);
            this_image_name = img_tmpname;
            %imshow(img)
            row = size(img, 1);
            col = size(img, 2);
            xyz = memmapfile(strrep(img_tmpname, '_image.jpg', '_cloud.bin'), ...
                'format', 'single').Data;
            xyz = reshape(xyz, [numel(xyz) / 3, 3])';
            proj = memmapfile(strrep(img_tmpname, '_image.jpg', '_proj.bin'), ...
                'format', 'single').Data;
            proj = reshape(proj, [4, 3])';
            depth_graph = dist_estimate(row, col, xyz, proj);
            map3d = map_point(xyz, proj);
            car_num = 0;
            if if_train == 1
                try
                    bbox = memmapfile(strrep(img_tmpname, '_image.jpg', '_bbox.bin'), ...
                    'format', 'single').Data;
                catch
                    disp('[*] no bbox found.')
                    bbox = single([]);
                end
                bbox = reshape(bbox, [11, numel(bbox) / 11])';
            end
        end
        valid_img_signal = 1;
    else
        valid_img_signal = 0;
    end
    if valid_img_signal == 1
        xmin = max(csv_cell{2}, 1);
        xmax = min(csv_cell{3}, col);
        ymin = max(csv_cell{4}, 1);
        ymax = min(csv_cell{5}, row);
        confidence = csv_cell{6};
        crop = depth_graph(ymin:ymax, xmin:xmax);
        ymid = round((ymax+ymin)/2);xmid = round((xmax+xmin)/2);
        crop1 = depth_graph(ymid:ymax, xmid:xmax);B1 = crop1 > 0;
        crop2 = depth_graph(ymin:ymid, xmin:xmid);B2 = crop2 > 0;
        crop3 = depth_graph(ymid:ymax, xmin:xmid);B3 = crop3 > 0;
        crop4 = depth_graph(ymin:ymid, xmid:xmax);B4 = crop4 > 0;
        get_crop_sep_var = get_4_var(sum(sum(crop1)), sum(sum(crop2)), sum(sum(crop3)), sum(sum(crop4)),sum(sum(B1)), sum(sum(B2)), sum(sum(B3)), sum(sum(B4)));
        B = crop > 0;
        if sum(sum(B)) ~= 0
            aver_dist = sum(sum(crop))/sum(sum(B));
        else
            aver_dist = 1000;
        end
        %z_inspect = [];
        %for index1 = xmin:xmax
        %    for index2 = ymin:ymax
        %        index1
        %        index2
        %        isempty(map3d{index2}{index1})
        %        if size(map3d{index2}{index1}) == 0
        %        else
        %            z_inspect = [z_inspect, map3d{index2}{index1}];
        %        end
        %    end
        %end
        %max_pt = max(z_inspect');
        %min_pt = min(z_inspect');
        %xyz_dist = max_pt - min_pt;
        %volumn = xyz_dist(1, 1)*xyz_dist(1, 2)*xyz(1,3)
        if confidence >= 0.35 
            if (aver_dist <= 60 && get_crop_sep_var <= 300)
                car_num = car_num+1;
            elseif (get_crop_sep_var >= 300 && max(get_crop_sep_var)<= 60)
                car_num = car_num+1;
            end
        end
    end
end
sp = textscan(this_image_name, '%s', 'delimiter', '/');
str_to_write = [sp{1}{4}, '/', strrep(sp{1}{5}, '_image.jpg', ''), ',', int2str(car_num)];
if if_train == 1
    for k = 1:size(bbox, 1)
        b = bbox(k, :);
        ignore_in_eval = logical(b(11));
        if ignore_in_eval ~= 1
            actual_car_num = actual_car_num + 1;
        end
    end
    str_to_write = [str_to_write, ',',int2str(actual_car_num)];
    actual_car_num = 0;
end
fprintf(file_out, str_to_write);
fprintf(file_out, '\r\n');
fclose(file_out);
end

function xy_dist = dist_estimate(row, col, xyz, proj_mat)
xy_dist = zeros(row, col);
uv = proj_mat * [xyz; ones(1, size(xyz, 2))];
uv = uv ./ uv(3, :);
size(uv);
for i = 1:size(uv, 2)
    x = round(double(uv(1, i)));
    y = round(double(uv(2, i)));
    
    xy_dist(y+1, x+1) = sqrt(sum(xyz(:, i).^2));
end
end

function map3d = map_point(xyz, proj_mat)
    uv = proj_mat * [xyz; ones(1, size(xyz, 2))];
    uv = uv ./ uv(3, :);
    for i = 1:size(uv, 2)
        x = round(double(uv(1, i)));
        y = round(double(uv(2, i)));
        map3d{y+1}{x+1} = xyz(:, i);
    end
end

function get_sep_var = get_4_var(sum1, sum2, sum3, sum4, b1, b2, b3, b4)
l1 = [];
if b1 ~= 0
    l1 = [l1, sum1/b1];
end
if b2 ~= 0
    l1 = [l1, sum2/b2];
end
if b3 ~= 0
    l1 = [l1, sum3/b3];
end
if b4 ~= 0
    l1 = [l1, sum4/b4];
end
get_sep_var = var(l1);
end
