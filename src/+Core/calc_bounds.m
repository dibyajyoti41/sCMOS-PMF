function [L,U,EX,STD] = calc_bounds(lambda,gain,lambdap,adFactor,offset,roNoise,numstds)
  %  if nargin < 6
        numstds = 6;
   
      %r = gain/adFactor;
     
    EX = lambda*gain/adFactor+offset; 
    s=roNoise; %ronoise is scale parameter s

    TLvar=(2.0/lambdap^2)*((1/(1+2*lambdap))-((gamma(1+lambdap))^2/gamma(2*lambdap+2)));
    STD=sqrt(gain^2*lambda+s^2*TLvar+1/12);
    L = EX-numstds*STD; % mean - 6 std
    U = EX+numstds*STD;
end


