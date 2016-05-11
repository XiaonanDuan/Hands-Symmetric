function V = findNewV(B)
	n = size(B, 1);
	maxBlobs = size(B, 2);
	V = zeros(n, maxBlobs);

	for i = 1:n 
		for j = 1:maxBlobs
			if isempty(B{i,j}) == 0
				V(i,j) = size(B{i,j}, 1);
			end
		end
	end
