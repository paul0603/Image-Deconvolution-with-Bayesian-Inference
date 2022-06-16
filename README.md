# Image-Deconvolution-with-Bayesian-Inference
  Please open initial_MAP_k.m and set the parameters.
  

This program is an implementation of deblur process, the main structure is based on Expectation–maximization(EM) algorithm. It contains two steps, E step and M step.
The key to fine results rely mainly on two parameters, the noise variance "noise_var_eta" and inverse variance of prior "model.prior_ivar". The noise variance actually measure the weight on prior term; if noise variance is low, the data fitting term become more important than our prior term in our objective function which we seize to optimize, since it means our degradation in blur image isn't that bad. On the other hand, if noise variance is high, the prior term become more important, since we need the statistic which is capture by the prior distribution to guide the optimization while the data is severely damaged. So if you attempt to produce satisfying results, modified these two parameters carefully. 

More detail in PPT
