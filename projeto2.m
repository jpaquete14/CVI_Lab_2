clear all, close all

frames = dir('Crowd_PETS09/S2/L1/Time_12-34/View_001/*.jpg');    
grandTruth = xmlread('PETS2009-S2l1.xml');
nFrames = length(frames);
t = 30
%figure,
step = 53;

frameName = ['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(1).name];
frame = imread(frameName);
[rows, columns, numberOfColorChannels] = size(frame);

vid4D = zeros([rows columns 3 nFrames/step]);
% Background estimation
k = 1;
for i=1:step:nFrames
    frameName = ['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(i).name];
    img = imread(frameName);
    vid4D(:,:,:,k)=img;
    %imshow(img); drawnow
    k = k+1;
    %pause
end
bkg = median(vid4D,4);
figure('Name', 'Background'),imshow(uint8(bkg));


%% Bounding boxes
figure
for f=1:nFrames
    f
    
%     figure('Name', 'Image Subtraction');
    frameName = ['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f).name];
    img = imread(frameName);
    newImg = imsubtract(uint8(bkg), img);
%     imshow(newImg); drawnow

    R = newImg(:,:,1) > t;
    B = newImg(:,:,2) > t;
    G = newImg(:,:,3) > t;
    bw = imclose(R|G|B, strel('disk',3));
%     imshow(bw)
    [lb num]=bwlabel(bw);
    regionProps = regionprops(lb,'centroid', 'area', 'perimeter', 'BoundingBox');

    imshow(img)
    
    % Plot results
    for i=1:num
        if regionProps(i).Area > 100
            rectangle('Position',[regionProps(i).BoundingBox(1),regionProps(i).BoundingBox(2),regionProps(i).BoundingBox(3),regionProps(i).BoundingBox(4)],...
            'EdgeColor','r','LineWidth',2 )
        end    
    end
    
    %Plot grand truth 
    currentFrame = grandTruth.getElementsByTagName('frame').item(f)
    gt_object = currentFrame.getElementsByTagName('object')
    
    if gt_object.getLength() > 0
        for i = 0:(gt_object.getLength()-1)
            gt_id = gt_object.item(i).getAttribute('id');
            gt_w = str2double(gt_object.item(i).getElementsByTagName('box').item(0).getAttribute('w'));
            gt_h = str2double(gt_object.item(i).getElementsByTagName('box').item(0).getAttribute('w'));
            gt_xc = str2double(gt_object.item(i).getElementsByTagName('box').item(0).getAttribute('xc'));
            gt_yc = str2double(gt_object.item(i).getElementsByTagName('box').item(0).getAttribute('yc'));

            rectangle('Position',[gt_xc, gt_yc, gt_w, gt_h], 'EdgeColor','g','LineWidth', 2)
        end
    end
    
    grandTruth.getElementsByTagName('frame').item(0)
    pause(0.2)
end
%% Simple algorithm 
close all

figure
for f=120:nFrames
    frame1 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f-1).name]);
    frame2 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f).name]);
    diff = imclose(abs(imsubtract(im2bw(frame2), im2bw(frame1))), strel('disk',1));
    [lb num]=bwlabel(diff);
    regionProps = regionprops(lb,'centroid', 'area', 'perimeter', 'BoundingBox');

    imshow(frame1);
    for i=1:num
        if regionProps(i).Area > 200
            rectangle('Position',[regionProps(i).BoundingBox(1),regionProps(i).BoundingBox(2),regionProps(i).BoundingBox(3),regionProps(i).BoundingBox(4)],...
            'EdgeColor','r','LineWidth',2 )
        end    
    end
    pause(0.2)
end

%% Motion field
close all

figure
for f=2:nFrames
    frame1 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f-1).name]);
    frame2 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f).name]);

    hold on;
    opflow = opticalFlow(im2double(im2bw(frame2)),im2double(im2bw(frame1)));
    plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
    hold off;
    pause(0.2)
end

%% Diff between two images
H = fspecial('sobel');
figure
subplot(1,4,1)
frame1 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(1).name]);
im1 = imfilter(im2bw(frame1), H,'replicate');
imshow(im1)
subplot(1,4,2)
frame2 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(2).name]);
im2 = imfilter(im2bw(frame2), H, 'replicate');
imshow(im2)
subplot(1,4,3)
diff = imsubtract(im2, im1)
imshow(diff)
subplot(1,4,4)
% blurred = imfilter(im2bw(frame2),H,'replicate'); 
% imshow(blurred);
figure
imshow(diff);
opflow = opticalFlow(im2double(im1),im2double(im2))
plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
