# Recipe to generate genetic drift histogram. The procedure consists
# of tracking a fixed number of allelic states for a system with two
# alleles (say, a and A), where the variable x corresponds to the
# *probability* of being in a particular state.

library(expm) # Matrix exponential library

# Number of possible allelic states. Setting this too large results in
# a prohibitively large transition matrix
n <- 10

# The x vector traces the *probability* of samples/sequences in a
# given allelic state, where x[1]=probability of fixation for allele
# a, x[n+1]=probability of fixation for allele A, x[i]=i/n, i=2,...,
# n, probability of being in state i (i alleles of type a, n-i alleles
# of type A)
x <- vector(mode = "numeric", length = n + 1) # Init x to vector of 0's

# Start with state n_a = n_A; find the index corresponding to the
# state with number of a alleles = number of A alleles and set to 1
n_a <- ceiling(length(x) / 2)
x[n_a] <- 1

# States 1, n+1 are absorbing states (alleles are fixed)
class <- c("absorbing", rep("normal", n - 1), "absorbing")
class_col <- c("black", rep("white", n - 1), "black")

# Make transition matrix, where an entry p_ij states the probability
# of transitioning from a state (i, n-i) with i alleles of type a,
# (n-i) alleles of type A, to state (j, n-j)
transmat <- do.call("rbind", lapply(0:n, function(i) {
  dbinom(0:n, n, i / n)
}))

# Number of generations
t <- 30

# The distribution at any time point is given as the initial
# distribution x times the transition matrix to the power of t
data <- t(x %*% (transmat %^% t))

# Make labels corresponding to the fraction of a alleles
xlabels <- unlist(lapply(0:n, function(x) {
  sprintf("frac(%i, %i)", x, n)
}))
xl <- do.call(c, lapply(xlabels, function(l) {
  parse(text = l)
}))
# Plot the results
barplot(height = data, beside = TRUE, col = class_col, names.arg = xl)
