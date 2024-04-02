BEGIN {
    FS=","
}

NR > 1 && $5 > 200 {
    print $2, "is a high roller!"
}

NR > 1 && $5 < 200 {
    print $2, "is not a high roller."
}