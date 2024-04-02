BEGIN {
    capitols["Ohio"] = "Columbus"
    capitols["Alaska"] = "Juno"
    capitols["Texas"] = "Austin"

    for(state in capitols){
        print "The capitol of " state " is " capitols[state] 
    }
}