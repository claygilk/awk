BEGIN {
    total=0
} 

NR > 1 {
    total+=$5
}

END {
    print "Total=" total
}