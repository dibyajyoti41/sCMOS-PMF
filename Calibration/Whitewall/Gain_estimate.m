sz = 1024;

mz=200;


numf = [10 20 30 40 50 60 70 80 90 100];

numfiles = length(numf);

meanimage=zeros(mz,mz,numfiles);
varimage=zeros(mz,mz,numfiles);



inis = 20;
fins = 40;

for k = 1:numfiles
    filename = sprintf('balanced2channel%d-01.tif', numf(k));

    img_mean = zeros(mz, mz);
    offs=100.16*ones(mz,mz);
    img_var = zeros(mz, mz);
    count = 0;

    for k1 = inis:fins
        thisImage = double(imread(filename, 2 * k1));
         az=size(thisImage);
        thisImagem=thisImage((az(1)/2)-(mz/2)+1:(az(1)/2)+(mz/2),(az(2)/2)-(mz/2)+1:(az(2)/2)+(mz/2));
    


        % Compute mean and variance incrementally
        count = count + 1;
        delta = thisImagem - img_mean;
        img_mean = img_mean + delta / count;
        img_var = img_var + delta .* (thisImagem - img_mean);

    
    
end


    img_var = img_var / (count - 1);

    meanimage(:,:,k) = img_mean-offs;
    varimage(:,:,k) = img_var;
    
    p = polyfit(img_mean(:)-offs(:), img_var(:), 1);
    fprintf('Gain for file %s: %f\n', filename, p(1));
end

figure
xlabel('E[n_{ic}]-\Delta')
ylabel('Var[n_{ic}]')

for k=1:numfiles

hold on

plot(meanimage(:,:,k),varimage(:,:,k),'o')


end
%hold off

p=polyfit(meanimage(:,:,:),varimage(:,:,:),1);

hold on


  m=p(1);
x=min(meanimage(:)):max(meanimage(:));
%x=-50:max(meanimage(:));
ymin=min(varimage(:));
y3=p(1)*x+p(2);
plot(x,y3,'LineWidth',2);

p


%g=[g p(1)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
