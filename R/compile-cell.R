
rows <- function(x)
{
  UseMethod("rows", x)
}

cols <- function(x)
{
  UseMethod("cols", x)
}

rows.list <- function(object)
{
  length(object)
}

cols.list <- function(object)
{
  if(length(object) >= 1)
  {
    length(object[[1]])
  }
  else
  {
    0
  }
}

#' Create an empty table of cells
#'
#' Create an empty list of lists to fill with desired table elements. Note that
#' The initial size is not a limiting factor, the table can grow as needed later.
#'
#' @param rows An integer of the number of rows to create
#' @param cols An integer of the number of cols to create
#' @param embedded A boolean representing whether this table will is to be marked as embedded in another
#'
#' @return An empty cell_table object.
#' @export
cell_table <- function(rows, cols, embedded=TRUE)
{
  cell(lapply(1:rows, function(x) as.list(rep(cell(""), cols))),
       embedded = embedded)
}

#' Construct a table cell from an object
#'
#' Any R object can be used as a cell value. Attributes
#' are used to store additional aspects of that cell
#' attached to the object. This is a helper function
#' to attach all the additional attributes to the
#' provided object
#'
#' Certain attributes have special meaning:
#' - 'names' is appended to the front of a value, e.g. "P=" for a p-value.
#' - 'sep' is used to join values, e.g. ", " for a list of values.
#' - 'aspect' denotes special rendering handling, e.g. generally passed as CSS class to HTML5
#' - 'reference' a list of reference symbols to put inside the cell
#' - 'row' and 'col' should refer to the row / column if key generation is needed
#' - 'subrow' and 'subcol' further delinate the key value of a cell for key generation
#'
#' @param x R object to attach attributes too
#' @param ... Each additional argument becomes an attribute for the object
#' @return The modified R object
#'
cell <- function(x, ...)
{
  UseMethod("cell", x)
}

cell.default <- function(x, ...)
{
  attribs <- list(...)
  for(i in names(attribs))
    attr(x, i) <- attribs[[i]]
  x
}

#' Create an cell_label (S3) object of the given text.
#'
#' A cell_label object represents a label cell inside a table. It can
#' also contain units.
#'
#' @param text character; The text of the label. May include a subset of LaTeX greek or math.
#' @param units character; An optional field that contains units
#' @param ... optional extra information to attach
#'
#' @return A cell_table object
#' @export
#'
#' @examples
#' cell_label("Compaction Method")
#' cell_label("Concentration", "mg/dl")
#' cell_label("Concentration", "mg/dl", subcol="A")
cell_label <- function(text, units=NA, ...)
{
  cell(as.character(text),
       aspect="cell_label",
       units=as.character(units), ...)
}

#' Create a cell_header object of the given text.
#'
#' A cell_header object represents a label cell inside a table. It can
#' also contain units.
#'
#' @param text character; The text of the label. May include a subset of LaTeX greek or math.
#' @param units character; An optional field that contains units
#' @param ... optional extra information to attach
#'
#' @return A cell_header object
#' @export
#' @examples
#' cell_header("Yahoo")
#' cell_header("Concentration", "mg/dl")
#' cell_header("Concentration", "mg/dl", src="A")
cell_header <- function(text, units=NA, ...)
{
  cell(as.character(text), aspect=c("cell_header", "cell_label"),
       units=as.character(units), ...)
}

#' Create a cell_subheader object of the given text.
#'
#' A cell_subheader object represents a label cell inside a table. It can
#' also contain units.
#'
#' @param text character; The text of the label. May include a subset of LaTeX greek or math.
#' @param units character; An optional field that contains units
#' @param ... optional extra information to attach
#'
#' @return A cell_subheader object.
#' @export
#' @examples
#' cell_subheader("Concentration")
#' cell_subheader("Concentration", "mg/dl")
#' cell_subheader("Concentration", "mg/dl", src="A")
cell_subheader <- function(text, units=NA, aspect=NULL, ...)
{
  cell(as.character(text),
       aspect=c(aspect, "cell_subheader", "cell_header", "cell_label"),
       units=as.character(units), ...)
}

