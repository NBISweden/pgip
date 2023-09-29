fn <- "assets/data/hsapiens_rat.dnds.tsv"
if (!file.exists(fn)) {
  library(biomaRt)
  ensembl <- useEnsembl(
    version = 99,
    biomart = "ENSEMBL_MART_ENSEMBL",
    dataset = "hsapiens_gene_ensembl"
  )
  genes <- getBM(mart = ensembl, attributes = c("ensembl_gene_id"))
  hsapiens_rat <- getBM(
    attributes = c(
      "ensembl_gene_id",
      "rnorvegicus_homolog_ensembl_gene",
      "rnorvegicus_homolog_dn",
      "rnorvegicus_homolog_ds",
      "rnorvegicus_homolog_orthology_type"
    ),
    filters = "ensembl_gene_id",
    values = genes$ensembl_gene_id,
    mart = ensembl
  )
  hsapiens_rat <- subset(
    hsapiens_rat,
    !is.na(rnorvegicus_homolog_ds) &
      !is.na(rnorvegicus_homolog_dn) &
      rnorvegicus_homolog_orthology_type == "ortholog_one2one"
  )
  hsapiens_rat$dnds <- hsapiens_rat$rnorvegicus_homolog_dn /
    hsapiens_rat$rnorvegicus_homolog_ds
  hsapiens_rat <- subset(hsapiens_rat, !is.nan(dnds))
  write.table(hsapiens_rat,
    file = "assets/data/hsapiens_rat.dnds.tsv",
    sep = "\t", quote = FALSE, row.names = FALSE
  )
}
x <- read.table(fn, header = TRUE)
ggplot(x, aes(x = dnds)) +
  geom_histogram(
    bins = 100, aes(y = ..count.. / sum(..count..)), fill = "white",
    color = "black"
  ) +
  xlim(0, 2) +
  xlab(expression(d[n] ~ "/" ~ d[s])) +
  ylab("Frequency") +
  ggtitle(paste0(nrow(x), " human-rat orthologue pairs"))
