
%Cristina Chu

%PS6
%Part 2.2: Appearance Model Update


% Getting the video 
video = VideoReader('noisy_debate.avi');

%-Getting frames and data
numFrames = video.NumberOfFrames;
videoHeight = video.Height;
videoWidth = video.Width; 

frames(1:numFrames) = struct('data', zeros(videoHeight, videoWidth, 3, 'uint8'), 'colormap', []);

for f=1:numFrames
    frames(f).cdata = read(video, f);
end


% Data for hand
    % top-left coordinate: 391, 530
    % width: 90
    % height: 90

% Face template
frame_1 = frames(1).cdata;
handTemplate = frame_1(391:391+90, 530:530+90, :);
originalTemplate = handTemplate;

% Coordinates of center
x_center = 436;
y_center = 575;
frameWidth = 90;
frameHeight = 90;

% Particles and weights
numParticles = 70;

particles = zeros(numParticles, 2);
weights = zeros(numParticles,1);

stdev = 6;
pointsind=zeros(numParticles,1);


% Generating first round of particles and their weight
for i = 1:numFrames

    for j = 1:numParticles
        particles(j,1) = x_center + (stdev)*randn;
        particles(j,2) = y_center + (stdev)*randn;
        weights(j,1) = calcWeight(handTemplate, frames(i).cdata, particles(j,1), particles(j,2), 10);
        frames(i).cdata(floor(particles(j,1)), floor(particles(j,2)), 2) = 255;
    end

%Normalizing
weights = weights./sum(weights);

%Sampling Points by weight
    for j = 1:numParticles
        pointsind(j) = find(rand <= cumsum(weights), 1);
    end    

%Getting new center coordinates
weighted_x = particles(pointsind,1);
weighted_y = particles(pointsind,2);

x_center = floor(mean(weighted_x));
y_center = floor(mean(weighted_y));

distx = weighted_x - x_center;
disty = weighted_y - y_center;

distrad=sum(sqrt(distx.^2+disty.^2));
th = 0:pi/100:2*pi;

circx = floor(distrad * cos(th) + x_center);
circy = floor(distrad * sin(th) + y_center);

%Setting markers
templHeight = floor(size(handTemplate,2)/2);
templWidth = floor(size(handTemplate,1)/2);

frames(i).cdata(x_center-templWidth:x_center+templWidth, [y_center-templHeight,y_center+templHeight], 3) = 255;
frames(i).cdata([x_center-templWidth,x_center+templWidth], y_center-templHeight:y_center+templHeight, 3) = 255;

    for k = 1:200
        if (circx(k)>0 && circy(k)>0)
            frames(i).cdata(circx(k):circx(k)+1, circy(k):circy(k)+1, 1) = 255;
        end
    end
    
newRange_x = x_center-templWidth : x_center+templWidth;
newRange_y = y_center-templHeight : y_center+templHeight;
newTemplate = frames(i).cdata(newRange_x, newRange_y, :);
handTemplate = 0.8*handTemplate + 0.2*newTemplate;

end
%%
%Showing movie
implay(frames);

%Showing specific frames
figure(1);
image(frames(15).cdata);
figure(2)
image(frames(50).cdata);
figure(3)
image(frames(140).cdata);

%faceTemplate
figure(4)
imshow(originalTemplate);

