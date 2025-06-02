function [images] = load_image(filename)

    % Images and associated information                             
    im = imread(filename,3); 
     im2=double(im);
    % im2=im2(116:end-115,116:end-115);% this is for CMOS fov
     %im2=im2(195:end-194,195:end-194);% this is lambdaT4 molecule pipeline
     %im2=im2(195:end-194,195:end-194);
    images.imAverage = double(im2);
   % images.imAverage=images.imAverage(13:end-13,13:end-13);
    images.registeredIm{1} = double(im);
   % images.registeredIm{1} =images.imAverage;
    images.imageName = 'BeadsOnSurface';
    images.imageNumber = 1;
    images.runNo = 1;

end

