#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec  7 11:28:14 2017

@author: yangzhang
"""
import pandas as pd
import numpy as np
import itertools
import random as ra

import string as s
from sklearn.svm import LinearSVC
from sklearn.model_selection import StratifiedKFold
from sklearn.svm import SVC
from sklearn import metrics
from matplotlib import pyplot as plt;
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn import svm
from sklearn.externals import joblib
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import Imputer

def main():
    #feature=pd.read_csv("/Users/yangzhang/Documents/UofM/Fall2017/EECS599/Project/rob599_dataset_deploy/train_feature.csv").values
    #label=pd.read_csv("/Users/yangzhang/Documents/UofM/Fall2017/EECS599/Project/rob599_dataset_deploy/train_label.csv").values
    
    #feature=pd.read_csv("/Users/yangzhang/Documents/UofM/Fall2017/EECS599/Project/rob599_dataset_deploy/features_no_score.csv").values
    #label=pd.read_csv("/Users/yangzhang/Documents/UofM/Fall2017/EECS599/Project/rob599_dataset_deploy/labels.csv").values
    feature = pd.read_csv("C:/Users/zy/Desktop/599 Training set/box_features.csv").values
    label = pd.read_csv("C:/Users/zy/Desktop/599 Training set/box_labels.csv").values
    
    imp = Imputer(missing_values=np.nan,strategy='mean',axis=0)
    imp.fit(feature)
    feature = imp.fit_transform(feature)
    
    label = np.ravel(label)
    
    best_score = 0.1
    best_n = 0
    best_feature = 0
    
    std = []
    mean_v = []
    
    for kk in range(np.shape(feature)[1]):
        temp_std = np.std(feature[:,kk])
        temp_mean = np.mean(feature[:,kk])
        std.append(temp_std)
        mean_v.append(temp_mean)
        feature[:,kk] = (feature[:,kk] - temp_mean)/temp_std
    
    X_train, X_test, y_train, y_test = train_test_split(feature, label, test_size=0.2, random_state=0)
    
    
    
    best_model = RandomForestClassifier
    tree_size = np.arange(10,200,10)
    feature_range = np.arange(2,np.shape(feature)[1],1)
   # C_range = [1]
   # gamma_range = [1]
    for m in feature_range:
        for n in tree_size:    
            clf = RandomForestClassifier(n_estimators=n,max_features=m,max_depth=None,min_samples_split=2)
            clf.fit(X_train, y_train)
            scores = cross_val_score(clf, X_train, y_train, cv=5)
            temp_score = np.mean(scores)
            #clf.score(X_test,y_test)
            if temp_score > best_score:
                best_score = temp_score
                best_n = n
                best_feature = m
                best_model = clf
            print("Feature size: = ",m, "Forest size = ",n,'')
            print("Best feature size = ",best_feature, "Best forest size = ",best_n,'')
            print("Best Score So Far :", best_score)
            filename = 'best_model_random_forest_purescore.sav'
            joblib.dump(best_model, filename)
            
   
    
    #loaded_model = joblib.load(filename)
    #test_file = pd.read_csv("C:/Users/zy/Desktop/599 Training set/predict_features_no_score.csv").values
    #for kk in range(15):
    #    test_file[:,kk] = (test_file[:,kk]-mean_v[kk])/std[kk]
        
    #test_label = best_model.predict(test_file)

    return

if __name__ == '__main__':
  main()
