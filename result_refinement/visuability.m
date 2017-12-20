function v_id = visuability(map_3D,x_min,y_min,x_max,y_max,v)


if isempty(v)
    v_id = -5;
else
    v_id = mean(v);
end

end
