function saveVideo(BB, C, objLabels, s)

	% videoWriter = VideoWriter('result.avi');
	% videoWriter.FrameRate = 30;
	% open(videoWriter);

	W = vision.VideoFileWriter('./result.avi', 'FrameRate', 30);
    
    n = length(s);
    
    moveDistance = cell(n, 1);
    angle = cell(n,1);
    box = cell(n,1);
  

	nobj = size(objLabels, 2); % number of objects

	lastObjPosition = zeros(nobj,2);

	function H = getTextInserter(text, pos)
		H = vision.TextInserter(text);
		H.Location = pos;
		H.FontSize = 20;
		H.Color = [1.0, 1.0, 1.0];
	end	

	for i = 1:n
		% i
		newimg = im2double(s(i).cdata);

	 	% Write the frame of the video

	 	handspos = [];
		for j = 1:2

			objIndex = objLabels(i, j);

			if objIndex ~= 0
                try
                    bb = cell2mat(BB(i,objIndex));
                    newhandpos = [round(C(i,2*objIndex - 1)), round(C(i,2*objIndex))];
                    if newhandpos ~= [0 0]
                    	handspos = [handspos; newhandpos];
                    end
                catch
                    
                end
                
				% draw boxes
				minx = bb(1);
				maxx = minx + bb(3);
				miny = bb(2);
				maxy = miny + bb(4);
                
                box{i,j}=[minx, maxx, miny, maxy];

				for dem = 1:3
				for x = minx:maxx
				newimg(miny,x,dem) = 255;
				newimg(maxy,x,dem) = 255;
				end

				for y = miny:maxy
				newimg(y,minx,dem) = 255;
				newimg(y,maxx,dem) = 255;
				end
				end

				% sign movements
				sign_loc = [minx, miny];
				sign_text = '';
                
                try
                    obj_y = C(i, 2*objIndex - 1);
                    obj_x = C(i, 2*objIndex);
                catch

                end

				if lastObjPosition(j,:) == [0,0]
					sign_text = 'appeared'; 
				else
					last_y = lastObjPosition(j,1);
					last_x = lastObjPosition(j,2);
                    
                    moveDistance{i,j} = sqrt((obj_x - last_x)^2 + (obj_y - last_y)^2);
                    angle{i,j} = atan((obj_y - last_y)/(obj_x - last_x));
                    

					if obj_x > last_x
						sign_text = [sign_text 'right'];
					else
						sign_text = [sign_text 'left'];
					end

					if obj_y > last_y
						% mark 'down'
						sign_text = [sign_text ' down'];
					else
						% mark 'up'
						sign_text = [sign_text ' up'];
					end

					if (obj_x - last_x)^2 + (obj_y - last_y)^2 < 16
						sign_text = 'still';
					end
					% mark
				end

				% sign_text
				lastObjPosition(j,:) = [obj_y, obj_x];
				H = getTextInserter(sign_text, sign_loc);
				newimg = step(H, newimg);

			else
				lastObjPosition(j,:) = [0,0];
			end
		end
		% newimg = im2double(newimg);

		% writeVideo(videoWriter, newimg);

		% for k = 1:size(handspos, 1)
		% 	newimg(handspos(k,1), handspos(k,2), :) = [255 255 255];
		% end
        try
            
		if size(handspos, 1) == 2 
			midx = round(sum(handspos(:,2)) / 2);
			for dy = handspos(1,1) - 1:handspos(1,1) + 1
				for dx = midx - 1:midx + 1
					newimg(dy, dx, :) = [0 255 255];
				end
			end
			for dy = handspos(2,1) - 1:handspos(2,1) + 1
				for dx = midx - 1:midx + 1
					newimg(dy, dx, :) = [0 255 255];
				end
			end
        end
        
        catch
            % handspos
            % i
        end

        step(W, newimg);
	end
	release(W);
    
    save('moveDistance', 'moveDistance');
    save('angle', 'angle');
    save('box', 'box');
   

end