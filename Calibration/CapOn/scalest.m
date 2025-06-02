
filename='balanced_dark_1us-02.tif';
%filename='1uspvcambalanceddark1.tif';


numimgs = size(imfinfo(filename),1);
pa2=zeros(1,numimgs);
pa3=zeros(1,numimgs);

for k=1:1
finIm=imread(filename,k);
finIm=double(finIm);
qf = @(p,s) 1./s.*(p.^(s)-(1-p).^(s));
qflogistic = @(p,s) log(p./(1-p));
p=0.01:0.1:0.99;

quantileImage = quantile(finIm(:)-mean(finIm(:)),p);


s=0.09;
pccS = zeros(1,length(s));
for i=1:length(s)
    if s(i)==0
        quantileTheoretical = qflogistic(p,s(i));
    else
        quantileTheoretical = qf(p,s(i));
    end


%  figure,plot(quantileImage,quantileTheoretical)
  %pccS(i) = zscore(quantileImage,1)*zscore(quantileTheoretical',1)/length(quantileTheoretical);

end
%figure,plot(quantileTheoretical,quantileImage)

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
xlabel('Theoretical Quantiles','Interpreter','latex','FontSize',15)
ylabel('Observed values','Interpreter','latex','FontSize',15)
% hold on
% 
% 
% box on
% %% define range of subpart
% %range=90:110% here i am using range from 90 to 110
% plot(pa2,'Linewidth',3)% here i am plotting sub part of same figure. you plot another figure
% box off
hold off