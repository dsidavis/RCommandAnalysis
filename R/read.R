#
# Start with a CSV file or a history file
#
#

readCode =
function(f, ...)
    UseMethod("readCode")

readCode.data.frame =
function(f, asDataFrame = TRUE, ...)
{
     # Clean up src to remove leading and trailing whitespace
    f[[1]] = trim(f[[1]])
     # remove a comment character with no content after it.
    f[[1]] = gsub("#$", "", f[[1]])

     # remove empty rows, i.e. the src or the expression is empty.
     # in other words, keep any row for which either is non-empty.
    elen = sapply(f[[2]], function(x) length(x[[1]]))
    f = f[f[[1]] != "" | elen > 0,]

     # Figure out the inline and the "pure" comments (i.e with no code)
    hasCommentText = grepl("#[[:space:]]*[^[:space:]]", f[[1]])
    isInlineComment = hasCommentText & grepl("[^[:space:]]", gsub("#.*", "", f[[1]]))
    isComment = !isInlineComment & hasCommentText

     # Extract the expression
    i = sapply(f[[2]], function(x) is.expression(x) && length(x) == 1)
    f[[2]][i] = lapply(f[[2]][i], `[[`, 1)    
     # Convert any comment text to a Comment object in the expr
    f[[2]][isComment] = lapply(f[[1]][isComment], Comment)

    if(asDataFrame) {
        f$isInlineComment = isInlineComment
        f$isComment = !isInlineComment & hasCommentText
        f
    } else 
        structure(f[[2]], class = "list")
}


readCode.character =
    #
    # read from a file
    #
function(f, ...)
{
    # This is for a regular history file, not a CSV file.
    # readCSV() for that.
    if(grepl("\\.csv$", f)) {
        tmp = read.csv(f, header = FALSE, stringsAsFactors = FALSE)
        e = evaluate::parse_all(tmp[[2]])
    } else
        e = evaluate::parse_all(file(f))
    
    readCode(e, ...)
}

Comment =
    # Create a comment object.
function(e)
{
  structure(e, class = "Comment")
}


longDF =
    #
    # Takes the expressions from readCode()
    # and arranges in long form with a row for each function called
    # with potentially multiple rows corresponding to a single expression due to .
    # multiple nested calls within that expression, e.g. sum(rnorm(x)).
    #
    # id - identifier for the file.
    #   If not provided, no column for id is created.
    #
function(exprs, exprInfo = lapply(exprs, getInputs), id = character(), ...)    
{
    #    ans = data.frame(comment = rep(NA, length(exprs)))

    tmp = lapply(seq(along = exprInfo),
                  function(i) expandLine(exprInfo[[i]], i))
    
    ans = do.call(rbind, tmp)

    if(length(id)) 
        ans$id = rep(id, nrow(ans))

    ans
}

expandLine =
function(info, lineNum)
{
    ans = if(is(info@code, "Comment")) 
              data.frame(lineNum = lineNum, comment = unclass(info@code), "functions" = as.character(NA), stringsAsFactors = FALSE)
          else {
              n = length(info@functions)  
              data.frame(lineNum = rep(lineNum, n),
                         comment = rep(as.character(NA), n),
                         functions = names(info@functions),
                         stringsAsFactors = FALSE)
          }
    ans
}

trim = function (x) 
gsub("(^[[:space:]]+|[[:space:]]+$)", "", x)
