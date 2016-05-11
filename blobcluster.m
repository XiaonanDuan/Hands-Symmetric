function Cluster = blobcluster(C)
	% C is the centroid matrix 
	% max width of C is 6
	% and if the block is empty
	% the value is 0

	% So firstly let us put the points together
	Cluster = zeros(3,2);
	maxblobs = 3;
	n = size(C,1);

	pointpool = [];
	for i = 1:n
		for j = 1:maxblobs
			if C(i, 2*j) >= 1
				y = C(i, 2*j - 1);
				x = C(i, 2*j);
				pointpool = [pointpool; y x];

			end
		end
	end



	[idx Clu] = kmeans(pointpool, 3)

	% find head
	[miny, idmy] = min(Clu(:,1));
	Cluster(1,:) = Clu(idmy, :);

	% find left hand
	[minx, idmx] = min(Clu(:,2));
	Cluster(2,:) = Clu(idmx, :);

	% find right hand
	[maxx, idmx] = max(Clu(:,2));
	Cluster(3,:) = Clu(idmx, :);

save('ClusterPoints','Cluster');