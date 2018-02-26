#
# Start with a CSV file or a history file
#
#

readCode =
function(f, ...)
    UseMethod("readCode")

readCode.data.frame =
function(f, ...)
{
    isComment = sapply(f[[2]], function(x) length(x[[1]])) == 0
    f[[2]][isComment] = lapply(f[[1]][isComment], Comment)
    f[[2]][!isComment] = lapply(f[[2]][!isComment], `[[`, 1)
    class(f[[2]]) = "list"
    f[[2]]
}


readCode.character =
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
function(e)
{
  structure(e, class = "Comment")
}


longDF =
    #
    # Takes the expressions from readCode()
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
