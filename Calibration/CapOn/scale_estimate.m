clear;
filename='balanced_dark_1us-02.tif';
numimgs = size(imfinfo(filename),1);

for k=1:numimgs
finIm=imread(filename,k);
finIm=double(finIm);
qf = @(p,s) 1./s.*(p.^(s)-(1-p).^(s));
qflogistic = @(p,s) log(p./(1-p));
p=0.01:0.1:0.99;

quantileImage = quantile(finIm(:)-mean(finIm(:)),p);


%s1=maxpccValShapePar(k);
s=0.055;
pccS = zeros(1,length(s));
for i=1:length(s)
    if s(i)==0
        quantileTheoretical = qflogistic(p,s(i));
    else
        quantileTheoretical = qf(p,s(i));
    end




end


pa=polyfit(quantileTheoretical,quantileImage,1);
pa2(k)=pa(1);
pa3(k)=pa(2);

end
figure
plot(quantileTheoretical,quantileImage,'LineWidth',4);

m=pa(1);
x=min(quantileTheoretical(:))+1:max(quantileTheoretical(:));
ymin=min(quantileImage(:));
y3=pa(1)*x+pa(2)-1;
hold on
plot(x,y3,'LineWidth',1);


title("Scale Parameter " + pa(1) + " ")
xlabel('Unscaled Theoretical Quantiles','Interpreter','latex','FontSize',15)
ylabel('Empiricial Quantiles, Q_{emp}','Interpreter','latex','FontSize',15)

hold off

%sprintf('offset %g',offset);
%sprintf('shape parameter %g',s1);
sprintf('scale parameter %g',pa(1));