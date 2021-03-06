% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/declare_estimator.R
\name{declare_estimator}
\alias{declare_estimator}
\alias{declare_estimators}
\alias{label_estimator}
\alias{model_handler}
\title{Declare estimator}
\usage{
declare_estimator(
  ...,
  handler = label_estimator(model_handler),
  label = "estimator"
)

declare_estimators(
  ...,
  handler = label_estimator(model_handler),
  label = "estimator"
)

label_estimator(fn)

model_handler(
  data,
  ...,
  model = estimatr::lm_robust,
  model_summary = tidy_try,
  term = FALSE
)
}
\arguments{
\item{...}{arguments to be captured, and later passed to the handler}

\item{handler}{a tidy-in, tidy-out function}

\item{label}{a string describing the step}

\item{fn}{A function that takes a data.frame as an argument and returns a data.frame with the estimates, summary statistics (i.e., standard error, p-value, and confidence interval), and a term column for labeling coefficient estimates.}

\item{data}{a data.frame}

\item{model}{A model function, e.g. lm or glm. By default, the model is the \code{\link{lm_robust}} function from the \link{estimatr} package, which fits OLS regression and calculates robust and cluster-robust standard errors.}

\item{model_summary}{A model-in data-out function to extract coefficient estimates or model summary statistics, such as \code{\link{tidy}} or \code{\link{glance}}. By default, the \code{DeclareDesign} model summary function \code{\link{tidy_try}} is used, which first attempts to use the available tidy method for the model object sent to \code{model}, then if not attempts to summarize coefficients using the \code{coef(summary())} and \code{confint} methods. If these do not exist for the model object, it fails.}

\item{term}{Symbols or literal character vector of term that represent quantities of interest, i.e. Z. If FALSE, return the first non-intercept term; if TRUE return all term. To escape non-standard-evaluation use \code{!!}.}
}
\value{
A function that accepts a data.frame as an argument and returns a data.frame containing the value of the estimator and associated statistics.
}
\description{
Declares an estimator which generates estimates and associated statistics.

Use of \code{declare_test} is identical to use of \code{\link{declare_estimator}}. Use \code{declare_test} for hypothesis testing with no specific inquiry in mind; use \code{declare_estimator} for hypothesis testing when you can link each estimate to an inquiry. For example, \code{declare_test} could be used for a K-S test of distributional equality and \code{declare_estimator} for a difference-in-means estimate of an average treatment effect.
}
\details{
\code{declare_estimator} is designed to handle two main ways of generating parameter estimates from data.

In \code{declare_estimator}, you can optionally provide the name of an inquiry or an objected created by \code{\link{declare_inquiry}} to connect your estimate(s) to inquiry(s).

The first is through \code{label_estimator(model_handler)}, which is the default value of the \code{handler} argument. Users can use standard modeling functions like lm, glm, or iv_robust. The models are summarized using the function passed to the \code{model_summary} argument. This will usually be a "tidier" like \code{broom::tidy}. The default \code{model_summary} function is \code{tidy_try}, which applies a tidy method if available, and if not, tries to make one on the fly.

An example of this approach is:

\code{declare_estimator(Y ~ Z + X, model = lm_robust, model_summary = tidy, term = "Z", inquiry = "ATE")}

The second approach is using a custom data-in, data-out function, usually first passed to \code{label_estimator}. The reason to pass the custom function to \code{label_estimator} first is to enable clean labeling and linking to inquiries.

An example of this approach is:

\code{
my_fun <- function(data){ with(data, median(Y[Z == 1]) - median(Y[Z == 0])) }
}

\code{
declare_estimator(handler = label_estimator(my_fun), inquiry = "ATE")
}

\code{label_estimator} takes a data-in-data out function to \code{fn}, and returns a data-in-data-out function that first runs the provided estimation function \code{fn} and then appends a label for the estimator and, if an inquiry is provided, a label for the inquiry.
}
\examples{
# base design
design <-
  declare_model(
    N = 100,
    female = rbinom(N, 1, 0.5),
    U = rnorm(N),
    potential_outcomes(
     Y ~ rbinom(N, 1, prob = pnorm(0.2 * Z + 0.2 * female + 0.1 * Z * female + U)))
  ) +
  declare_inquiry(ATE = mean(Y_Z_1 - Y_Z_0)) + 
  declare_assignment(Z = complete_ra(N, m = 50)) + 
  declare_measurement(Y = reveal_outcomes(Y ~ Z))

# Most estimators are modeling functions like lm or glm.
  
# Default statistical model is estimatr::difference_in_means
design + declare_estimator(Y ~ Z, inquiry = "ATE")

# lm from base R (classical standard errors assuming homoskedasticity)
design + declare_estimator(Y ~ Z, model = lm, inquiry = "ATE")

# Use lm_robust (linear regression with heteroskedasticity-robust standard errors) 
# from `estimatr` package

design + declare_estimator(Y ~ Z, model = lm_robust, inquiry = "ATE")

# use `term` to select particular coefficients
design + declare_estimator(Y ~ Z*female, term = "Z:female", model = lm_robust)

# Use glm from base R
design + declare_estimator(
  Y ~ Z + female,
  family = "gaussian",
  inquiry = "ATE",
  model = glm
)

# If we use logit, we'll need to estimate the average marginal effect with 
# margins::margins. We wrap this up in function we'll pass to model_summary

library(margins) # for margins
library(broom) # for tidy

tidy_margins <- function(x) {
  tidy(margins(x, data = x$data), conf.int = TRUE)
}

design +
  declare_estimator(
    Y ~ Z + female,
    model = glm,
    family = binomial("logit"),
    model_summary = tidy_margins,
    term = "Z"
  ) 

# Multiple estimators for one inquiry

two_estimators <-
  design +
  declare_estimator(Y ~ Z,
                    model = lm_robust,
                    inquiry = "ATE",
                    label = "OLS") +
  declare_estimator(
    Y ~ Z + female,
    model = glm,
    family = binomial("logit"),
    model_summary = tidy_margins,
    inquiry = "ATE",
    term = "Z",
    label = "logit"
  )

run_design(two_estimators)

# Declare estimator using a custom handler

# Define your own estimator and use the `label_estimator` function for labeling
# Must have `data` argument that is a data.frame
my_dim_function <- function(data){
  data.frame(estimate = with(data, mean(Y[Z == 1]) - mean(Y[Z == 0])))
}

design + declare_estimator(
  handler = label_estimator(my_dim_function),
  inquiry = "ATE"
)

}
