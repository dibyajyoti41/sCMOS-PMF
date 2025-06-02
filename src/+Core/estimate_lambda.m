function [lambdaBg,intThreshBg,structRes ] = ...
                    estimate_lambda(intensities, gain, shapep,adFactor, countOffset, roNoise,pvalThresh)
    % estimate_lambda 
    %
    % determines lambdaBg (Poisson parameter for background)
    % and the largest intensity cut-off intThreshBg so thate goodness-of-fit chi^2 test
    % is successful

    % Input:
    %
    % intensities = matrix or vector with intensity values
    % chipPars = struct containing the chip parameters
    % qStar = parameter (q^*) which controls the false detection rate (FDR)
    %         [q^* should be "rather" close to 1 to make sure that there are
    %          essentially no pixels below intThreshBg. 
    %          However, if "too close" to 1 the estmated number of
    %          background pixels may be unrealiable (see estimate_n_bg.m)
    %          and, as a consequence, the amplitude in the fit may not be
    %          accurate].
    %
    % Output:
    %
    % lambdaBg = lambda-parameter for Poisson distribution
    % intThreshBg = intensity threshold (integer) below which 
    %               most pixels are background
    % structRes - results structure
    %

    % other parameters in the algorithm:
    %
    %   lowestIntThresh - lower limit on the intThreshBg (25% of data)
    %   sortI - sorted data intensities
    %   Nthresh - initial estimate for intThreshBg for quick estimation of
    %   lambda
    %   sortTruncI - truncated data
    %   lamGuess - lambda guess
    %   histAll - histogram counts for data

    opt = statset('MaxIter',200,'MaxFunEvals',400,'FunValCheck','on');
    % Type: statset('mlecustom')   for additional fields

    if nargin < 7
        method = 'FOR';
    end

    lowestIntThresh = ceil(quantile(intensities,0.25)); 
    structRes.lowestIntThresh = lowestIntThresh;
    %
    sortI = sort(intensities);
    S = numel(sortI);
    Nthresh = sortI(round(S/2));


    lamGuess = abs((sortI(round(end/2)) - countOffset)/(gain/adFactor));

    % Prep data for truncated fit
    import Core.calc_bounds;
    [L, U, EX, STD] = calc_bounds(lamGuess, gain, shapep,adFactor, countOffset, roNoise, 6);
    structRes.LU = [max(1,ceil(L)) floor(U)];


    % Get bin edges
    binCenters = [max(1,ceil(L)):1:floor(U)+1 inf]; % bin edges shifted by half  

    % histogram for intensities. Calculated only once!
    histAll = zeros(1,binCenters(end-1));
    histAll(binCenters(1:end-1)) = histcounts(sortI,binCenters-0.5)';
    
    structRes.histAll = histAll;

    %% CHI^2 test
    nQuantiles = 3; % number quantiles
    intVals = lowestIntThresh:structRes.LU(2); 
    % calculate chi^2 test to check which bin sizes are ok
    lambdaBgMLE = nan(1,max(intVals));
    chi2Score = nan(1,max(intVals));
    distVals = cell(1,max(intVals));

    import Core.chi2_calc;
    for Nthresh = intVals;
        [lambdaBgMLE(Nthresh), pci, pdf, cdf] = est_lambda(histAll,lamGuess, Nthresh, gain, shapep,adFactor, countOffset, roNoise,structRes.LU,opt);
%         [chi2Score(Nthresh)] = chi2_calc(histAll, pdf, cdf, Nthresh);
        [chi2Score(Nthresh)] = chi2_calc(histAll, pdf, cdf, Nthresh,structRes.LU, nQuantiles);
%         [chi2Score(Nthresh)] = chi2_calc(histAll, pdf, cdf, Nthresh,structRes.LU);

        distVals{Nthresh}.pdf = pdf;
        distVals{Nthresh}.cdf = cdf;

    end


pval = chi2pdf(chi2Score,nQuantiles-2 );%/length(intVals); 

% figure,plot(pval)
% 
% figure,plot(pval>nanmean(pval))



    pvalThresh = pval > pvalThresh;
    intThreshBg = find(pvalThresh==1,1,'last');
    if isempty(intThreshBg)
        [maxPval,intThreshBg] = min(chi2Score);
%         intThreshBg = find(~isnan(chi2Score),1,'first'); % not nan
        structRes.passthresh = 0;
        warning('pvalues too low');
    else
        structRes.passthresh = 1;
    end
    % 

    lambdaBg = lambdaBgMLE(intThreshBg);

    structRes.pval = pval;
    structRes.chi2Score = chi2Score;
    structRes.lambdaBgMLE = lambdaBgMLE;
    structRes.pdf = distVals{intThreshBg}.pdf;
    structRes.cdf =  distVals{intThreshBg}.cdf;


end

