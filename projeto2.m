frames = dir('Crowd_PETS09/S2/L1/Time_12-34/View_001/*.jpg');      
nFrames = length(frames);
%figure,
step = 53;

frameName = ['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(1).name];
frame = imread(frameName);
[rows, columns, numberOfColorChannels] = size(frame);

vid4D = zeros([rows columns 3 nFrames/step]);

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

figure
frame1 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(1).name]);
imshow(im2bw(frame1));
figure
frame2 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(5).name]);
imshow(im2bw(frame2));
figure
diff = imsubtract(uint8(im2bw(frame1)), uint8(im2bw(frame2)));
imshow(diff);
%%
for f=1:nFrames
    f
%     figure('Name', 'Image Subtraction');
    frameName = ['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f).name];
    img = imread(frameName);
    newImg = imsubtract(uint8(bkg), img);
%     imshow(newImg); drawnow

%     figure('Name', 'Bounding Boxes');
    BW_Img = newImg(:,:,1) > 40;
    [lb num]=bwlabel(BW_Img);
    regionProps = regionprops(lb,'centroid', 'area', 'perimeter', 'BoundingBox');

%     hold on;
    imshow(img)
    for i=1:num
        if regionProps(i).Area > 100
            rectangle('Position',[regionProps(i).BoundingBox(1),regionProps(i).BoundingBox(2),regionProps(i).BoundingBox(3),regionProps(i).BoundingBox(4)],...
            'EdgeColor','r','LineWidth',2 )
        end    
    end
    pause(0.2)
end

