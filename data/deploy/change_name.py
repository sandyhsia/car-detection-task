import glob
import os
import shutil

folders = glob.glob('./trainval/Subset0/*')
i = 0;
for folder in folders:
	images = glob.glob(folder + '/*.jpg')
	for image in images:
		i+=1;
		# print  folder.replace('./trainval/', '') + '_' + image.replace(folder+'/', '')
		image_path = folder.replace('./trainval/', './images/') + '_' + image.replace(folder+'/', '')
		shutil.copy(image, image_path)
		
	# os.rename(folder+'/000000_image.jpg', folder.replace('./trainval/', '')+'.jpg')
	# i+=1
	# print i
print i