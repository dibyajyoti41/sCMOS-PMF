function [lambdaBg, pci,pdf,cdf] = est_lambda(histAll,lamGuess,Nthresh,gain,shapep,adFactor,offset,roNoise, LU, opt)
    %   est_lambda - estimating lambda_bg function
    % 
    %   Returns:
    %       lambdaBg - lambda using MLE
    %       pci - predicted confidence intervals


    binPos = LU(1):Nthresh;
    import Core.log_likelihood_trunc_dist; 
    logL = @(lambda,data,cens,freq,trunc) log_likelihood_trunc_dist(lambda,data,cens,freq,trunc, ...
                       gain, shapep, adFactor, offset, roNoise);
            
    % use mle with negative loglikelihood (nloglf)
    [lambdaBg, pci] = mle(binPos,'nloglf',logL,'start',lamGuess,'lowerBound',0,'Frequency',histAll(binPos),'TruncationBounds',LU,'Options',opt);
   
    cdf = nan(1,length(histAll)-1);
    pdf = nan(1,length(histAll)-1);
    import Core.pdf_cdf_scmos;

    [pdf(LU(1):length(histAll)-1), cdf(LU(1):length(histAll)-1)] = pdf_cdf_scmos(LU(1):length(histAll)-1, lambdaBg, gain, shapep,adFactor, offset, roNoise, LU(1), LU(2));


end

