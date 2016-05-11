function BB = boundbox(B)
	sz = size(B);
	n = sz(1);
	maxblobs = sz(2);
	BB = cell(n,maxblobs);

	for i = 1:n
		for j = 1:maxblobs
			points = B{i,j};
			if isempty(points) == 0
				minp = min(points);
				minx = minp(2);
				miny = minp(1);
				maxp = max(points);
				maxx = maxp(2);
				maxy = maxp(1);

				BB{i,j} = [minx, miny, maxx-minx, maxy-miny];
			end
		end
	end

save('BoundingBox', 'BB');
