function [logL] = log_likelihood_trunc_dist(lambda, data, cens, freq, trunc,...
                             gain, shapep,adFactor, offset, roNoise)
    % Calculates the  log-likelihood for the truncated sCMOS-PMF distribution
    % 
    % Args: 
    % 
    %   sortTruncI = sorted and truncated intensity values 
    %   lambda = Poisson parameter
    %   gain, adFactor, countOffset, roNoise - chipPars
    %
    % Returns:
    % 
    % logL = log likelihood
    %
    % Comment: 
    % The truncated PDF is
    %      PDF_trunc = pdfsCMOS(I)/cdfsCMOS(I_trunc) for I <= I_trunc
    %      PDF_trunc = 0 elsewhere
    % Here, I_trunc is the truncation intensity.
    %  

    import Core.pdf_cdf_scmos;
    [pdfsCMOS, cdfsCMOS] = pdf_cdf_scmos(data',lambda,gain, shapep,adFactor, offset, roNoise);%, trunc(1), trunc(2) % not using trunc will jumpy score
    logL = -sum(freq.*log(pdfsCMOS)) + sum(freq)*log(cdfsCMOS(end));


  
end