#' Declare the size and features of the population
#'
#' @inheritParams declare_internal_inherit_params
#' @return A potential outcomes declaration, which is a function that returns a data.frame.
#' @export
#' @importFrom fabricatr fabricate
#'
#' @examples
#'
#' # Declare a single-level population with no covariates
#' my_population <- declare_model(N = 100)
#'
#' # Declare a population from existing data
#' my_population <- declare_model(sleep)
#'
#' # Declare a single-level population with a covariate
#' my_population <- declare_model(
#'   N = 6,
#'   female = rbinom(n = N, 1, prob = 0.5),
#'   height_ft = rnorm(N, mean = 5.67 - 0.33 * female, sd = 0.25)
#' )
#' 
#' 
#' # Declare a population from existing data
#' 
#' declare_population(mtcars)
#' 
#' # Resample from existing data
#' 
#' declare_population(N = 100, data = mtcars, handler = resample_data)
#' 
#' 
#' # Declare a two-level hierarchical population
#' # containing cities within regions and a
#' # pollution variable defined at the city level
#'
#' my_population <- declare_model(
#'   regions = add_level(N = 5),
#'   cities = add_level(N = 10, pollution = rnorm(N, mean = 5))
#' )
#'
#' # Declare a population using a custom function
#' 
#' # the default handler is fabricatr::fabricate, 
#' # but you can supply any function that returns a data.frame
#'
#' my_population_function <- function(N) {
#'   data.frame(u = rnorm(N))
#' }
#'
#' my_population_custom <- declare_model(N = 10, handler = my_population_function)
#'
declare_population <- make_declarations(fabricate, "population")
