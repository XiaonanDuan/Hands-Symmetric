function newC = findNewCent(B, sz)
	n = size(B, 1);
	maxBlobs = size(B, 2);

	newC = zeros(n, 2*maxBlobs);

	for i = 1:n
		numBlobs = 0;

		for j = 1:maxBlobs
			if isempty(B{i,j}) == 0
				numBlobs = j;
			end
		end

		for j = 1:numBlobs
	        [cy, cx] = findRegionCentroid(B{i,j}, sz);
	        newC(i, 2*j-1) = cy;
	        newC(i, 2*j) = cx;
    	end
    end

save('NewCentroid', 'newC');