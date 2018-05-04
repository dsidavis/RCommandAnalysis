

rw = readRDS("baseRaw.rds")

# Find calls to sapply() whose first argument is a call
# Looking for the sapply(length())
w = sapply(rw$expr, function(x) is.call(x) && as.character(x[[1]]) == "sapply" && is.call(x[[2]]))

w = sapply(rw$expr, function(x) is.call(x) && as.character(x[[1]]) %in% c("sapply", "lapply", "tapply", "by") && is.call(x[[2]]))


a = rw[w, "expr"][c(1, 5)]
identical(a[[1]], a[[2]]) # False - the second has a comment
all.equal(a[[1]], a[[2]]) # True - this ignores the comment.



# Simple measure of complexity of an expression
ln = sapply(rw$expr, function(x) if(is.call(x)) length(x) else if(class(x) %in% c("=", "<-")) length(x[[3]]) else length(x))


elen =
function(x)
{        
    if(is.call(x))
        sum(sapply(x, elen))
    else if(class(x) %in% c("=", "<-"))
        elen(x[[3]]) + elen(x[[1]])
    else
        length(x)
}

ln = sapply(rw$expr, elen)
rw$src[ln > 20]
