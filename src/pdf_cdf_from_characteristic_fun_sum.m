function [pdfsCMOS,cdfsCMOS,L,U] = pdf_cdf_from_characteristic_fun_sum(intensities,lambda,gain,lambdap,adFactor,offset,roNoise,M, L, U)

    % Generates EMCCD probability density function (PDF) and 
    % cumulative distribution functin (CDF) by numerical inversion 
    % of the characteristic function.
    %
    %   This is for the case we have sum of m pixels
    %
    % Input:
    % 
    % intensities = vector (or matrix) with intensity values
    % lambda = Poisson parameter
    % chipPars = struct containing the chip parameters
    % N = number of integration points.
    %
    % Output:
    % 
    % pdfEmccd = EMCCD probability density function 
    % cdfEmccd = cumulative distribution function 
    %
    % Refs: V. Witkovský, "Numerical inversion of a characteristic function: 
    % An alternative tool to form the probability distribution of 
    % output quantity in linear measurement models.", 
    % Acta IMEKO 5.3 (2016): 32-44, see Eqs. (8) and (9).
    %
    %
    
    % Hard-coded variables:
%     pdfMin = 1E-14;   % smallest allow value for PDF 
                      % (need to be > 0 to avoid errors in 
                      % log-likelihood calculations)
%     cdfDelta = 1E-14; % smallest allowed CDF value is cdfDelta,
                      % and largest allowed CDF value is 1-cdfDelta.
      
     % Extract chip parameters
%     gain = chipPars.gain;
%     adFactor = chipPars.adFactor;
%     offset = chipPars.countOffset;
%     roNoise = chipPars.roNoise;

    lambda = M*lambda;
    offset = M*offset;
    roNoise = sqrt(M)*roNoise;
    % offset = 
    %  summedInt(regIdx), M*lambdaBg,gain,adFactor, M*offset,sqrt(M)*roNoise
    r = gain/adFactor;
      
    %     % Analytic expressions for the mean and variance
 %   EX = lambda*gain/adFactor+offset; 

      %  numstds = 6;
   
      %r = gain/adFactor;
     
    EX = lambda*gain/adFactor+offset; 
    

if nargin < 9
    % STD = sqrt(roNoise^2 + 2*lambda*r^2 + (M/12));  
     numstds = 6;
    % L = EX-numstds*STD; % mean - 6 std
    % U = EX+numstds*STD;
    s=roNoise; %ronoise is scale parameter s

    TLvar=(2.0/lambdap^2)*((1/(1+2*lambdap))-((gamma(1+lambdap))^2/gamma(2*lambdap+2)));
    STD=sqrt(gain^2*lambda+s^2*TLvar+1/12);
    L = EX-numstds*STD; % mean - 6 std
    U = EX+numstds*STD;
end
dt = 2*pi/(U-L);

    % For discrete, integral is -pi..pi, because the output variable is
    % discretized
    N = pi/dt;
    
    
    % Estimate step size, dt, for numerical integration
    t = (1:1:N)' * dt;  

    cf = char_fun(t,gain,lambdap,roNoise,lambda,r,offset,dt,M);%(t , roNoise,lambda,r,offset,M);

        % y is the grid for our pdf (from L to U)
    y = intensities;
%     
%     % Analytic expression for the characteristic function 
%     % for the EMCCD distribution
% %     cfAnaly = @(t) exp(-t.^2*roNoise^2/2 + lambda./(1-1i*r*t) - lambda + 1i*t*offset)*2*sin(t/2)/t;
% 
%     %
%    % limits where pdf is nonzero

%     U = min(max(intensities),U); % limit to U for truncated case

%%%%%%%%%


%%%%%%%%%%
	% optimal value for step parameter
    
    
    % TODO: change to PMF
    % calculate main integral
    pdfsCMOS = trapezoidal_pdf(y,dt,t,cf);
    cdfsCMOS = cumsum(pdfsCMOS);

   
    
end

function cfCombined = char_fun(t,gain,lambdap,roNoise,lambda,r,offset,dt,M)

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

    cfROUND = (2*sin(t/2)./t).^M;
    cfROUND(t==0) = 1;
    cfO = exp(1i*t*offset);
    cfCombined = cfGX.*real(cfNREAD).*cfROUND.*cfO;


   % cfCombined = cfAnaly.*cfROUND;

end
% function cfCombined = char_fun(t , roNoise,lambda,lambdap,r,offset,M)
%     % calculate log for computational efficiency?
% 
%     cfAnaly = exp(-t.^2*roNoise^2/2 + lambda./(1-1i*r*t) - lambda + 1i*t*offset);
%     cfROUND = (2*sin(t/2)./t).^M;
%     cfROUND(t==0) = 1;
% 
% 
% 
%     cfCombined = cfAnaly.*cfROUND;
% 
% end
% 
% %
% function pdf = trapezoidal_pdf(y,dt,t,cf)
%     w = ones(length(t),1);
%     w(end) = 1/2; % last coef is 1/2
% 
%     pdf = dt/pi*(1/2 +cos(t*y)'*(real(cf).*w)+sin(t*y)'*(imag(cf).*w));
% end
% %
% function cdf = trapezoidal_cdf(y,dt,t,cf,ex)
%     w = ones(length(t),1);
%     w(end)=1/2; % last coef is 1/2
%     cdf = 1/2 - dt/pi*(1/2*(ex-y') +cos(t*y)'*(imag(cf./t).*w)-sin(t*y)'*(real(cf./t).*w));
% end
% function cfCombined = char_fun(t,gain,lambdap,roNoise,lambda,r,offset,dt)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %lambdap=shapep;
% del=0.005;
% rn = 0:del:1;
% 
% 
%  sRand = roNoise*(rn.^lambdap - (1-rn).^lambdap)/lambdap;
% 
% 
% for j = 1:length(t)
%     k = t(j);
% 
%      y1=exp(1i * k * sRand');
%      cfNREAD(j)=(del/2)*(y1(1)+y1(end)+sum(2*y1(2:end-1)));
% 
% end
% 
% cfNREAD=cfNREAD(:);
% 
% 
%    cfGX =  exp(lambda*(exp(1i*gain*t)-1));%gain=1.0
% 
%     cfROUND = 2*sin(t/2)./t;
%     cfROUND(t==0) = 1;
%     cfO = exp(1i*t*offset);
%     cfCombined = cfGX.*real(cfNREAD).*cfROUND.*cfO;
% 
% 
%    % cfCombined = cfAnaly.*cfROUND;
% 
% end

%
function pdf = trapezoidal_pdf(y,dt,t,cf,roNoise)
    w = ones(length(t),1);
    w(end) = 1/2; % last coef is 1/2
     % t1=t/roNoise;
    pdf = dt/pi*(1/2 +cos(t*y)'*(real(cf).*w)+sin(t*y)'*(imag(cf).*w));
    %pdf=pdf/roNoise;
end

