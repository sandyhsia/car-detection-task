import glob
import os
import shutil
from lxml import etree
from PIL import Image

files = glob.glob('./annotations/Subset0/*')
for file in files:
	img_path = file.replace('./annotations/', './images/').replace('.xml', '_image.jpg')
	dst_path = img_path.replace('./images/', './labeled_images/')

	shutil.copy(img_path, dst_path)
	