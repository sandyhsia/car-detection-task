import glob
import os
import shutil
from lxml import etree
files = glob.glob('./trainval_annotation/Subset0/*')
i = 0;
for file in files:

	label = open(file)
	data = label.read().split();
	if len(data) < 8:
		continue

	# root = ET.Element("annotation", verified = "yes")

	# folder = ET.SubElement(root, "folder")
	# folder.text = "images"
	# filename = ET.SubElement(root, "filename")
	# filename.text = file.replace("./trainval_annotation/", "./images/").replace('.txt', '_image.jpg')

	# tree = ET.ElementTree(root)
	# tree.write(file.replace('./trainval_annotation/','./annotations/').replace('.txt', '.xml'), prettyprint = True)
	
	root = etree.Element("annotation", verified = "yes")
	folder = etree.SubElement(root, "folder")
	folder.text = "images"
	filename = etree.SubElement(root, "filename")
	filename.text = file.replace("./trainval_annotation/Subset0/", "").replace('.txt', '_image.jpg')
	filepath = etree.SubElement(root, "path")
	filepath.text = file.replace("./trainval_annotation/", "./images/").replace('.txt', '_image.jpg')
	
	source = etree.SubElement(root, "source")
	database = etree.SubElement(source, "database")
	database.text = "Unknown"

	size = etree.SubElement(root, "size")
	width = etree.SubElement(size, "width")
	width.text = data[0]
	height = etree.SubElement(size, "height")
	height.text = data[1]
	depth = etree.SubElement(size, "depth")
	depth.text = data[2]

	segmented = etree.SubElement(root, "segmented")
	segmented.text = "0"

	num_obj = len(data)/6
	for i in range(num_obj):
		obj = etree.SubElement(root, "object")
		name = etree.SubElement(obj, "name")
		name.text = "car"
		pose = etree.SubElement(obj, "pose")
		pose.text = "Unspecified"
		truncated = etree.SubElement(obj, "truncated")
		truncated.text = "0"
		difficult = etree.SubElement(obj, "difficult")
		difficult.text = "0"

		bndbox = etree.SubElement(obj, "bndbox")
		xmin = etree.SubElement(bndbox, "xmin")
		xmin.text = str(int(float(data[2+i*6+3])))
		ymin = etree.SubElement(bndbox, "ymin")
		ymin.text = str(int(float(data[2+i*6+4])))
		xmax = etree.SubElement(bndbox, "xmax")
		xmax.text = str(int(float(data[2+i*6+5])))
		ymax = etree.SubElement(bndbox, "ymax")
		ymax.text = str(int(float(data[2+i*6+6])))

	tree = etree.ElementTree(root)
	tree.write(file.replace('./trainval_annotation/','./annotations/').replace('.txt', '.xml'), pretty_print = True)


print i
