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

 If we are comparing two models and estimating θ̂ = X- Y :
 Var(θ̂ ) = Var(X) + Var(Y)- 2Cov(X, Y)
 
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

 **Table 1** <b>
  *Two-Sample 95% Confidence Intervals for Expected Wait Time With and Without CRN* <b>
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
 
 θ̂ = ( f (U₁) + f (U₂)) / 2
 
 Var(θ̂ ) = (Var(U₁) + Var(U₂) + 2Cov( f (U₁), f (U₂))) / 4
 
 Since Var(U₁) and Var(U₂) are i.i.d.,
 
 Var(θ̂ ) = (Var(U₁) + Cov( f (U₁), f (U₂))) / 2
 
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