#' Create a interquartile range cell object of the given data
#'
#' Construct a cell which has the 3 interquartile ranges specified.
#'
#' @param x numeric vector whose sample quantiles are wanted. NA and NaN values are not allowed in numeric vectors unless na.rm is TRUE.
#' @param format numeric or character; Significant digits or fmt to pass to sprintf
#' @param na.rm logical; if true, any NA and NaN's are removed from x before the quantiles are computed.
#' @param names logical; if true, the result has a names attribute. Set to FALSE for speedup with many probs.
#' @param type integer; specify algorithm to use in constructing quantile. See quantile for more information.
#' @param ... additional arguments to constructing cell
#'
#' @return A cell_quantile object.
#' @export
#' @examples
#' require(stats)
#' cell_iqr(rnorm(100), '3')
cell_iqr <- function(x,
                     format = NA,
                     na.rm  = TRUE,
                     names  = FALSE,
                     type   = 8,
                     ...
                          )
{
  x <- quantile(x,  c(0.25, 0.50, 0.75), na.rm, names, type)

  if(is.na(format)) format <- format_guess(x)
  ql <- sapply(x, function(x) render_f(x, format))
  cell(ql, aspect="cell_iqr", ...)
}

#' Create named value cells
#'
#' A cell object with
#' additionally contain an interval with a low and high of a
#' specified width.
#'
#' @param values vector; to create cell values from
#' @param names character; names to apply to values
#' @param sep character; separator to use when rendering
#' @param ... additional attributes to attach to cell
#'
#' @return A cell object with named values
#' @export
#' @examples
#' cell_named_values(1.0, "one")
cell_named_values <- function(values, names, aspect=NULL, sep=", ", ...)
{
  names(values) <- names
  cell(values, aspect=c(aspect, "cell_value"), sep=sep, ...)
}

cell_range <- function(low, high, aspect=NULL, sep=", ", ...)
{
  cell(c(low, high), aspect=c(aspect, "cell_range"), sep=sep, ...)
}

#' Create an cell_estimate object of the given estimate
#'
#' A cell_estimate object contains a statistical estimate. It may
#' additionally contain an interval with a low and high of a
#' specified width.
#'
#' @param value The value of the estimate
#' @param low Specifies a lower interval for the estimate.
#' @param high Specifies an upper interval for the estimate.
#' @param name character; An optional name to apply to the value
#' @param aspect character; additional aspects to apply
#' @param sep character; option separator character for the range
#'
#' @return A cell_estimate object.
#' @export
#' @examples
#' cell_estimate(1.0, name="one")
#' cell_estimate(1.0, 0.5, 1.5)
cell_estimate <- function(value, low, high, name=NULL, aspect=NULL, sep=", ", ...)
{
  cell(list(cell_named_values(value, names=name),
            cell_range(low, high, sep=sep)),
       aspect=c(aspect, "cell_estimate"),
       ...)
}


#' Create an cell_fraction (S3) object of the given statistic
#'
#' A cell_fraction object contains a statistical result of a fraction/percentage.
#'
#' @param numerator The value of the numerator
#' @param denominator The value of the denominator
#' @param ratio The ratio of the two
#' @param percentage The percentage this represents
#' @param src An optional field for traceability of the source of the field
#'
#' @return A cell_fraction object.
#' @export
#' @examples
#' cell_fraction(1, 4, 0.25, 25)
cell_fraction <- function(numerator, denominator, format=3, aspect=NULL, ...)
{
  ratio      <- render_f(numerator / denominator, format)
  percentage <- render_f(100 * numerator / denominator, format)
  cell_named_values(c(numerator, denominator, ratio, percentage),
                    c("numerator", "denominator", "ratio", "percentage"),
                    aspect=c(aspect, "cell_fraction"),
                    ...)
}

#' Create an cell_fstat (S3) object of the given statistic
#'
#' A cell_fstat object contains a statistical result of an F-test.
#'
#' @param f The value of the f-statistic
#' @param n1 1st dimension degrees of freedom
#' @param n2 2nd dimension degrees of freedom
#' @param p The p-value of the resulting test
#'
#' @return A cell_fstat object.
#' @export
#' @examples
#' cell_fstat(4.0, 10, 20, 0.004039541, reference=1,)
cell_fstat <- function(f, n1, n2, p, aspect=NULL, ...)
{
  cell_named_values(c(f, p), names=c(paste0("F_{",n1,",",n2,"}"), "P"), aspect=c(aspect, "cell_fstat", "statistics"), ...)
}

