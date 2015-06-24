%Function to get weights for given particles

function [ weight ] = calcWeight( template, frame, point_x, point_y, sigma )

rows = floor(size(template,1)/2);
columns = floor(size(template,2)/2);

xRange = floor(point_x-rows : point_x+rows);
yRange = floor(point_y-columns : point_y+columns);

diff = (template(:,:,:)-frame(xRange,yRange,:)).^2;

diff = sum(sum(sum(diff)));
diff = diff./(rows*columns);

weight = exp(-diff/(2*sigma));
end
