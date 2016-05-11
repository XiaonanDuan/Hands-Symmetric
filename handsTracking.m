function handsLabel = handsTracking(V, C, Cluster, Face_BB, s)
	% firstly let us say some main criterias
	% 1. the x distance from head eg. x - hx 
	% 2. the y distance form head eg  y - hy
	% 3. the volume difference from the last frame eg. |V(j) - V(j-1)|
	% 4. the position difference from Cluster points
	% 5. the position from last place
	n = size(Face_BB, 1);
	handsLabel = zeros(n, 2);

	% there will not operate the data from Cluster and defaultly think the points in the Cluster are [head lefthand righthand]
	meanheadpos = Cluster(1,:);
	meanlefthandpos = Cluster(2,:);
	meanrighthandpos = Cluster(3,:);

	head = struct('appear',1,'x',0,'y',0,'volume',0);
	lefthand = struct('appear',0,'x',0,'y',0,'volume',0);
	righthand = struct('appear',0,'x',0,'y',0,'volume',0);

	% generally say the head will not easily disappear so I just need to find heads first

	

	for i = 1:n
        if i >= 400
            imshow(s(i).cdata);
        end

		numblobs = 0;
		for j = 1:3
			if V(i,j) > 0
				numblobs = j;
			end
		end

		headD = [];
		
		if isempty(Face_BB{i}) == 0
			FaceBox = Face_BB{i};
		end 
		
		for j = 1:numblobs
			bloby = C(i, 2*j - 1);
			blobx = C(i, 2*j);
			facebbx = FaceBox(1) + FaceBox(3);
			facebby = FaceBox(2) + FaceBox(4);
			dis = sqrt((blobx - facebbx)^2  + (bloby - facebby)^2);
			headD = [headD dis];
		end

		% find min dis for Face
		% headlabel =
		% update face
		% headD
        
		[mind id] = min(headD);
		head.y = C(i,2*id - 1);
		head.x = C(i,2*id);
		head.volume = V(i,id);

		headlabel = id;


		% find other labels
		restlabel = [];
		for j = 1:numblobs
			if j ~= headlabel
				restlabel = [restlabel j];
			end
		end

		% calcdis for both hands
		lefthanddis = [];
		righthanddis = [];

		numrestlabels = length(restlabel);

		if numrestlabels == 0
			lefthand.appear = 0;
			lefthand.x = 0;
			lefthand.y = 0;
			lefthand.volume = 0;

			righthand.appear = 0;
			righthand.x = 0;
			righthand.y = 0;
			righthand.volume = 0;

			continue;
        end
       
        confidence = 1;
        if numrestlabels <= 1
            confidence = 1;
        else
           C1 = [C(i, 2*restlabel(1) -1), C(i, 2*restlabel(1))];
           C2 = [C(i, 2*restlabel(2) -1), C(i, 2*restlabel(2))];
           confidence = sigmoid(C1, C2);
        end
        
		for j = 1:numrestlabels
			
			cy = C(i, 2*restlabel(j) -1);
			cx = C(i, 2*restlabel(j));

			% left
			if lefthand.appear == 1

				disMean = (cy - meanlefthandpos(1))^2 + (cx - meanlefthandpos(2))^2;

				disVolume = abs(V(i, j) - lefthand.volume);

				disLast = (cy - lefthand.y)^2 + (cx - lefthand.x)^2;

				disRelated = (cx - head.x)*abs(cx - head.x);

				% I think the head must be select all right and I will not take the head mess into consider
				lefthanddis = [lefthanddis (0.5*disMean+0.25*disRelated)+confidence*(0.5*disVolume+disLast)];
                
                leftinfo = [disMean disVolume disLast disRelated lefthanddis];

			else

				disMean = (cy - meanlefthandpos(1))^2 + (cx - meanlefthandpos(2))^2;

				disRelated = (cx - head.x)*abs(cx - head.x);

				% I think the head must be select all right and I will not take the head mess into consider
				lefthanddis = [lefthanddis (0.5*disMean+disRelated)];

				leftinfo = [disMean disRelated lefthanddis];

			end


			% right
			if righthand.appear == 1

				disMean = (cy - meanrighthandpos(1))^2 + (cx - meanrighthandpos(2))^2;

				disVolume = abs(V(i, j) - righthand.volume);

				disLast = (cy - righthand.y)^2 + (cx - righthand.x)^2;

				disRelated = -(cx - head.x)*abs(cx - head.x);

				% I think the head must be select all right and I will not take the head mess into consider
				righthanddis = [righthanddis (0.5*disMean+0.25*disRelated)+confidence*(0.5*disVolume+disLast)];

				rightinfo = [disMean disVolume disLast disRelated righthanddis];

			else

				disMean = (cy - meanrighthandpos(1))^2 + (cx - meanrighthandpos(2))^2;

				disRelated = -(cx - head.x)*abs(cx - head.x);

				% I think the head must be select all right and I will not take the head mess into consider
				righthanddis = [righthanddis (0.5*disMean+0.1*disRelated)];

				rightinfo = [disMean disRelated righthanddis];

			end

        end

        % lefthanddis
        % lefthand
        % righthanddis
        % righthand
        
		[lmin lid] = min(lefthanddis);
		[rmin rid] = min(righthanddis);

		maxError = 10000;

		if lmin < maxError
			label = restlabel(lid);

			lefthand.appear = 1;
			lefthand.x = C(i, 2*label);
			lefthand.y = C(i, 2*label - 1);
			lefthand.volume = V(i, label);
			
			handsLabel(i,1) = label;
		else
			lefthand.appear = 0;
			lefthand.x = 0;
			lefthand.y = 0;
			lefthand.volume = 0;
		end

		if rmin < maxError
			label = restlabel(rid);

			righthand.appear = 1;
			righthand.x = C(i, 2*label);
			righthand.y = C(i, 2*label - 1);
			righthand.volume = V(i, label);
			
			handsLabel(i,2) = label;
		else
			righthand.appear = 0;
			righthand.x = 0;
			righthand.y = 0;
			righthand.volume = 0;
		end

	end

save('HandsLabel', 'handsLabel');