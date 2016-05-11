function BB = face_BB(s)
	n = length(s);
	BB = cell(n,1);

	for i = 1:n
		bb = facedetection(s(i).cdata);
		BB{i} = bb;
	end

save('Face_BoundingBox', 'BB');