# Control Variates

This project discusses a number of variance reduction methods as a way to save the costs
 of replications needed to reduce error in simulations, as well as providing examples using the
 ARENAsimulation software. Common Random Numbers involve inducing a positive
 correlation between models. With Antithetic Variates, negative correlation is forced between
 pairs of runs. Control Variates are variables correlated with the response variable used to make a
 better estimate. Other methods including Importance Sampling, Conditioning, and Stratified
 Sampling are also reviewed.
 
The following files created in ARENA and R accompany the Variance Reduction Methods.

CommonRandomNumbers.doe
- ARENA model corresponding to the Common Random Numbers Example section, with Table 1 generated from the outputs.

AntitheticVariates.doe
- ARENA model corresponding to the Antithetic Variates Example section, with Table 2 generated from the outputs.

ControlVariates.doe
- ARENA model corresponding to the Control Variates Example section, with the outputs used for the R file.

ControlVariates.csv
- Excel output of response and control variables to be analyzed in R.

ControlVariates.R
- R code corresponding to the Control Variates Example section, with Table 3 generated from the outputs.

# Background

Simulation is often used for large-scale, time-consuming projects where reaching a small
 margin of error is both important and costly. According to the Law of Large Numbers, as n, or
 the number of replications, gets large, the estimator converges to the actual value being estimated
 (Kleijnen, Ridder & Rubinstein, 2013). Achieving the desired margin of error may require a very
 large number of replications which can require a lot of time and money. Estimating the
 probability of rare events in particular can take a very long time to compute. This makes variance
 reduction methods important, as it can greatly reduce the number of replications needed. This
 paper will discuss some of the most commonly used methods to reduce variance, including
 Common Random Numbers, Antithetic Variates, and Control Variates with examples using
 ARENA. Other variance reduction methods are also explored in brief.

 # Common Random Numbers

 This method involves using the same set of random numbers across different models you
 are comparing (Law, 2015). Each model will be under the same condition or source of
 randomness. Controlling randomness in this way makes it so that observed differences will be
 the result of the differences between the models. This is one reason why reproducibility is a very
 important property of good random number generators.
 
 In order to be effective, it is important to maintain synchronicity of the random numbers
 between the systems (Law, 2015). It is best to use a given CRN for the same kind of process in
 both models, for example, using it to produce interarrival times in both models, as opposed to
 interarrivals in one model and service times in the other. Generally, for producing random
 variates with CRN, the inverse transform method should be used because it transforms random
 numbers one-to-one, producing the strongest positive correlation, compared to the
 acceptance-rejection method, which uses a random amount of random numbers to produce one
 value. An alternative assumption is that the generated random variates are approximately normal
 (Kleijnen, Ridder & Rubinstein, 2013).
 
 It is not possible to know beforehand if CRN will succeed at reducing variance and to
 what extent (Law, 2015). There are instances in which it may backfire and increase variance. It
 may be beneficial to run a pilot study to ensure it is working as intended, and that the systems are
 correctly synchronized. Another limitation is that while effective for sensitivity analysis, the use 
 of common random numbers is not as well-suited for the purposes of prediction (Kleijnen, Ridder & Rubinstein, 2013).

 If we are comparing two models and estimating *θ̂ * = X- Y :
 
 Var(*θ̂ *) = Var(X) + Var(Y)- 2Cov(X, Y)
 
 When X and Y are different random numbers they are independent, and the covariance of
 X and Y is zero, so the total variance is based solely on the sum of Var(X) and Var(Y). By
 inducing a covariance > 0, such as with CRN, the variance is therefore decreased.

 ARENA and many other simulation languages typically use CRN for model comparison
 by default, however it is possible to set the random number stream used for each process in order
 to ensure synchronization between specific mechanisms. To apply in ARENA, the Seeds module
 should be used. This can be found in the Elements template, which is not displayed by default,
 and so the Attach Template function must first be used. In the Seeds module, the seed can be
 named, assigned a number, and the initialization parameter should be set to Common. To assign a
 stream to a particular process, the stream is listed after the parameters in an expression (ie.
 EXPO(3, Stream 1)).
 
 In this example, an M/M/1 queue with an interarrival rate of EXPO(5) and a service rate
 of EXPO(2) is compared to a M/M/2 queue with an interarrival rate of EXPO(5) and a service
 rate of EXPO(5). The basic idea is a comparison of one experienced server with two junior
 servers in a simple queue model. The two models are compared with independent random
 numbers where the seeds are set to be different, followed by CRN, in which case the interarrival
 times in the two models are assigned to a common seed, and the service times for both are
 assigned to their own common seed.The simulation is run with 100 replications that are 24 hours
 long.
 
 As an evaluation, the 95% confidence intervals for the expected wait time difference
 between the two models is reported in Table 1. The half-width for CRN is lower compared to the
 independent systems, indicating the confidence intervals are tighter and variance was reduced.

 **Table 1**
  *Two-Sample 95% Confidence Intervals for Expected Wait Time With and Without CRN*
  ||  | Average  | Half-Width |
  | --- | --- | --- |
  | Independent Systems | -0.1950 | 0.2431 | 
  | Common Random Numbers | 0.0540 | 0.1371 |

