# ROB599 Perception Project
# Team 19: Dr Stanley and his assistants
The following instructions show how to run the car detection project. We have tested on our computer that the following works, but we cannot make sure the environment of your computer is the same as ours. Thus, you might need to modify a little bit such as the file path to make this run.

***************************
Step 0: Package Preparation
***************************
Install the following packages required for running the program:
0. Ubuntu 16.04 or higher
1. Python 2.7.12
2. Cuda 8.0
3. Cudnn 6.0
4. Tensorflow >=1.2.0
5. Keras 2.1.2
6. OpenCV 3.2.0
7. libhdf5
8. Basic python packages such as numpy, tqdm, glob, lxml, json etc. Use pip to install if needed.

***************************
Step 1: Before Data Preprocessing
***************************
1. If you think dataset is not enough, go to ./label_generation/ and run figure_augment.m. Result images in ./aug_img/, and annotation in ./aug_img_anno/
[You MUST have the matching directory in .m when you run it.]
2. Use ./label_generation/try_label.m to generate labels for images in dataset. 
[For example, if you want to generate labels for git-master/dataset/trainval/all-jpg, labels are in git-master/dataset/trainval/trainval_annotation/ in .txt format.]

**************************
Step 2: Data Preprocessing
**************************
The first thing to do is to prepare the dataset and annotations.
1. Put the training dataset into /data/deploy/trainval/, a useable dataset is on link: 
    [Initial dataset](http://umich.edu/~fcav/rob599_dataset_deploy.zip)
    [Our images](https://drive.google.com/open?id=12P386OeNPXWlFitftNmgkzMbRzzRe8lC)
    
2. Put the annotations into /data/deploy/trainval/annotations, a useable annotation set is on link: 
[Our annotation](https://drive.google.com/open?id=1jiZU7EynxJzaKo4V9dPSNHcmZtksZ0f5)
3. Run change_name.py, this will copy your training set images out of subfolders to /data/deploy/images/, and use the subfolder name as part of the file name.
4. Run label_generate.py, this will translate the raw .txt annotations into .xml annotations which are used by the program.
5. Run check_image.py, this will check each of your training set images has a label or not. Images with valid label will be copied to /data/deploy/labeled_images/

**********************
Step 3: Model Training
**********************
Train a model of the GTA cars using the YOLO network.
1. Modify config.json in a way that you wanted. To generate the same result as ours, DO NOT change input size, anchors, learning rate, and scales. Change batch size and epochs according to your GPU memory, and change the path according to the path you put the datasets.
2. Download the pre-trained weight for small features from link:
https://drive.google.com/open?id=17To0q2Ve2Msb_cKENSB1e_3j2YrnUgpe
There is no pre-trained weight for the car model, so the model starts from 0 as you train it.
3. Run "python train.py -c config.json"

****************************
Step 4: Candidate Prediction
****************************
Now you have a well-trained model, so you can detect the cars in your images!
1. If you don't want to spend time on training, you can just use our model on this link: https://drive.google.com/open?id=1Gpc0xR6M0sw90Aqw6G1ZXEzce-NzoR2W
2. Run "python predict.py -c config.json -w [your-weight-file] -i [your-image-path]"
Here, [your-weight-file] is the trained model in ".h5" format, [your-image-path] can be a folder or a single image.
3. The prediction result gives every posible car's coordinates, and is saved in output.csv, you can change the name and path in predict.py if you want.
4. For result refinement, you should put the output.csv under master_dir/result_refinement/

*************************
Step 5: Result Refinement
*************************
After Yolo, use a Machine Learning model to finally count the number of the car in each picture. (Codes are in master_dir/result_refinement/)
1. Following the instruction in Training_preparation.m (matlab) to prepare training data
2. Run train_random_forest.py (python3) to training ML model and predict results
3. Follow the instruction in combine_results.m (matlab) to get the submission version