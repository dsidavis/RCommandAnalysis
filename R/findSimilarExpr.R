findSimilarExpr = 
function(e, h, compare = isEquiv, ...)
{

    if(is(e, "MalformedRCode") || is(e, "IncompleteRCode")) {
        # Could try to match, but not worth it for now.
        return(h[0,])
    }
    
    
    isAssign = class(e) %in% c("<-", "=", "->")

    e.orig = e
    h.orig = h  # may need for library() calls.

    if(isAssign) {
        w = sapply(h$expr, class) %in% c("<-", "=", "->")
        if(!any(w))
            return(h[0,])

        h = h[w, ]

        var = as.character(e[[2]])
        vars = sapply(h$expr, function(x) if(is.name(x[[2]])) as.character(x[[2]]) else NA)
        w = !is.na(vars) & vars == var

        if(!any(w) && !all(is.na(vars))) {
            # allow a close match to variable name
            # e.g. x1 rather than x or x_name rather than x.name
            # perhaps adist()

            return(h[0,])
        } else
            h = h[w,]


           # removing the var <-  and just having the RHS
        h$tmp = sapply(h$expr, `[[`, 3)

        e = e[[3]]
    } else {
        h = h[sapply(h$expr, is, class(e)), ]
        h$tmp = h$expr
    }


    if(is.call(e)) {

        funName = as.character(e[[1]])
        k = sapply(h$tmp, function(x) if(is.call(x) && is.name(x[[1]]) ) as.character(x[[1]]) else NA)
        w = !is.na(k) & k == funName
        if(!any(w)) {
            warning("no calls to ", funName)
            return(h[0, ])
        }
        
        h = h[w,]

        # now compare the  calls
        # This assumes library() calls were made in this R session, not the student's
        # so that the functions such as ggplot are on the search path.
        # We could find the calls to library in h and replay them.
        # Instead of get(), we may want equivalent of  eval(ns::funName) so we don't actually call library()
        # but then have to search the packages that would have been loaded to find the funName object.
        # Later
        fun = get(funName, globalenv())
        e = match.call(fun, e)
        calls = lapply(h$tmp, function(x) match.call(fun, x))

        w = sapply(calls, compare, e, ...)
        if(any(w))
            return(h[w, names(h) != "tmp"])

        # so none are identical, find close ones.
        # 
    } else if(is.name(e) || is.literal(e)) {
        w = sapply(h$tmp, compare, e, ...)

        if(any(w))
            return(h[w, names(h) != "tmp"])                   
    }
    # function
    # while
    # for
    # Probably just fold directly into the condition above for is.name()...
    

}


is.literal =
function(x)
{
    is.character(x) || is.logical(x) || is.integer(x) || is.numeric(x) || is.complex(x)
}


setGeneric("isEquiv", 
function(x, y, ...)
{
  standardGeneric("isEquiv")
})


setMethod("isEquiv", c("ANY", "ANY"),
function(x, y, ...)
{
    identical(x, y, ...)
})


setOldClass("call")
setMethod("isEquiv", c("call", "call"),
function(x, y, matched = FALSE, ...)
{
    if(x[[1]] != y[[1]])
        return(FALSE)
    
    if(!matched) {
        fn = get(as.character(x[[1]]), globalenv())
        x = match.call(fn, x)
        y = match.call(fn, y)        
    }

    w = mapply(isEquiv, y[names(x)[-1]], x[-1], ...)
    all(w)
})


if(FALSE) {
isEquiv(quote(rnorm(10, 1)), quote(rnorm(10, mean = 1)))

isEquiv(quote(rnorm(10, 1)), quote(rnorm(10, mean = 1, 2)))
}
