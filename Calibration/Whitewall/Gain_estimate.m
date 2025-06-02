
meanimage=zeros(1024,1024);
varimage=zeros(1024,1024);
p1=zeros(100);
numfiles =10;

for k = 1:numfiles
 
   filename = sprintf('balanced2channel%d-01.tif',10*k);
 
numimgs = size(imfinfo(filename),1);
numimgs=numimgs/2;
sz=1024;
img = zeros(sz,sz);

img2 =zeros(sz,sz);


varimg = zeros(sz,sz);



for k1 = 1 : numimgs
  thisImage  = imread(filename,2*k1);
    thisImage=double(thisImage);
   
    
    
    
    img=img+thisImage;
    img2=img2+thisImage.*thisImage;
    
end

img=img/numimgs;

img2=img2/numimgs;

varimg=img2-img.*img;


meanimage(:,:,k)=img;
varimage(:,:,k)=varimg;

end


figure
for k=1:numfiles


hold on

plot(meanimage(:,:,k),varimage(:,:,k),'o')

end


p=polyfit(meanimage(:,:,:),varimage(:,:,:),1);

hold on

m=p(1);
x =70:10:1500; 

x1 = 70; % Specify your starting x
y1 = 70;  % Specify your starting y

y = m*(x - x1) + y1;

plot(x,y,'LineWidth',3);
ylim([0 1800]);
hold off

xlabel('Mean','Interpreter','latex','FontSize',15)
ylabel('Variance','Interpreter','latex','FontSize',15)
hold off


