#! /usr/bin/env python
import glob
import argparse
import os
import cv2
import numpy as np
from tqdm import tqdm
from preprocessing import parse_annotation
from utils import draw_boxes
from frontend import YOLO
import json
import csv

os.environ["CUDA_DEVICE_ORDER"]="PCI_BUS_ID"
os.environ["CUDA_VISIBLE_DEVICES"]=""

argparser = argparse.ArgumentParser(
    description='Train and validate YOLO_v2 model on any dataset')

argparser.add_argument(
    '-c',
    '--conf',
    help='path to configuration file')

argparser.add_argument(
    '-w',
    '--weights',
    help='path to pretrained weights')

argparser.add_argument(
    '-i',
    '--input',
    help='path to an image or an video (mp4 format)')

def _main_(args):
 
    config_path  = args.conf
    weights_path = args.weights
    image_path   = args.input
    files = glob.glob(image_path + "*/*.jpg")
    # print files

    with open(config_path) as config_buffer:    
        config = json.load(config_buffer)

    ###############################
    #   Make the model 
    ###############################

    yolo = YOLO(architecture        = config['model']['architecture'],
                input_size          = config['model']['input_size'], 
                labels              = config['model']['labels'], 
                max_box_per_image   = config['model']['max_box_per_image'],
                anchors             = config['model']['anchors'])

    ###############################
    #   Load trained weights
    ###############################    

    print weights_path
    yolo.load_weights(weights_path)

    ###############################
    #   Predict bounding boxes 
    ###############################

    if image_path[-4:] == '.jpg':
        image = cv2.imread(image_path)

        # b, g, r = cv2.split(image)
        # # equalize the histogram of the Y channel
        # b = cv2.equalizeHist(b)
        # g = cv2.equalizeHist(g)
        # r = cv2.equalizeHist(r)
        # image_equ = cv2.merge((b, g, r))
        # image = np.multiply(np.array(image_equ),0.25) + image*0.75
        # image = image.astype("uint8")
        # image = adjust_gamma(image, gamma=0.5)

        img_hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
        if (np.mean(img_hsv[:,:,2]) < 108):
            desired_gamma = 1+(108-np.mean(img_hsv[:,:,2]))/108
            image = adjust_gamma(image, gamma=desired_gamma)
            print np.mean(img_hsv[:,:,2])

        boxes = yolo.predict(image)
        image = draw_boxes(image, boxes, config['model']['labels'])
        print len(boxes), 'boxes are found'
        
        # image = cv2.equalizeHist(image)
        for box in boxes:
                xmin  = int((box.x - box.w/2) * image.shape[1])
                xmax  = int((box.x + box.w/2) * image.shape[1])
                ymin  = int((box.y - box.h/2) * image.shape[0])
                ymax  = int((box.y + box.h/2) * image.shape[0])
                print xmin, xmax, ymin, ymax
        cv2.imwrite(image_path.replace(".jpg","_detected_equ.jpg"), image)
    else:
        # data = []
        resultFile = open("output.csv",'w')
        wr = csv.writer(resultFile, dialect='excel')
        input_size = config['model']['input_size'];
        for file in files:
            image = cv2.imread(file)
            img_hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
            if (np.mean(img_hsv[:,:,2]) < 100):
                desired_gamma = 1+(108-np.mean(img_hsv[:,:,2]))/100
                image = adjust_gamma(image, gamma=desired_gamma)
                print np.mean(img_hsv[:,:,2])
            boxes = yolo.predict(image)
            for box in boxes:
                xmin  = int((box.x - box.w/2) * image.shape[1])
                xmax  = int((box.x + box.w/2) * image.shape[1])
                ymin  = int((box.y - box.h/2) * image.shape[0])
                ymax  = int((box.y + box.h/2) * image.shape[0])
                # data.append([file.replace("image_path",""),xmin, xmax, ymin, ymax, box.get_score()])
                wr.writerow([file.replace("image_path",""),xmin, xmax, ymin, ymax, box.get_score()])

            image = draw_boxes(image, boxes, config['model']['labels'])
            print len(boxes), 'boxes are found'
            file_b = file[-20:].replace("/","_")
            file = file[:-20].replace("test", "detected")+file_b

            # cv2.imwrite(file.replace(".jpg", "_"+str(input_size)+ ".jpg"), image)

def adjust_gamma(image, gamma=1.0):
    # build a lookup table mapping the pixel values [0, 255] to
    # their adjusted gamma values
    invGamma = 1.0 / gamma
    table = np.array([((i / 255.0) ** invGamma) * 255
        for i in np.arange(0, 256)]).astype("uint8")
 
    # apply gamma correction using the lookup table
    return cv2.LUT(image, table)


if __name__ == '__main__':
    args = argparser.parse_args()
    _main_(args)
