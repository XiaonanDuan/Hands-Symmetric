function [cy, cx] = findRegionCentroid(blob, sz)
	blob = blob;
	py = blob(:,1);
	px = blob(:,2);
	[inds] = sub2ind(sz, py, px);
    region = zeros(sz);
    region(inds) = 1;
    cent=regionprops(region, 'centroid');
    cy = cent.Centroid(2);
    cx = cent.Centroid(1);   