# Antithetic Variates

 Antithetic Variates follow a similar logic to common random numbers, but instead
 involve forcing a negative correlation rather than a positive (Law, 2015). While CRN involves
 using the same numbers in different models being compared, Antithetic Variates are applied to
 pairs of runs. Where the random number U is used in one replication, its opposite, 1-U, is used in
 the other. It is also especially important that these pairs are synchronized to the same process (ie.
 both applied to service times), because of the two numbers generated, one will be high and the
 other low relative to each other, but if mixed up between different processes, they may be
 interpreted differently and lose the intended effect. Like CRN, it is not known in advance how
 effective they will be at reducing variance for a given model. Once again, the assumption for
 generating random variate generation is that they are normally distributed or the inverse
 transformation method is used (Kleijnen, Ridder & Rubinstein, 2013).

 Taking the average of two paired observations
 
 *θ̂ *= ( f (U₁) + f (U₂)) / 2
 
 Var(*θ̂ *) = (Var(U₁) + Var(U₂) + 2Cov( f (U₁), f (U₂))) / 4
 
 Since Var(U₁) and Var(U₂) are i.i.d.,
 
 Var(*θ̂ *) = (Var(U₁) + Cov( f (U₁), f (U₂))) / 2
 
 If Cov( f (U₁), f (U₂)) < 0, the variance is reduced, and so we can expect inducing a negative
 correlation will be effective.

 To apply in ARENA, the same method as CRN is applied, however the initialization
 parameter in the Seeds module should be set to Antithetic rather than Common, and in this case
 it is only applied to one system. The same M/M/1 queue example used for CRN is used again
 here, not the M/M/2. Once again, it has an interarrival rate of EXPO(5) and a service rate of
 EXPO(2).
 
 Antithetic Variates were applied to reduce the variance for estimating the mean wait time.
 Compared to using independent runs, AV resulted in slightly tighter confidence intervals,
 successfully reducing variance (Table 2).

**Table 2** <b>
*One-Sample 95% Confidence Intervals for Expected Wait Time With and Without AV* <b>
  ||  | Average  | Half-Width |
  | --- | --- | --- |
  | No Variation Reduction |  0.6625 | 0.2116 | 
  | Antithetic Variates | 0.7280 |  0.2055 |

# Control Variates

When estimating the mean of a variable, we can use another variable known to be
 correlated with it to reduce the variance (Law, 2015). To be an effective method of variance
 reduction, the CV should have both a high correlation with the output variable and have a low
 variance itself, as well as having a known mean. It is possible to include many different control
 variates for additional variance reduction. The number of good candidates for control variates
 will depend on the nature of the simulation and the response. They may arise naturally from
 existing conditions of the simulation or be an external variable that is induced.

 The estimator adjusted with the control variate is
 
 C=E[X] +β(Y-E[Y])
 
 With the variance
 
 Var(C) = Var(X) + β²Var(Y) + 2βCov(X,Y)
 
 Beta is a constant that is chosen to produce the most variance reduction. To minimize the
 variance beta is defined as
 
 β =-Cov(X,Y) / Var(Y)
 
 This is comparable to regression, wherein there is a coefficient adjusting the baseline intercept to
 explain variation. Here, Var(C) is minimized with respect to Beta, as in regression the sum of
 squared errors is minimized with respect to the coefficients in the model. For the CV to reduce
 variance, β²Var(Y) + 2βCov(X,Y) < 0. Beta will have the opposite sign of the correlation, so
 when the response and control are positively correlated, β < 0.

  For this example, output of the M/M/1 queue with independent runs used previously was
 analyzed in R. Once again, the expected wait time is the response, and expected service time is
 used as the CV, as they have a clear relation. From the output correlation coefficient was
