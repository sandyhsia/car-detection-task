function op = Occupancy(map_3D,x_min,y_min,x_max,y_max,count)

d_x = x_max - x_min + 1;
d_y = y_max - y_min + 1;
op = count/(d_x*d_y);
end