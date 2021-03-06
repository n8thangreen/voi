% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/evsi.R
\name{evsi}
\alias{evsi}
\title{Calculate the expected value of sample information from a decision-analytic model}
\usage{
evsi(
  outputs,
  inputs,
  study = NULL,
  datagen_fn = NULL,
  pars = NULL,
  n = 100,
  method = NULL,
  likelihood = NULL,
  analysis_model = NULL,
  analysis_options = NULL,
  decision_model = NULL,
  Q = 30,
  npreg_method = "gam",
  nsim = NULL,
  verbose = TRUE,
  ...
)
}
\arguments{
\item{outputs}{This could take one of two forms

  "net benefit" form: a matrix or data frame of samples from the uncertainty
  distribution of the expected net benefit.  The number of rows should equal
  the number of samples, and the number of columns should equal the number
  of decision options.

  "cost-effectiveness analysis" form: a list with the following named
  components:

  \code{"c"}: a matrix or data frame of samples from the distribution of
  costs.  There should be one column for each decision option.

  \code{"e"}: a matrix or data frame of samples from the distribution of
  effects, likewise.

  \code{"k"}: a vector of willingness-to-pay values.

Objects of class \code{"bcea"}, as created by the \pkg{BCEA} package, are in
this "cost-effectiveness analysis" format, therefore they may be supplied as
the \code{outputs} argument.

If \code{outputs} is a matrix or data frame it is assumed to be of "net
benefit" form.  Otherwise if it is a list, it is assumed to be of "cost
effectiveness analysis" form.}

\item{inputs}{Matrix or data frame of samples from the uncertainty
distribution of the input parameters of the decision model.   The number
of columns should equal the number of parameters, and the columns should
be named.    This should have the same number of rows as there are samples
in \code{outputs}, and each row of the samples in \code{outputs} should
give the model output evaluated at the corresponding parameters.}

\item{study}{Name of one of the built-in study types supported by this package for EVSI calculation.  If this is supplied, then the columns of \code{inputs} that correspond to the parameters governing the study data should be identified in \code{poi}.

Currently supported studies are

\code{"trial_binary"} Two-arm trial with a binary outcome.   Requires two parameters: the probability of the outcome in arm 1 and 2 respectively.  The sample size is the same in each arm, specifed in the \code{n} argument to \code{evsi()}, and the binomial outcomes are named \code{X1} and \code{X2} respectively. 

Either \code{study} or \code{datagen_fn} should be supplied to \code{evsi()}.}

\item{datagen_fn}{If the proposed study is not one of the built-in types supported, it can be specified in this argument as an R function to sample predicted data from the study.  This function should have the following specification:

1. the function's first argument should be a data frame of parameter simulations, with one row per simulation and one column per parameter.  The parameters in this data frame must all be found in \code{inputs}.

2. the function should return a data frame.

3. the returned data frame should have number of rows equal to the number of parameter simulations in \code{inputs}.

4. if \code{inputs} is considered as a sample from the posterior, then \code{datagen_fn(inputs)} returns a corresponding sample from the posterior predictive distribution, which includes two sources of uncertainty: (a) uncertainty about the parameters and (b) sampling variation in observed data given fixed parameter values.

5. the function can optionally have more than one argument. If so, these additional arguments should be given default values in the definition of \code{datagen_fn}.  These arguments might be used to define sample sizes for a proposed study.

Examples of this are currently in the \code{tests/tests_slow} package directory.}

\item{pars}{Character vector identifying which columns of \code{inputs} are the parameters required to generate data from the proposed study.  Required if the proposed study is specified through the \code{study} argument, but not if it is specified through the \code{datagen_fn} argument.

For example, if \code{study = "trial_binary"} is specified, then \code{pars} should be a vector of two elements naming the probability of the outcome in arm 1 and arm 2 respectively.

The \code{pars} argument is also required for the methods which involve an intermediate EVPPI calculation, that is the \code{"is"} and \code{"mm"}.  It should consist of the variables used in the definition of \code{datagen_fn} (and \code{likelihood} if used TODO ALSO in \code{analysis_model} and \code{model}?) and only these variables.}

\item{n}{Sample size of future study - optional argument to datagen_fn - facilitates calculating EVSI for multiple sample sizes.  TODO if we want to design trials with multiple unbalanced arms, we'll need more than one argument.}

\item{method}{Character string indicating the calculation method.

All the nonparametric regression methods supported for \code{\link{evppi}}, that is \code{"gam","gp","earth","inla"}, can also be used for EVSI calculation by regressing on a summary statistics of the predicted data (Strong et al 201?).   Defaults to \code{"gam"}.

\code{"is"} for importance sampling (Menzies 2016)

\code{"mm"} for moment matching (Heath et al 2018)

Note that the  \code{"is"} and \code{"mm"} (and Jalal) methods are used in conjunction with nonparametric regression, thus the \code{gam_formula} argument can be supplied to \code{evsi} to specify this regression - see \code{\link{evppi}}. 

The Heath et al. and Jalal et al. methods are under development.}

\item{likelihood}{Likelihood function, required (and only required) for the importance sampling method.  This should have two arguments as follows:

1. a data frame of predicted data. Columns are defined by the number of outcomes in the data, and names matching the data frame returned by \code{datagen_fn}. 

2. a data frame of parameter values, whose names should all correspond to variables in \code{inputs}.

The function should return a vector whose length matches the number of rows of the parameters data frame given as the second argument.   Each element of the vector gives the likelihood of the corresponding set of parameters, given the data in the first argument.

Examples of this are currently in \code{tests/tests_slow} and \code{tests/testthat} in the package directory. 

Note the definition of the likelihood should agree with the definition of \code{datagen_fn} to define a consistent sampling distribution for the data.}

\item{analysis_model}{Function which fits a Bayesian model to the generated data.   Under development (need to decide format, output, JAGS dependencies, etc.). Required for \code{method="mm"} (and Jalal method if n0 not given)}

\item{analysis_options}{List of arguments required by \code{analysis_model}.  Under development - for \code{method="mm"} and Jalal method.}

\item{decision_model}{Function which evaluates the decision-analytic model, given parameter values.  Under development - for \code{method="mm"} and Jalal method.  Need to decide the required format for nb, c, e output.}

\item{Q}{Number of quantiles to use in \code{method="mm"} (under development).}

\item{npreg_method}{Method to use to calculate the EVPPI, for those methods that require it.  This is passed to \code{\link{evppi}} as the \code{method} argument.}

\item{nsim}{Number of simulations from the model to use for calculating EVPPI.  The first \code{nsim} rows of the objects in \code{inputs} and \code{outputs} are used.}

\item{verbose}{If \code{TRUE}, then print messages describing each step of
the calculation.  Useful to see the progress of slow calculations.
Currently only supported by the \code{"inla"} EVPPI method.}

\item{...}{Other arguments required by specific methods}
}
\description{
Calculate the expected value of sample information from a decision-analytic model
}
\references{
Strong, M., Oakley, J. E., Brennan, A., & Breeze, P. (2015). Estimating the expected value of sample information using the probabilistic sensitivity analysis sample: a fast, nonparametric regression-based method. Medical Decision Making, 35(5), 570-583.

Menzies, N. A. (2016). An efficient estimator for the expected value of sample information. Medical Decision Making, 36(3), 308-320.

Heath, A., Manolopoulou, I., & Baio, G. (2018). Efficient Monte Carlo estimation of the expected value of sample information using moment matching. Medical Decision Making, 38(2), 163-173.

Jalal, H., & Alarid-Escudero, F. (2018). A Gaussian approximation approach for value of information analysis. Medical Decision Making, 38(2), 174-188.
}