calculated as 0.6439. Beta was calculated to be-0.8227, and used to adjust the estimated wait
 time. This adjustment results in a greatly reduced variance, as shown by the smaller half-width
 (Table 3).

 **Table 2** <b>
*One-Sample 95% Confidence Intervals for Expected Wait Time With and Without AV* <b>
  ||  | Average  | Half-Width |
  | --- | --- | --- |
  | No Variance Reduction |  0.6625 | 0.2116 | 
  | Control Variates | 0.6625 |  0.0013 |

  # Other Variance Reduction Methods

  Here is a brief overview of some additional variance reduction
 methods, including Importance Sampling, Conditioning, and Stratified Sampling.
 
 Importance Sampling is used for rare event probability estimation, when certain random
 inputs have a greater impact on the estimate (Kleijnen, Ridder & Rubinstein, 2013). If it is
 difficult to sample from the distribution p(x), the event can be sampled from another distribution
 q(x) where it is more likely to occur. ∫ p(x) = ∫ Lq(x), where the likelihood function is L =
 p(x)/q(x). The alternative distribution is the change of measure. Depending on the simulation
 problem, there are different change of measure methods to be considered, such as Exponential,
 Cross-Entropy, State-Dependent, and Markov Chains.
 
 Conditioning works based on the Law of the Unconscious Statistician, where E[X] =
 E[E[X|Y]], meaning E(X|Y) is unbiased for the parameter being estimated (Law, 2015).
 Var(E(X|Y) = Var(Y)- E(Var(X|Y)), so observing the expectation of X given Y gives a smaller
 variance than X. The estimator becomes the average of the conditional expectations (Kleijnen,
 Ridder & Rubinstein, 2013). The use of this technique will be dependent on the probabilistic
 structure of the model and the chosen variables.
 
 Stratified Sampling, developed as a survey sampling method, involves dividing the
 sample into a number of bins, taking equal samples from each (Keramat & Kielbasa, 1998).
 Selecting proportional samples reduces the variance, with the number of bins chosen to minimize
 the variance.

# Conclusion

  This project summarized an assortment of commonly used variance reduction methods to
 provide a straightforward understanding using basic examples. It is clear these techniques can be
 very beneficial, even though their effects may not be known beforehand. As seen in the
 examples, the variance reduction might seem small in some cases, however at a large scale this
 can save a lot of processing time, making it worthwhile to explore. For additional
 experimentation, many of these methods may be compatible to be used in combination for a
 potential greater effect of variance reduction. For example, the Schruben-Margolin strategy
involves switching between common random numbers and antithetic variates for different blocks
 in a simulation (Kleijnen, Ridder & Rubinstein, 2013).
 
 While variance reduction methods often take relatively little cost and are an intuitive
 inclusion to a simulation model, this is not always the case. It is important to consider how much
 time will be saved by reducing the variance relative to the time required to implement the
 methodology, as well as consider the appropriateness to the model and additional testing
 required.
 
 From working on this project, there is something to be said about the capabilities of
 simulation languages for variance reduction. For Common Random Numbers and Antithetic
 Variates, it is relatively straightforward to just use the Seeds module in ARENA, and CRN is
 generally used by default in many simulation languages. In the case of Control Variates and other
 variance reduction methods, it seems to either be not possible or not obvious how to apply them
 using ARENA alone, and other software may be required to be used in conjunction. There are
 some extensions for ARENA developed by Torres and Glynn (1995) supporting Control Variates
 and Importance Sampling which may be outdated, however, I think it would be useful to have
 more accessible, well documented tools available.

 # References
 
 Keramat, M., & Kielbasa, R. (1998). A study of stratified sampling in variance reduction
 techniques for parametric yield estimation. IEEE Transactions on Circuits and Systems
 II: Analog and Digital Signal Processing, 45(5).
 https://doi.org/https://doi.org/10.1109/82.673639
 
 Kleijnen, J.P.C., Ridder, A.A.N., Rubinstein, R.Y. (2013). Variance Reduction Techniques in
 Monte Carlo Methods. In: Gass, S.I., Fu, M.C. (eds) Encyclopedia of Operations
 Research and Management Science. Springer, Boston, MA.
 https://doi.org/10.1007/978-1-4419-1153-7_638
 
 Law, A. M. (2015). Simulation Modeling and Analysis (5th ed.). McGraw-Hill Education.
 
 Torres, M. J., & Glynn, P. W. (1995). A set of extensions to the Siman/Arena Simulation
 Environment. Winter Simulation Conference Proceedings, 1995.
 https://doi.org/10.1109/wsc.1995.478736
