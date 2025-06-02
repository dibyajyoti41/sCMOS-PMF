


filename='balanced_dark_1us-02.tif';


numimgs = size(imfinfo(filename),1);

bmean=zeros(1,numimgs);
maxpccValShapePar=zeros(1,numimgs);
for k=1:numimgs

finIm=imread(filename,k);
finIm=double(finIm);
%bmean(k)=mean(finIm(:));
qf = @(p,s) 1./s.*(p.^(s)-(1-p).^(s));
qflogistic = @(p,s) log(p./(1-p));
p=0.01:0.01:0.99;
offset=mean(finIm(:));
quantileImage = quantile(finIm(:)-mean(finIm(:)),p);

s = -0.95:0.005:0.95;

pccS = zeros(1,length(s));
for i=1:length(s)
    if s(i)==0
        quantileTheoretical = qflogistic(p,s(i));
    else
        quantileTheoretical = qf(p,s(i));
    end



  pccS(i) = zscore(quantileImage,1)*zscore(quantileTheoretical',1)/length(quantileTheoretical);

end


[value,position] =max(pccS);

maxpccValShapePar(k) = s(position);
end 

%  figure,plot(s,pccS,'LineWidth',4)
%  xlabel('Shape parmeter','Interpreter','latex','FontSize',15)
% ylabel('PCC score','Interpreter','latex','FontSize',15)



figure;


plot(s,pccS,'LineWidth',4)
hold on
plot(ones(1,13)*maxpccValShapePar(k),0.7:0.025:1,'--')
xlabel('$\lambda_{TL}$','Interpreter','latex','FontSize',15)
ylabel('PCC score','Interpreter','latex','FontSize',15)


title('\lambda_{TL}=0.0517')

