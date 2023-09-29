pops <- c("CEU", "CHB", "YRI")
fn <- file.path(
  "data/Homo_sapiens/1000g/genotypes",
  paste0(pops, ".22:17000000-20000000.hwe.gz")
)
names(fn) <- pops
x <- do.call(
  "rbind", lapply(pops, function(p) {
    y <- cbind(population = p, read.table(fn[[p]], header = TRUE))
    geno <- do.call("rbind", lapply(strsplit(y$GENO, "/"), as.numeric))
    n <- round(nrow(geno) / 2)
    geno <- rbind(geno[1:n, ], geno[(n + 1):nrow(geno), 3:1])
    colnames(geno) <- c("AA.cnt", "Aa.cnt", "aa.cnt")
    geno_frq <- as.data.frame(geno / apply(geno, 1, sum))
    colnames(geno_frq) <- c("AA", "Aa", "aa")
    allele_frq <- as.data.frame(cbind(
      geno_frq$AA + 0.5 * geno_frq$Aa,
      geno_frq$aa + 0.5 * geno_frq$Aa
    ))
    colnames(allele_frq) <- c("p", "q")
    cbind(y, geno, geno_frq, allele_frq)
  })
)
x <- pivot_longer(x, cols = c("AA", "Aa", "aa"), names_to = "genotype")
p <- seq(0, 1, 0.01)
n <- 10000
z <- do.call("rbind", by(x, x$population, function(y) {
  y[sample(nrow(y), 10000), ]
}))

vend <- 0.8
cols_hwe <- c(viridis_pal(end = vend)(3), "black", "black")
lt_hwe <- c(rep("blank", 3), "dashed", "solid")
shape_hwe <- c(rep(16, 3), NA, NA)
cnames <- c("aa", "Aa", "AA", "Hardy Weinberg Expectation", "Mean")
names(cols_hwe) <- cnames
names(lt_hwe) <- cnames
names(shape_hwe) <- cnames

ggplot(z, aes(x = p, y = value)) +
  geom_point(size = 2, alpha = .6, aes(color = genotype)) +
  geom_smooth(
    method = "loess", linewidth = 1, show.legend = TRUE,
    lty = "dashed", aes(group = genotype, color = "Mean")
  ) +
  geom_line(inherit.aes = FALSE, aes(
    x = p, y = p**2,
    color = "Hardy Weinberg Expectation"
  )) +
  geom_line(inherit.aes = FALSE, aes(
    x = p, y = 2 * p * (1 - p),
    color = "Hardy Weinberg Expectation"
  )) +
  geom_line(inherit.aes = FALSE, aes(
    x = p, y = (1 - p)**2,
    color = "Hardy Weinberg Expectation"
  )) +
  xlab("allele frequency") +
  ylab("genotype frequency") +
  facet_grid(. ~ population) +
  scale_color_viridis_d(end = vend) +
  scale_color_manual(
    name = NULL, values = cols_hwe,
    guide = guide_legend(
      override.aes = list(
        linetype = lt_hwe,
        shape = shape_hwe
      )
    )
  )
