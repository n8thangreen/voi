##' Convert either "net benefit" or "cost-effectiveness" forms for
##' 'outputs' to a 3D array [ number of simulations x number of
##' willingness to pay values x number of decision options ] with one
##' WTP value when `outputs` is in "net benefit" form.
##' 
##' @keywords internal
form_nbarray <- function(outputs, inputs, output_type){
    if (output_type == "cea"){
        nsim <- nrow(outputs$c)
        nk <- length(outputs$k)
        nopt <- ncol(outputs$c) # number of decision options 
        nb <- array(dim=c(nsim, nk, nopt))
        for (i in 1:nk){
            nb[,i,] <- outputs$e * outputs$k[i] - outputs$c
        }
    } else {
        nsim <- nrow(outputs)
        nk <- 1
        nopt <- ncol(outputs)
        nb <- array(outputs, dim=c(nsim, nk, nopt))
    }
    nb
}

## Code taken from BCEA package
## Baio, G., Berardi, A., & Heath, A. (2017). Bayesian cost-effectiveness analysis with the R package BCEA. New York: Springer.
## https://github.com/giabaio/BCEA

evppi_so <- function(outputs, inputs, output_type, pars, ...){
    n.blocks <- list(...)$n.blocks
    if (is.null(n.blocks))
        stop("`n.blocks` is required for method=\"so\"")
        
    U <- form_nbarray(outputs, inputs, output_type)
    nsim <- dim(U)[1]
    nk <- dim(U)[2]
    nopt <- dim(U)[3]

    J <- nsim / n.blocks
    check <- nsim %% n.blocks
    if (check > 0) {
        stop("`n.blocks` must be an integer\n")
    }
    if (length(pars) > 1) 
        stop("`method=\"so\" only works for single-parameter EVPPI")
    sort.order <- order(inputs[, pars])
    sort.U <- array(NA, dim(U))
    res <- numeric()
    for (i in 1:nk) {
        sort.U[, i, ] <- U[sort.order, i, ]
        U.array <- array(sort.U[, i, ], dim = c(J, n.blocks, nopt))
        mean.k <- apply(U.array, c(2, 3), mean)
        partial.info <- mean(apply(mean.k, 1, max))
        res[i] <- partial.info - max(apply(U[,i,], 2, mean))
    }
    res
}