#' Create an cell_chi2 (S3) object of the given statistic
#'
#' A cell_chi2 object contains a statistical result of an X^2-test.
#'
#' @param chi2 The value of the X^2 statistic
#' @param df degrees of freedom
#' @param p p-value of resulting test
#' @param reference A possible reference number for use in a table key
#' @param src An optional field for traceability of the source of the field
#'
#' @return A cell_chi2 object.
#' @export
#' @examples
#' cell_chi2(5.6, 2, 0.06081)
cell_chi2 <- function(chi2, df, p, aspect=NULL, ...)
{
  cell_named_values(c(chi2, p),
                    c(paste0("\\chi^2_{",df,"}"), "P"),
                    aspect=c(aspect, "cell_chi2", "statistics"),
                    ...)
}

#' Create an cell_studentt (S3) object of the given statistic
#'
#' A cell_studentt object contains a statistical result of an t-test.
#'
#' @param t The value of the X^2 statistic
#' @param df degrees of freedom
#' @param p p-value of resulting test
#'
#' @return A cell_studentt object.
#' @export
#' @examples
#' cell_studentt(2.0, 20, 0.02963277)
cell_studentt <- function(t, df, p, aspect=NULL, ...)
{
  cell_named_values(c(t, p),
                    c(paste0("t_{",df,"}"), "P"),
                    aspect=c(aspect, "cell_studentt", "statistics"),
                    ...)
}

#' Create an cell_spearman (S3) object of the given statistic
#'
#' A cell_spearman object contains a statistical result of an spearman-test.
#'
#' @param S The value of the spearman statistic
#' @param rho The rho value of the test
#' @param p p-value of resulting test
#' @param reference A possible reference number for use in a table key
#' @param src An optional field for traceability of the source of the field
#'
#' @return A cell_spearman object.
#' @export
#' @examples
#' cell_spearman(20, 0.2, 0.05)
cell_spearman <- function(S, rho, p, aspect=NULL, ...)
{
  cell_named_values(c(S, rho, p),
                    names=c("S", "\\rho", "P"),
                    aspect=c(aspect, "cell_spearman", "statistics"),
                    ...)
}

#' Create an cell_n (S3) object of the given statistic
#'
#' A cell_n object contains a statistical result of an X^2-test.
#'
#' @param n The value of the X^2 statistic
#' @param src An optional field for traceability of the source of the field
#'
#' @return A cell_n object.
#' @export
#' @examples
#' cell_n(20)
cell_n <- function(n, aspect=NULL, ...)
{
  cell_named_values(n, "N", aspect=c(aspect, "cell_n"), ...)
}


#' AOV model as cell
#'
#' Construct a cell from an analysis of variance model
#'
#' @param x The aov object to turn into a renderable cell
#' @param row The AST row of that is generating this cell
#' @param column The AST column that is generating this cell
#' @param ... additional specifiers for identifying this cell (see key)
#' @return an S3 rendereable cell that is an F-statistic
#' @export
#' @examples
#' tg(aov(rnorm(10) ~ rnorm(10)), list(value="A"), list(value="B"))
cell.aov <- function(x, format_p="%1.3f", ...)
{
  test <- summary(x)[[1]]
  cell_fstat(f   = render_f(test$'F value'[1], "%.2f"),
             n1  = test$Df[1],
             n2  = test$Df[2],
             p   = render_f(test$'Pr(>F)'[1], format_p),
             ...)
}

#' Construct hypothesis test cell
#'
#' Construct a cell from a hypothesis test
#'
#' @param x The htest object to convert to a rendereable cell
#' @param ... additional specifiers for identifying this cell (see key)
#' @return an S3 rendereable cell that is a hypothesis test
#' @export
#' @examples
#' tg(t.test(rnorm(10),rnorm(10)), list(value="A"), list(value="B"))
cell.htest <- function(x, format=2, format_p="%1.3f", ...)
{
  if(names(x$statistic) == "X-squared")
    cell_chi2(render_f(x$statistic, format), x$parameter[1], render_f(x$p.value, format_p), ...)
  else if(x$method == "Spearman's rank correlation rho")
    cell_spearman(render_f(x$statistic, 0), x$parameter, render_f(x$p.value, format_p), ...)
  else
    cell_studentt(render_f(x$statistic, format), x$parameter[1], render_f(x$p.value, format_p), ...)
}
