%Step 1, extract bbox info mation for training data

gt = gt_info(); % you may change data route

%Step 2, Add confidence level to ground truth accourding to trained Yolo
%model's prediction on training set

% Import CSV (prediction on training set)
% name first  coloum: name
%      second coloum: xmin
%      Third  coloum: xmax
%      Fourth coloum: ymin
%      Fifth  coloum: ymax
%      name the data as predict
%You may just loaded the 'predict.map'

gt = add_gt_score(gt,predict); % you may change the directory in the code

%Add Lidar features
training_data =  add_Lidar_Feature(gt);

%Save training set as csv for further machine learning training
write_training_feature(training_data);

%Prepare prediction features
%Import the csv file from yolo prediction
% you can import "output.csv"
% Name each coloum the same as before, add one more coloum score
% Name the data as test_file
% You may just load the prepared output.mat, name it as test_file

test_file =  preprocess_data(test_file);

% Add Lidar Feature
predict = add_predict_features(test_file);

%Write it into csv
write_test_feature(test_file,predict);