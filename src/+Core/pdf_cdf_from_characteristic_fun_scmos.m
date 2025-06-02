function [pdfsCMOS,cdfsCMOS] = pdf_cdf_from_characteristic_fun_scmos(intensities,lambda,gain,shapep,adFactor,offset,roNoise,L,U)

    import Core.calc_bounds;

    %if nargin < 7
        [L, U, EX, STD] = calc_bounds(lambda, gain, shapep,adFactor, offset, roNoise);
    %end
      
     
    r = gain/adFactor;
      


	% optimal value for step parameter
    dt = 2*pi/(U-L);

    
    N=pi/dt;
  
    t = (1:1:N)' * dt;
    
    
    cf = char_fun(t,gain,shapep,roNoise,lambda,r,offset,dt);

        % y is the grid for our pdf (from L to U)
    y = intensities;
    
    
    % calculate main integral
    pdfsCMOS = trapezoidal_pdf(y,dt,t,cf,roNoise);
    cdfsCMOS = cumsum(pdfsCMOS);

%     cdfEmccd = trapezoidal_cdf(y,dt,t,cf,EX);

   
    
end


function cfCombined = char_fun(t,gain,lambdap,roNoise,lambda,r,offset,dt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lambdap=0.0517;
del=0.005;
rn = 0:del:1;


 sRand = roNoise*(rn.^lambdap - (1-rn).^lambdap)/lambdap;


for j = 1:length(t)
    k = t(j);

     y1=exp(1i * k * sRand');
     cfNREAD(j)=(del/2)*(y1(1)+y1(end)+sum(2*y1(2:end-1)));

end

cfNREAD=cfNREAD(:);


   cfGX =  exp(lambda*(exp(1i*gain*t)-1));%gain=1.0
  % cfNREAD = pi*roNoise*t./(sinh(pi*roNoise*t));
    cfROUND = 2*sin(t/2)./t;
    cfROUND(t==0) = 1;
    cfO = exp(1i*t*offset);
    cfCombined = cfGX.*real(cfNREAD).*cfROUND.*cfO;
  
    
   % cfCombined = cfAnaly.*cfROUND;

end

%
function pdf = trapezoidal_pdf(y,dt,t,cf,roNoise)
    w = ones(length(t),1);
    w(end) = 1/2; % last coef is 1/2
     % t1=t/roNoise;
    pdf = dt/pi*(1/2 +cos(t*y)'*(real(cf).*w)+sin(t*y)'*(imag(cf).*w));
    %pdf=pdf/roNoise;
end

